Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id CAA10010
	for <linux-mm@kvack.org>; Sun, 2 Feb 2003 02:57:15 -0800 (PST)
Date: Sun, 2 Feb 2003 02:57:22 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: hugepage patches
Message-Id: <20030202025722.67970001.akpm@digeo.com>
In-Reply-To: <20030131151501.7273a9bf.akpm@digeo.com>
References: <20030131151501.7273a9bf.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: davem@redhat.com, rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

13/4

hugetlb mremap fix

If you attempt tp perform a relocating 4k-aligned mremap and the new address
for the map lands on top of a hugepage VMA, do_mremap() will attempt to
perform a 4k-aligned unmap inside the hugetlb VMA.  The hugetlb layer goes
BUG.

Fix that by trapping the poorly-aligned unmap attempt in do_munmap(). 
do_remap() will then fall through without having done anything to the place
where it tests for a hugetlb VMA.

It would be neater to perform these checks on entry to do_mremap(), but that
would incur another VMA lookup.

Also, if you attempt to perform a 4k-aligned and/or sized munmap() inside a
hugepage VMA the same BUG happens.  This patch fixes that too.


 mmap.c |    5 +++++
 1 files changed, 5 insertions(+)

diff -puN mm/mmap.c~hugetlb-mremap-fix mm/mmap.c
--- 25/mm/mmap.c~hugetlb-mremap-fix	2003-02-02 02:53:56.000000000 -0800
+++ 25-akpm/mm/mmap.c	2003-02-02 02:53:56.000000000 -0800
@@ -1227,6 +1227,11 @@ int do_munmap(struct mm_struct *mm, unsi
 		return 0;
 	/* we have  start < mpnt->vm_end  */
 
+	if (is_vm_hugetlb_page(mpnt)) {
+		if ((start & ~HPAGE_MASK) || (len & ~HPAGE_MASK))
+			return -EINVAL;
+	}
+
 	/* if it doesn't overlap, we have nothing.. */
 	end = start + len;
 	if (mpnt->vm_start >= end)

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
