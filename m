Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id CAA09974
	for <linux-mm@kvack.org>; Sun, 2 Feb 2003 02:56:32 -0800 (PST)
Date: Sun, 2 Feb 2003 02:56:39 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: hugepage patches
Message-Id: <20030202025639.6a984730.akpm@digeo.com>
In-Reply-To: <20030131151501.7273a9bf.akpm@digeo.com>
References: <20030131151501.7273a9bf.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: davem@redhat.com, rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

10/4

Fix hugetlbfs faults


If the underlying mapping was truncated and someone references the
now-unmapped memory the kernel will enter handle_mm_fault() and will start
instantiating PAGE_SIZE pte's inside the hugepage VMA.  Everything goes
generally pear-shaped.

So trap this in handle_mm_fault().  It adds no overhead to non-hugepage
builds.

Another possible fix would be to not unmap the huge pages at all in truncate
- just anonymise them.

But I think we want full ftruncate semantics for hugepages for management
purposes.


 i386/mm/fault.c |    0 
 memory.c        |    4 ++++
 2 files changed, 4 insertions(+)

diff -puN arch/i386/mm/fault.c~hugetlbfs-fault-fix arch/i386/mm/fault.c
diff -puN mm/memory.c~hugetlbfs-fault-fix mm/memory.c
--- 25/mm/memory.c~hugetlbfs-fault-fix	2003-02-01 22:46:48.000000000 -0800
+++ 25-akpm/mm/memory.c	2003-02-01 22:46:48.000000000 -0800
@@ -1447,6 +1447,10 @@ int handle_mm_fault(struct mm_struct *mm
 	pgd = pgd_offset(mm, address);
 
 	inc_page_state(pgfault);
+
+	if (is_vm_hugetlb_page(vma))
+		return VM_FAULT_SIGBUS;	/* mapping truncation does this. */
+
 	/*
 	 * We need the page table lock to synchronize with kswapd
 	 * and the SMP-safe atomic PTE updates.

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
