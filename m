Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6160F6B02A3
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 18:13:27 -0500 (EST)
Received: by mail-io0-f177.google.com with SMTP id l127so90896269iof.3
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 15:13:27 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id g5si8469254igg.12.2016.02.18.15.13.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 15:13:26 -0800 (PST)
Date: Fri, 19 Feb 2016 10:13:19 +1100
From: Paul Mackerras <paulus@ozlabs.org>
Subject: Re: [PATCH V3 00/30] Book3s abstraction in preparation for new MMU
 model
Message-ID: <20160218231319.GB2765@fergus.ozlabs.ibm.com>
References: <1455814254-10226-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1455814254-10226-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu, Feb 18, 2016 at 10:20:24PM +0530, Aneesh Kumar K.V wrote:
> Hello,
> 
> This is a large series, mostly consisting of code movement. No new features
> are done in this series. The changes are done to accomodate the upcoming new memory
> model in future powerpc chips. The details of the new MMU model can be found at
> 
>  http://ibm.biz/power-isa3 (Needs registration). I am including a summary of the changes below.

This doesn't apply against Linus' current tree - have you already
posted the prerequisite patches?  If so, what's the subject of the
0/N patch of the prerequisite series?

> ISA 3.0 adds support for the radix tree style of MMU with full
> virtualization and related control mechanisms that manage its
> coexistence with the HPT. Radix-using operating systems will
> manage their own translation tables instead of relying on hcalls.
> 
> Radix style MMU model requires us to do a 4 level page table
> with 64K and 4K page size. The table index size different page size
> is listed below
> 
> PGD -> 13 bits
> PUD -> 9 (1G hugepage)
> PMD -> 9 (2M huge page)
> PTE -> 5 (for 64k), 9 (for 4k)
> 
> We also require the page table to be in big endian format.
> 
> The changes proposed in this series enables us to support both
> hash page table and radix tree style MMU using a single kernel
> with limited impact. The idea is to change core page table
> accessors to static inline functions and later hotpatch them
> to switch to hash or radix tree functions. For ex:
> 
> static inline int pte_write(pte_t pte)
> {
>        if (radix_enabled())
>                return rpte_write(pte);
>         return hlpte_write(pte);
> }

Given that with a hash-based MMU, the Linux page tables are purely a
software construct, I don't see why this complexity is necessary.  We
can make the PTE have the same format on radix and hash instead.  I
have a patch series that does that almost ready to post.

> On boot we will hotpatch the code so as to avoid conditional operation.
> 
> The other two major change propsed in this series is to switch hash
> linux page table to a 4 level table in big endian format. This is
> done so that functions like pte_val(), pud_populate() doesn't need
> hotpatching and thereby helps in limiting runtime impact of the changes.

Right, I agree with this.

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
