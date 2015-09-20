Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9A7766B0253
	for <linux-mm@kvack.org>; Sun, 20 Sep 2015 08:59:46 -0400 (EDT)
Received: by qgev79 with SMTP id v79so71200390qge.0
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 05:59:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 34si17026032qgb.89.2015.09.20.05.59.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Sep 2015 05:59:45 -0700 (PDT)
Date: Sun, 20 Sep 2015 14:56:42 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: can't oom-kill zap the victim's memory?
Message-ID: <20150920125642.GA2104@redhat.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com> <20150919150316.GB31952@redhat.com> <CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On 09/19, Linus Torvalds wrote:
>
> On Sat, Sep 19, 2015 at 8:03 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> > +
> > +static void oom_unmap_func(struct work_struct *work)
> > +{
> > +       struct mm_struct *mm = xchg(&oom_unmap_mm, NULL);
> > +
> > +       if (!atomic_inc_not_zero(&mm->mm_users))
> > +               return;
> > +
> > +       // If this is not safe we can do use_mm() + unuse_mm()
> > +       down_read(&mm->mmap_sem);
>
> I don't think this is safe.
>
> What makes you sure that we might not deadlock on the mmap_sem here?
> For all we know, the process that is going out of memory is in the
> middle of a mmap(), and already holds the mmap_sem for writing. No?

In this case the workqueue thread will block. But it can not block
forever. I mean if it can then the killed process will never exit
(exit_mm does down_read) and release its memory, so we lose anyway.

But let me repeat this patch is obviously not complete/etc,

> So at the very least that needs to be a trylock, I think.

And we want to avoid using workqueues when the caller can do this
directly. And in this case we certainly need trylock. But this needs
some refactoring: we do not want to do this under oom_lock, otoh it
makes sense to do this from mark_oom_victim() if current && killed,
and a lot more details.

The workqueue thread has other reasons for trylock, but probably not
in the initial version of this patch. And perhaps we should use a
dedicated kthread and do not use workqueues at all. And yes, a single
"mm_struct *oom_unmap_mm" is ugly, it should be the list of mm's to
unmap, but then at least we need MMF_MEMDIE.

> And I'm not
> sure zap_page_range() is ok with the mmap_sem only held for reading.
> Normally our rule is that you can *populate* the page tables
> concurrently, but you can't tear the down.

Well, according to madvise_need_mmap_write() MADV_DONTNEED does this
under down_read().

But yes, yes, this is probably not right anyway. Say, VM_LOCKED...
That is why I mentioned that perhaps this should only unmap the
anonymous pages. We can probably add zap_details->for_oom hint.



Another question if it is safe to abuse the foreign mm this way.
Well, zap_page_range_single() does this, so this is probably safe.
But we can do use_mm().

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
