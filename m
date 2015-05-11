Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 034E66B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 02:30:37 -0400 (EDT)
Received: by pdea3 with SMTP id a3so140367797pde.3
        for <linux-mm@kvack.org>; Sun, 10 May 2015 23:30:36 -0700 (PDT)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [122.248.162.1])
        by mx.google.com with ESMTPS id es10si16724557pac.102.2015.05.10.23.30.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Sun, 10 May 2015 23:30:35 -0700 (PDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 11 May 2015 12:00:31 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 504FF125805C
	for <linux-mm@kvack.org>; Mon, 11 May 2015 12:02:38 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4B6UMo416842880
	for <linux-mm@kvack.org>; Mon, 11 May 2015 12:00:23 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4B6ULLO013348
	for <linux-mm@kvack.org>; Mon, 11 May 2015 12:00:22 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V2 2/2] powerpc/thp: Serialize pmd clear against a linux page table walk.
In-Reply-To: <20150508152149.7fd52bb4b7c2a0911c33be00@linux-foundation.org>
References: <1430983408-24924-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1430983408-24924-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20150508152149.7fd52bb4b7c2a0911c33be00@linux-foundation.org>
Date: Mon, 11 May 2015 12:00:18 +0530
Message-ID: <87zj5b4oed.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mpe@ellerman.id.au, paulus@samba.org, benh@kernel.crashing.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Thu,  7 May 2015 12:53:28 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>
>> Serialize against find_linux_pte_or_hugepte which does lock-less
>> lookup in page tables with local interrupts disabled. For huge pages
>> it casts pmd_t to pte_t. Since format of pte_t is different from
>> pmd_t we want to prevent transit from pmd pointing to page table
>> to pmd pointing to huge page (and back) while interrupts are disabled.
>> We clear pmd to possibly replace it with page table pointer in
>> different code paths. So make sure we wait for the parallel
>> find_linux_pte_or_hugepage to finish.
>
> I'm not seeing here any description of the problem which is being
> fixed.  Does the patch make the machine faster?  Does the machine
> crash?

I sent v3 with updated commit message. Adding that below.

    powerpc/thp: Serialize pmd clear against a linux page table walk.
    
    Serialize against find_linux_pte_or_hugepte which does lock-less
    lookup in page tables with local interrupts disabled. For huge pages
    it casts pmd_t to pte_t. Since format of pte_t is different from
    pmd_t we want to prevent transit from pmd pointing to page table
    to pmd pointing to huge page (and back) while interrupts are disabled.
    We clear pmd to possibly replace it with page table pointer in
    different code paths. So make sure we wait for the parallel
    find_linux_pte_or_hugepage to finish.
    
    Without this patch, a find_linux_pte_or_hugepte running in parallel to
    __split_huge_zero_page_pmd or do_huge_pmd_wp_page_fallback or zap_huge_pmd
    can run into the above issue. With __split_huge_zero_page_pmd and
    do_huge_pmd_wp_page_fallback we clear the hugepage pte before inserting
    the pmd entry with a regular pgtable address. Such a clear need to
    wait for the parallel find_linux_pte_or_hugepte to finish.
    
    With zap_huge_pmd, we can run into issues, with a hugepage pte
    getting zapped due to a MADV_DONTNEED while other cpu fault it
    in as small pages.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
