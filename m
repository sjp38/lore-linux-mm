Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l0VKGQW5018545
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 15:16:26 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0VKGQHh295628
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 15:16:26 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0VKGP9W008028
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 15:16:26 -0500
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 0/6] hugetlb: Remove is_file_hugepages() macro
Date: Wed, 31 Jan 2007 12:16:24 -0800
Message-Id: <20070131201624.13810.45848.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: agl@us.ibm.com, wli@holomorphy.com, kenchen@google.com, hugh@veritas.com, david@gibson.dropbear.id.au
List-ID: <linux-mm.kvack.org>

The kernel code is currently peppered with special casing for hugetlbfs
mappings.  In many places we check a struct file's f_op member to see if it
points to the hugetlbfs file_operations in which case we'll employ some sort of
workaround.  The need to check file_operations in this manner suggests that we
are either missing f_op operations, or have deficient abstraction elsewhere.

I am motivated to clean this up for two reasons:  1) The community has asked
for huge pages to be kept "on the side" of the main VM.  I believe these
patches advance that goal.  2) Proper abstraction of hugetlbfs allows the
underlying implementation to be changed without disturbing the main VM.

Removing the is_file_hugepages() macro involved finding all the call sites,
determining the actual incompatibility that huge page mappings introduce, and
applying a relatively trivial fix for the problem.  The following patches
perform this surgery.

When converting these, I have tried to use as general of a solution as
possible.  Review of some of the design decisions would be appreciated --
specifically the use of backing_dev_info for the note about special accounting,
and hugetlbfs sharing the inode_info struct with shmem.

Thanks to Andy Whitcroft and others for review of the preliminary patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
