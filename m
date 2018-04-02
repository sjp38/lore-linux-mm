Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 971296B0022
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 10:11:00 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d6-v6so3286954plo.2
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 07:11:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v72si279728pgb.333.2018.04.02.07.10.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 02 Apr 2018 07:10:59 -0700 (PDT)
Date: Mon, 2 Apr 2018 07:10:58 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Signal handling in a page fault handler
Message-ID: <20180402141058.GL13332@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Souptick Joarder <jrdr.linux@gmail.com>
Cc: linux-kernel@vger.kernel.org


Souptick and I have been auditing the various page fault handler routines
and we've noticed that graphics drivers assume that a signal should be
able to interrupt a page fault.  In contrast, the page cache takes great
care to allow only fatal signals to interrupt a page fault.

I believe (but have not verified) that a non-fatal signal being delivered
to a task which is in the middle of a page fault may well end up in an
infinite loop, attempting to handle the page fault and failing forever.

Here's one of the simpler ones:

        ret = mutex_lock_interruptible(&etnaviv_obj->lock);
        if (ret)
                return VM_FAULT_NOPAGE;

(many other drivers do essentially the same thing including i915)

On seeing NOPAGE, the fault handler believes the PTE is in the page
table, so does nothing before it returns to arch code at which point
I get lost in the magic assembler macros.  I believe it will end up
returning to userspace if the signal is non-fatal, at which point it'll
go right back into the page fault handler, and mutex_lock_interruptible()
will immediately fail.  So we've converted a sleeping lock into the most
expensive spinlock.

I don't think the graphics drivers really want to be interrupted by
any signal.  I think they want to be interruptible by fatal signals
and should use the mutex_lock_killable / fatal_signal_pending family of
functions.  That's going to be a bit of churn, funnelling TASK_KILLABLE
/ TASK_INTERRUPTIBLE all the way down into the dma-fence code.  Before
anyone gets started on that, I want to be sure that my analysis is
correct, and the drivers are doing the wrong thing by using interruptible
waits in a page fault handler.
