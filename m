Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7E0476B0089
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 04:31:11 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAT9V8kh007078
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 29 Nov 2010 18:31:09 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C4C2445DE6E
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 18:31:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A5FFE45DE4D
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 18:31:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E2981DB8037
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 18:31:08 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4020EE38002
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 18:31:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Free memory never fully used, swapping
In-Reply-To: <20101124084652.GC25170@hostway.ca>
References: <1290501331.2390.7023.camel@nimitz> <20101124084652.GC25170@hostway.ca>
Message-Id: <20101129182211.82C2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 29 Nov 2010 18:31:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Simon Kirby <sim@hostway.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi

> On Tue, Nov 23, 2010 at 12:35:31AM -0800, Dave Hansen wrote:
>=20
> > I wish.  :)  The best thing to do is to watch stuff like /proc/vmstat
> > along with its friends like /proc/{buddy,meminfo,slabinfo}.  Could you
> > post some samples of those with some indication of where the bad
> > behavior was seen?
> >=20
> > I've definitely seen swapping in the face of lots of free memory, but
> > only in cases where I was being a bit unfair about the numbers of
> > hugetlbfs pages I was trying to reserve.
>=20
> So, Dave and I spent quite some time today figuring out was going on
> here.  Once load picked up during the day, kswapd actually never slept
> until late in the afternoon.  During the evening now, it's still waking
> up in bursts, and still keeping way too much memory free:
>=20
> 	http://0x.ca/sim/ref/2.6.36/memory_tonight.png
>=20
> 	(NOTE: we did swapoff -a to keep /dev/sda from overloading)
>=20
> We have a much better idea on what is happening here, but more questions.
>=20
> This x86_64 box has 4 GB of RAM; zones are set up as follows:
>=20
> [    0.000000] Zone PFN ranges:
> [    0.000000]   DMA      0x00000001 -> 0x00001000
> [    0.000000]   DMA32    0x00001000 -> 0x00100000
> [    0.000000]   Normal   0x00100000 -> 0x00130000
> ...
> [    0.000000] On node 0 totalpages: 1047279 =20
> [    0.000000]   DMA zone: 56 pages used for memmap
> [    0.000000]   DMA zone: 0 pages reserved  =20
> [    0.000000]   DMA zone: 3943 pages, LIFO batch:0
> [    0.000000]   DMA32 zone: 14280 pages used for memmap
> [    0.000000]   DMA32 zone: 832392 pages, LIFO batch:31
> [    0.000000]   Normal zone: 2688 pages used for memmap
> [    0.000000]   Normal zone: 193920 pages, LIFO batch:31

This machine's zone size are

	DMA32:  3250MB
	NORMAL:  750MB

This inbalance zone size is one of root cause of the strange swapping=20
issue. I'm sure we certinally need to fix our VM heuristics. However=20
there is no perfect heuristics in the real world and we can't make it.=20
Also, I guess a bug reporter need practical workaround.

Then, I wrote following patch.

if you pass a following boot parameter, zone division change to
dma32=3D1G + normal=3D3G.

in grub.conf

	 kernel /boot/vmlinuz ro root=3Dfoobar .... zone_dma32_size=3D1G=20


I bet this one reduce your head pain a lot. Can you please try this?
Of cource, this is only workaround. not truth fix.


=46rom 1446c915fd59a5f123c2619d1f1f3b4e1bd0c648 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 23 Dec 2010 08:57:27 +0900
Subject: [PATCH] x86: implement zone_dma32_size boot parameter

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 Documentation/kernel-parameters.txt |    5 +++++
 arch/x86/mm/init_64.c               |   17 ++++++++++++++++-
 2 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-par=
ameters.txt
index a5966c0..25b4a53 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2686,6 +2686,11 @@ and is between 256 and 4096 characters. It is define=
d in the file
 			Format:
 			<irq>,<irq_mask>,<io>,<full_duplex>,<do_sound>,<lockup_hack>[,<irq2>[,<=
irq3>[,<irq4>]]]
=20
+	zone_dma32_size=3Dnn[KMG]		[KNL,BOOT,X86-64]
+			forces the dma32 zone to have an exact size of <nn>.
+			This works to reduce dma32 zone (In other word, to
+			increase normal zone) size.
+
 ______________________________________________________________________
=20
 TODO:
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 71a5929..12d813d 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -95,6 +95,21 @@ static int __init nonx32_setup(char *str)
 }
 __setup("noexec32=3D", nonx32_setup);
=20
+static unsigned long max_dma32_pfn =3D MAX_DMA32_PFN;
+static int __init parse_zone_dma32_size(char *arg)
+{
+	unsigned long dma32_pages;
+
+	if (!arg)
+		return -EINVAL;
+
+	dma32_pages =3D memparse(arg, &arg) >> PAGE_SHIFT;
+	max_dma32_pfn =3D min(MAX_DMA_PFN + dma32_pages, MAX_DMA32_PFN);
+
+	return 0;
+}
+early_param("zone_dma32_size", parse_zone_dma32_size);
+
 /*
  * When memory was added/removed make sure all the processes MM have
  * suitable PGD entries in the local PGD level page.
@@ -625,7 +640,7 @@ void __init paging_init(void)
=20
 	memset(max_zone_pfns, 0, sizeof(max_zone_pfns));
 	max_zone_pfns[ZONE_DMA] =3D MAX_DMA_PFN;
-	max_zone_pfns[ZONE_DMA32] =3D MAX_DMA32_PFN;
+	max_zone_pfns[ZONE_DMA32] =3D max_dma32_pfn;
 	max_zone_pfns[ZONE_NORMAL] =3D max_pfn;
=20
 	sparse_memory_present_with_active_regions(MAX_NUMNODES);
--=20
1.6.5.2




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
