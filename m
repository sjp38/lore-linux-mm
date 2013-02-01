Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 50D716B0005
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 05:24:50 -0500 (EST)
Received: by mail-we0-f181.google.com with SMTP id t44so2793467wey.26
        for <linux-mm@kvack.org>; Fri, 01 Feb 2013 02:24:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <0000013c695fbea7-9472355c-ccb3-4aa3-ba3d-2ecd6afb2e5a-000000@email.amazonses.com>
References: <20130123214514.370647954@linux.com>
	<0000013c695fbea7-9472355c-ccb3-4aa3-ba3d-2ecd6afb2e5a-000000@email.amazonses.com>
Date: Fri, 1 Feb 2013 12:24:47 +0200
Message-ID: <CAOJsxLFQt+Yq-n5QABgGczUjiaAGCJMwHZJwzWnpAKDCtKvabA@mail.gmail.com>
Subject: Re: FIX [2/2] slub: tid must be retrieved from the percpu area of the
 current processor.
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, RT <linux-rt-users@vger.kernel.org>, Clark Williams <clark@redhat.com>, John Kacur <jkacur@gmail.com>, "Luis Claudio R. Goncalves" <lgoncalv@redhat.com>, Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On Wed, Jan 23, 2013 at 11:45 PM, Christoph Lameter <cl@linux.com> wrote:
> As Steven Rostedt has pointer out: Rescheduling could occur on a differnet processor
> after the determination of the per cpu pointer and before the tid is retrieved.
> This could result in allocation from the wrong node in slab_alloc.
>
> The effect is much more severe in slab_free() where we could free to the freelist
> of the wrong page.
>
> The window for something like that occurring is pretty small but it is possible.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Okay, makes sense. Has anyone triggered this in practice? Do we want
to tag this for -stable?

>
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c        2013-01-23 15:06:39.805154107 -0600
> +++ linux/mm/slub.c     2013-01-23 15:24:47.656868067 -0600
> @@ -2331,13 +2331,18 @@ static __always_inline void *slab_alloc_
>
>         s = memcg_kmem_get_cache(s, gfpflags);
>  redo:
> -
>         /*
>          * Must read kmem_cache cpu data via this cpu ptr. Preemption is
>          * enabled. We may switch back and forth between cpus while
>          * reading from one cpu area. That does not matter as long
>          * as we end up on the original cpu again when doing the cmpxchg.
> +        *
> +        * Preemption is disabled for the retrieval of the tid because that
> +        * must occur from the current processor. We cannot allow rescheduling
> +        * on a different processor between the determination of the pointer
> +        * and the retrieval of the tid.
>          */
> +       preempt_disable();
>         c = __this_cpu_ptr(s->cpu_slab);
>
>         /*
> @@ -2347,7 +2352,7 @@ redo:
>          * linked list in between.
>          */
>         tid = c->tid;
> -       barrier();
> +       preempt_enable();
>
>         object = c->freelist;
>         page = c->page;
> @@ -2594,10 +2599,11 @@ redo:
>          * data is retrieved via this pointer. If we are on the same cpu
>          * during the cmpxchg then the free will succedd.
>          */
> +       preempt_disable();
>         c = __this_cpu_ptr(s->cpu_slab);
>
>         tid = c->tid;
> -       barrier();
> +       preempt_enable();
>
>         if (likely(page == c->page)) {
>                 set_freepointer(s, object, c->freelist);
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
