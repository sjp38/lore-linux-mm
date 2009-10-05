Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 823426B0055
	for <linux-mm@kvack.org>; Mon,  5 Oct 2009 02:51:06 -0400 (EDT)
From: Frans Pop <elendil@planet.nl>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
Date: Mon, 5 Oct 2009 08:50:58 +0200
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <200910021111.55749.elendil@planet.nl> <200910050714.01908.elendil@planet.nl>
In-Reply-To: <200910050714.01908.elendil@planet.nl>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200910050851.02056.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 05 October 2009, Frans Pop wrote:
> I'll dig into this a bit more as it looks like this should be
> reproducible, probably even without the kernel build. Next step is to
> see how .30 behaves in the same situation.

This looks conclusive. I tested .30 and .32-rc3 from clean reboots and
only starting gitk. I only started music playing in the background
(amarok) from an NFS share to ensure network activity.

With .32-rc3 I got 4 SKB allocation errors while starting the *second* gitk
instance. And the system was completely frozen with music stopped until gitk
finished loading.

With .30 I was able to start *three* gitk's (which meant 2 of them got
(partially) swapped out) without any allocation errors. And with the system
remaining relatively responsive. There was a short break in the music while
I started the 2nd instance, but it just continued playing afterwards. There
was also some mild latency in the mouse cursor, but nothing like the full
desktop freeze I get with .32-rc3.

With .30 I looked at /proc/buddyinfo while the 3rd gitk was being started,
and that looked fairly healthy all the time:
Node 0, zone      DMA      5      9     22     20     21     11      0      0      0      0      1
Node 0, zone    DMA32    579     67     25      8      5      1      1      0      1      1      0
Node 0, zone      DMA      5      9     22     20     21     11      0      0      0      0      1
Node 0, zone    DMA32    276     54     13     15      8     10      3      1      1      1      0
Node 0, zone      DMA      4      9     22     20     21     11      0      0      0      0      1
Node 0, zone    DMA32    119     45     24     18     12      4      5      2      1      1      0
Node 0, zone      DMA      4      9     22     20     21     11      0      0      0      0      1
Node 0, zone    DMA32    527     13      9      5      5      3      2      1      1      1      0
Node 0, zone      DMA      5      9     22     20     21     11      0      0      0      0      1
Node 0, zone    DMA32   1375     24      7      7      8      5      1      1      0      1      0
Node 0, zone      DMA      5      9     22     20     21     11      0      0      0      0      1
Node 0, zone    DMA32    329     21      3      3     17      8      5      1      0      1      0

With .32 it was obviously impossible to get that info due to the total
freeze of the desktop. Not sure if the scheduler changes in .32 contribute
to this. Guess I could find out by doing the same test with .31.

One thing I should mention: my swap is an LVM volume that's in a VG that's
on a LUKS encrypted partition.

Does this give you enough info to go on, or should I try a bisection?

Cheers,
FJP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
