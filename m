Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 82D976B00A2
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 17:29:34 -0500 (EST)
Date: Wed, 12 Dec 2012 17:28:44 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/8] mm: memcg: only evict file pages when we have plenty
Message-ID: <20121212222844.GA10257@cmpxchg.org>
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
 <1355348620-9382-2-git-send-email-hannes@cmpxchg.org>
 <50C8FCE0.1060408@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50C8FCE0.1060408@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 12, 2012 at 04:53:36PM -0500, Rik van Riel wrote:
> On 12/12/2012 04:43 PM, Johannes Weiner wrote:
> >dc0422c "mm: vmscan: only evict file pages when we have plenty" makes
> >a point of not going for anonymous memory while there is still enough
> >inactive cache around.
> >
> >The check was added only for global reclaim, but it is just as useful
> >for memory cgroup reclaim.
> >
> >Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> >---
> >  mm/vmscan.c | 19 ++++++++++---------
> >  1 file changed, 10 insertions(+), 9 deletions(-)
> >
> >diff --git a/mm/vmscan.c b/mm/vmscan.c
> >index 157bb11..3874dcb 100644
> >--- a/mm/vmscan.c
> >+++ b/mm/vmscan.c
> >@@ -1671,6 +1671,16 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
> >  		denominator = 1;
> >  		goto out;
> >  	}
> >+	/*
> >+	 * There is enough inactive page cache, do not reclaim
> >+	 * anything from the anonymous working set right now.
> >+	 */
> >+	if (!inactive_file_is_low(lruvec)) {
> >+		fraction[0] = 0;
> >+		fraction[1] = 1;
> >+		denominator = 1;
> >+		goto out;
> >+	}
> >
> >  	anon  = get_lru_size(lruvec, LRU_ACTIVE_ANON) +
> >  		get_lru_size(lruvec, LRU_INACTIVE_ANON);
> >@@ -1688,15 +1698,6 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
> >  			fraction[1] = 0;
> >  			denominator = 1;
> >  			goto out;
> >-		} else if (!inactive_file_is_low_global(zone)) {
> >-			/*
> >-			 * There is enough inactive page cache, do not
> >-			 * reclaim anything from the working set right now.
> >-			 */
> >-			fraction[0] = 0;
> >-			fraction[1] = 1;
> >-			denominator = 1;
> >-			goto out;
> >  		}
> >  	}
> >
> >
> 
> I believe the if() block should be moved to AFTER
> the check where we make sure we actually have enough
> file pages.

You are absolutely right, this makes more sense.  Although I'd figure
the impact would be small because if there actually is that little
file cache, it won't be there for long with force-file scanning... :-)

I moved the condition, but it throws conflicts in the rest of the
series.  Will re-run tests, wait for Michal and Mel, then resend.

Thanks, Rik!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
