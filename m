Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 60C116B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 04:08:28 -0500 (EST)
Received: by wmww144 with SMTP id w144so12927610wmw.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 01:08:28 -0800 (PST)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id d79si48847428wmh.100.2015.12.03.01.08.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 01:08:27 -0800 (PST)
Received: by wmvv187 with SMTP id v187so16635515wmv.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 01:08:27 -0800 (PST)
Date: Thu, 3 Dec 2015 10:08:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg, vmscan: Do not wait for writeback if killed
Message-ID: <20151203090826.GD9264@dhcp22.suse.cz>
References: <1449066378-4764-1-git-send-email-mhocko@kernel.org>
 <20151202142503.0921c0d6e06394ff7dff85fa@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151202142503.0921c0d6e06394ff7dff85fa@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 02-12-15 14:25:03, Andrew Morton wrote:
> On Wed,  2 Dec 2015 15:26:18 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Legacy memcg reclaim waits for pages under writeback to prevent from a
> > premature oom killer invocation because there was no memcg dirty limit
> > throttling implemented back then.
> > 
> > This heuristic might complicate situation when the writeback cannot make
> > forward progress because of the global OOM situation. E.g. filesystem
> > backed by the loop device relies on the underlying filesystem hosting
> > the image to make forward progress which cannot be guaranteed and so
> > we might end up triggering OOM killer to resolve the situation. If the
> > oom victim happens to be the task stuck in wait_on_page_writeback in the
> > memcg reclaim then we are basically deadlocked.
> > 
> > Introduce wait_on_page_writeback_killable and use it in this path to
> > prevent from the issue. shrink_page_list will back off if the wait
> > was interrupted.
> > 
> > ...
> >
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1021,10 +1021,19 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  
> >  			/* Case 3 above */
> >  			} else {
> > +				int ret;
> > +
> >  				unlock_page(page);
> > -				wait_on_page_writeback(page);
> > +				ret = wait_on_page_writeback_killable(page);
> >  				/* then go back and try same page again */
> >  				list_add_tail(&page->lru, page_list);
> > +
> > +				/*
> > +				 * We've got killed while waiting here so
> > +				 * expedite our way out from the reclaim
> > +				 */
> > +				if (ret)
> > +					break;
> >  				continue;
> >  			}
> >  		}
> 
> This function is 350 lines long and it takes a bit of effort to work
> out what that `break' is breaking from and where it goes next.  I think
> you want a "goto keep_killed" here for consistency and sanity.

Yeah, sounds better. See an update below:

> Also, there's high risk here of a pending signal causing the code to
> fall into some busy loop where it repeatedly tries to do something but
> then bales out without doing it.  It's unobvious how this change avoids
> such things.  (Maybe it *does* avoid such things, but it should be
> obvious!).

shrink_page_list is called from __alloc_contig_migrate_range and
shrink_inactive_list. Both of them handle fatal_signal_pending and bail
out. I was relying on this behavior. I realize this is far from optimal
wrt. readability but I do not have a great idea how to improve it
without sticking more fatal_signal_pending checks into the reclaim path.

So you think a comment would be sufficient?
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 98a1934493af..2e8ee9e5fcb5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1031,9 +1031,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				/*
 				 * We've got killed while waiting here so
 				 * expedite our way out from the reclaim
+				 *
+				 * Our callers should make sure we do not
+				 * get here with fatal signals again.
 				 */
 				if (ret)
-					break;
+					goto keep_killed;
 				continue;
 			}
 		}
@@ -1227,6 +1230,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), page);
 	}
 
+keep_killed:
 	mem_cgroup_uncharge_list(&free_pages);
 	try_to_unmap_flush();
 	free_hot_cold_page_list(&free_pages, true);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
