Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 121CB6B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 21:44:01 -0400 (EDT)
Received: by mail-pf0-f180.google.com with SMTP id 4so2881894pfd.0
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 18:44:01 -0700 (PDT)
Received: from smtp-fw-33001.amazon.com (smtp-fw-33001.amazon.com. [207.171.189.228])
        by mx.google.com with ESMTPS id m27si318649pfj.88.2016.03.22.18.43.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 22 Mar 2016 18:44:00 -0700 (PDT)
From: Joel Fernandes <joelaf@lab126.com>
Subject: [RFC] high preempt off latency in vfree path
Message-ID: <56F1F4A6.2060400@lab126.com>
Date: Tue, 22 Mar 2016 18:43:02 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tj@kernel.org, linux-rt-users@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Andi Kleen <ak@linux.intel.com>

Hi,

I'm seeing on my system with some real time audio requirements, I'm seeing the preemptirqsoff 
tracer complaining that preempt was off for 17ms in the vfree path. Since we have requirements 
of 8ms scheduling this seems awfully bad.

The tracer output showed __free_vmap_area was about 7300 times. Can we do better here? I have 
proposed 2 potential fixes here, any thoughts on which one's better?

Here's the path that blocks preempt (full latency ftrace output uploaded to 
http://raw.codepile.net/pile/OWNpvKkB.js)

  => preempt_count_sub
  => _raw_spin_unlock
  => __purge_vmap_area_lazy
  => free_vmap_area_noflush
  => remove_vm_area
  => __vunmap
  => vfree
  => n_tty_close
  => tty_ldisc_close.isra.1
  => tty_ldisc_kill
  => tty_ldisc_release
  => tty_release

Here are the approaches:
(1)
One is we reduce the number of lazy_max_pages (right now its around 32MB per core worth of pages).

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index aa3891e..2720f4f 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -564,7 +564,7 @@ static unsigned long lazy_max_pages(void)

         log = fls(num_online_cpus());

-       return log * (32UL * 1024 * 1024 / PAGE_SIZE);
+       return log * (8UL * 1024 * 1024 / PAGE_SIZE);
  }


(2) Second alternative approach I am thinking is to change purge_lock into a mutex and then 
move the vmap_area spinlock around the free_vmap_area call. Thus giving the scheduler a chance 
to put something else on the CPU in between free_vmap_area calls. That would look like:

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index aa3891e..9565d72 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -594,7 +594,7 @@ void set_iounmap_nonlazy(void)
  static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
                                         int sync, int force_flush)
  {
-       static DEFINE_SPINLOCK(purge_lock);
+       static DEFINE_MUTEX(purge_lock);
         LIST_HEAD(valist);
         struct vmap_area *va;
         struct vmap_area *n_va;
@@ -606,10 +606,10 @@ static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
          * the case that isn't actually used at the moment anyway.
          */
         if (!sync && !force_flush) {
-               if (!spin_trylock(&purge_lock))
+               if (!mutex_trylock(&purge_lock))
                         return;
         } else
-               spin_lock(&purge_lock);
+               mutex_lock(&purge_lock);

         if (sync)
                 purge_fragmented_blocks_allcpus();
@@ -636,12 +636,13 @@ static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
                 flush_tlb_kernel_range(*start, *end);

         if (nr) {
-               spin_lock(&vmap_area_lock);
-               list_for_each_entry_safe(va, n_va, &valist, purge_list)
+               list_for_each_entry_safe(va, n_va, &valist, purge_list) {
+                       spin_lock(&vmap_area_lock);
                         __free_vmap_area(va);
+                       spin_unlock(&vmap_area_lock);
+               }
-               spin_unlock(&vmap_area_lock);

         }
-       spin_unlock(&purge_lock);
+       mutex_unlock(&purge_lock);
  }

  /*

Thanks!
Joel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
