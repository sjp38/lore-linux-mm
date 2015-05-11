Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0A77A6B0070
	for <linux-mm@kvack.org>; Mon, 11 May 2015 02:34:03 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so102317801pac.0
        for <linux-mm@kvack.org>; Sun, 10 May 2015 23:34:02 -0700 (PDT)
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com. [202.81.31.143])
        by mx.google.com with ESMTPS id mk3si16712769pdb.222.2015.05.10.23.34.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Sun, 10 May 2015 23:34:02 -0700 (PDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 11 May 2015 16:33:56 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 594013578048
	for <linux-mm@kvack.org>; Mon, 11 May 2015 16:33:53 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4B6XiF238207670
	for <linux-mm@kvack.org>; Mon, 11 May 2015 16:33:52 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4B6XJaT008418
	for <linux-mm@kvack.org>; Mon, 11 May 2015 16:33:20 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V2 1/2] mm/thp: Split out pmd collpase flush into a seperate functions
In-Reply-To: <20150508152428.4326eaaae99b74fa53c96f23@linux-foundation.org>
References: <1430983408-24924-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20150508152428.4326eaaae99b74fa53c96f23@linux-foundation.org>
Date: Mon, 11 May 2015 12:02:52 +0530
Message-ID: <87wq0f4oa3.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mpe@ellerman.id.au, paulus@samba.org, benh@kernel.crashing.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Thu,  7 May 2015 12:53:27 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>
>> After this patch pmdp_* functions operate only on hugepage pte,
>> and not on regular pmd_t values pointing to page table.
>> 
>
> The patch looks like a pretty safe no-op for non-powerpc?

That is correct. I also updated the commit message

    mm/thp: Split out pmd collpase flush into a seperate functions
    
    Architectures like ppc64 [1] need to do special things while clearing
    pmd before a collapse. For them this operation is largely different
    from a normal hugepage pte clear. Hence add a separate function
    to clear pmd before collapse. After this patch pmdp_* functions
    operate only on hugepage pte, and not on regular pmd_t values
    pointing to page table.
    
    [1] ppc64 needs to invalidate all the normal page pte mappings we
    already have inserted in the hardware hash page table. But before
    doing that we need to make sure there are no parallel hash page
    table insert going on. So we need to do a kick_all_cpus_sync()
    before flushing the older hash table entries. By moving this to
    a separate function we capture these details and mention how it
    is different from a hugepage pte clear.


>
>> --- a/arch/powerpc/include/asm/pgtable-ppc64.h
>> +++ b/arch/powerpc/include/asm/pgtable-ppc64.h
>> @@ -576,6 +576,10 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm, unsigned long addr,
>>  extern void pmdp_splitting_flush(struct vm_area_struct *vma,
>>  				 unsigned long address, pmd_t *pmdp);
>>  
>> +#define __HAVE_ARCH_PMDP_COLLAPSE_FLUSH
>> +extern pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
>> +				 unsigned long address, pmd_t *pmdp);
>> +
>
> The fashionable way of doing this is
>
> extern pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
> 				 unsigned long address, pmd_t *pmdp);
> #define pmdp_collapse_flush pmdp_collapse_flush
>
> then, elsewhere,
>
> #ifndef pmdp_collapse_flush
> static inline pmd_t pmdp_collapse_flush(...) {}
> #define pmdp_collapse_flush pmdp_collapse_flush
> #endif
>
> It avoids introducing a second (ugly) symbol into the kernel.

Ok updated to the above style. The reason I used the earlier style was
because of similar usages in asm-generic/pgtable.h


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
