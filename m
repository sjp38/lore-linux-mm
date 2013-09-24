Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id C3BF16B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 19:22:57 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so5257656pdj.31
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 16:22:57 -0700 (PDT)
Received: by mail-bk0-f45.google.com with SMTP id mx11so2003324bkb.32
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 16:22:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1380061346.3467.50.camel@schen9-DESK>
References: <cover.1380057198.git.tim.c.chen@linux.intel.com>
	<1380061346.3467.50.camel@schen9-DESK>
Date: Tue, 24 Sep 2013 16:22:53 -0700
Message-ID: <CAGQ1y=7okjk0AZaH-WNn33vkpyhT8Z-eNDJr1CiqW4jK9OnVFw@mail.gmail.com>
Subject: Re: [PATCH v5 1/6] rwsem: check the lock before cpmxchg in down_write_trylock
From: Jason Low <jason.low2@hp.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

Should we do something similar with __down_read_trylock, such as
the following?


Signed-off-by: Jason Low <jason.low2@hp.com>
---
 include/asm-generic/rwsem.h |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/asm-generic/rwsem.h b/include/asm-generic/rwsem.h
index bb1e2cd..47990dc 100644
--- a/include/asm-generic/rwsem.h
+++ b/include/asm-generic/rwsem.h
@@ -42,6 +42,9 @@ static inline int __down_read_trylock(struct
rw_semaphore *sem)
        long tmp;

        while ((tmp = sem->count) >= 0) {
+               if (sem->count != tmp)
+                       continue;
+
                if (tmp == cmpxchg(&sem->count, tmp,
                                   tmp + RWSEM_ACTIVE_READ_BIAS)) {
                        return 1;
-- 
1.7.1

On Tue, Sep 24, 2013 at 3:22 PM, Tim Chen <tim.c.chen@linux.intel.com> wrote:
> Cmpxchg will cause the cacheline bouning when do the value checking,
> that cause scalability issue in a large machine (like a 80 core box).
>
> So a lock pre-read can relief this contention.
>
> Signed-off-by: Alex Shi <alex.shi@intel.com>
> ---
>  include/asm-generic/rwsem.h |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/include/asm-generic/rwsem.h b/include/asm-generic/rwsem.h
> index bb1e2cd..5ba80e7 100644
> --- a/include/asm-generic/rwsem.h
> +++ b/include/asm-generic/rwsem.h
> @@ -70,11 +70,11 @@ static inline void __down_write(struct rw_semaphore *sem)
>
>  static inline int __down_write_trylock(struct rw_semaphore *sem)
>  {
> -       long tmp;
> +       if (unlikely(sem->count != RWSEM_UNLOCKED_VALUE))
> +               return 0;
>
> -       tmp = cmpxchg(&sem->count, RWSEM_UNLOCKED_VALUE,
> -                     RWSEM_ACTIVE_WRITE_BIAS);
> -       return tmp == RWSEM_UNLOCKED_VALUE;
> +       return cmpxchg(&sem->count, RWSEM_UNLOCKED_VALUE,
> +                     RWSEM_ACTIVE_WRITE_BIAS) == RWSEM_UNLOCKED_VALUE;
>  }
>
>  /*
> --
> 1.7.4.4
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
