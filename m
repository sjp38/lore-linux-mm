Received: from ns-ca.netscreen.com (ns-ca.netscreen.com [10.100.10.21])
	by mail.netscreen.com (8.10.0/8.10.0) with ESMTP id f4FH09A04080
	for <linux-mm@kvack.org>; Tue, 15 May 2001 10:00:09 -0700
Message-ID: <A33AEFDC2EC0D411851900D0B73EBEF766DBEB@NAPA>
From: Hua Ji <hji@netscreen.com>
Subject: About performance related to do_map
Date: Tue, 15 May 2001 10:13:30 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Folks,

When reading source codes, get a question. Thanks in advance.

Function do_map() ./mm/mmap.c,

After/if we get a vma by using **get_unmapped_area**, why we still
double-check
the vma area by using do_munmap()? 

This call to do_munmap()is ONLY NECESSARY when (flags & MAP_FIXED) is
**TRUE**.

The do_munmap will bring some EXTRA cost with the look up the vma linked
list or/and AVL tree.

Also, why not check it first before we create a new vma area? We don't have
to create a vma first and then release it afterwards when lateron we find
out that this vma is overlapped by some other vma area already.

Mike
------------------------------------------------
 /* Obtain the address to map to. we verify (or select) it and ensure
	 * that it represents a valid section of the address space.
	 */
	if (flags & MAP_FIXED) {
		if (addr & ~PAGE_MASK)
			return -EINVAL;
	} else {
		addr = get_unmapped_area(addr, len);
		if (!addr)
			return -ENOMEM;
	}
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
