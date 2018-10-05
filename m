Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 552666B0273
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 12:30:24 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id d29-v6so10654021wrc.3
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 09:30:24 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id l2-v6si8408331wrf.109.2018.10.05.09.30.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 05 Oct 2018 09:30:22 -0700 (PDT)
Date: Fri, 5 Oct 2018 18:30:18 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH] kasan: convert kasan/quarantine_lock to raw_spinlock
Message-ID: <20181005163018.icbknlzymwjhdehi@linutronix.de>
References: <20180918152931.17322-1-williams@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20180918152931.17322-1-williams@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Clark Williams <williams@redhat.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

On 2018-09-18 10:29:31 [-0500], Clark Williams wrote:

So I received this from Clark:

> The static lock quarantine_lock is used in mm/kasan/quarantine.c to prote=
ct
> the quarantine queue datastructures. It is taken inside quarantine queue
> manipulation routines (quarantine_put(), quarantine_reduce() and quaranti=
ne_remove_cache()),
> with IRQs disabled. This is no problem on a stock kernel but is problemat=
ic
> on an RT kernel where spin locks are converted to rt_mutex_t, which can s=
leep.
>=20
> Convert the quarantine_lock to a raw spinlock. The usage of quarantine_lo=
ck
> is confined to quarantine.c and the work performed while the lock is held=
 is limited.
>=20
> Signed-off-by: Clark Williams <williams@redhat.com>

This is the minimum to get this working on RT splat free. There is one
memory deallocation with irqs off which should work on RT in its current
way.
Once this and the on_each_cpu() invocation, I was wondering if=E2=80=A6

> ---
>  mm/kasan/quarantine.c | 18 +++++++++---------
>  1 file changed, 9 insertions(+), 9 deletions(-)
>=20
> diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
> index 3a8ddf8baf7d..b209dbaefde8 100644
> --- a/mm/kasan/quarantine.c
> +++ b/mm/kasan/quarantine.c
> @@ -103,7 +103,7 @@ static int quarantine_head;
>  static int quarantine_tail;
>  /* Total size of all objects in global_quarantine across all batches. */
>  static unsigned long quarantine_size;
> -static DEFINE_SPINLOCK(quarantine_lock);
> +static DEFINE_RAW_SPINLOCK(quarantine_lock);
>  DEFINE_STATIC_SRCU(remove_cache_srcu);
> =20
>  /* Maximum size of the global queue. */
> @@ -190,7 +190,7 @@ void quarantine_put(struct kasan_free_meta *info, str=
uct kmem_cache *cache)
>  	if (unlikely(q->bytes > QUARANTINE_PERCPU_SIZE)) {
>  		qlist_move_all(q, &temp);
> =20
> -		spin_lock(&quarantine_lock);
> +		raw_spin_lock(&quarantine_lock);
>  		WRITE_ONCE(quarantine_size, quarantine_size + temp.bytes);
>  		qlist_move_all(&temp, &global_quarantine[quarantine_tail]);
>  		if (global_quarantine[quarantine_tail].bytes >=3D
> @@ -203,7 +203,7 @@ void quarantine_put(struct kasan_free_meta *info, str=
uct kmem_cache *cache)
>  			if (new_tail !=3D quarantine_head)
>  				quarantine_tail =3D new_tail;
>  		}
> -		spin_unlock(&quarantine_lock);
> +		raw_spin_unlock(&quarantine_lock);
>  	}
> =20
>  	local_irq_restore(flags);
> @@ -230,7 +230,7 @@ void quarantine_reduce(void)
>  	 * expected case).
>  	 */
>  	srcu_idx =3D srcu_read_lock(&remove_cache_srcu);
> -	spin_lock_irqsave(&quarantine_lock, flags);
> +	raw_spin_lock_irqsave(&quarantine_lock, flags);
> =20
>  	/*
>  	 * Update quarantine size in case of hotplug. Allocate a fraction of
> @@ -254,7 +254,7 @@ void quarantine_reduce(void)
>  			quarantine_head =3D 0;
>  	}
> =20
> -	spin_unlock_irqrestore(&quarantine_lock, flags);
> +	raw_spin_unlock_irqrestore(&quarantine_lock, flags);
> =20
>  	qlist_free_all(&to_free, NULL);
>  	srcu_read_unlock(&remove_cache_srcu, srcu_idx);
> @@ -310,17 +310,17 @@ void quarantine_remove_cache(struct kmem_cache *cac=
he)
>  	 */
>  	on_each_cpu(per_cpu_remove_cache, cache, 1);
> =20
> -	spin_lock_irqsave(&quarantine_lock, flags);
> +	raw_spin_lock_irqsave(&quarantine_lock, flags);
>  	for (i =3D 0; i < QUARANTINE_BATCHES; i++) {
>  		if (qlist_empty(&global_quarantine[i]))
>  			continue;
>  		qlist_move_cache(&global_quarantine[i], &to_free, cache);
>  		/* Scanning whole quarantine can take a while. */
> -		spin_unlock_irqrestore(&quarantine_lock, flags);
> +		raw_spin_unlock_irqrestore(&quarantine_lock, flags);
>  		cond_resched();
> -		spin_lock_irqsave(&quarantine_lock, flags);
> +		raw_spin_lock_irqsave(&quarantine_lock, flags);
>  	}
> -	spin_unlock_irqrestore(&quarantine_lock, flags);
> +	raw_spin_unlock_irqrestore(&quarantine_lock, flags);
> =20
>  	qlist_free_all(&to_free, cache);
> =20
> --=20
> 2.17.1
>=20

Sebastian
