Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id B41C78E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 21:01:23 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id h7so531543iof.19
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 18:01:23 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id t3si8257363ioc.106.2019.01.22.18.01.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 18:01:22 -0800 (PST)
Message-Id: <201901230201.x0N214eq043832@www262.sakura.ne.jp>
Subject: Re: possible deadlock in =?ISO-2022-JP?B?X19kb19wYWdlX2ZhdWx0?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Wed, 23 Jan 2019 11:01:04 +0900
References: <4b0a5f8c-2be2-db38-a70d-8d497cb67665@I-love.SAKURA.ne.jp> <20190122153220.GA191275@google.com>
In-Reply-To: <20190122153220.GA191275@google.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Todd Kjos <tkjos@google.com>, syzbot+a76129f18c89f3e2ddd4@syzkaller.appspotmail.com, ak@linux.intel.com, Johannes Weiner <hannes@cmpxchg.org>, jack@suse.cz, jrdr.linux@gmail.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, mawilcox@microsoft.com, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com, Arve =?UTF-8?B?SGrDuG5uZXbDpWc=?= <arve@android.com>, Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Joel Fernandes wrote:
> > Why do we need to call fallocate() synchronously with ashmem_mutex held?
> > Why can't we call fallocate() asynchronously from WQ_MEM_RECLAIM workqueue
> > context so that we can call fallocate() with ashmem_mutex not held?
> > 
> > I don't know how ashmem works, but as far as I can guess, offloading is
> > possible as long as other operations which depend on the completion of
> > fallocate() operation (e.g. read()/mmap(), querying/changing pinned status)
> > wait for completion of asynchronous fallocate() operation (like a draft
> > patch shown below is doing).
> 
> This adds a bit of complexity, I am worried if it will introduce more
> bugs especially because ashmem is going away in the long term, in favor of
> memfd - and if its worth adding more complexity / maintenance burden to it.

I don't care migrating to memfd. I care when bugs are fixed.

> 
> I am wondering if we can do this synchronously, without using a workqueue.
> All you would need is a temporary list of areas to punch. In
> ashmem_shrink_scan, you would create this list under mutex and then once you
> release the mutex, you can go through this list and do the fallocate followed
> by the wake up of waiters on the wait queue, right? If you can do it this
> way, then it would be better IMO.

Are you sure that none of locks held before doing GFP_KERNEL allocation
interferes lock dependency used by fallocate() ? If yes, we can do without a
workqueue context (like a draft patch shown below). Since I don't understand
what locks are potentially involved, I offloaded to a clean workqueue context.

Anyway, I need your checks regarding whether this approach is waiting for
completion at all locations which need to wait for completion.

---
 drivers/staging/android/ashmem.c | 25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
index 90a8a9f1ac7d..6a267563cb66 100644
--- a/drivers/staging/android/ashmem.c
+++ b/drivers/staging/android/ashmem.c
@@ -75,6 +75,9 @@ struct ashmem_range {
 /* LRU list of unpinned pages, protected by ashmem_mutex */
 static LIST_HEAD(ashmem_lru_list);
 
+static atomic_t ashmem_shrink_inflight = ATOMIC_INIT(0);
+static DECLARE_WAIT_QUEUE_HEAD(ashmem_shrink_wait);
+
 /*
  * long lru_count - The count of pages on our LRU list.
  *
@@ -292,6 +295,7 @@ static ssize_t ashmem_read_iter(struct kiocb *iocb, struct iov_iter *iter)
 	int ret = 0;
 
 	mutex_lock(&ashmem_mutex);
+	wait_event(ashmem_shrink_wait, !atomic_read(&ashmem_shrink_inflight));
 
 	/* If size is not set, or set to 0, always return EOF. */
 	if (asma->size == 0)
@@ -359,6 +363,7 @@ static int ashmem_mmap(struct file *file, struct vm_area_struct *vma)
 	int ret = 0;
 
 	mutex_lock(&ashmem_mutex);
+	wait_event(ashmem_shrink_wait, !atomic_read(&ashmem_shrink_inflight));
 
 	/* user needs to SET_SIZE before mapping */
 	if (!asma->size) {
@@ -438,7 +443,6 @@ static int ashmem_mmap(struct file *file, struct vm_area_struct *vma)
 static unsigned long
 ashmem_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 {
-	struct ashmem_range *range, *next;
 	unsigned long freed = 0;
 
 	/* We might recurse into filesystem code, so bail out if necessary */
@@ -448,17 +452,27 @@ ashmem_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 	if (!mutex_trylock(&ashmem_mutex))
 		return -1;
 
-	list_for_each_entry_safe(range, next, &ashmem_lru_list, lru) {
+	while (!list_empty(&ashmem_lru_list)) {
+		struct ashmem_range *range =
+			list_first_entry(&ashmem_lru_list, typeof(*range), lru);
 		loff_t start = range->pgstart * PAGE_SIZE;
 		loff_t end = (range->pgend + 1) * PAGE_SIZE;
+		struct file *f = range->asma->file;
 
-		range->asma->file->f_op->fallocate(range->asma->file,
-				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
-				start, end - start);
+		get_file(f);
+		atomic_inc(&ashmem_shrink_inflight);
 		range->purged = ASHMEM_WAS_PURGED;
 		lru_del(range);
 
 		freed += range_size(range);
+		mutex_unlock(&ashmem_mutex);
+		f->f_op->fallocate(f,
+				   FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
+				   start, end - start);
+		fput(f);
+		if (atomic_dec_and_test(&ashmem_shrink_inflight))
+			wake_up_all(&ashmem_shrink_wait);
+		mutex_lock(&ashmem_mutex);
 		if (--sc->nr_to_scan <= 0)
 			break;
 	}
@@ -713,6 +727,7 @@ static int ashmem_pin_unpin(struct ashmem_area *asma, unsigned long cmd,
 		return -EFAULT;
 
 	mutex_lock(&ashmem_mutex);
+	wait_event(ashmem_shrink_wait, !atomic_read(&ashmem_shrink_inflight));
 
 	if (!asma->file)
 		goto out_unlock;
-- 
2.17.1
