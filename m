Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id C30C76B0003
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 20:40:27 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id j80-v6so2607015vke.22
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 17:40:27 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id a1-v6si2712317uah.80.2018.07.27.17.40.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jul 2018 17:40:26 -0700 (PDT)
Subject: Re: [PATCH] ipc/shm.c add ->pagesize function to shm_vm_ops
References: <20180727211727.5020-1-jane.chu@oracle.com>
 <20180727145009.5dde68fb680ec148a7504f37@linux-foundation.org>
From: Jane Chu <jane.chu@oracle.com>
Message-ID: <6ea01f10-066a-6fe6-bf82-3a3b4ddf1175@oracle.com>
Date: Fri, 27 Jul 2018 17:40:16 -0700
MIME-Version: 1.0
In-Reply-To: <20180727145009.5dde68fb680ec148a7504f37@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: dan.j.williams@intel.com, mhocko@suse.com, jack@suse.cz, jglisse@redhat.com, mike.kravetz@oracle.com, dave@stgolabs.net, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Jane Chu <jane.chu@oracle.com>

Hi, Andrew,

On 7/27/2018 2:50 PM, Andrew Morton wrote:

> On Fri, 27 Jul 2018 15:17:27 -0600 Jane Chu <jane.chu@oracle.com> wrote:
>
>> Commit 05ea88608d4e13 (mm, hugetlbfs: introduce ->pagesize() to
>> vm_operations_struct) adds a new ->pagesize() function to
>> hugetlb_vm_ops, intended to cover all hugetlbfs backed files.
> That was merged three months ago.  Can you suggest why this was only
> noticed now?

The issue was recently reported by a QA engineer running Oracle database
test in Oracle Linux. He first noticed the issue in upstream 4.17, then 4.18,
but because the issue wasn't in Oracle product, it wasn't reported, not
until I cherry picked the patch into Oracle Linux recently.

> What workload triggered this?  I see no cc:stable, but 4.17 is affected?

It's Oracle database workload. Large shared memory segments(SGAs) were created
and shared among dozens to hundreds of processes. The crash occurs when the
test stops the database workload.  I do not have access to the test source.
Yes, 4.17 is affected.

>> With System V shared memory model, if "huge page" is specified,
>> the "shared memory" is backed by hugetlbfs files, but the mappings
>> initiated via shmget/shmat have their original vm_ops overwritten
>> with shm_vm_ops, so we need to add a ->pagesize function to shm_vm_ops.
>> Otherwise, vma_kernel_pagesize() returns PAGE_SIZE given a hugetlbfs
>> backed vma, result in below BUG:
>>
>> fs/hugetlbfs/inode.c
>>          443             if (unlikely(page_mapped(page))) {
>>          444                     BUG_ON(truncate_op);
> OK, help me out here.  How does an incorrect return value from
> vma_kernel_pagesize() result in remove_inode_hugepages() deciding that
> it's truncating a mapped page?

To be honest, I don't have a satisfactory answer to how the wrong
pagesize causes a page that's about to be truncated remain mapped.
I relied on the hind sight of BUG_ON(truncate_op).

At a time I inserted dump_stack() into vma_kernel_pagesize() as Mike
suggested to try to dig out more,

unsigned long vma_kernel_pagesize(struct vm_area_struct *vma)
{
-       if (vma->vm_ops && vma->vm_ops->pagesize)
+       if (vma->vm_ops && vma->vm_ops->pagesize) {
                 return vma->vm_ops->pagesize(vma);
+        } else if (is_vm_hugetlb_page(vma)) {
+               struct hstate *hstate;
+               dump_stack();
+               hstate = hstate_vma(vma);
+               return 1UL << huge_page_shift(hstate);
+       }
         return PAGE_SIZE;
}

There were too many stack traces that clogged the console, I didn't
capture the entire output, perhaps I should go back to capture them.

Any other ideas?

Regards,
-jane
