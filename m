Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id F366F6B0005
	for <linux-mm@kvack.org>; Thu,  5 May 2016 08:37:23 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b203so165083503pfb.1
        for <linux-mm@kvack.org>; Thu, 05 May 2016 05:37:23 -0700 (PDT)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id hu12si11219646pac.157.2016.05.05.05.37.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 05:37:22 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: kmap_atomic and preemption
Date: Thu, 5 May 2016 12:37:17 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075F4EA086B@us01wembx1.internal.synopsys.com>
References: <5729D0F4.9090907@synopsys.com>
 <20160504134729.GP3430@twins.programming.kicks-ass.net>
 <C2D7FE5348E1B147BCA15975FBA23075F4EA065E@us01wembx1.internal.synopsys.com>
 <20160504150138.GR3430@twins.programming.kicks-ass.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, David Hildenbrand <dahi@linux.vnet.ibm.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Russell King <linux@arm.linux.org.uk>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

On Wednesday 04 May 2016 08:31 PM, Peter Zijlstra wrote:=0A=
> So I'm fairly sure people rely on the fact you cannot have pagefault=0A=
> inside a kmap_atomic().=0A=
=0A=
So this translates to: any hardware page faults inside kmap_atomic() can't =
lead to=0A=
do_page_fault() taking a lock - those can only be ex_table fixups, yes ?=0A=
Could you please also help explain your earlier comment about kmap_atomic n=
eeding=0A=
to disable preemption so that "returned pointer stayed valid". I can't quit=
e=0A=
fathom how that can happen=0A=
=0A=
> But you could potentially get away with leaving preemption enabled. Give=
=0A=
> it a try, see if something goes *bang* ;-)=0A=
=0A=
So tried patch further below: on a quad core slowish FPGA setup, concurrent=
=0A=
hackbench and LMBench seem to run w/o issues  - so it is not obviously brok=
en even=0A=
if not proven otherwise. But the point is highmem page is a slow path anywa=
ys -=0A=
needs a PTE update, new TLB entry etc. I hoped to not wiggle even a single =
cache=0A=
line for the low page - but seems like that is not possible.=0A=
=0A=
OTOH, if we do keep the status quo - then making these 2 cache lines into 1=
 is not=0A=
possible either. From reading the orig "decoupling of prremption and page f=
ault"=0A=
thread it seems to be because preempt count is per cpu on x86.=0A=
=0A=
@@ -67,7 +67,6 @@ void *kmap_atomic(struct page *page)=0A=
        int idx, cpu_idx;=0A=
        unsigned long vaddr;=0A=
 =0A=
-       preempt_disable();=0A=
        pagefault_disable();=0A=
        if (!PageHighMem(page))=0A=
                return page_address(page);=0A=
@@ -107,7 +106,6 @@ void __kunmap_atomic(void *kv)=0A=
        }=0A=
 =0A=
        pagefault_enable();=0A=
-       preempt_enable();=0A=
 }=0A=
=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
