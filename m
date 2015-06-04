Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3D045900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 05:35:59 -0400 (EDT)
Received: by qgf75 with SMTP id 75so13819944qgf.1
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 02:35:59 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d10si3483836qhc.120.2015.06.04.02.35.58
        for <linux-mm@kvack.org>;
        Thu, 04 Jun 2015 02:35:58 -0700 (PDT)
Date: Thu, 4 Jun 2015 10:35:50 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm: kmemleak: Fix crashing during kmemleak disabling
Message-ID: <20150604093550.GA8346@e104818-lin.cambridge.arm.com>
References: <1433346176-912-1-git-send-email-catalin.marinas@arm.com>
 <20150603162936.9132276820819001436585b3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150603162936.9132276820819001436585b3@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Vignesh Radhakrishnan <vigneshr@codeaurora.org>

Hi Andrew,

On Thu, Jun 04, 2015 at 12:29:36AM +0100, Andrew Morton wrote:
> On Wed,  3 Jun 2015 16:42:56 +0100 Catalin Marinas <catalin.marinas@arm.com> wrote:
> 
> > With the current implementation, if kmemleak is disabled because of an
> > error condition (e.g. fails to allocate metadata), alloc/free calls are
> > no longer tracked. Usually this is not a problem since the kmemleak
> > metadata is being removed via kmemleak_do_cleanup(). However, if the
> > scanning thread is running at the time of disabling, kmemleak would no
> > longer notice a potential vfree() call and the freed/unmapped object may
> > still be accessed, causing a fault.
> > 
> > This patch separates the kmemleak_free() enabling/disabling from the
> > overall kmemleak_enabled nob so that we can defer the disabling of the
> > object freeing tracking until the scanning thread completed. The
> > kmemleak_free_part() is deliberately ignored by this patch since this is
> > only called during boot before the scanning thread started.
> 
> I'm having trouble with this.  afacit, kmemleak_free() can still be
> called while kmemleak_scan() is running on another CPU. 
> kmemleak_free_enabled hasn't been cleared yet so the races remain.

It's not about kmemleak_free() racing with kmemleak_scan().
kmemleak_free() (and __delete_object()) is meant to race with the
scanning thread (which can run for minutes at a time), the locking is
done on individual kmemleak_object items.

> However your statement "if the scanning thread is running at the time
> of disabling" implies that the race is between kmemleak_scan() and
> kmemleak_disable().  Yet the race avoidance code is placed in
> kmemleak_free().

The race is indeed between kmemleak_disable() and kmemleak_scan(). Since
the former may be called in atomic contexts, we cannot issue a
kthread_stop() and wait for the scanning thread to finish. This is
deferred to the kmemleak_do_cleanup() work queue.

> All confused.  A more detailed description of the race would help.

I'll try to improve it and re-post.

> Also, the words "kmemleak would no longer notice a potential vfree()
> call" aren't sufficiently specific.  kmemleak is a big place - what
> *part* of kmemleak are you referring to here?

What I meant is that without any patch, kmemleak_free() simply returns
on !kmemleak_enabled and kmemleak_scan() does not notice that objects it
is scanning are being freed (__delete_object() no longer called). This
is worse with vfree() as the object is no longer mapped.

There are other ways of fixing this like adding heavier locking but I
found that simply allowing kmemleak_free() to get through to
__delete_object() until the kmemleak_scan stopped is the simplest.

> Finally, I'm concerned that a bare
> 
> 	kmemleak_free_enabled = 0;
> 
> lacks sufficient synchronization with respect to the
> kmemleak_free_enabled readers from a locking/reordering point of view. 

I thought about this as well and I didn't see an issue initially. From
an atomicity perspective, I'm not sure using atomic_t has any more
benefits (we used to have atomics here until commit 8910ae896c8c
"kmemleak: change some global variables to int").

As for the ordering, we need to ensure the visibility of the
kmemleak_free_enabled = 0 update to other CPUs in two cases:

1. after kmemleak_scan() is stopped. This is done by calling
   kthread_stop() -> put_task_struct() -> atomic_dec_and_test(). The
   latter implies barriers on each side of the operation, so I think
   this case is safe.

2. before __kmemleak_do_cleanup(). The risk here is that a
   delete_object_full() call from __kmemleak_do_cleanup() races with the
   same call from kmemleak_free(). The object_tree_root look-up (via
   find_get_object) is covered by the kmemleak_lock. However, it looks
   to me like two delete_object_full() calls on the same object can race
   to __delete_object() and call rb_erase() and list_del_rcu() twice on
   the same object.

Second case is trickier. A barrier after kmemleak_free_enabled = 0 does
not help, we need locking from object look-up all the way to removing
the object from the object list and tree. Alternatively, I could take
the object->lock for the whole __delete_object() function and use the
OBJECT_ALLOCATED flag to decide whether to call rb_erase and
list_del_rcu. Something like below, but untested yet (I'm off most of
the day); I would need to pass it through lock proving as well:

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 11d6f8015896..27e2e0b688a9 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -607,20 +607,25 @@ static void __delete_object(struct kmemleak_object *object)
 {
 	unsigned long flags;
 
+	/*
+	 * Locking here ensures that the corresponding memory block cannot be
+	 * freed when it is being scanned. It also avoids __delete_object()
+	 * race when being called form __kmemleak_do_cleanup().
+	 */
+	spin_lock_irqsave(&object->lock, flags);
+	if (!(object->flags & OBJECT_ALLOCATED))
+		goto out;
+
 	write_lock_irqsave(&kmemleak_lock, flags);
 	rb_erase(&object->rb_node, &object_tree_root);
 	list_del_rcu(&object->object_list);
 	write_unlock_irqrestore(&kmemleak_lock, flags);
 
-	WARN_ON(!(object->flags & OBJECT_ALLOCATED));
 	WARN_ON(atomic_read(&object->use_count) < 2);
 
-	/*
-	 * Locking here also ensures that the corresponding memory block
-	 * cannot be freed when it is being scanned.
-	 */
-	spin_lock_irqsave(&object->lock, flags);
 	object->flags &= ~OBJECT_ALLOCATED;
+
+out:
 	spin_unlock_irqrestore(&object->lock, flags);
 	put_object(object);
 }

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
