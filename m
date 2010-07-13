Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D77756B02A3
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 02:45:13 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6D6jAoS004701
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 13 Jul 2010 15:45:10 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3742645DE60
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 15:45:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0913945DE6E
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 15:45:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CF85EE38002
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 15:45:09 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 808961DB803B
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 15:45:09 +0900 (JST)
Date: Tue, 13 Jul 2010 15:40:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Tight check of pfn_valid on sparsemem
Message-Id: <20100713154025.7c60c76b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTinVwmo5pemz86nXaQT3V_ujaPLOsyNeQIFhL0Vu@mail.gmail.com>
References: <20100712155348.GA2815@barrios-desktop>
	<20100713121947.612bd656.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTiny7dz8ssDknI7y4JFcVP9SV1aNM7f0YMUxafv7@mail.gmail.com>
	<20100713132312.a7dfb100.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTinVwmo5pemz86nXaQT3V_ujaPLOsyNeQIFhL0Vu@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux@arm.linux.org.uk, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, Yakui Zhao <yakui.zhao@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arm-kernel@lists.infradead.org, kgene.kim@samsung.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jul 2010 15:04:00 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> >> > A 2. This can't be help for a case where a section has multiple small holes.
> >>
> >> I agree. But this(not punched hole but not filled section problem)
> >> isn't such case. But it would be better to handle it altogether. :)
> >>
> >> >
> >> > Then, my proposal for HOLES_IN_MEMMAP sparsemem is below.
> >> > ==
> >> > Some architectures unmap memmap[] for memory holes even with SPARSEMEM.
> >> > To handle that, pfn_valid() should check there are really memmap or not.
> >> > For that purpose, __get_user() can be used.
> >>
> >> Look at free_unused_memmap. We don't unmap pte of hole memmap.
> >> Is __get_use effective, still?
> >>
> > __get_user() works with TLB and page table, the vaddr is really mapped or not.
> > If you got SEGV, __get_user() returns -EFAULT. It works per page granule.
> 
> I mean following as.
> For example, there is a struct page in on 0x20000000.
> 
> int pfn_valid_mapped(unsigned long pfn)
> {
>        struct page *page = pfn_to_page(pfn); /* hole page is 0x2000000 */
>        char *lastbyte = (char *)(page+1)-1;  /* lastbyte is 0x2000001f */
>        char byte;
> 
>        /* We pass this test since free_unused_memmap doesn't unmap pte */
>        if(__get_user(byte, page) != 0)				
>                return 0;

why ? When the page size is 4096 byte.

      0x1ffff000 - 0x1ffffffff
      0x20000000 - 0x200000fff are on the same page. And memory is mapped per page.

What we access by above __get_user() is a byte at [0x20000000, 0x20000001)
and it's unmapped if 0x20000000 is unmapped.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
