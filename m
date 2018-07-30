Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id EE6F76B000D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 12:45:12 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id n21-v6so9398536plp.9
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 09:45:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h34-v6si10890948pld.355.2018.07.30.09.45.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 09:45:11 -0700 (PDT)
Date: Mon, 30 Jul 2018 09:44:59 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH] ipc/shm.c add ->pagesize function to shm_vm_ops
Message-ID: <20180730164459.zduhnk7itoldqnom@linux-r8p5>
References: <20180727211727.5020-1-jane.chu@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20180727211727.5020-1-jane.chu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jane Chu <jane.chu@oracle.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, jack@suse.cz, jglisse@redhat.com, mike.kravetz@oracle.com, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org

On Fri, 27 Jul 2018, Jane Chu wrote:

>Commit 05ea88608d4e13 (mm, hugetlbfs: introduce ->pagesize() to
>vm_operations_struct) adds a new ->pagesize() function to
>hugetlb_vm_ops, intended to cover all hugetlbfs backed files.
>
>With System V shared memory model, if "huge page" is specified,
>the "shared memory" is backed by hugetlbfs files, but the mappings
>initiated via shmget/shmat have their original vm_ops overwritten
>with shm_vm_ops, so we need to add a ->pagesize function to shm_vm_ops.
>Otherwise, vma_kernel_pagesize() returns PAGE_SIZE given a hugetlbfs
>backed vma, result in below BUG:
>
>fs/hugetlbfs/inode.c
>        443             if (unlikely(page_mapped(page))) {
>        444                     BUG_ON(truncate_op);
>
>[  242.268342] hugetlbfs: oracle (4592): Using mlock ulimits for SHM_HUGETLB is deprecated
>[  282.653208] ------------[ cut here ]------------
>[  282.708447] kernel BUG at fs/hugetlbfs/inode.c:444!
>[  282.818957] Modules linked in: nfsv3 rpcsec_gss_krb5 nfsv4 ...
>[  284.025873] CPU: 35 PID: 5583 Comm: oracle_5583_sbt Not tainted 4.14.35-1829.el7uek.x86_64 #2
>[  284.246609] task: ffff9bf0507aaf80 task.stack: ffffa9e625628000
>[  284.317455] RIP: 0010:remove_inode_hugepages+0x3db/0x3e2
>....
>[  285.292389] Call Trace:
>[  285.321630]  hugetlbfs_evict_inode+0x1e/0x3e
>[  285.372707]  evict+0xdb/0x1af
>[  285.408185]  iput+0x1a2/0x1f7
>[  285.443661]  dentry_unlink_inode+0xc6/0xf0
>[  285.492661]  __dentry_kill+0xd8/0x18d
>[  285.536459]  dput+0x1b5/0x1ed
>[  285.571939]  __fput+0x18b/0x216
>[  285.609495]  ____fput+0xe/0x10
>[  285.646030]  task_work_run+0x90/0xa7
>[  285.688788]  exit_to_usermode_loop+0xdd/0x116
>[  285.740905]  do_syscall_64+0x187/0x1ae
>[  285.785740]  entry_SYSCALL_64_after_hwframe+0x150/0x0
>
>Suggested-by: Mike Kravetz <mike.kravetz@oracle.com>
>Signed-off-by: Jane Chu <jane.chu@oracle.com>

Acked-by: Davidlohr Bueso <dbueso@suse.de>
