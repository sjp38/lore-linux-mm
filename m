Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id BCD636B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 12:31:14 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id f134so12178598lfg.6
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 09:31:14 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id in2si55237315wjb.3.2016.10.19.09.31.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 09:31:13 -0700 (PDT)
Date: Wed, 19 Oct 2016 18:31:12 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/6] mm: mark all calls into the vmalloc subsystem as
	potentially sleeping
Message-ID: <20161019163112.GA31091@lst.de>
References: <1476773771-11470-1-git-send-email-hch@lst.de> <1476773771-11470-3-git-send-email-hch@lst.de> <20161019111541.GQ29358@nuc-i3427.alporthouse.com> <20161019130552.GB5876@lst.de> <CALCETrVqjejgpQVUdem8RK3uxdEgfOZy4cOJqJQjCLtBDnJfyQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVqjejgpQVUdem8RK3uxdEgfOZy4cOJqJQjCLtBDnJfyQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Christoph Hellwig <hch@lst.de>, Chris Wilson <chris@chris-wilson.co.uk>, Andrew Morton <akpm@linux-foundation.org>, joelaf@google.com, jszhang@marvell.com, joaodias@google.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-rt-users@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Oct 19, 2016 at 08:34:40AM -0700, Andy Lutomirski wrote:
> 
> It would be quite awkward for a task stack to get freed from a
> sleepable context, because the obvious sleepable context is the task
> itself, and it still needs its stack.  This was true even in the old
> regime when task stacks were freed from RCU context.
> 
> But vfree has a magic automatic deferral mechanism.  Couldn't you make
> the non-deferred case might_sleep()?

But it's only magic from interrupt context..

Chris, does this patch make virtually mapped stack work for you again?

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index f2481cb..942e02d 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1533,7 +1533,7 @@ void vfree(const void *addr)
 
 	if (!addr)
 		return;
-	if (unlikely(in_interrupt())) {
+	if (in_interrupt() || in_atomic()) {
 		struct vfree_deferred *p = this_cpu_ptr(&vfree_deferred);
 		if (llist_add((struct llist_node *)addr, &p->list))
 			schedule_work(&p->wq);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
