Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1FF826B0260
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 03:14:09 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h186so30511271pfg.2
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 00:14:09 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id yk6si5032951pab.73.2016.07.27.00.14.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 00:14:08 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6R7E7Tr110444
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 03:14:07 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24dsrq235x-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 03:14:07 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Wed, 27 Jul 2016 08:14:04 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 0EEF11B08061
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 08:15:30 +0100 (BST)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6R7E2jS27787452
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 07:14:02 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6R7E2bT030597
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 01:14:02 -0600
Date: Wed, 27 Jul 2016 09:14:00 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [BUG -next] "random: make /dev/urandom scalable for silly userspace
 programs" causes crash
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Message-Id: <20160727071400.GA3912@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: linux-next@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

Hi Ted,

it looks like your patch "random: make /dev/urandom scalable for silly
userspace programs" within linux-next seems to be a bit broken:

It causes this allocation failure and subsequent crash on s390 with fake
NUMA enabled:

[    0.533195] SLUB: Unable to allocate memory on node 1, gfp=0x24008c0(GFP_KERNEL|__GFP_NOFAIL)
[    0.533198]   cache: kmalloc-192, object size: 192, buffer size: 528, defaul order: 3, min order: 0
[    0.533202]   node 0: slabs: 2, objs: 124, free: 17
[    0.533208] Unable to handle kernel pointer dereference in virtual kernel address space
[    0.533211] Failing address: 0000000000000000 TEID: 0000000000000483
...
[    0.533276] Krnl PSW : 0704e00180000000 00000000001a853e (lockdep_init_map+0x1e/0x220)
[    0.533281]            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3 CC:2 PM:0 RI:0 EA:3
               Krnl GPRS: 0000000000a23400 00000000370c8008 0000000000000060 0000000000bedc90
[    0.533285]            0000000002070800 0000000000000000 0000000000000001 0000000000000000
[    0.533287]            000000003743d3f8 000000003743d408 0000000002070800 0000000000bedc90
[    0.533289]            0000000000000048 00000000009c2030 00000000370cfd00 00000000370cfcc0
[    0.533295] Krnl Code: 00000000001a852e: a7840001            brc     8,1a8530
           00000000001a8532: e3f0ffc0ff71       lay     %r15,-64(%r15)
          #00000000001a8538: e3e0f0980024       stg     %r14,152(%r15)
          >00000000001a853e: e54820080000       mvghi   8(%r2),0
           00000000001a8544: e54820100000       mvghi   16(%r2),0
           00000000001a854a: 58100370           l       %r1,880
           00000000001a854e: 50102020           st      %r1,32(%r2)
           00000000001a8552: b90400c2           lgr     %r12,%r2
[    0.533313] Call Trace:
[    0.533315] ([<0000000000000001>] 0x1)
[    0.533318] ([<00000000001b4220>] __raw_spin_lock_init+0x50/0x80)
[    0.533320] ([<0000000000759e7a>] rand_initialize+0xc2/0xf0)
[    0.533322] ([<00000000001002cc>] do_one_initcall+0xb4/0x140)
[    0.533325] ([<0000000000ef2cc0>] kernel_init_freeable+0x140/0x2d8)
[    0.533328] ([<00000000009b07ea>] kernel_init+0x2a/0x150)
[    0.533330] ([<00000000009bd782>] kernel_thread_starter+0x6/0xc)
[    0.533332] ([<00000000009bd77c>] kernel_thread_starter+0x0/0xc)

To me it looks rand_initialize is broken with CONFIG_NUMA:

static int rand_initialize(void)
{
#ifdef CONFIG_NUMA
	int i;
	int num_nodes = num_possible_nodes();
	struct crng_state *crng;
	struct crng_state **pool;
#endif

	init_std_data(&input_pool);
	init_std_data(&blocking_pool);
	crng_initialize(&primary_crng);

#ifdef CONFIG_NUMA
	pool = kmalloc(num_nodes * sizeof(void *),
		       GFP_KERNEL|__GFP_NOFAIL|__GFP_ZERO);
	for (i=0; i < num_nodes; i++) {
		crng = kmalloc_node(sizeof(struct crng_state),
				    GFP_KERNEL | __GFP_NOFAIL, i);
		spin_lock_init(&crng->lock);
		crng_initialize(crng);
		pool[i] = crng;

	}
	mb();
	crng_node_pool = pool;
#endif
	return 0;
}
early_initcall(rand_initialize);

First the for loop should use for_each_node() to skip not possible nodes,
no?

However that wouldn't be enough, since in this case it crashed because node
1 is in the possible map, but it isn't online and doesn't have any memory,
which explains why the allocation fails and the subsequent crash when
calling spin_lock_init().

I think the proper fix would be to simply use for_each_online_node(); at
least that fixes the crash on s390.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
