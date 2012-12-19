Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 726016B002B
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 00:24:56 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fb1so1037546pad.11
        for <linux-mm@kvack.org>; Tue, 18 Dec 2012 21:24:55 -0800 (PST)
Subject: Re: [patch 1/8] mm: memcg: only evict file pages when we have
 plenty
From: Simon Jeons <simon.jeons@gmail.com>
In-Reply-To: <20121217155416.GC25432@dhcp22.suse.cz>
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
	 <1355348620-9382-2-git-send-email-hannes@cmpxchg.org>
	 <50C8FCE0.1060408@redhat.com> <20121212222844.GA10257@cmpxchg.org>
	 <20121213145514.GD21644@dhcp22.suse.cz> <50CD2232.8020909@gmail.com>
	 <20121217155416.GC25432@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 19 Dec 2012 00:21:55 -0500
Message-ID: <1355894515.1657.2.camel@kernel-VirtualBox>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2012-12-17 at 16:54 +0100, Michal Hocko wrote:
> On Sun 16-12-12 09:21:54, Simon Jeons wrote:
> > On 12/13/2012 10:55 PM, Michal Hocko wrote:
> > >On Wed 12-12-12 17:28:44, Johannes Weiner wrote:
> > >>On Wed, Dec 12, 2012 at 04:53:36PM -0500, Rik van Riel wrote:
> > >>>On 12/12/2012 04:43 PM, Johannes Weiner wrote:
> > >>>>dc0422c "mm: vmscan: only evict file pages when we have plenty" makes
> > >>>>a point of not going for anonymous memory while there is still enough
> > >>>>inactive cache around.
> > >>>>
> > >>>>The check was added only for global reclaim, but it is just as useful
> > >>>>for memory cgroup reclaim.
> > >>>>
> > >>>>Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > >>>>---
> > >>>>  mm/vmscan.c | 19 ++++++++++---------
> > >>>>  1 file changed, 10 insertions(+), 9 deletions(-)
> > >>>>
> > >>>>diff --git a/mm/vmscan.c b/mm/vmscan.c
> > >>>>index 157bb11..3874dcb 100644
> > >>>>--- a/mm/vmscan.c
> > >>>>+++ b/mm/vmscan.c
> > >>>>@@ -1671,6 +1671,16 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
> > >>>>  		denominator = 1;
> > >>>>  		goto out;
> > >>>>  	}
> > >>>>+	/*
> > >>>>+	 * There is enough inactive page cache, do not reclaim
> > >>>>+	 * anything from the anonymous working set right now.
> > >>>>+	 */
> > >>>>+	if (!inactive_file_is_low(lruvec)) {
> > >>>>+		fraction[0] = 0;
> > >>>>+		fraction[1] = 1;
> > >>>>+		denominator = 1;
> > >>>>+		goto out;
> > >>>>+	}
> > >>>>
> > >>>>  	anon  = get_lru_size(lruvec, LRU_ACTIVE_ANON) +
> > >>>>  		get_lru_size(lruvec, LRU_INACTIVE_ANON);
> > >>>>@@ -1688,15 +1698,6 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
> > >>>>  			fraction[1] = 0;
> > >>>>  			denominator = 1;
> > >>>>  			goto out;
> > >>>>-		} else if (!inactive_file_is_low_global(zone)) {
> > >>>>-			/*
> > >>>>-			 * There is enough inactive page cache, do not
> > >>>>-			 * reclaim anything from the working set right now.
> > >>>>-			 */
> > >>>>-			fraction[0] = 0;
> > >>>>-			fraction[1] = 1;
> > >>>>-			denominator = 1;
> > >>>>-			goto out;
> > >>>>  		}
> > >>>>  	}
> > >>>>
> > >>>>
> > >>>I believe the if() block should be moved to AFTER
> > >>>the check where we make sure we actually have enough
> > >>>file pages.
> > >>You are absolutely right, this makes more sense.  Although I'd figure
> > >>the impact would be small because if there actually is that little
> > >>file cache, it won't be there for long with force-file scanning... :-)
> > >Yes, I think that the result would be worse (more swapping) so the
> > >change can only help.
> > >
> > >>I moved the condition, but it throws conflicts in the rest of the
> > >>series.  Will re-run tests, wait for Michal and Mel, then resend.
> > >Yes the patch makes sense for memcg as well. I guess you have tested
> > >this primarily with memcg. Do you have any numbers? Would be nice to put
> > >them into the changelog if you have (it should help to reduce swapping
> > >with heavy streaming IO load).
> > >
> > >Acked-by: Michal Hocko <mhocko@suse.cz>
> > 
> > Hi Michal,
> > 
> > I still can't understand why "The goto out means that it should be
> > fine either way.",
> 
> Not sure I understand your question. goto out just says that either page
> cache is low or inactive file LRU is too small. And it works for both
> memcg and global because the page cache is low condition is evaluated
> only for the global reclaim and always before inactive file is small.
> Makes more sense?

Hi Michal,

I confuse of Gorman's comments below, why the logic change still fine.  

Current
  low_file      inactive_is_high        force reclaim anon
  low_file      !inactive_is_high       force reclaim anon
  !low_file     inactive_is_high        force reclaim file
  !low_file     !inactive_is_high       normal split

Your patch

  low_file      inactive_is_high        force reclaim anon
  low_file      !inactive_is_high       force reclaim anon
  !low_file     inactive_is_high        force reclaim file
  !low_file     !inactive_is_high       normal split

However, if you move the inactive_file_is_low check down you get

Moving the check
  low_file      inactive_is_high        force reclaim file
  low_file      !inactive_is_high       force reclaim anon
  !low_file     inactive_is_high        force reclaim file
  !low_file     !inactive_is_high       normal split

> 
> > could you explain to me, sorry for my stupid. :-)
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
