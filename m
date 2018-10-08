Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id E3D6A6B0005
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 05:16:19 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id f64-v6so18716464ioa.8
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 02:16:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t12-v6sor7056203ioa.0.2018.10.08.02.16.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Oct 2018 02:16:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20181005163320.zkacovxvlih6blpp@linutronix.de>
References: <20180918152931.17322-1-williams@redhat.com> <20181005163018.icbknlzymwjhdehi@linutronix.de>
 <20181005163320.zkacovxvlih6blpp@linutronix.de>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 8 Oct 2018 11:15:57 +0200
Message-ID: <CACT4Y+YoNCm=0C6PZtQR1V1j4QeQ0cFcJzpJF1hn34Oaht=jwg@mail.gmail.com>
Subject: Re: [PATCH] kasan: convert kasan/quarantine_lock to raw_spinlock
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Clark Williams <williams@redhat.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rt-users@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

On Fri, Oct 5, 2018 at 6:33 PM, Sebastian Andrzej Siewior
<bigeasy@linutronix.de> wrote:
> On 2018-10-05 18:30:18 [+0200], To Clark Williams wrote:
>> This is the minimum to get this working on RT splat free. There is one
>> memory deallocation with irqs off which should work on RT in its current
>> way.
>> Once this and the on_each_cpu() invocation, I was wondering if=E2=80=A6
>
> the patch at the bottom wouldn't work just fine for everyone.
> It would have the beaty of annotating the locking scope a little and
> avoiding the on_each_cpu() invocation. No local_irq_save() but actually
> the proper locking primitives.
> I haven't fully decoded the srcu part in the code.
>
> Wouldn't that work for you?

Hi Sebastian,

This seems to beak quarantine_remove_cache( ) in the sense that some
object from the cache may still be in quarantine when
quarantine_remove_cache() returns. When quarantine_remove_cache()
returns all objects from the cache must be purged from quarantine.
That srcu and irq trickery is there for a reason.
This code is also on hot path of kmallock/kfree, an additional
lock/unlock per operation is expensive. Adding 2 locked RMW per
kmalloc is not something that should be done only out of refactoring
reasons.

The original message from Clark mentions that the problem can be fixed
by just changing type of spinlock. This looks like a better and
simpler way to resolve the problem to me.


> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
>  mm/kasan/quarantine.c | 45 +++++++++++++++++++++++++------------------
>  1 file changed, 26 insertions(+), 19 deletions(-)
>
> diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
> index 3a8ddf8baf7dc..8ed595960e3c1 100644
> --- a/mm/kasan/quarantine.c
> +++ b/mm/kasan/quarantine.c
> @@ -39,12 +39,13 @@
>   * objects inside of it.
>   */
>  struct qlist_head {
> +       spinlock_t      lock;
>         struct qlist_node *head;
>         struct qlist_node *tail;
>         size_t bytes;
>  };
>
> -#define QLIST_INIT { NULL, NULL, 0 }
> +#define QLIST_INIT {.head =3D NULL, .tail =3D NULL, .bytes =3D 0 }
>
>  static bool qlist_empty(struct qlist_head *q)
>  {
> @@ -95,7 +96,9 @@ static void qlist_move_all(struct qlist_head *from, str=
uct qlist_head *to)
>   * The object quarantine consists of per-cpu queues and a global queue,
>   * guarded by quarantine_lock.
>   */
> -static DEFINE_PER_CPU(struct qlist_head, cpu_quarantine);
> +static DEFINE_PER_CPU(struct qlist_head, cpu_quarantine) =3D {
> +       .lock =3D __SPIN_LOCK_UNLOCKED(cpu_quarantine.lock),
> +};
>
>  /* Round-robin FIFO array of batches. */
>  static struct qlist_head global_quarantine[QUARANTINE_BATCHES];
> @@ -183,12 +186,13 @@ void quarantine_put(struct kasan_free_meta *info, s=
truct kmem_cache *cache)
>          * beginning which ensures that it either sees the objects in per=
-cpu
>          * lists or in the global quarantine.
>          */
> -       local_irq_save(flags);
> +       q =3D raw_cpu_ptr(&cpu_quarantine);
> +       spin_lock_irqsave(&q->lock, flags);
>
> -       q =3D this_cpu_ptr(&cpu_quarantine);
>         qlist_put(q, &info->quarantine_link, cache->size);
>         if (unlikely(q->bytes > QUARANTINE_PERCPU_SIZE)) {
>                 qlist_move_all(q, &temp);
> +               spin_unlock(&q->lock);
>
>                 spin_lock(&quarantine_lock);
>                 WRITE_ONCE(quarantine_size, quarantine_size + temp.bytes)=
;
> @@ -203,10 +207,10 @@ void quarantine_put(struct kasan_free_meta *info, s=
truct kmem_cache *cache)
>                         if (new_tail !=3D quarantine_head)
>                                 quarantine_tail =3D new_tail;
>                 }
> -               spin_unlock(&quarantine_lock);
> +               spin_unlock_irqrestore(&quarantine_lock, flags);
> +       } else {
> +               spin_unlock_irqrestore(&q->lock, flags);
>         }
> -
> -       local_irq_restore(flags);
>  }
>
>  void quarantine_reduce(void)
> @@ -284,21 +288,11 @@ static void qlist_move_cache(struct qlist_head *fro=
m,
>         }
>  }
>
> -static void per_cpu_remove_cache(void *arg)
> -{
> -       struct kmem_cache *cache =3D arg;
> -       struct qlist_head to_free =3D QLIST_INIT;
> -       struct qlist_head *q;
> -
> -       q =3D this_cpu_ptr(&cpu_quarantine);
> -       qlist_move_cache(q, &to_free, cache);
> -       qlist_free_all(&to_free, cache);
> -}
> -
>  /* Free all quarantined objects belonging to cache. */
>  void quarantine_remove_cache(struct kmem_cache *cache)
>  {
>         unsigned long flags, i;
> +       unsigned int cpu;
>         struct qlist_head to_free =3D QLIST_INIT;
>
>         /*
> @@ -308,7 +302,20 @@ void quarantine_remove_cache(struct kmem_cache *cach=
e)
>          * achieves the first goal, while synchronize_srcu() achieves the
>          * second.
>          */
> -       on_each_cpu(per_cpu_remove_cache, cache, 1);
> +       /* get_online_cpus() invoked by caller */
> +       for_each_online_cpu(cpu) {
> +               struct qlist_head *q;
> +               unsigned long flags;
> +               struct qlist_head to_free =3D QLIST_INIT;
> +
> +               q =3D per_cpu_ptr(&cpu_quarantine, cpu);
> +               spin_lock_irqsave(&q->lock, flags);
> +               qlist_move_cache(q, &to_free, cache);
> +               spin_unlock_irqrestore(&q->lock, flags);
> +
> +               qlist_free_all(&to_free, cache);
> +
> +       }
>
>         spin_lock_irqsave(&quarantine_lock, flags);
>         for (i =3D 0; i < QUARANTINE_BATCHES; i++) {
> --
> 2.19.0
>
