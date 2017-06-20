Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C8E06B0279
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 17:08:35 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 77so11256751wrb.11
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 14:08:35 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 7si15600359wrc.13.2017.06.20.14.08.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 14:08:33 -0700 (PDT)
Date: Tue, 20 Jun 2017 14:08:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 0/8] Support for contiguous pte hugepages
Message-Id: <20170620140831.6bd835649d475bcf30c3c434@linux-foundation.org>
In-Reply-To: <871sqezsk2.fsf@e105922-lin.cambridge.arm.com>
References: <20170619170145.25577-1-punit.agrawal@arm.com>
	<20170619150133.cb4173220e4e3abd02c6f6d0@linux-foundation.org>
	<871sqezsk2.fsf@e105922-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com, steve.capper@arm.com, mark.rutland@arm.com, linux-arch@vger.kernel.org, aneesh.kumar@linux.vnet.ibm.com

On Tue, 20 Jun 2017 14:39:57 +0100 Punit Agrawal <punit.agrawal@arm.com> wrote:

> 
> The architecture supports two flavours of hugepages -
> 
> * Block mappings at the pud/pmd level
> 
>   These are regular hugepages where a pmd or a pud page table entry
>   points to a block of memory. Depending on the PAGE_SIZE in use the
>   following size of block mappings are supported -
> 
>           PMD	PUD
>           ---	---
>   4K:      2M	 1G
>   16K:    32M
>   64K:   512M
> 
>   For certain applications/usecases such as HPC and large enterprise
>   workloads, folks are using 64k page size but the minimum hugepage size
>   of 512MB isn't very practical.
> 
> To overcome this ...
> 
> * Using the Contiguous bit
> 
>   The architecture provides a contiguous bit in the translation table
>   entry which acts as a hint to the mmu to indicate that it is one of a
>   contiguous set of entries that can be cached in a single TLB entry.
> 
>   We use the contiguous bit in Linux to increase the mapping size at the
>   pmd and pte (last) level.
> 
>   The number of supported contiguous entries varies by page size and
>   level of the page table.
> 
>   Using the contiguous bit allows additional hugepage sizes -
> 
>            CONT PTE    PMD    CONT PMD    PUD
>            --------    ---    --------    ---
>     4K:         64K     2M         32M     1G
>     16K:         2M    32M          1G
>     64K:         2M   512M         16G
> 
>   Of these, 64K with 4K and 2M with 64K pages have been explicitly
>   requested by a few different users.
> 
> Entries with the contiguous bit set are required to be modified all
> together - which makes things like memory poisoning and migration
> impossible to do correctly without knowing the size of hugepage being
> dealt with - the reason for adding size parameter to a few of the
> hugepage helpers in this series.
> 

Thanks, I added the above to the 1/n changelog.  Perhaps it's worth
adding something like this to Documentation/vm/hugetlbpage.txt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
