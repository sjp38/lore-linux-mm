Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 92D518E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 05:03:07 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id w124so7079262oif.3
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 02:03:07 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id s61si7787194otb.294.2019.01.22.02.03.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 02:03:06 -0800 (PST)
Subject: Re: possible deadlock in __do_page_fault
References: <000000000000f7a28e057653dc6e@google.com>
 <20180920141058.4ed467594761e073606eafe2@linux-foundation.org>
 <CAHRSSEzX5HOUEQ6DgEF76OLGrwS1isWMdtvneBLOEEnwoMxVrA@mail.gmail.com>
 <CAEXW_YSot+3AMQ=jmDRowmqoOmQmujp9r8Dh18KJJN1EDmyHOw@mail.gmail.com>
 <20180921162110.e22d09a9e281d194db3c8359@linux-foundation.org>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <4b0a5f8c-2be2-db38-a70d-8d497cb67665@I-love.SAKURA.ne.jp>
Date: Tue, 22 Jan 2019 19:02:35 +0900
MIME-Version: 1.0
In-Reply-To: <20180921162110.e22d09a9e281d194db3c8359@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joel@joelfernandes.org>
Cc: Todd Kjos <tkjos@google.com>, Joel Fernandes <joelaf@google.com>, syzbot+a76129f18c89f3e2ddd4@syzkaller.appspotmail.com, ak@linux.intel.com, Johannes Weiner <hannes@cmpxchg.org>, jack@suse.cz, jrdr.linux@gmail.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, mawilcox@microsoft.com, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com, =?UTF-8?Q?Arve_Hj=c3=b8nnev=c3=a5g?= <arve@android.com>, Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 2018/09/22 8:21, Andrew Morton wrote:
> On Thu, 20 Sep 2018 19:33:15 -0400 Joel Fernandes <joel@joelfernandes.org> wrote:
> 
>> On Thu, Sep 20, 2018 at 5:12 PM Todd Kjos <tkjos@google.com> wrote:
>>>
>>> +Joel Fernandes
>>>
>>> On Thu, Sep 20, 2018 at 2:11 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>>>>
>>>>
>>>> Thanks.  Let's cc the ashmem folks.
>>>>
>>
>> This should be fixed by https://patchwork.kernel.org/patch/10572477/
>>
>> It has Neil Brown's Reviewed-by but looks like didn't yet appear in
>> anyone's tree, could Greg take this patch?
> 
> All is well.  That went into mainline yesterday, with a cc:stable.
> 

This problem was not fixed at all.

Why do we need to call fallocate() synchronously with ashmem_mutex held?
Why can't we call fallocate() asynchronously from WQ_MEM_RECLAIM workqueue
context so that we can call fallocate() with ashmem_mutex not held?

I don't know how ashmem works, but as far as I can guess, offloading is
possible as long as other operations which depend on the completion of
fallocate() operation (e.g. read()/mmap(), querying/changing pinned status)
wait for completion of asynchronous fallocate() operation (like a draft
patch shown below is doing).

---
 drivers/staging/android/ashmem.c | 50 ++++++++++++++++++++++++++++----
 1 file changed, 45 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
index 90a8a9f1ac7d..1a890c43a10a 100644
--- a/drivers/staging/android/ashmem.c
+++ b/drivers/staging/android/ashmem.c
@@ -75,6 +75,17 @@ struct ashmem_range {
 /* LRU list of unpinned pages, protected by ashmem_mutex */
 static LIST_HEAD(ashmem_lru_list);
 
+static struct workqueue_struct *ashmem_wq;
+static atomic_t ashmem_shrink_inflight = ATOMIC_INIT(0);
+static DECLARE_WAIT_QUEUE_HEAD(ashmem_shrink_wait);
+
+struct ashmem_shrink_work {
+	struct work_struct work;
+	struct file *file;
+	loff_t start;
+	loff_t end;
+};
+
 /*
  * long lru_count - The count of pages on our LRU list.
  *
@@ -292,6 +303,7 @@ static ssize_t ashmem_read_iter(struct kiocb *iocb, struct iov_iter *iter)
 	int ret = 0;
 
 	mutex_lock(&ashmem_mutex);
+	wait_event(ashmem_shrink_wait, !atomic_read(&ashmem_shrink_inflight));
 
 	/* If size is not set, or set to 0, always return EOF. */
 	if (asma->size == 0)
@@ -359,6 +371,7 @@ static int ashmem_mmap(struct file *file, struct vm_area_struct *vma)
 	int ret = 0;
 
 	mutex_lock(&ashmem_mutex);
+	wait_event(ashmem_shrink_wait, !atomic_read(&ashmem_shrink_inflight));
 
 	/* user needs to SET_SIZE before mapping */
 	if (!asma->size) {
@@ -421,6 +434,19 @@ static int ashmem_mmap(struct file *file, struct vm_area_struct *vma)
 	return ret;
 }
 
+static void ashmem_shrink_worker(struct work_struct *work)
+{
+	struct ashmem_shrink_work *w = container_of(work, typeof(*w), work);
+
+	w->file->f_op->fallocate(w->file,
+				 FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
+				 w->start, w->end - w->start);
+	fput(w->file);
+	kfree(w);
+	if (atomic_dec_and_test(&ashmem_shrink_inflight))
+		wake_up_all(&ashmem_shrink_wait);
+}
+
 /*
  * ashmem_shrink - our cache shrinker, called from mm/vmscan.c
  *
@@ -449,12 +475,18 @@ ashmem_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 		return -1;
 
 	list_for_each_entry_safe(range, next, &ashmem_lru_list, lru) {
-		loff_t start = range->pgstart * PAGE_SIZE;
-		loff_t end = (range->pgend + 1) * PAGE_SIZE;
+		struct ashmem_shrink_work *w = kzalloc(sizeof(*w), GFP_ATOMIC);
+
+		if (!w)
+			break;
+		INIT_WORK(&w->work, ashmem_shrink_worker);
+		w->file = range->asma->file;
+		get_file(w->file);
+		w->start = range->pgstart * PAGE_SIZE;
+		w->end = (range->pgend + 1) * PAGE_SIZE;
+		atomic_inc(&ashmem_shrink_inflight);
+		queue_work(ashmem_wq, &w->work);
 
-		range->asma->file->f_op->fallocate(range->asma->file,
-				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
-				start, end - start);
 		range->purged = ASHMEM_WAS_PURGED;
 		lru_del(range);
 
@@ -713,6 +745,7 @@ static int ashmem_pin_unpin(struct ashmem_area *asma, unsigned long cmd,
 		return -EFAULT;
 
 	mutex_lock(&ashmem_mutex);
+	wait_event(ashmem_shrink_wait, !atomic_read(&ashmem_shrink_inflight));
 
 	if (!asma->file)
 		goto out_unlock;
@@ -883,8 +916,15 @@ static int __init ashmem_init(void)
 		goto out_free2;
 	}
 
+	ashmem_wq = alloc_workqueue("ashmem_wq", WQ_MEM_RECLAIM, 0);
+	if (!ashmem_wq) {
+		pr_err("failed to create workqueue\n");
+		goto out_demisc;
+	}
+
 	ret = register_shrinker(&ashmem_shrinker);
 	if (ret) {
+		destroy_workqueue(ashmem_wq);
 		pr_err("failed to register shrinker!\n");
 		goto out_demisc;
 	}
-- 
2.17.1
