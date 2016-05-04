Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 04C8C6B025E
	for <linux-mm@kvack.org>; Wed,  4 May 2016 10:17:09 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 4so106565425pfw.0
        for <linux-mm@kvack.org>; Wed, 04 May 2016 07:17:08 -0700 (PDT)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id s72si5049723pfs.86.2016.05.04.07.17.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 07:17:08 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: kmap_atomic and preemption
Date: Wed, 4 May 2016 14:16:11 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075F4EA065E@us01wembx1.internal.synopsys.com>
References: <5729D0F4.9090907@synopsys.com>
 <20160504134729.GP3430@twins.programming.kicks-ass.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, David Hildenbrand <dahi@linux.vnet.ibm.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Russell King <linux@arm.linux.org.uk>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

On Wednesday 04 May 2016 07:17 PM, Peter Zijlstra wrote:=0A=
> On Wed, May 04, 2016 at 04:07:40PM +0530, Vineet Gupta wrote:=0A=
>> Is preemption disabling a requirement of kmap_atomic() callers independe=
nt of=0A=
>> where page is or is it only needed when page is in highmem and can trigg=
er page=0A=
>> faults or TLB Misses between kmap_atomic() and kunmap_atomic and wants p=
rotection=0A=
>> against reschedules etc.=0A=
> Traditionally kmap_atomic() disables preemption; and the reason is that=
=0A=
> the returned pointer must stay valid. This had a side effect in that it=
=0A=
> also disabled pagefaults.=0A=
=0A=
But how could the ptr possibly get invalid. Say despite the disable calls, =
we=0A=
could actually take the page fault (or TLB Miss on ARC) - the pagefault_dis=
able()=0A=
only makes do_page_fault() do reduced handling vs. calling handle_mm_fault(=
) etc.=0A=
It is essentially restricting the fault handling to a kernel mode fixup onl=
y.=0A=
=0A=
Now if we didn't do disable, on ARC the semantics of do_page_fault() are st=
ill the=0A=
same - since the address would be for fixmap which is handled under "kernel=
" only=0A=
category as well.=0A=
=0A=
void do_page_fault(unsigned long address, struct pt_regs *regs)=0A=
{=0A=
=0A=
    if (address >=3D VMALLOC_START) {=0A=
        ret =3D handle_kernel_vaddr_fault(address);=0A=
        return;=0A=
...=0A=
    if (faulthandler_disabled() || !mm)=0A=
        goto no_context;=0A=
...=0A=
=0A=
> We've since de-coupled the pagefault from the preemption thing, so you=0A=
> could disable pagefaults while leaving preemption enabled.=0A=
=0A=
Right - I've seen that patch set from David H.=0A=
=0A=
> ...=0A=
>=0A=
> If you want a fast-slow path splt, you can easily do something like:=0A=
>=0A=
> static inline void *kmap_atomic(struct page *page)=0A=
> {=0A=
> 	preempt_disable();=0A=
> 	pagefault_disable();=0A=
> 	if (!PageHighMem(page))=0A=
> 		return page_address(page);=0A=
>=0A=
> 	return __kmap_atomic(page);=0A=
> }=0A=
=0A=
I actually want to return early for !PageHighMem and avoid the pointless 2=
=0A=
LD-ADD-ST to memory for map and 2 LD-SUB-ST for unmap for regular pages for=
 such=0A=
cases.=0A=
=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
