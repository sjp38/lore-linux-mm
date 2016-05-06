Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f72.google.com (mail-qg0-f72.google.com [209.85.192.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2FF7D6B007E
	for <linux-mm@kvack.org>; Thu,  5 May 2016 22:57:41 -0400 (EDT)
Received: by mail-qg0-f72.google.com with SMTP id f101so159660119qge.3
        for <linux-mm@kvack.org>; Thu, 05 May 2016 19:57:41 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id z132si8115878qhd.67.2016.05.05.19.57.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 May 2016 19:57:40 -0700 (PDT)
Message-ID: <572C0674.9080006@huawei.com>
Date: Fri, 6 May 2016 10:50:28 +0800
From: zhouchengming <zhouchengming1@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] ksm: fix conflict between mmput and scan_get_next_rmap_item
References: <1462452176-33462-1-git-send-email-zhouchengming1@huawei.com> <20160505140745.32b100a6d100a86d59f1d11b@linux-foundation.org>
In-Reply-To: <20160505140745.32b100a6d100a86d59f1d11b@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: hughd@google.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, geliangtang@163.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com, dingtianhong@huawei.com, huawei.libin@huawei.com, thunder.leizhen@huawei.com, qiuxishi@huawei.com

On 2016/5/6 5:07, Andrew Morton wrote:
> On Thu, 5 May 2016 20:42:56 +0800 Zhou Chengming<zhouchengming1@huawei.com>  wrote:
>
>> A concurrency issue about KSM in the function scan_get_next_rmap_item.
>>
>> task A (ksmd):				|task B (the mm's task):
>> 					|
>> mm = slot->mm;				|
>> down_read(&mm->mmap_sem);		|
>> 					|
>> ...					|
>> 					|
>> spin_lock(&ksm_mmlist_lock);		|
>> 					|
>> ksm_scan.mm_slot go to the next slot;	|
>> 					|
>> spin_unlock(&ksm_mmlist_lock);		|
>> 					|mmput() ->
>> 					|	ksm_exit():
>> 					|
>> 					|spin_lock(&ksm_mmlist_lock);
>> 					|if (mm_slot&&  ksm_scan.mm_slot != mm_slot) {
>> 					|	if (!mm_slot->rmap_list) {
>> 					|		easy_to_free = 1;
>> 					|		...
>> 					|
>> 					|if (easy_to_free) {
>> 					|	mmdrop(mm);
>> 					|	...
>> 					|
>> 					|So this mm_struct will be freed successfully.
>> 					|
>> up_read(&mm->mmap_sem);			|
>>
>> As we can see above, the ksmd thread may access a mm_struct that already
>> been freed to the kmem_cache.
>> Suppose a fork will get this mm_struct from the kmem_cache, the ksmd thread
>> then call up_read(&mm->mmap_sem), will cause mmap_sem.count to become -1.
>> I changed the scan_get_next_rmap_item function refered to the khugepaged
>> scan function.
>
> Thanks.
>
> We need to decide whether this fix should be backported into earlier
> (-stable) kernels.  Can you tell us how easily this is triggered and
> share your thoughts on this?
>
>
> .
>

I write a patch that can easily trigger this bug.
When ksmd go to sleep, if a fork get this mm_struct, BUG_ON
will be triggered.

 From eedfdd12eb11858f69ff4a4300acad42946ca260 Mon Sep 17 00:00:00 2001
From: Zhou Chengming <zhouchengming1@huawei.com>
Date: Thu, 5 May 2016 17:49:22 +0800
Subject: [PATCH] ksm: trigger a bug

Signed-off-by: Zhou Chengming <zhouchengming1@huawei.com>
---
  mm/ksm.c |   17 +++++++++++++++++
  1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index ca6d2a0..676368c 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1519,6 +1519,18 @@ static struct rmap_item 
*get_next_rmap_item(struct mm_slot *mm_slot,
  	return rmap_item;
  }

+static void trigger_a_bug(struct task_struct *p, struct mm_struct *mm)
+{
+	/* send KILL sig to the task, hope the mm_struct will be freed */
+	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
+	/* sleep for 5s, the mm_struct will be freed and another fork
+	 * will use this mm_struct
+	 */
+	schedule_timeout(msecs_to_jiffies(5000));
+	/* the mm_struct owned by another task */
+	BUG_ON(mm->owner != p);
+}
+
  static struct rmap_item *scan_get_next_rmap_item(struct page **page)
  {
  	struct mm_struct *mm;
@@ -1526,6 +1538,7 @@ static struct rmap_item 
*scan_get_next_rmap_item(struct page **page)
  	struct vm_area_struct *vma;
  	struct rmap_item *rmap_item;
  	int nid;
+	struct task_struct *taskp;

  	if (list_empty(&ksm_mm_head.mm_list))
  		return NULL;
@@ -1636,6 +1649,8 @@ next_mm:
  	remove_trailing_rmap_items(slot, ksm_scan.rmap_list);

  	spin_lock(&ksm_mmlist_lock);
+	/* get the mm's task now in the ksm_mmlist_lock */
+	taskp = mm->owner;
  	ksm_scan.mm_slot = list_entry(slot->mm_list.next,
  						struct mm_slot, mm_list);
  	if (ksm_scan.address == 0) {
@@ -1651,6 +1666,7 @@ next_mm:
  		hash_del(&slot->link);
  		list_del(&slot->mm_list);
  		spin_unlock(&ksm_mmlist_lock);
+		trigger_a_bug(taskp, mm);

  		free_mm_slot(slot);
  		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
@@ -1658,6 +1674,7 @@ next_mm:
  		mmdrop(mm);
  	} else {
  		spin_unlock(&ksm_mmlist_lock);
+		trigger_a_bug(taskp, mm);
  		up_read(&mm->mmap_sem);
  	}

-- 
1.7.7


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
