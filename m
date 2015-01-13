Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C6FF96B006C
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 16:49:15 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so6093585pab.2
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 13:49:15 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id n7si28231614pdj.247.2015.01.13.13.49.13
        for <linux-mm@kvack.org>;
        Tue, 13 Jan 2015 13:49:14 -0800 (PST)
Message-ID: <54B592D6.4090406@linux.intel.com>
Date: Tue, 13 Jan 2015 13:49:10 -0800
From: Dave Hansen <dave.hansen@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: rename mm->nr_ptes to mm->nr_pgtables
References: <1421176456-21796-1-git-send-email-kirill.shutemov@linux.intel.com> <1421176456-21796-2-git-send-email-kirill.shutemov@linux.intel.com> <20150113214355.GC2253@moon>
In-Reply-To: <20150113214355.GC2253@moon>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 01/13/2015 01:43 PM, Cyrill Gorcunov wrote:
> On Tue, Jan 13, 2015 at 09:14:15PM +0200, Kirill A. Shutemov wrote:
>> We're going to account pmd page tables too. Let's rename mm->nr_pgtables
>> to something more generic.
>>
>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> --- a/fs/proc/task_mmu.c
>> +++ b/fs/proc/task_mmu.c
>> @@ -64,7 +64,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
>>  		data << (PAGE_SHIFT-10),
>>  		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
>>  		(PTRS_PER_PTE * sizeof(pte_t) *
>> -		 atomic_long_read(&mm->nr_ptes)) >> 10,
>> +		 atomic_long_read(&mm->nr_pgtables)) >> 10,
> 
> This implies that (PTRS_PER_PTE * sizeof(pte_t)) = (PTRS_PER_PMD * sizeof(pmd_t))
> which might be true for all archs, right?

I wonder if powerpc is OK on this front today.  This diagram:

	http://linux-mm.org/PageTableStructure

says that they use a 128-byte "pte" table when mapping 16M pages.  I
wonder if they bump mm->nr_ptes for these.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
