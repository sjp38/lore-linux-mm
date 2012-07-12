Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 67D516B0071
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 23:14:21 -0400 (EDT)
Received: by yenr5 with SMTP id r5so2302783yen.14
        for <linux-mm@kvack.org>; Wed, 11 Jul 2012 20:14:20 -0700 (PDT)
Date: Wed, 11 Jul 2012 20:13:40 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2 -mm] memcg: prevent from OOM with too many dirty
 pages
In-Reply-To: <20120711192106.b6b8232f.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1207112012020.3727@eggly.anvils>
References: <1340117404-30348-1-git-send-email-mhocko@suse.cz> <20120619150014.1ebc108c.akpm@linux-foundation.org> <20120620101119.GC5541@tiehlicka.suse.cz> <alpine.LSU.2.00.1207111818380.1299@eggly.anvils>
 <20120711192106.b6b8232f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Fengguang Wu <fengguang.wu@intel.com>

On Wed, 11 Jul 2012, Andrew Morton wrote:
> On Wed, 11 Jul 2012 18:57:43 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
> 
> > --- 3.5-rc6-mm1/mm/vmscan.c	2012-07-11 14:42:13.668335884 -0700
> > +++ linux/mm/vmscan.c	2012-07-11 16:01:20.712814127 -0700
> > @@ -726,7 +726,8 @@ static unsigned long shrink_page_list(st
> >  			 * writeback from reclaim and there is nothing else to
> >  			 * reclaim.
> >  			 */
> > -			if (!global_reclaim(sc) && PageReclaim(page))
> > +			if (!global_reclaim(sc) && PageReclaim(page) &&
> > +					may_enter_fs)
> >  				wait_on_page_writeback(page);
> >  			else {
> >  				nr_writeback++;
> 
> um, that may_enter_fs test got removed because nobody knew why it was
> there.  Nobody knew why it was there because it was undocumented.  Do
> you see where I'm going with this?

I was hoping you might do that bit ;)  Here's my display of ignorance:

--- 3.5-rc6-mm1/mm/vmscan.c	2012-07-11 14:42:13.668335884 -0700
+++ linux/mm/vmscan.c	2012-07-11 20:09:33.182829986 -0700
@@ -725,8 +725,15 @@ static unsigned long shrink_page_list(st
 			 * could easily OOM just because too many pages are in
 			 * writeback from reclaim and there is nothing else to
 			 * reclaim.
+			 *
+			 * Check may_enter_fs, certainly because a loop driver
+			 * thread might enter reclaim, and deadlock if it waits
+			 * on a page for which it is needed to do the write
+			 * (loop masks off __GFP_IO|__GFP_FS for this reason);
+			 * but more thought would probably show more reasons.
 			 */
-			if (!global_reclaim(sc) && PageReclaim(page))
+			if (!global_reclaim(sc) && PageReclaim(page) &&
+					may_enter_fs)
 				wait_on_page_writeback(page);
 			else {
 				nr_writeback++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
