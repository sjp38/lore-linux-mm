Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A28596B01F0
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 17:28:22 -0400 (EDT)
Received: by ywl5 with SMTP id 5so1280435ywl.14
        for <linux-mm@kvack.org>; Mon, 30 Aug 2010 14:28:22 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 30 Aug 2010 23:28:21 +0200
Message-ID: <AANLkTi=4k0tc2ofwU0XLUn6Az3FhXrTex_EK4Ny-vJVM@mail.gmail.com>
Subject: (arch_)get_unmapped_area can be terribly slow due to unnecessary
 linear search and find_vma
From: Luca Barbieri <luca@luca-barbieri.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[Sending copy of bug #17531 since the BTS seemingly can't/won't send it to LKML]

Currently most/all versions of get_unmapped_area perform a linear search in the
process virtual address space to find free space.

Some, like arch_get_unmapped_area_topdown for x86-64 even call find_vma for
each step, which does a full walk on the rb-tree of vmas.

Instead, they should use, from slower to faster:
- O(n) but faster: a linked list of virtual address space holes
- O(log(n)): an rb-tree of virtual address space holes indexed by size
- O(1): a buddy allocator of virtual address space holes, or another scheme
with buckets

Is there any reason this issue hasn't been fixed yet? (i.e. any reason none of
the proposed schemes are feasible?)

Workloads doing a lot of mmaps tend to suffer greatly, especially on the
versions that do a find_vma for each step of the scan.

An example are OpenGL drivers using DRM/GEM/TTM who don't employ userspace
caching and suballocation of TTM allocated buffers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
