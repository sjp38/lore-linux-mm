Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0FBDC9003C8
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 18:49:03 -0400 (EDT)
Received: by pacan13 with SMTP id an13so147155807pac.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 15:49:02 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id qn16si6859959pab.174.2015.07.22.15.49.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 15:49:02 -0700 (PDT)
Received: by padck2 with SMTP id ck2so145089845pad.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 15:49:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1507221436350.21468@chino.kir.corp.google.com>
References: <1437585214-22481-1-git-send-email-catalin.marinas@arm.com> <alpine.DEB.2.10.1507221436350.21468@chino.kir.corp.google.com>
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Wed, 22 Jul 2015 23:48:42 +0100
Message-ID: <CAHkRjk7=VMG63VfZdWbZqYu8FOa9M+54Mmdro661E2zt3WToog@mail.gmail.com>
Subject: Re: [PATCH] mm: Flush the TLB for a single address in a huge page
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

On 22 July 2015 at 22:39, David Rientjes <rientjes@google.com> wrote:
> On Wed, 22 Jul 2015, Catalin Marinas wrote:
>
>> When the page table entry is a huge page (and not a table), there is no
>> need to flush the TLB by range. This patch changes flush_tlb_range() to
>> flush_tlb_page() in functions where we know the pmd entry is a huge
>> page.
>>
>> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> ---
>>
>> Hi,
>>
>> That's just a minor improvement but it saves iterating over each small
>> page in a huge page when a single TLB entry is used (we already have a
>> similar assumption in __tlb_adjust_range).
>
> For x86 smp, this seems to mean the difference between unconditional
> flush_tlb_page() and local_flush_tlb() due to
> tlb_single_page_flush_ceiling, so I don't think this just removes the
> iteration.

You are right, on x86 the tlb_single_page_flush_ceiling seems to be
33, so for an HPAGE_SIZE range the code does a local_flush_tlb()
always. I would say a single page TLB flush is more efficient than a
whole TLB flush but I'm not familiar enough with x86.

Alternatively, I could introduce a flush_tlb_pmd_huge_page (suggested
by Andrea separately) and let the architectures deal with this as they
see fit. The default definition would do a flush_tlb_range(vma,
address, address + HPAGE_SIZE). For arm64, I'll define it as
flush_tlb_page(vma, address).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
