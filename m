Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9E6576B000A
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 23:08:54 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id g9-v6so4659982uam.17
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 20:08:54 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 4-v6si5780811vkg.117.2018.07.30.20.08.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 20:08:53 -0700 (PDT)
Subject: Re: [PATCH] ipc/shm.c add ->pagesize function to shm_vm_ops
References: <20180727211727.5020-1-jane.chu@oracle.com>
 <20180730164459.zduhnk7itoldqnom@linux-r8p5>
From: Jane Chu <jane.chu@oracle.com>
Message-ID: <a4c4bdab-b0f8-fb10-9b3d-f5740f30748c@oracle.com>
Date: Mon, 30 Jul 2018 20:08:48 -0700
MIME-Version: 1.0
In-Reply-To: <20180730164459.zduhnk7itoldqnom@linux-r8p5>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, jack@suse.cz, jglisse@redhat.com, mike.kravetz@oracle.com, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org

Hi, Davidlohr,

On 7/30/2018 9:44 AM, Davidlohr Bueso wrote:

> On Fri, 27 Jul 2018, Jane Chu wrote:
>
>> Commit 05ea88608d4e13 (mm, hugetlbfs: introduce ->pagesize() to
>> vm_operations_struct) adds a new ->pagesize() function to
>> hugetlb_vm_ops, intended to cover all hugetlbfs backed files.
>>
>> With System V shared memory model, if "huge page" is specified,
>> the "shared memory" is backed by hugetlbfs files, but the mappings
>> initiated via shmget/shmat have their original vm_ops overwritten
>> with shm_vm_ops, so we need to add a ->pagesize function to shm_vm_ops.
>> Otherwise, vma_kernel_pagesize() returns PAGE_SIZE given a hugetlbfs
>> backed vma, result in below BUG:
>>
>> fs/hugetlbfs/inode.c
>> A A A A A A  443A A A A A A A A A A A A  if (unlikely(page_mapped(page))) {
>> A A A A A A  444A A A A A A A A A A A A A A A A A A A A  BUG_ON(truncate_op);
>>
>> [A  242.268342] hugetlbfs: oracle (4592): Using mlock ulimits for 
>> SHM_HUGETLB is deprecated
>> [A  282.653208] ------------[ cut here ]------------
>> [A  282.708447] kernel BUG at fs/hugetlbfs/inode.c:444!
>> [A  282.818957] Modules linked in: nfsv3 rpcsec_gss_krb5 nfsv4 ...
>> [A  284.025873] CPU: 35 PID: 5583 Comm: oracle_5583_sbt Not tainted 
>> 4.14.35-1829.el7uek.x86_64 #2
>> [A  284.246609] task: ffff9bf0507aaf80 task.stack: ffffa9e625628000
>> [A  284.317455] RIP: 0010:remove_inode_hugepages+0x3db/0x3e2
>> ....
>> [A  285.292389] Call Trace:
>> [A  285.321630]A  hugetlbfs_evict_inode+0x1e/0x3e
>> [A  285.372707]A  evict+0xdb/0x1af
>> [A  285.408185]A  iput+0x1a2/0x1f7
>> [A  285.443661]A  dentry_unlink_inode+0xc6/0xf0
>> [A  285.492661]A  __dentry_kill+0xd8/0x18d
>> [A  285.536459]A  dput+0x1b5/0x1ed
>> [A  285.571939]A  __fput+0x18b/0x216
>> [A  285.609495]A  ____fput+0xe/0x10
>> [A  285.646030]A  task_work_run+0x90/0xa7
>> [A  285.688788]A  exit_to_usermode_loop+0xdd/0x116
>> [A  285.740905]A  do_syscall_64+0x187/0x1ae
>> [A  285.785740]A  entry_SYSCALL_64_after_hwframe+0x150/0x0
>>
>> Suggested-by: Mike Kravetz <mike.kravetz@oracle.com>
>> Signed-off-by: Jane Chu <jane.chu@oracle.com>
>
> Acked-by: Davidlohr Bueso <dbueso@suse.de>

Thank you!

-jane
