Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BEEAB6B02C6
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 11:47:52 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t23so13931466pfe.17
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 08:47:52 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y71si15659374pgd.130.2017.04.24.08.47.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 08:47:52 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3OFhq1A113278
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 11:47:51 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a0mgfs4p0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 11:47:51 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 24 Apr 2017 16:47:48 +0100
Subject: Re: [RFC 4/4] Change mmap_sem to range lock
References: <cover.1492595897.git.ldufour@linux.vnet.ibm.com>
 <1492698500-24219-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <8737d2d52e.fsf@firstfloor.org>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Mon, 24 Apr 2017 17:47:43 +0200
MIME-Version: 1.0
In-Reply-To: <8737d2d52e.fsf@firstfloor.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <13a115b6-2f75-e399-265e-2e6c73c09e9a@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, Paul.McKenney@us.ibm.com, linux-kernel@vger.kernel.org

On 21/04/2017 01:36, Andi Kleen wrote:
> Laurent Dufour <ldufour@linux.vnet.ibm.com> writes:
> 
>> [resent this patch which seems to have not reached the mailing lists]
>>
>> Change the mmap_sem to a range lock to allow finer grain locking on
>> the memory layout of a task.
>>
>> This patch rename mmap_sem into mmap_rw_tree to avoid confusion and
>> replace any locking (read or write) by complete range locking.  So
>> there is no functional change except in the way the underlying locking
>> is achieved.
>>
>> Currently, this patch only supports x86 and PowerPc architectures,
>> furthermore it should break the build of any others.
> 
> Thanks for working on this.
> 
> However as commented before I think the first step to make progress here
> is a description of everything mmap_sem protects.

Hi Andy,

I looked for the write mmap_sem locking in x86 and ppc64 architectures,
here is what I found:

mmap_sem protects
 vdso mapping
 VMA layout changes
 VMA cache
 Page protection/layout
 Changes to mmu notifier chain
 mmap_sem is used to serialize khugepaged's access
 mmap_sem is used to serialize ksm's access
 protection keys (pkey_alloc()...)

Calls to
 get_unmap_area()
 do_mmap()
 do_mmap_pgoff()
 do_munmap()
 get_user_pages()
 put_page()
 set_page_dirty_lock()
 find_vma()
 find_vma_intersection()
 alloc_empty_pages()
 insert_vm_struct()
 get_mm_rss()
 uprobe_consumer->filter() (currently only uprobe_perf_filter())
 _install_special_mapping()
 pmdp_collapse_flush()
 do_swap_page()
 do_brk()
 __split_vma()
 mremap_to()
 vma_to_resize()
 vma_adjust()

MM fields
   pinned_vm
   stack_vm
   total_vm
   locked_vm
   start_stack
   start_code
   end_code
   start_data
   start_brk
   bd_addr
   mm_users
   core_state
   context.vdso_*
   def_flags
   mmu_notifier_mm

VMA fields
    vm_private_data
    vm_flags
    vm_page_prot
    vm_file
    vm_pgoff
    vm_policy


Userfaultfd has not been looked in details yet.
dup_mmap() locks the oldmm in write mode when copying it, is it necessary ?

> Surely the init full case could be done shorter with some wrapper
> that combines the init_full and lock operation?

Yes that doable, I wrote this like that, because the range should be
initialized based on the on going operation, so having an explicit init
operation is making this more explicit.

> Then it would be likely a simple search'n'replace to move the
> whole tree in one atomic step to the new wrappers.
> Initially they could be just defined to use rwsems too to
> not change anything at all.
> 
> It would be a good idea to merge such a patch as quickly
> as possible beause it will be a nightmare to maintain
> longer term.
> 
> Then you could add a config to use a range lock through
> the wrappers.

I agree, I should try a way to make that patch activated through a
CONFIG_value, but there is a the additional range value that make it
more complex to achieve. I'll try to figure out a way to do that.

> Then after that you could add real ranges step by step,
> after doing the proper analysis.

That's the biggest part of the job.
I'm also wondering if a dedicated lock/sem should be introduced to
protect the VMA cache and the VMA list, since the range itself will not
protect against change while walking the VMA list.

Please advise.

Cheers,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
