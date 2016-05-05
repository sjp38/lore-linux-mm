Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A85346B007E
	for <linux-mm@kvack.org>; Thu,  5 May 2016 17:07:47 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b203so190422271pfb.1
        for <linux-mm@kvack.org>; Thu, 05 May 2016 14:07:47 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ss2si13430420pab.111.2016.05.05.14.07.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 14:07:46 -0700 (PDT)
Date: Thu, 5 May 2016 14:07:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] ksm: fix conflict between mmput and
 scan_get_next_rmap_item
Message-Id: <20160505140745.32b100a6d100a86d59f1d11b@linux-foundation.org>
In-Reply-To: <1462452176-33462-1-git-send-email-zhouchengming1@huawei.com>
References: <1462452176-33462-1-git-send-email-zhouchengming1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhou Chengming <zhouchengming1@huawei.com>
Cc: hughd@google.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, geliangtang@163.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com, dingtianhong@huawei.com, huawei.libin@huawei.com, thunder.leizhen@huawei.com, qiuxishi@huawei.com

On Thu, 5 May 2016 20:42:56 +0800 Zhou Chengming <zhouchengming1@huawei.com> wrote:

> A concurrency issue about KSM in the function scan_get_next_rmap_item.
> 
> task A (ksmd):				|task B (the mm's task):
> 					|
> mm = slot->mm;				|
> down_read(&mm->mmap_sem);		|
> 					|
> ...					|
> 					|
> spin_lock(&ksm_mmlist_lock);		|
> 					|
> ksm_scan.mm_slot go to the next slot;	|
> 					|
> spin_unlock(&ksm_mmlist_lock);		|
> 					|mmput() ->
> 					|	ksm_exit():
> 					|
> 					|spin_lock(&ksm_mmlist_lock);
> 					|if (mm_slot && ksm_scan.mm_slot != mm_slot) {
> 					|	if (!mm_slot->rmap_list) {
> 					|		easy_to_free = 1;
> 					|		...
> 					|
> 					|if (easy_to_free) {
> 					|	mmdrop(mm);
> 					|	...
> 					|
> 					|So this mm_struct will be freed successfully.
> 					|
> up_read(&mm->mmap_sem);			|
> 
> As we can see above, the ksmd thread may access a mm_struct that already
> been freed to the kmem_cache.
> Suppose a fork will get this mm_struct from the kmem_cache, the ksmd thread
> then call up_read(&mm->mmap_sem), will cause mmap_sem.count to become -1.
> I changed the scan_get_next_rmap_item function refered to the khugepaged
> scan function.

Thanks.

We need to decide whether this fix should be backported into earlier
(-stable) kernels.  Can you tell us how easily this is triggered and
share your thoughts on this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
