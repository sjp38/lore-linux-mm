Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id ACE066B0005
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 08:22:25 -0500 (EST)
Received: by mail-qg0-f47.google.com with SMTP id b35so139446849qge.0
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 05:22:25 -0800 (PST)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id c65si35736583qgc.16.2016.02.09.05.22.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Feb 2016 05:22:24 -0800 (PST)
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 9 Feb 2016 06:22:24 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 24B4D1FF0045
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 06:10:32 -0700 (MST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08027.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u19DMMBK30474436
	for <linux-mm@kvack.org>; Tue, 9 Feb 2016 06:22:22 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u19DMKcf031698
	for <linux-mm@kvack.org>; Tue, 9 Feb 2016 06:22:21 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V2 00/29] Book3s abstraction in preparation for new MMU model
In-Reply-To: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Date: Tue, 09 Feb 2016 18:52:14 +0530
Message-ID: <87zivaxbll.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, Scott Wood <scottwood@freescale.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org



Hi Scott,

I missed adding you on CC:, Can you take a look at this and make sure we
are not breaking anything on freescale.

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:

> Hello,
>
> This is a large series, mostly consisting of code movement. No new features
> are done in this series. The changes are done to accomodate the upcoming new memory
> model in future powerpc chips. The details of the new MMU model can be found at
>
>  http://ibm.biz/power-isa3 (Needs registration). I am including a summary of the changes below.
>
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
>
> On boot we will hotpatch the code so as to avoid conditional operation.
>
> The other two major change propsed in this series is to switch hash
> linux page table to a 4 level table in big endian format. This is
> done so that functions like pte_val(), pud_populate() doesn't need
> hotpatching and thereby helps in limiting runtime impact of the changes.
>
> I didn't included the radix related changes in this series. You can
> find them at https://github.com/kvaneesh/linux/commits/radix-mmu-v1
>
> Changes from V1:
> * move patches adding helpers to the next series
>


Thanks
-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
