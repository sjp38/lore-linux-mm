Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 821A76B02A3
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 00:28:03 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6D4S1Ra008630
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 13 Jul 2010 13:28:01 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C1D9145DE6E
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 13:28:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 95A5A45DE60
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 13:28:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 700A91DB8042
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 13:28:00 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 175321DB8037
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 13:27:57 +0900 (JST)
Date: Tue, 13 Jul 2010 13:23:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Tight check of pfn_valid on sparsemem
Message-Id: <20100713132312.a7dfb100.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTiny7dz8ssDknI7y4JFcVP9SV1aNM7f0YMUxafv7@mail.gmail.com>
References: <20100712155348.GA2815@barrios-desktop>
	<20100713121947.612bd656.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTiny7dz8ssDknI7y4JFcVP9SV1aNM7f0YMUxafv7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux@arm.linux.org.uk, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, Yakui Zhao <yakui.zhao@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arm-kernel@lists.infradead.org, kgene.kim@samsung.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jul 2010 13:11:14 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Tue, Jul 13, 2010 at 12:19 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 13 Jul 2010 00:53:48 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> >
> >> Kukjin, Could you test below patch?
> >> I don't have any sparsemem system. Sorry.
> >>
> >> -- CUT DOWN HERE --
> >>
> >> Kukjin reported oops happen while he change min_free_kbytes
> >> http://www.spinics.net/lists/arm-kernel/msg92894.html
> >> It happen by memory map on sparsemem.
> >>
> >> The system has a memory map following as.
> >> A  A  A section 0 A  A  A  A  A  A  section 1 A  A  A  A  A  A  A section 2
> >> 0x20000000-0x25000000, 0x40000000-0x50000000, 0x50000000-0x58000000
> >> SECTION_SIZE_BITS 28(256M)
> >>
> >> It means section 0 is an incompletely filled section.
> >> Nontheless, current pfn_valid of sparsemem checks pfn loosely.
> >>
> >> It checks only mem_section's validation.
> >> So in above case, pfn on 0x25000000 can pass pfn_valid's validation check.
> >> It's not what we want.
> >>
> >> The Following patch adds check valid pfn range check on pfn_valid of sparsemem.
> >>
> >> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> >> Reported-by: Kukjin Kim <kgene.kim@samsung.com>
> >>
> >> P.S)
> >> It is just RFC. If we agree with this, I will make the patch on mmotm.
> >>
> >> --
> >>
> >> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> >> index b4d109e..6c2147a 100644
> >> --- a/include/linux/mmzone.h
> >> +++ b/include/linux/mmzone.h
> >> @@ -979,6 +979,8 @@ struct mem_section {
> >> A  A  A  A  struct page_cgroup *page_cgroup;
> >> A  A  A  A  unsigned long pad;
> >> A #endif
> >> + A  A  A  unsigned long start_pfn;
> >> + A  A  A  unsigned long end_pfn;
> >> A };
> >>
> >
> > I have 2 concerns.
> > A 1. This makes mem_section twice. Wasting too much memory and not good for cache.
> > A  A But yes, you can put this under some CONFIG which has small number of mem_section[].
> >
> 
> I think memory usage isn't a big deal. but for cache, we can move
> fields into just after section_mem_map.
> 
I don't think so. This addtional field can eat up the amount of memory you saved
by unmap.

> > A 2. This can't be help for a case where a section has multiple small holes.
> 
> I agree. But this(not punched hole but not filled section problem)
> isn't such case. But it would be better to handle it altogether. :)
> 
> >
> > Then, my proposal for HOLES_IN_MEMMAP sparsemem is below.
> > ==
> > Some architectures unmap memmap[] for memory holes even with SPARSEMEM.
> > To handle that, pfn_valid() should check there are really memmap or not.
> > For that purpose, __get_user() can be used.
> 
> Look at free_unused_memmap. We don't unmap pte of hole memmap.
> Is __get_use effective, still?
> 
__get_user() works with TLB and page table, the vaddr is really mapped or not.
If you got SEGV, __get_user() returns -EFAULT. It works per page granule.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
