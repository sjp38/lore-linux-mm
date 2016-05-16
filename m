Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 245D76B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 11:57:34 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id x189so403554657ywe.2
        for <linux-mm@kvack.org>; Mon, 16 May 2016 08:57:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r79si23494344qha.41.2016.05.16.08.57.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 08:57:33 -0700 (PDT)
Date: Mon, 16 May 2016 17:57:29 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/1] userfaultfd: don't pin the user memory in
 userfaultfd_file_create()
Message-ID: <20160516155729.GH550@redhat.com>
References: <20160516152522.GA19120@redhat.com>
 <20160516152546.GA19129@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160516152546.GA19129@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, May 16, 2016 at 05:25:46PM +0200, Oleg Nesterov wrote:
> userfaultfd_file_create() increments mm->mm_users; this means that the memory
> won't be unmapped/freed if mm owner exits/execs, and UFFDIO_COPY after that can
> populate the orphaned mm more.
> 
> Change userfaultfd_file_create() and userfaultfd_ctx_put() to use mm->mm_count
> to pin mm_struct. This means that atomic_inc_not_zero(mm->mm_users) is needed
> when we are going to actually play with this memory. Except handle_userfault()
> path doesn't need this, the caller must already have a reference.

This is nice and desired improvement to reduce the pinning from the
"mm" as a whole to just the "mm struct". The code used mm_users for
simplicity, but using mm_count was definitely wanted to always keep
the memory footprint as low as possible (especially to avoid some
latency in the footprint reduction in the future non-cooperative
usage).

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

> +static inline bool userfaultfd_get_mm(struct userfaultfd_ctx *ctx)
> +{
> +	return atomic_inc_not_zero(&ctx->mm->mm_users);
> +}

Nice cleanup, but wouldn't it be more generic to implement this as
mmget(&ctx->mm) (or maybe mmget_not_zero) in include/linux/mm.h
instead of userfaultfd.c, so then others can use it too, see:

drivers/gpu/drm/i915/i915_gem_userptr.c:                if (atomic_inc_not_zero(&mm->mm_users)) {
drivers/iommu/intel-svm.c:              if (!atomic_inc_not_zero(&svm->mm->mm_users))
fs/proc/base.c: if (!atomic_inc_not_zero(&mm->mm_users))
fs/proc/base.c: if (!atomic_inc_not_zero(&mm->mm_users))
fs/proc/task_mmu.c:     if (!mm || !atomic_inc_not_zero(&mm->mm_users))
fs/proc/task_mmu.c:     if (!mm || !atomic_inc_not_zero(&mm->mm_users))
fs/proc/task_nommu.c:   if (!mm || !atomic_inc_not_zero(&mm->mm_users))
kernel/events/uprobes.c:                if (!atomic_inc_not_zero(&vma->vm_mm->mm_users))
mm/oom_kill.c:  if (!atomic_inc_not_zero(&mm->mm_users)) {
mm/swapfile.c:                          if (!atomic_inc_not_zero(&mm->mm_users))

Anyway this is just an idea, userfaultfd_get_mm is sure fine with me.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
