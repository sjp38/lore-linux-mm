Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id CA2276B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 19:08:07 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id v128so147950qkh.1
        for <linux-mm@kvack.org>; Mon, 23 May 2016 16:08:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r95si29200835qkr.150.2016.05.23.16.08.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 16:08:06 -0700 (PDT)
Date: Tue, 24 May 2016 01:08:00 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/3] mm, thp: make swapin readahead under down_read of
 mmap_sem
Message-ID: <20160523230800.GC20829@redhat.com>
References: <1464023651-19420-1-git-send-email-ebru.akagunduz@gmail.com>
 <1464023651-19420-4-git-send-email-ebru.akagunduz@gmail.com>
 <20160523184246.GE32715@dhcp22.suse.cz>
 <1464029349.16365.58.camel@redhat.com>
 <20160523190154.GA79357@black.fi.intel.com>
 <1464031607.16365.60.camel@redhat.com>
 <20160523200244.GA4289@node.shutemov.name>
 <1464034383.16365.70.camel@redhat.com>
 <20160523214942.GA79646@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160523214942.GA79646@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, hughd@google.com, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, boaz@plexistor.com

On Tue, May 24, 2016 at 12:49:42AM +0300, Kirill A. Shutemov wrote:
> That's what we do now and that's not enough.
> 
> We would need to serialize against pmd_lock() during normal page-fault
> path (and other pte manipulation), which we don't do now if pmd points to
> page table.

Yes, mmap_sem for writing while converting the pmd to a
pmd_trans_huge() in khugepaged, is so that the pagetable walk doesn't
require the pmd_lock after holding the mmap_sem for reading if the pmd
is found !pmd_trans_unstable, i.e. if the pmd points to a pte.

This way the non-THP pte walk retains the identical cost it has with
THP not compiled into the kernel (even when THP is enabled).

khugepaged already starts by doing work with the mmap_sem for reading,
then while holding the mmap_sem for reading if khugepaged_scan_pmd()
finds a candidate pmd to collapse into a pmd_trans_huge(), it calls
collapse_huge_page which at some point releases the mmap_sem for
reading (before the THP memory allocation) and takes it again for
writing if the allocation succeeded and we can go ahead with the
atomic THP collapse (under mmap_sem for writing and under the anon_vma
lock for writing too to serialize against split_huge_page which can be
called on the physical page and doesn't hold any mmap_sem but just
finds the pagetables through a rmap walk). The atomic part is all non
blocking.

The swapin loop can run under the mmap_sem for reading if it does the
proper check to revalidate the vma, but it should move above the below
comment.

	/*
	 * Prevent all access to pagetables with the exception of
	 * gup_fast later hanlded by the ptep_clear_flush and the VM
	 * handled by the anon_vma lock + PG_lock.
	 */
	down_write(&mm->mmap_sem);

Which is more or less what the last patch was doing except by keeping
the comment above the swapin stage, it made the comment wrong, as the
comment was then followed by a down_read.

Aside from the comment being wrong (which is not a kernel crashing
issue), the real problem was lack of revalidates after releasing the
mmap_sem and this revalidate attempt is also not correct:

+                       vma = find_vma(mm, address);
+                       /* vma is no longer available, don't continue to swapin */
+                       if (vma != vma_orig)
+                               return false;

Because the mmap_sem was temporarily dropped, the vma may have been
freed and reallocated at the same address, but it may be a completely
different vma with different vm_start/end values or it may not be
anonymous or mremap may have altered the vm_start/end too or the "mm"
may have exited in the meanwhile.

collapse_huge_page already shows how to correctly to revalidate the
vma after dropping the mmap_sem temporarily:

	down_write(&mm->mmap_sem);
	if (unlikely(khugepaged_test_exit(mm))) {
		result = SCAN_ANY_PROCESS;
		goto out;
	}

	vma = find_vma(mm, address);
	if (!vma) {
		result = SCAN_VMA_NULL;
		goto out;
	}
	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
	hend = vma->vm_end & HPAGE_PMD_MASK;
	if (address < hstart || address + HPAGE_PMD_SIZE > hend) {
		result = SCAN_ADDRESS_RANGE;
		goto out;
	}
	if (!hugepage_vma_check(vma)) {
		result = SCAN_VMA_CHECK;
		goto out;
	}

All checks above are needed for a correct revalidate, otherwise the
above code could also have been replaced by a vma != vma_orig.

If we move this swapin stage before the comment and after the THP
allocation succeeded, and we do enough revalidates correctly (which
are currently missing or incorrect, and find_vma is not enough for a
revalidate, find_vma only says there's some random vma with vm_end >
address), it should then work ok under only the mmap_sem for
reading.

Overall the last patch goes in the right direction just it needs to do
all revalidates right and to move the swapin stage a bit more up to
avoid invalidating the comment I think.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
