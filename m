Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 659B86B0007
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 03:37:25 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k27-v6so608388wre.23
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 00:37:25 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id f12-v6si375146edd.262.2018.04.27.00.37.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Apr 2018 00:37:21 -0700 (PDT)
Date: Fri, 27 Apr 2018 09:37:20 +0200
From: "joro@8bytes.org" <joro@8bytes.org>
Subject: Re: [PATCH v2 2/2] x86/mm: implement free pmd/pte page interfaces
Message-ID: <20180427073719.GT15462@8bytes.org>
References: <20180314180155.19492-1-toshi.kani@hpe.com>
 <20180314180155.19492-3-toshi.kani@hpe.com>
 <20180426141926.GN15462@8bytes.org>
 <1524759629.2693.465.camel@hpe.com>
 <20180426172327.GQ15462@8bytes.org>
 <1524764948.2693.478.camel@hpe.com>
 <20180426200737.GS15462@8bytes.org>
 <1524781764.2693.503.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1524781764.2693.503.camel@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshi" <toshi.kani@hpe.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "bp@suse.de" <bp@suse.de>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "willy@infradead.org" <willy@infradead.org>, "hpa@zytor.com" <hpa@zytor.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "Hocko, Michal" <MHocko@suse.com>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Thu, Apr 26, 2018 at 10:30:14PM +0000, Kani, Toshi wrote:
> Thanks for the clarification. After reading through SDM one more time, I
> agree that we need a TLB purge here. Here is my current understanding. 
> 
>  - INVLPG purges both TLB and paging-structure caches. So, PMD cache was
> purged once.
>  - However, processor may cache this PMD entry later in speculation
> since it has p-bit set. (This is where my misunderstanding was.
> Speculation is not allowed to access a target address, but it may still
> cache this PMD entry.)
>  - A single INVLPG on each processor purges this PMD cache. It does not
> need a range purge (which was already done).
> 
> Does it sound right to you?

The right fix is to first synchronize the changes when the PMD/PUD is
cleared and then flush the TLB system-wide. After that is done you can
free the page.

But doing all that in the pud/pmd_free_pmd/pte_page() functions is too
expensive, as the TLB flush requires to send IPIs to all cores in the
system, and that every time the function is called.

So what needs to be done is to fix this from high-level ioremap code to
first unmap all required PTE/PMD pages and collect them in a list. When
that is done you can synchronize the changes with the other page-tables
in the system and do one system-wide TLB flush. When that is complete
you can free the pages on the list that were collected while unmapping.

Then the new mappings can be established and again synchronized with the
other page-tables in the system.

> As for the BUG_ON issue, are you able to reproduce this issue?  If so,
> would you be able to test the fix?

Yes, I can reproduce the BUG_ON with my PTI patches and a fedora-i386
VM.

I already ran into the issue before your patches were merged upstream,
but my "fix" is different because it just prevents huge-mappings when
there were smaller mappings before. See

	e3e288121408 x86/pgtable: Don't set huge PUD/PMD on non-leaf entries

for details. This patch does not fix the base-problem, but hides it
again, as the real fix needs some more work across architectures.

Your patch actually makes the problem worse, without it the PTE/PMD pages
were just leaked, so that they could not be reused. But with your patch
the pages can be used again and the page-walker might establish TLB
entries based on random content the new owner writes to it. This can
lead to all kinds of random and very hard to debug data corruption
issues.

So until we make the generic ioremap code in lib/ioremap.c smarter about
unmapping/remapping ranges the best solution is making my fix work again
by reverting your patch.


Thanks,

	Joerg
