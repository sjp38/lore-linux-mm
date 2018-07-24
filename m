Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0A94E6B0003
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 18:36:39 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e19-v6so3386006pgv.11
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 15:36:39 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u4-v6si11582015pgu.546.2018.07.24.15.36.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 15:36:37 -0700 (PDT)
Date: Tue, 24 Jul 2018 15:36:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] mm: Change return type int to vm_fault_t for fault
 handlers
Message-Id: <20180724153621.e7eed7faa1d265eee73a7031@linux-foundation.org>
In-Reply-To: <20180604171727.GA20279@jordon-HP-15-Notebook-PC>
References: <20180604171727.GA20279@jordon-HP-15-Notebook-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: willy@infradead.org, viro@zeniv.linux.org.uk, hughd@google.com, mhocko@suse.com, ross.zwisler@linux.intel.com, zi.yan@cs.rutgers.edu, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, gregkh@linuxfoundation.org, mark.rutland@arm.com, riel@redhat.com, pasha.tatashin@oracle.com, jschoenh@amazon.de, kstewart@linuxfoundation.org, rientjes@google.com, tglx@linutronix.de, peterz@infradead.org, mgorman@suse.de, yang.s@alibaba-inc.com, minchan@kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 4 Jun 2018 22:47:27 +0530 Souptick Joarder <jrdr.linux@gmail.com> wrote:

> Use new return type vm_fault_t for fault handler. For
> now, this is just documenting that the function returns
> a VM_FAULT value rather than an errno. Once all instances
> are converted, vm_fault_t will become a distinct type.
> 
> Ref-> commit 1c8f422059ae ("mm: change return type to vm_fault_t")
> 
> The aim is to change the return type of finish_fault()
> and handle_mm_fault() to vm_fault_t type. As part of
> that clean up return type of all other recursively called
> functions have been changed to vm_fault_t type.
> 
> The places from where handle_mm_fault() is getting invoked
> will be change to vm_fault_t type but in a separate patch.
> 
> vmf_error() is the newly introduce inline function
> in 4.17-rc6.

Looks OK.

For some reason the shmem.c changes are already present.

One incidental fixup:

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-change-return-type-int-to-vm_fault_t-for-fault-handlers-fix

don't shadow outer local `ret' in __do_huge_pmd_anonymous_page()

--- a/mm/huge_memory.c~mm-change-return-type-int-to-vm_fault_t-for-fault-handlers-fix
+++ a/mm/huge_memory.c
@@ -584,15 +584,15 @@ static vm_fault_t __do_huge_pmd_anonymou
 
 		/* Deliver the page fault to userland */
 		if (userfaultfd_missing(vma)) {
-			vm_fault_t ret;
+			vm_fault_t ret2;
 
 			spin_unlock(vmf->ptl);
 			mem_cgroup_cancel_charge(page, memcg, true);
 			put_page(page);
 			pte_free(vma->vm_mm, pgtable);
-			ret = handle_userfault(vmf, VM_UFFD_MISSING);
-			VM_BUG_ON(ret & VM_FAULT_FALLBACK);
-			return ret;
+			ret2 = handle_userfault(vmf, VM_UFFD_MISSING);
+			VM_BUG_ON(ret2 & VM_FAULT_FALLBACK);
+			return ret2;
 		}
 
 		entry = mk_huge_pmd(page, vma->vm_page_prot);
