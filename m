Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D16F6B026B
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 17:50:13 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id g15-v6so4325795plo.11
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 14:50:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 17-v6si4018046pgp.289.2018.07.27.14.50.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jul 2018 14:50:12 -0700 (PDT)
Date: Fri, 27 Jul 2018 14:50:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] ipc/shm.c add ->pagesize function to shm_vm_ops
Message-Id: <20180727145009.5dde68fb680ec148a7504f37@linux-foundation.org>
In-Reply-To: <20180727211727.5020-1-jane.chu@oracle.com>
References: <20180727211727.5020-1-jane.chu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jane Chu <jane.chu@oracle.com>
Cc: dan.j.williams@intel.com, mhocko@suse.com, jack@suse.cz, jglisse@redhat.com, mike.kravetz@oracle.com, dave@stgolabs.net, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

On Fri, 27 Jul 2018 15:17:27 -0600 Jane Chu <jane.chu@oracle.com> wrote:

> Commit 05ea88608d4e13 (mm, hugetlbfs: introduce ->pagesize() to
> vm_operations_struct) adds a new ->pagesize() function to
> hugetlb_vm_ops, intended to cover all hugetlbfs backed files.

That was merged three months ago.  Can you suggest why this was only
noticed now?

What workload triggered this?  I see no cc:stable, but 4.17 is affected?

> With System V shared memory model, if "huge page" is specified,
> the "shared memory" is backed by hugetlbfs files, but the mappings
> initiated via shmget/shmat have their original vm_ops overwritten
> with shm_vm_ops, so we need to add a ->pagesize function to shm_vm_ops.
> Otherwise, vma_kernel_pagesize() returns PAGE_SIZE given a hugetlbfs
> backed vma, result in below BUG:
> 
> fs/hugetlbfs/inode.c
>         443             if (unlikely(page_mapped(page))) {
>         444                     BUG_ON(truncate_op);

OK, help me out here.  How does an incorrect return value from
vma_kernel_pagesize() result in remove_inode_hugepages() deciding that
it's truncating a mapped page?
