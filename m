Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 572696B0011
	for <linux-mm@kvack.org>; Thu, 12 May 2011 20:47:17 -0400 (EDT)
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <20110512221506.GM16531@cmpxchg.org>
References: <1305127773-10570-4-git-send-email-mgorman@suse.de>
	 <alpine.DEB.2.00.1105120942050.24560@router.home>
	 <1305213359.2575.46.camel@mulgrave.site>
	 <alpine.DEB.2.00.1105121024350.26013@router.home>
	 <1305214993.2575.50.camel@mulgrave.site> <1305215742.27848.40.camel@jaguar>
	 <1305225467.2575.66.camel@mulgrave.site>
	 <1305229447.2575.71.camel@mulgrave.site>
	 <1305230652.2575.72.camel@mulgrave.site>
	 <1305237882.2575.100.camel@mulgrave.site>
	 <20110512221506.GM16531@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 12 May 2011 19:47:05 -0500
Message-ID: <1305247626.2575.111.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Rik van Riel <riel@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Fri, 2011-05-13 at 00:15 +0200, Johannes Weiner wrote:
> On Thu, May 12, 2011 at 05:04:41PM -0500, James Bottomley wrote:
> > On Thu, 2011-05-12 at 15:04 -0500, James Bottomley wrote:
> > > Confirmed, I'm afraid ... I can trigger the problem with all three
> > > patches under PREEMPT.  It's not a hang this time, it's just kswapd
> > > taking 100% system time on 1 CPU and it won't calm down after I unload
> > > the system.
> > 
> > Just on a "if you don't know what's wrong poke about and see" basis, I
> > sliced out all the complex logic in sleeping_prematurely() and, as far
> > as I can tell, it cures the problem behaviour.  I've loaded up the
> > system, and taken the tar load generator through three runs without
> > producing a spinning kswapd (this is PREEMPT).  I'll try with a
> > non-PREEMPT kernel shortly.
> > 
> > What this seems to say is that there's a problem with the complex logic
> > in sleeping_prematurely().  I'm pretty sure hacking up
> > sleeping_prematurely() just to dump all the calculations is the wrong
> > thing to do, but perhaps someone can see what the right thing is ...
> 
> I think I see the problem: the boolean logic of sleeping_prematurely()
> is odd.  If it returns true, kswapd will keep running.  So if
> pgdat_balanced() returns true, kswapd should go to sleep.
> 
> This?

I was going to say this was a winner, but on the third untar run on
non-PREEMPT, I hit the kswapd livelock.  It's got much farther than
previous attempts, which all hang on the first run, but I think the
essential problem is still (at least on this machine) that
sleeping_prematurely() is doing too much work for the wakeup storm that
allocators are causing.

Something that ratelimits the amount of time we spend in the watermark
calculations, like the below (which incorporates your pgdat fix) seems
to be much more stable (I've not run it for three full runs yet, but
kswapd CPU time is way lower so far).

The heuristic here is that if we're making the calculation more than ten
times in 1/10 of a second, stop and sleep anyway.

James

---

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0665520..545250c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2249,12 +2249,32 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
 {
 	int i;
 	unsigned long balanced = 0;
-	bool all_zones_ok = true;
+	bool all_zones_ok = true, ret;
+	static int returned_true = 0;
+	static unsigned long prev_jiffies = 0;
+	
 
 	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
 	if (remaining)
 		return true;
 
+	/* rate limit our entry to the watermark calculations */
+	if (time_after(prev_jiffies + HZ/10, jiffies)) {
+		/* previously returned false, do so again */
+		if (returned_true == 0)
+			return false;
+		/* or we've done the true calculation too many times */
+		if (returned_true++ > 10)
+			return false;
+
+		return true;
+	} else {
+		/* haven't been here for a while, reset the true count */
+		returned_true = 0;
+	}
+
+	prev_jiffies = jiffies;
+
 	/* Check the watermark levels */
 	for (i = 0; i < pgdat->nr_zones; i++) {
 		struct zone *zone = pgdat->node_zones + i;
@@ -2286,9 +2306,16 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
 	 * must be balanced
 	 */
 	if (order)
-		return pgdat_balanced(pgdat, balanced, classzone_idx);
+		ret = !pgdat_balanced(pgdat, balanced, classzone_idx);
+	else
+		ret = !all_zones_ok;
+
+	if (ret)
+		returned_true++;
 	else
-		return !all_zones_ok;
+		returned_true = 0;
+
+	return ret;
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
