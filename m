Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B1A1290010B
	for <linux-mm@kvack.org>; Thu, 12 May 2011 18:04:58 -0400 (EDT)
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <1305230652.2575.72.camel@mulgrave.site>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de>
	 <1305127773-10570-4-git-send-email-mgorman@suse.de>
	 <alpine.DEB.2.00.1105120942050.24560@router.home>
	 <1305213359.2575.46.camel@mulgrave.site>
	 <alpine.DEB.2.00.1105121024350.26013@router.home>
	 <1305214993.2575.50.camel@mulgrave.site> <1305215742.27848.40.camel@jaguar>
	 <1305225467.2575.66.camel@mulgrave.site>
	 <1305229447.2575.71.camel@mulgrave.site>
	 <1305230652.2575.72.camel@mulgrave.site>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 12 May 2011 17:04:41 -0500
Message-ID: <1305237882.2575.100.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Thu, 2011-05-12 at 15:04 -0500, James Bottomley wrote:
> Confirmed, I'm afraid ... I can trigger the problem with all three
> patches under PREEMPT.  It's not a hang this time, it's just kswapd
> taking 100% system time on 1 CPU and it won't calm down after I unload
> the system.

Just on a "if you don't know what's wrong poke about and see" basis, I
sliced out all the complex logic in sleeping_prematurely() and, as far
as I can tell, it cures the problem behaviour.  I've loaded up the
system, and taken the tar load generator through three runs without
producing a spinning kswapd (this is PREEMPT).  I'll try with a
non-PREEMPT kernel shortly.

What this seems to say is that there's a problem with the complex logic
in sleeping_prematurely().  I'm pretty sure hacking up
sleeping_prematurely() just to dump all the calculations is the wrong
thing to do, but perhaps someone can see what the right thing is ...

By the way, I stripped off all the patches, so this is a plain old
2.6.38.6 kernel with the default FC15 config.

James

---

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0665520..1bdea7d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2255,6 +2255,8 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
 	if (remaining)
 		return true;
 
+	return false;
+
 	/* Check the watermark levels */
 	for (i = 0; i < pgdat->nr_zones; i++) {
 		struct zone *zone = pgdat->node_zones + i;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
