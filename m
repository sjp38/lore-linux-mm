Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id C19076B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 09:23:48 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so25011761wic.0
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 06:23:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ht8si3828189wib.54.2015.10.08.06.23.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Oct 2015 06:23:47 -0700 (PDT)
Date: Thu, 8 Oct 2015 06:23:31 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH -next] mm/vmacache: inline vmacache_valid_mm()
Message-ID: <20151008132331.GC3353@linux-uzut.site>
References: <1444277879-22039-1-git-send-email-dave@stgolabs.net>
 <20151008062115.GA876@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20151008062115.GA876@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Thu, 08 Oct 2015, Sergey Senozhatsky wrote:

>After moving vmacache_update() and vmacache_valid_mm() to include/linux/vmacache.h
>(both `static inline')
>
>
>./scripts/bloat-o-meter vmlinux.o.old vmlinux.o
>add/remove: 0/1 grow/shrink: 1/0 up/down: 22/-54 (-32)
>function                                     old     new   delta
>find_vma                                      97     119     +22
>vmacache_update                               54       -     -54
>
>
>Something like this, perhaps?

iirc we actually had something like this in its original form, and akpm was forced
to move things around for all users to be happy and not break the build. But yeah,
that vmacache_update() could certainly be inlined if we can have it so. It's no
where near as hot a path as the mm validity check (we have a good hit rate), but still
seems reasonable.

>
>---
>
> include/linux/vmacache.h | 21 ++++++++++++++++++++-
> mm/vmacache.c            | 20 --------------------
> 2 files changed, 20 insertions(+), 21 deletions(-)
>
>diff --git a/include/linux/vmacache.h b/include/linux/vmacache.h
>index c3fa0fd4..0ec750b 100644
>--- a/include/linux/vmacache.h
>+++ b/include/linux/vmacache.h
>@@ -15,8 +15,27 @@ static inline void vmacache_flush(struct task_struct *tsk)
> 	memset(tsk->vmacache, 0, sizeof(tsk->vmacache));
> }
>
>+/*
>+ * This task may be accessing a foreign mm via (for example)
>+ * get_user_pages()->find_vma().  The vmacache is task-local and this
>+ * task's vmacache pertains to a different mm (ie, its own).  There is
>+ * nothing we can do here.
>+ *
>+ * Also handle the case where a kernel thread has adopted this mm via use_mm().
>+ * That kernel thread's vmacache is not applicable to this mm.
>+ */
>+static bool vmacache_valid_mm(struct mm_struct *mm)

This needs (explicit) inlined, no?

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
