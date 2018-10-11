Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id AC35D6B0006
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 04:03:28 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id y73-v6so8919779ita.2
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 01:03:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r10-v6sor11126179iog.108.2018.10.11.01.03.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Oct 2018 01:03:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20181010214945.5owshc3mlrh74z4b@linutronix.de>
References: <20180918152931.17322-1-williams@redhat.com> <20181005163018.icbknlzymwjhdehi@linutronix.de>
 <20181005163320.zkacovxvlih6blpp@linutronix.de> <CACT4Y+YoNCm=0C6PZtQR1V1j4QeQ0cFcJzpJF1hn34Oaht=jwg@mail.gmail.com>
 <20181009142742.ikh7xv2dn5skjjbe@linutronix.de> <CACT4Y+ZB38pKvT8+BAjDZ1t4ZjXQQKoya+ytXT+ASQxHUkWwnA@mail.gmail.com>
 <20181010092929.a5gd3fkkw6swco4c@linutronix.de> <CACT4Y+agGPSTZ-8A8r8haSeRM8UpRYMAF8BC4A87yeM9nvpP6w@mail.gmail.com>
 <20181010095343.6qxved3owi6yokoa@linutronix.de> <CACT4Y+ZpMjYBPS0GHP0AsEJZZmDjwV9DJBiVUzYKBnD+r9W4+A@mail.gmail.com>
 <20181010214945.5owshc3mlrh74z4b@linutronix.de>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 11 Oct 2018 10:03:06 +0200
Message-ID: <CACT4Y+Zj0pBR_C-6fcMkFkrkKh-LwDupNHDz=ud7HJomtvFUVw@mail.gmail.com>
Subject: Re: [PATCH] mm/kasan: make quarantine_lock a raw_spinlock_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Clark Williams <williams@redhat.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rt-users@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Oct 10, 2018 at 11:49 PM, Sebastian Andrzej Siewior
<bigeasy@linutronix.de> wrote:
> From: Clark Williams <williams@redhat.com>
> Date: Tue, 18 Sep 2018 10:29:31 -0500
>
> The static lock quarantine_lock is used in quarantine.c to protect the
> quarantine queue datastructures. It is taken inside quarantine queue
> manipulation routines (quarantine_put(), quarantine_reduce() and
> quarantine_remove_cache()), with IRQs disabled.
> This is not a problem on a stock kernel but is problematic on an RT
> kernel where spin locks are sleeping spinlocks, which can sleep and can
> not be acquired with disabled interrupts.
>
> Convert the quarantine_lock to a raw spinlock_t. The usage of
> quarantine_lock is confined to quarantine.c and the work performed while
> the lock is held is used for debug purpose.
>
> Signed-off-by: Clark Williams <williams@redhat.com>
> Acked-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> [bigeasy: slightly altered the commit message]
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Acked-by: Dmitry Vyukov <dvyukov@google.com>

> ---
> On 2018-10-10 11:57:41 [+0200], Dmitry Vyukov wrote:
>> Yes. Clark's patch looks good to me. Probably would be useful to add a
>> comment as to why raw spinlock is used (otherwise somebody may
>> refactor it back later).
>
> If you really insist, I could add something but this didn't happen so
> far. git's changelog should provide enough information why to why it was
> changed.
>
>  mm/kasan/quarantine.c |   18 +++++++++---------
>  1 file changed, 9 insertions(+), 9 deletions(-)
>
> --- a/mm/kasan/quarantine.c
> +++ b/mm/kasan/quarantine.c
> @@ -103,7 +103,7 @@ static int quarantine_head;
>  static int quarantine_tail;
>  /* Total size of all objects in global_quarantine across all batches. */
>  static unsigned long quarantine_size;
> -static DEFINE_SPINLOCK(quarantine_lock);
> +static DEFINE_RAW_SPINLOCK(quarantine_lock);
>  DEFINE_STATIC_SRCU(remove_cache_srcu);
>
>  /* Maximum size of the global queue. */
> @@ -190,7 +190,7 @@ void quarantine_put(struct kasan_free_me
>         if (unlikely(q->bytes > QUARANTINE_PERCPU_SIZE)) {
>                 qlist_move_all(q, &temp);
>
> -               spin_lock(&quarantine_lock);
> +               raw_spin_lock(&quarantine_lock);
>                 WRITE_ONCE(quarantine_size, quarantine_size + temp.bytes);
>                 qlist_move_all(&temp, &global_quarantine[quarantine_tail]);
>                 if (global_quarantine[quarantine_tail].bytes >=
> @@ -203,7 +203,7 @@ void quarantine_put(struct kasan_free_me
>                         if (new_tail != quarantine_head)
>                                 quarantine_tail = new_tail;
>                 }
> -               spin_unlock(&quarantine_lock);
> +               raw_spin_unlock(&quarantine_lock);
>         }
>
>         local_irq_restore(flags);
> @@ -230,7 +230,7 @@ void quarantine_reduce(void)
>          * expected case).
>          */
>         srcu_idx = srcu_read_lock(&remove_cache_srcu);
> -       spin_lock_irqsave(&quarantine_lock, flags);
> +       raw_spin_lock_irqsave(&quarantine_lock, flags);
>
>         /*
>          * Update quarantine size in case of hotplug. Allocate a fraction of
> @@ -254,7 +254,7 @@ void quarantine_reduce(void)
>                         quarantine_head = 0;
>         }
>
> -       spin_unlock_irqrestore(&quarantine_lock, flags);
> +       raw_spin_unlock_irqrestore(&quarantine_lock, flags);
>
>         qlist_free_all(&to_free, NULL);
>         srcu_read_unlock(&remove_cache_srcu, srcu_idx);
> @@ -310,17 +310,17 @@ void quarantine_remove_cache(struct kmem
>          */
>         on_each_cpu(per_cpu_remove_cache, cache, 1);
>
> -       spin_lock_irqsave(&quarantine_lock, flags);
> +       raw_spin_lock_irqsave(&quarantine_lock, flags);
>         for (i = 0; i < QUARANTINE_BATCHES; i++) {
>                 if (qlist_empty(&global_quarantine[i]))
>                         continue;
>                 qlist_move_cache(&global_quarantine[i], &to_free, cache);
>                 /* Scanning whole quarantine can take a while. */
> -               spin_unlock_irqrestore(&quarantine_lock, flags);
> +               raw_spin_unlock_irqrestore(&quarantine_lock, flags);
>                 cond_resched();
> -               spin_lock_irqsave(&quarantine_lock, flags);
> +               raw_spin_lock_irqsave(&quarantine_lock, flags);
>         }
> -       spin_unlock_irqrestore(&quarantine_lock, flags);
> +       raw_spin_unlock_irqrestore(&quarantine_lock, flags);
>
>         qlist_free_all(&to_free, cache);
>
