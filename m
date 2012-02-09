Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 43C806B13F0
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 06:36:19 -0500 (EST)
Date: Thu, 9 Feb 2012 12:36:06 +0100
From: Johannes Stezenbach <js@sig21.net>
Subject: Re: swap storm since kernel 3.2.x
Message-ID: <20120209113606.GA8054@sig21.net>
References: <201202041109.53003.toralf.foerster@gmx.de>
 <201202051107.26634.toralf.foerster@gmx.de>
 <CAJd=RBCvvVgWqfSkoEaWVG=2mwKhyXarDOthHt9uwOb2fuDE9g@mail.gmail.com>
 <201202080956.18727.toralf.foerster@gmx.de>
 <20120208115244.GA24959@sig21.net>
 <CAJd=RBDbYA4xZRikGtHJvKESdiSE-B4OucZ6vQ+tHCi+hG2+aw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBDbYA4xZRikGtHJvKESdiSE-B4OucZ6vQ+tHCi+hG2+aw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Toralf =?iso-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

On Wed, Feb 08, 2012 at 08:34:14PM +0800, Hillf Danton wrote:
> And I want to ask kswapd to do less work, the attached diff is
> based on 3.2.5, mind to test it with CONFIG_DEBUG_OBJECTS enabled?

Sorry, for slow reply.  The patch does not apply to 3.2.4
(3.2.5 only has the ASPM change which I don't want to
try atm).  Is the patch below correct?

I'll let this run for a while and will report back.

Thanks
Johannes


--- mm/vmscan.c.orig	2012-02-03 21:39:51.000000000 +0100
+++ mm/vmscan.c	2012-02-09 12:30:42.000000000 +0100
@@ -2067,8 +2067,11 @@ restart:
 		 * with multiple processes reclaiming pages, the total
 		 * freeing target can get unreasonably large.
 		 */
-		if (nr_reclaimed >= nr_to_reclaim && priority < DEF_PRIORITY)
+		if (nr_reclaimed >= nr_to_reclaim) {
+			nr_to_reclaim = 0;
 			break;
+		}
+		nr_to_reclaim -= nr_reclaimed;
 	}
 	blk_finish_plug(&plug);
 	sc->nr_reclaimed += nr_reclaimed;
@@ -2535,12 +2538,12 @@ static unsigned long balance_pgdat(pg_da
 		 * we want to put equal scanning pressure on each zone.
 		 */
 		.nr_to_reclaim = ULONG_MAX,
-		.order = order,
 		.mem_cgroup = NULL,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
 	};
+	sc.order = order = 0;
 loop_again:
 	total_scanned = 0;
 	sc.nr_reclaimed = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
