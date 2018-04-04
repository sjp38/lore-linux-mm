Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE67B6B0006
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 10:39:02 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 91-v6so14612037pla.18
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 07:39:02 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y6si4119051pfe.248.2018.04.04.07.39.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 04 Apr 2018 07:39:01 -0700 (PDT)
Date: Wed, 4 Apr 2018 07:39:00 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Signal handling in a page fault handler
Message-ID: <20180404143900.GA1777@bombadil.infradead.org>
References: <20180402141058.GL13332@bombadil.infradead.org>
 <20180404093254.GC3881@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180404093254.GC3881@phenom.ffwll.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Souptick Joarder <jrdr.linux@gmail.com>, linux-kernel@vger.kernel.org

On Wed, Apr 04, 2018 at 11:32:54AM +0200, Daniel Vetter wrote:
> So we've done some experiments for the case where the fault originated
> from kernel context (copy_to|from_user and friends). The fixup code seems
> to retry the copy once after the fault (in copy_user_handle_tail), if that
> fails again we get a short read/write. This might result in an -EFAULT,
> short read()/write() or anything else really, depending upon the syscall
> api.
> 
> Except in some code paths in gpu drivers where we convert anything into
> -ERESTARTSYS/EINTR if there's a signal pending it won't ever result in the
> syscall getting restarted (well except maybe short read/writes if
> userspace bothers with that).
> 
> So I guess gpu fault handlers indeed break the kernel's expectations, but
> then I think we're getting away with that because the inner workings of
> gpu memory objects is all heavily abstracted away by opengl/vulkan and
> friends.
> 
> I guess what we could do is try to only do killable sleeps if it's a
> kernel fault, but that means wiring a flag through all the callchains. Not
> pretty. Except when there's a magic set of functions that would convert
> all interruptible sleeps to killable ones only for us.

I actually have plans to allow mutex_lock_{interruptible,killable} to
return -EWOULDBLOCK if a flag is set.  So this doesn't seem entirely
unrelated.  Something like this perhaps:

 struct task_struct {
+	unsigned int sleep_state;
 };

 static noinline int __sched
-__mutex_lock_interruptible_slowpath(struct mutex *lock)
+__mutex_lock_slowpath(struct mutex *lock, long state)
 {
-	return __mutex_lock(lock, TASK_INTERRUPTIBLE, 0, NULL, _RET_IP_);
+	if (state == TASK_NOBLOCK)
+		return -EWOULDBLOCK;
+	return __mutex_lock(lock, state, 0, NULL, _RET_IP_);
 }

+int __sched mutex_lock_state(struct mutex *lock, long state)
+{
+	might_sleep();
+
+	if (__mutex_trylock_fast(lock))
+		return 0;
+
+	return __mutex_lock_slowpath(lock, state);
+}
+EXPORT_SYMBOL(mutex_lock_state);

Then the page fault handler can do something like:

	old_state = current->sleep_state;
	current->sleep_state = TASK_INTERRUPTIBLE;
	...
	current->sleep_state = old_state;


This has the page-fault-in-a-signal-handler problem.  I don't know if
there's a way to determine if we're already in a signal handler and use
a different sleep_state ...?
