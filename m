Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id C1E3A6B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 06:51:25 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id m7-v6so3683992otd.20
        for <linux-mm@kvack.org>; Thu, 31 May 2018 03:51:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r25-v6si5639071ote.94.2018.05.31.03.51.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 03:51:24 -0700 (PDT)
Date: Thu, 31 May 2018 06:51:22 -0400 (EDT)
From: Chunyu Hu <chuhu@redhat.com>
Reply-To: Chunyu Hu <chuhu@redhat.com>
Message-ID: <2074740225.5769475.1527763882580.JavaMail.zimbra@redhat.com>
In-Reply-To: <20180530123826.GF27180@dhcp22.suse.cz>
References: <CA+7wUswp_Sr=hHqi1bwRZ3FE2wY5ozZWZ8Z1BgrFnSAmijUKjA@mail.gmail.com> <201805290605.DGF87549.LOVFMFJQSOHtFO@I-love.SAKURA.ne.jp> <1126233373.5118805.1527600426174.JavaMail.zimbra@redhat.com> <f3d58cbd-29ca-7a23-69e0-59690b9cd4fb@i-love.sakura.ne.jp> <1730157334.5467848.1527672937617.JavaMail.zimbra@redhat.com> <20180530104637.GC27180@dhcp22.suse.cz> <1684479370.5483281.1527680579781.JavaMail.zimbra@redhat.com> <20180530123826.GF27180@dhcp22.suse.cz>
Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, malat@debian.org, dvyukov@google.com, linux-mm@kvack.org, catalin marinas <catalin.marinas@arm.com>, Akinobu Mita <akinobu.mita@gmail.com>



----- Original Message -----
> From: "Michal Hocko" <mhocko@suse.com>
> To: "Chunyu Hu" <chuhu@redhat.com>
> Cc: "Tetsuo Handa" <penguin-kernel@i-love.sakura.ne.jp>, malat@debian.org, dvyukov@google.com, linux-mm@kvack.org,
> "catalin marinas" <catalin.marinas@arm.com>, "Akinobu Mita" <akinobu.mita@gmail.com>
> Sent: Wednesday, May 30, 2018 8:38:26 PM
> Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
> 
> On Wed 30-05-18 07:42:59, Chunyu Hu wrote:
> > 
> > ----- Original Message -----
> > > From: "Michal Hocko" <mhocko@suse.com>
> > > To: "Chunyu Hu" <chuhu@redhat.com>
> > > Cc: "Tetsuo Handa" <penguin-kernel@i-love.sakura.ne.jp>,
> > > malat@debian.org, dvyukov@google.com, linux-mm@kvack.org,
> > > "catalin marinas" <catalin.marinas@arm.com>
> > > Sent: Wednesday, May 30, 2018 6:46:37 PM
> > > Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
> > > 
> > > On Wed 30-05-18 05:35:37, Chunyu Hu wrote:
> > > [...]
> > > > I'm trying to reuse the make_it_fail field in task for fault injection.
> > > > As
> > > > adding
> > > > an extra memory alloc flag is not thought so good,  I think adding task
> > > > flag
> > > > is either?
> > > 
> > > Yeah, task flag will be reduced to KMEMLEAK enabled configurations
> > > without an additional maint. overhead. Anyway, you should really think
> > > about how to guarantee trackability for atomic allocation requests. You
> > > cannot simply assume that GFP_NOWAIT will succeed. I guess you really
> > 
> > Sure. While I'm using task->make_it_fail, I'm still in the direction of
> > making kmemleak avoid fault inject with task flag instead of page alloc
> > flag.
> > 
> > > want to have a pre-populated pool of objects for those requests. The
> > > obvious question is how to balance such a pool. It ain't easy to track
> > > memory by allocating more memory...
> > 
> > This solution is going to make kmemleak trace really nofail. We can think
> > later.
> > 
> > while I'm thinking about if fault inject can be disabled via flag in task.
> > 
> > Actually, I'm doing something like below, the disable_fault_inject() is
> > just setting a flag in task->make_it_fail. But this will depend on if
> > fault injection accept a change like this. CCing Akinobu
> 
> You still seem to be missing my point I am afraid (or I am ;). So say
> that you want to track a GFP_NOWAIT allocation request. So create_object
> will get called with that gfp mask and no matter what you try here your
> tracking object will be allocated in a weak allocation context as well
> and disable kmemleak. So it only takes a more heavy memory pressure and
> the tracing is gone...

Michal,

Thank you for the good suggestion. You mean GFP_NOWAIT still can make create_object
fail and as a result kmemleak disable itself. So it's not so useful, just like
the current __GFP_NOFAIL usage in create_object. 

In the first thread, we discussed this. and that time you suggested we have 
fault injection disabled when kmemleak is working and suggested per task way.
so my head has been stuck in that point. While now you gave a better suggestion
that why not we pre allocate a urgent pool for kmemleak objects. After thinking
for a while, I got  your point, it's a good way for improving kmemleak to make
it can tolerate light allocation failure. And catalin mentioned that we have
one option that use the early_log array as urgent pool, which has the similar
ideology.

Basing on your suggestions, I tried to draft this, what does it look to you? 
another strong alloc mask and an extra thread for fill the pool, which containts
1M objects in a frequency of 100 ms. If first kmem_cache_alloc failed, then
get a object from the pool. 


diff --git a/mm/kmemleak.c b/mm/kmemleak.c                                                                                                                                   
index 9a085d5..7163489 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -128,6 +128,10 @@
                 __GFP_NORETRY | __GFP_NOMEMALLOC | \
                 __GFP_NOWARN | __GFP_NOFAIL)
 
+#define gfp_kmemleak_mask_strong() (__GFP_NOMEMALLOC | \
+                __GFP_NOWARN | __GFP_RECLAIM | __GFP_NOFAIL)
+
+
 /* scanning area inside a memory block */
 struct kmemleak_scan_area {
    struct hlist_node node;
@@ -299,6 +303,83 @@ struct early_log {
    kmemleak_disable();     \
 } while (0)
 
+static DEFINE_SPINLOCK(kmemleak_object_lock);
+static LIST_HEAD(pool_object_list);
+static unsigned int volatile total;
+static unsigned int pool_object_max = 1024 * 1024;
+static struct task_struct *pool_thread;
+
+static struct kmemleak_object* kmemleak_pool_fill(void)
+{
+   struct kmemleak_object *object = NULL;
+   unsigned long flags;
+
+   object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask_strong());
+   spin_lock_irqsave(&kmemleak_object_lock, flags);
+   if (object) {
+       list_add(&object->object_list, &pool_object_list);
+       total++;
+   }
+   spin_unlock_irqrestore(&kmemleak_object_lock, flags);
+   return object;
+}
+
+static struct kmemleak_object* kmemleak_get_pool_object(void)
+{
+   struct kmemleak_object *object = NULL;
+   unsigned long flags;
+
+   spin_lock_irqsave(&kmemleak_object_lock, flags);
+   if (!list_empty(&pool_object_list)) {
+       object = list_first_entry(&pool_object_list,struct kmemleak_object,
+               object_list);
+       list_del(&object->object_list);
+       total--;
+   }
+   spin_unlock_irqrestore(&kmemleak_object_lock, flags);
+   return object;
+}
+
+static int kmemleak_pool_thread(void *nothinng)
+{
+   struct kmemleak_object *object = NULL;
+   while (!kthread_should_stop()) {
+       if (READ_ONCE(total) < pool_object_max) {
+           object = kmemleak_pool_fill();
+           WARN_ON(!object);
+       }
+       schedule_timeout_interruptible(msecs_to_jiffies(100));
+   }
+   return 0;
+}
+
+static void start_pool_thread(void)
+{
+   if (pool_thread)
+       return;
+   pool_thread = kthread_run(kmemleak_pool_thread, NULL, "kmemleak_pool");
+   if (IS_ERR(pool_thread)) {
+       pr_warn("Failed to create the scan thread\n");
+       pool_thread = NULL;
+   }
+}
+static void stop_pool_thread(void)
+{
+   struct kmemleak_object *object;
+   unsigned long flags;
+   if (pool_thread) {
+       kthread_stop(pool_thread);
+       pool_thread = NULL;
+   }
+   spin_lock_irqsave(&kmemleak_object_lock, flags);
+   list_for_each_entry(object, &pool_object_list, object_list) {
+       list_del(&object->object_list);
+       kmem_cache_free(object_cache, object);
+   }
+   spin_unlock_irqrestore(&kmemleak_object_lock, flags);
+}
+
 /*
  * Printing of the objects hex dump to the seq file. The number of lines to be
  * printed is limited to HEX_MAX_LINES to prevent seq file spamming. The
@@ -553,6 +634,10 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 
    object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
    if (!object) {
+       object = kmemleak_get_pool_object();
+       pr_info("total=%u", total);
+   }
+   if (!object) {
        pr_warn("Cannot allocate a kmemleak_object structure\n");
        kmemleak_disable();
        return NULL;
@@ -1872,8 +1957,10 @@ static ssize_t kmemleak_write(struct file *file, const char __user *user_buf,
        kmemleak_stack_scan = 0;
    else if (strncmp(buf, "scan=on", 7) == 0)
        start_scan_thread();
-   else if (strncmp(buf, "scan=off", 8) == 0)
+   else if (strncmp(buf, "scan=off", 8) == 0) {
        stop_scan_thread();
+       stop_pool_thread();
+   }
    else if (strncmp(buf, "scan=", 5) == 0) {
        unsigned long secs;
 
@@ -1929,6 +2016,7 @@ static void __kmemleak_do_cleanup(void)
 static void kmemleak_do_cleanup(struct work_struct *work)
 {
    stop_scan_thread();
+   stop_pool_thread();
 
    mutex_lock(&scan_mutex);
    /*
@@ -2114,6 +2202,7 @@ static int __init kmemleak_late_init(void)
        pr_warn("Failed to create the debugfs kmemleak file\n");
    mutex_lock(&scan_mutex);
    start_scan_thread();
+   start_pool_thread();
    mutex_unlock(&scan_mutex);
 
    pr_info("Kernel memory leak detector initialized\n");                           



> --
> Michal Hocko
> SUSE Labs
> 

-- 
Regards,
Chunyu Hu
