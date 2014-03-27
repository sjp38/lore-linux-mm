Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f175.google.com (mail-vc0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id CBCBE6B0031
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 14:16:40 -0400 (EDT)
Received: by mail-vc0-f175.google.com with SMTP id lh14so4649567vcb.20
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 11:16:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140327134653.GA22407@kvack.org>
References: <20140327134653.GA22407@kvack.org>
Date: Thu, 27 Mar 2014 11:16:38 -0700
Message-ID: <CA+55aFzFgY4-26SO-MsFagzaj9JevkeeT1OJ3pjj-tcjuNCEeQ@mail.gmail.com>
Subject: Re: git pull -- [PATCH] aio: v2 ensure access to ctx->ring_pages is
 correctly serialised
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Sasha Levin <sasha.levin@oracle.com>, Tang Chen <tangchen@cn.fujitsu.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, linux-aio@kvack.org, linux-mm <linux-mm@kvack.org>

On Thu, Mar 27, 2014 at 6:46 AM, Benjamin LaHaise <bcrl@kvack.org> wrote:
>
> Please pull the change below from my aio-fixes git repository

Ugh. This is way late in the release, and the patch makes me go: "This
is completely insane", which doesn't really help.

>
>  static void aio_free_ring(struct kioctx *ctx)
>  {
> +       unsigned long flags;
>         int i;
>
> +       spin_lock_irqsave(&ctx->completion_lock, flags);
>         for (i = 0; i < ctx->nr_pages; i++) {
>                 struct page *page;
>                 pr_debug("pid(%d) [%d] page->count=%d\n", current->pid, i,
> @@ -253,6 +255,7 @@ static void aio_free_ring(struct kioctx *ctx)
>                 ctx->ring_pages[i] = NULL;
>                 put_page(page);
>         }
> +       spin_unlock_irqrestore(&ctx->completion_lock, flags);

This is just pure bullshit.

aio_free_ring() is called before ctx is free'd, so if something can
race with it, then you have some seriously big problems.

So the above locking change is at least terminally stupid, and at most
a sign of something much much worse.

And quite frankly, in either case it sounds like a bad idea for me to
pull this change after rc8.

>From what I can tell, the *sane* solution is to just move the
"put_aio_ring_file()" to *before* this whole loop, which should mean
that migratepages cannot possible access the context any more (and
dammit, exactly because 'ctx' is generally immediately free'd after
this function, that had *better* be true).

So taking the completion_lock here really screams to me: "This patch is broken".

> @@ -556,9 +582,17 @@ static int ioctx_add_table(struct kioctx *ctx, struct mm_struct *mm)
>                                         rcu_read_unlock();
>                                         spin_unlock(&mm->ioctx_lock);
>
> +                                       /*
> +                                        * Accessing ring pages must be done
> +                                        * holding ctx->completion_lock to
> +                                        * prevent aio ring page migration
> +                                        * procedure from migrating ring pages.
> +                                        */
> +                                       spin_lock_irq(&ctx->completion_lock);
>                                         ring = kmap_atomic(ctx->ring_pages[0]);
>                                         ring->id = ctx->id;
>                                         kunmap_atomic(ring);
> +                                       spin_unlock_irq(&ctx->completion_lock);
>                                         return 0;
>                                 }

And quite frankly, this smells too.

Question to people following around: Why does this particular access
to the first page need the completion_lock(), but the earlier accesses
in "aio_setup_ring()" does not?

Answer: the locking is broken, idiotic, and totally not architected.
The caller (which is the same in both cases: ioctx_alloc()) randomly
takes one lock in one case but not the other.

> -       if (aio_setup_ring(ctx) < 0)
> +       /* Prevent races with page migration in aio_setup_ring() by holding
> +        * the ring_lock mutex.
> +        */
> +       mutex_lock(&ctx->ring_lock);
> +       err = aio_setup_ring(ctx);
> +       mutex_unlock(&ctx->ring_lock);
> +       if (err < 0)
>                 goto err;
>
>         atomic_set(&ctx->reqs_available, ctx->nr_events - 1);

but a few lines later when we call ioctx_add_table(), we don't do it
under that lock.

It would all be cleaner if all the setup was done with the
ctx->ring_lock held (you can even *initialize* it to the locked state,
since this is the function that allocates it!) and then it would just
be unlocked when done. But no. The locking is some ad-hoc random stuff
that makes no sense.

So to make a long sad story short: there is no way in hell I will
apply this obviously crap patch this late in the game. Because this
patch is just inexcusable crap, and it should *not* have been sent to
me in this state. If I can see these kinds of obvious problems with
it, it damn well shouldn't go into stable or into rc8.

And if I'm wrong, and the "obvious problems" are actually due to
subtle effects that are so subtle that I can't see them, they need
bigger explanations in the commit message. But from what I can see,
it's really just the patch being stupid and nobody spent the time
asking themselves: "What should the locking really look like?".

Because here's a hint: if you need locks at tear-down, you're almost
certainly doing something wrong, because you are tearing down data
structures that shouldn't be reachable.

That rule really is a good rule to follow. It's why I started looking
at the patch and going "this can't be right". Learn it. Please think
about locking, and make it make sense - don't just add random locks to
random places to "fix bugs".

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
