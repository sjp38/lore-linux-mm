Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DDA096B02A3
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 03:44:06 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6E7i2w5024208
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 14 Jul 2010 16:44:02 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DC8C45DE58
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 16:44:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D93E545DE51
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 16:44:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BB7EF1DB8043
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 16:44:01 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 58E611DB803F
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 16:44:01 +0900 (JST)
Date: Wed, 14 Jul 2010 16:39:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Tight check of pfn_valid on sparsemem
Message-Id: <20100714163916.95afaf92.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTilVVKdLNC0OJfVv5N5GGXL9bwXJfOLC5NHE-Qc4@mail.gmail.com>
References: <20100712155348.GA2815@barrios-desktop>
	<20100713093006.GB14504@cmpxchg.org>
	<20100713154335.GB2815@barrios-desktop>
	<1279038933.10995.9.camel@nimitz>
	<20100713164423.GC2815@barrios-desktop>
	<20100714092301.69e7e628.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTin8tdw4VmfCPHE0TR3f-l7ao8ngQJcepTDPpMAC@mail.gmail.com>
	<20100714161045.ef028769.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTilVVKdLNC0OJfVv5N5GGXL9bwXJfOLC5NHE-Qc4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux@arm.linux.org.uk, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, Yakui Zhao <yakui.zhao@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arm-kernel@lists.infradead.org, kgene.kim@samsung.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jul 2010 16:35:22 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Wed, Jul 14, 2010 at 4:10 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Wed, 14 Jul 2010 15:44:41 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> >
> >> Hi, Kame.
> >>
> >> On Wed, Jul 14, 2010 at 9:23 AM, KAMEZAWA Hiroyuki
> >> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> > On Wed, 14 Jul 2010 01:44:23 +0900
> >> > Minchan Kim <minchan.kim@gmail.com> wrote:
> >> >
> >> >> > If you _really_ can't make the section size smaller, and the vast
> >> >> > majority of the sections are fully populated, you could hack something
> >> >> > in. A We could, for instance, have a global list that's mostly readonly
> >> >> > which tells you which sections need to be have their sizes closely
> >> >> > inspected. A That would work OK if, for instance, you only needed to
> >> >> > check a couple of memory sections in the system. A It'll start to suck if
> >> >> > you made the lists very long.
> >> >>
> >> >> Thanks for advise. As I say, I hope Russell accept 16M section.
> >> >>
> >> >
> >> > It seems what I needed was good sleep....
> >> > How about this if 16M section is not acceptable ?
> >> >
> >> > == NOT TESTED AT ALL, EVEN NOT COMPILED ==
> >> >
> >> > register address of mem_section to memmap itself's page struct's pg->private field.
> >> > This means the page is used for memmap of the section.
> >> > Otherwise, the page is used for other purpose and memmap has a hole.
> >>
> >> It's a very good idea. :)
> >> But can this handle case that a page on memmap pages have struct page
> >> descriptor of hole?
> >> I mean one page can include 128 page descriptor(4096 / 32).
> > yes.
> >
> >> In there, 64 page descriptor is valid but remain 64 page descriptor is on hole.
> >> In this case, free_memmap doesn't free the page.
> >
> > yes. but in that case, there are valid page decriptor for 64pages of holes.
> > pfn_valid() should return true but PG_reserved is set.
> > (This is usual behavior.)
> >
> > My intention is that
> >
> > A - When all 128 page descriptors are unused, free_memmap() will free it.
> > A  In that case, clear page->private of a page for freed page descriptors.
> >
> > A - When some of page descriptors are used, free_memmap() can't free it
> > A  and page->private points to &mem_section. We may have memmap for memory
> > A  hole but pfn_valid() is a function to check there is memmap or not.
> > A  The bahavior of pfn_valid() is valid.
> > A  Anyway, you can't free only half of page.
> 
> Okay. I missed PageReserved.
> Your idea seems to be good. :)
> 
> I looked at pagetypeinfo_showblockcount_print.
> It doesn't check PageReserved. Instead of it, it does ugly memmap_valid_within.
> Can't we remove it and change it with PageReserved?
> 
maybe. but I'm not sure how many archs uses CONFIG_ARCH_HAS_HOLES_MEMORYMODEL.
Because my idea requires to add arch-dependent hook, enhancement of pfn_valid()
happens only when an arch supports it. So, you may need a conservative path.

Anyway, I can't test the patch by myself. So, I pass ball to ARM guys.
Feel free to reuse my idea if you like.
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
