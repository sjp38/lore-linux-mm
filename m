Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 814C18E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 02:07:15 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id g188so10901258pgc.22
        for <linux-mm@kvack.org>; Sun, 27 Jan 2019 23:07:15 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 9si31723083pgn.524.2019.01.27.23.07.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Jan 2019 23:07:13 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0S73jc2103733
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 02:07:13 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q9vy2rakm-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 02:07:13 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 28 Jan 2019 07:07:11 -0000
Date: Mon, 28 Jan 2019 09:07:05 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [LSF/MM TOPIC]: memory management bits in arch/*
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Message-Id: <20190128070705.GB2470@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org

Hi,

There is a lot of similar and duplicated code in architecture specific
bits of memory management.

For instance, as it was recently discussed at [1], most architectures
have

	#define GFP_KERNEL | __GFP_ZERO

for allocating page table pages and many of them use similar, if not
identical, implementation of pte_alloc_one*().

But that's only the tip of the iceberg.

I've seen several early_alloc() or similarly called routines that do

	if (slab_is_available())
		return kazalloc()
	else
		return memblock_alloc()

Some other trivial examples are free_initmem(), free_initrd_mem() and,
to some extent, mem_init(), but more generally there are a lot of
similarities in arch/*/mm/.

More complex cases are per-cpu initialization, passing of memory topology
to the generic MM, reservation of crash kernel, mmap of vdso etc. They
are not really duplicated, but still are very similar in at least
several architectures.

While factoring out the common code is an obvious step to take, I
believe there is also room for refining arch <-> mm interface to avoid
adding extra HAVE_ARCH_NO_BOOTMEM^w^wWHAT_NOT and then searching for
ways to get rid of them.

This is particularly true for mm initialization. It evolved the way
it's evolved, but now we can step back to black/white board and
consider design that hopefully will avoid problems like [2].

As a side note, it might be also worth looking into dropping
DISCONTIGMEM, although Kconfig still recommends to prefer it over
SPARSEMEM [3].

[1] https://lore.kernel.org/lkml/1547619692-7946-1-git-send-email-anshuman.khandual@arm.com/
[2] https://lore.kernel.org/lkml/20190114082416.30939-1-mhocko@kernel.org/
[3] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/Kconfig#n49

-- 
Sincerely yours,
Mike.
