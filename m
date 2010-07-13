Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3ABD96B02A7
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 04:08:33 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6D88VEI008501
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 13 Jul 2010 17:08:31 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F2E1345DE55
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 17:08:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C5B7E45DE4F
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 17:08:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A7DEE1DB8044
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 17:08:30 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4753A1DB803E
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 17:08:30 +0900 (JST)
Date: Tue, 13 Jul 2010 17:03:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Tight check of pfn_valid on sparsemem
Message-Id: <20100713170342.2e9e0b6b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTinxTojeckJpfLh9eMM4odK61-VzE2A0G9E3nRuQ@mail.gmail.com>
References: <20100712155348.GA2815@barrios-desktop>
	<20100713121947.612bd656.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTiny7dz8ssDknI7y4JFcVP9SV1aNM7f0YMUxafv7@mail.gmail.com>
	<20100713132312.a7dfb100.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTinVwmo5pemz86nXaQT3V_ujaPLOsyNeQIFhL0Vu@mail.gmail.com>
	<20100713154025.7c60c76b.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTinxTojeckJpfLh9eMM4odK61-VzE2A0G9E3nRuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux@arm.linux.org.uk, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, Yakui Zhao <yakui.zhao@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arm-kernel@lists.infradead.org, kgene.kim@samsung.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jul 2010 17:06:56 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Tue, Jul 13, 2010 at 3:40 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 13 Jul 2010 15:04:00 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> >
> >> >> > A 2. This can't be help for a case where a section has multiple small holes.
> >> >>
> >> >> I agree. But this(not punched hole but not filled section problem)
> >> >> isn't such case. But it would be better to handle it altogether. :)
> >> >>
> >> >> >
> >> >> > Then, my proposal for HOLES_IN_MEMMAP sparsemem is below.
> >> >> > ==
> >> >> > Some architectures unmap memmap[] for memory holes even with SPARSEMEM.
> >> >> > To handle that, pfn_valid() should check there are really memmap or not.
> >> >> > For that purpose, __get_user() can be used.
> >> >>
> >> >> Look at free_unused_memmap. We don't unmap pte of hole memmap.
> >> >> Is __get_use effective, still?
> >> >>
> >> > __get_user() works with TLB and page table, the vaddr is really mapped or not.
> >> > If you got SEGV, __get_user() returns -EFAULT. It works per page granule.
> >>
> >> I mean following as.
> >> For example, there is a struct page in on 0x20000000.
> >>
> >> int pfn_valid_mapped(unsigned long pfn)
> >> {
> >> A  A  A  A struct page *page = pfn_to_page(pfn); /* hole page is 0x2000000 */
> >> A  A  A  A char *lastbyte = (char *)(page+1)-1; A /* lastbyte is 0x2000001f */
> >> A  A  A  A char byte;
> >>
> >> A  A  A  A /* We pass this test since free_unused_memmap doesn't unmap pte */
> >> A  A  A  A if(__get_user(byte, page) != 0)
> >> A  A  A  A  A  A  A  A return 0;
> >
> > why ? When the page size is 4096 byte.
> >
> > A  A  A 0x1ffff000 - 0x1ffffffff
> > A  A  A 0x20000000 - 0x200000fff are on the same page. And memory is mapped per page.
> 
> sizeof(struct page) is 32 byte.
> So lastbyte is address of struct page + 32 byte - 1.
> 
> > What we access by above __get_user() is a byte at [0x20000000, 0x20000001)
> 
> Right.
> 
> > and it's unmapped if 0x20000000 is unmapped.
> 
> free_unused_memmap doesn't unmap pte although it returns the page to
> free list of buddy.
> 
ok, I understood. please see my latest mail and ignore all others.

-kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
