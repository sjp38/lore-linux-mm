Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id AE9AC6B0006
	for <linux-mm@kvack.org>; Wed, 30 May 2018 07:43:02 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id 106-v6so11481080otg.22
        for <linux-mm@kvack.org>; Wed, 30 May 2018 04:43:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u12-v6si13368717otu.61.2018.05.30.04.43.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 04:43:01 -0700 (PDT)
Date: Wed, 30 May 2018 07:42:59 -0400 (EDT)
From: Chunyu Hu <chuhu@redhat.com>
Reply-To: Chunyu Hu <chuhu@redhat.com>
Message-ID: <1684479370.5483281.1527680579781.JavaMail.zimbra@redhat.com>
In-Reply-To: <20180530104637.GC27180@dhcp22.suse.cz>
References: <CA+7wUswp_Sr=hHqi1bwRZ3FE2wY5ozZWZ8Z1BgrFnSAmijUKjA@mail.gmail.com> <f054219d-6daa-68b1-0c60-0acd9ad8c5ab@i-love.sakura.ne.jp> <20180528132410.GD27180@dhcp22.suse.cz> <201805290605.DGF87549.LOVFMFJQSOHtFO@I-love.SAKURA.ne.jp> <1126233373.5118805.1527600426174.JavaMail.zimbra@redhat.com> <f3d58cbd-29ca-7a23-69e0-59690b9cd4fb@i-love.sakura.ne.jp> <1730157334.5467848.1527672937617.JavaMail.zimbra@redhat.com> <20180530104637.GC27180@dhcp22.suse.cz>
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
> "catalin marinas" <catalin.marinas@arm.com>
> Sent: Wednesday, May 30, 2018 6:46:37 PM
> Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
> 
> On Wed 30-05-18 05:35:37, Chunyu Hu wrote:
> [...]
> > I'm trying to reuse the make_it_fail field in task for fault injection. As
> > adding
> > an extra memory alloc flag is not thought so good,  I think adding task
> > flag
> > is either?
> 
> Yeah, task flag will be reduced to KMEMLEAK enabled configurations
> without an additional maint. overhead. Anyway, you should really think
> about how to guarantee trackability for atomic allocation requests. You
> cannot simply assume that GFP_NOWAIT will succeed. I guess you really

Sure. While I'm using task->make_it_fail, I'm still in the direction of 
making kmemleak avoid fault inject with task flag instead of page alloc flag.

> want to have a pre-populated pool of objects for those requests. The
> obvious question is how to balance such a pool. It ain't easy to track
> memory by allocating more memory...

This solution is going to make kmemleak trace really nofail. We can think
later.

while I'm thinking about if fault inject can be disabled via flag in task.

Actually, I'm doing something like below, the disable_fault_inject() is
just setting a flag in task->make_it_fail. But this will depend on if
fault injection accept a change like this. CCing Akinobu 

[1] http://lkml.kernel.org/r/1524243513-29118-1-git-send-email-chuhu@redhat.com
[2] http://lkml.kernel.org/r/CA+7wUswp_Sr=hHqi1bwRZ3FE2wY5ozZWZ8Z1BgrFnSAmijUKjA@mail.gmail.com
[3] commit d9570ee3bd1d ("kmemleak: allow to coexist with fault injection")


+#define disable_fault_inject() \
+do {   \
+   unsigned long flag; \
+   local_irq_save(flag);   \
+   if (in_irq())   \
+       current->make_it_fail |= HARDIRQ_NOFAULT_OFFSET;    \
+   else    \
+       current->make_it_fail |= TASK_NOFAULT_OFFSET;   \
+   local_irq_restore(flag);        \
+} while (0)


--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c                                                                                                                                                          
@@ -111,6 +111,7 @@
 #include <linux/kasan.h>
 #include <linux/kmemleak.h>
 #include <linux/memory_hotplug.h>
+#include <linux/fault-inject.h>
 
 /*
  * Kmemleak configuration and common defines.
@@ -126,7 +127,7 @@
 /* GFP bitmask for kmemleak internal allocations */
 #define gfp_kmemleak_mask(gfp) (((gfp) & (GFP_KERNEL | GFP_ATOMIC)) | \
                 __GFP_NORETRY | __GFP_NOMEMALLOC | \
-                __GFP_NOWARN | __GFP_NOFAIL)
+                __GFP_NOWARN)
 
 /* scanning area inside a memory block */
 struct kmemleak_scan_area {
@@ -551,12 +552,15 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
    struct kmemleak_object *object, *parent;
    struct rb_node **link, *rb_parent;
 
+   disable_fault_inject();
    object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
    if (!object) {
        pr_warn("Cannot allocate a kmemleak_object structure\n");
        kmemleak_disable();
+       enable_fault_inject();
        return NULL;
    }
+   enable_fault_inject();
 
    INIT_LIST_HEAD(&object->object_list);
    INIT_LIST_HEAD(&object->gray_list);


> 
> --
> Michal Hocko
> SUSE Labs
> 

-- 
Regards,
Chunyu Hu
