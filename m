Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0DBE36B002D
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 23:08:39 -0400 (EDT)
Subject: Re: [patch 2/2]vmscan: correctly detect GFP_ATOMIC allocation
 failure
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20110928092751.GA15062@tiehlicka.suse.cz>
References: <1317108187.29510.201.camel@sli10-conroe>
	 <20110927112810.GA3897@tiehlicka.suse.cz>
	 <1317170933.22361.5.camel@sli10-conroe>
	 <20110928092751.GA15062@tiehlicka.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 08 Oct 2011 11:14:34 +0800
Message-ID: <1318043674.22361.38.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mel <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, MinchanKim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>

On Wed, 2011-09-28 at 17:27 +0800, Michal Hocko wrote:
> On Wed 28-09-11 08:48:53, Shaohua Li wrote:
> > On Tue, 2011-09-27 at 19:28 +0800, Michal Hocko wrote:
> > > On Tue 27-09-11 15:23:07, Shaohua Li wrote:
> > > > has_under_min_watermark_zone is used to detect if there is GFP_ATOMIC allocation
> > > > failure risk. For a high end_zone, if any zone below or equal to it has min
> > > > matermark ok, we have no risk. But current logic is any zone has min watermark
> > > > not ok, then we have risk. This is wrong to me.
> > > 
> > > This, however, means that we skip congestion_wait more often as ZONE_DMA
> > > tend to be mostly balanced, right? This would mean that kswapd could hog
> > > CPU more.
> > We actually might have more congestion_wait, as now if any zone can meet
> > min watermark, we don't have has_under_min_watermark_zone set so do
> > congestion_wait
> 
> Ahh, sorry, got confused.
resend the patch to correct email address of akpm.

Subject: vmscan: correctly detect GFP_ATOMIC allocation failure

has_under_min_watermark_zone is used to detect if there is GFP_ATOMIC allocation
failure risk. For a high end_zone, if any zone below or equal to it has min
matermark ok, we have no risk. But current logic is any zone has min watermark
not ok, then we have risk. This is wrong to me.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 mm/vmscan.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

Index: linux/mm/vmscan.c
===================================================================
--- linux.orig/mm/vmscan.c	2011-09-27 15:09:29.000000000 +0800
+++ linux/mm/vmscan.c	2011-09-27 15:14:45.000000000 +0800
@@ -2463,7 +2463,7 @@ loop_again:
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		unsigned long lru_pages = 0;
-		int has_under_min_watermark_zone = 0;
+		int has_under_min_watermark_zone = 1;
 
 		/* The swap token gets in the way of swapout... */
 		if (!priority)
@@ -2594,9 +2594,10 @@ loop_again:
 				 * means that we have a GFP_ATOMIC allocation
 				 * failure risk. Hurry up!
 				 */
-				if (!zone_watermark_ok_safe(zone, order,
+				if (has_under_min_watermark_zone &&
+					    zone_watermark_ok_safe(zone, order,
 					    min_wmark_pages(zone), end_zone, 0))
-					has_under_min_watermark_zone = 1;
+					has_under_min_watermark_zone = 0;
 			} else {
 				/*
 				 * If a zone reaches its high watermark,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
