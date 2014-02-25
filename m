Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 16DC76B00C3
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 14:04:04 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id va2so6176836obc.9
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 11:04:03 -0800 (PST)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id sp3si13867351obb.108.2014.02.25.11.04.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 11:04:03 -0800 (PST)
Message-ID: <1393355040.2577.52.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v2] mm: per-thread vma caching
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 25 Feb 2014 11:04:00 -0800
In-Reply-To: <CA+55aFzPYZnkSQa=Y4Uo3zMVUVdchVxN2S266KyZLu-yJ314pw@mail.gmail.com>
References: <1393352206.2577.36.camel@buesod1.americas.hpqcorp.net>
	 <CA+55aFzPYZnkSQa=Y4Uo3zMVUVdchVxN2S266KyZLu-yJ314pw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, "Norton, Scott J" <scott.norton@hp.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, 2014-02-25 at 10:37 -0800, Linus Torvalds wrote:
> On Tue, Feb 25, 2014 at 10:16 AM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> > index a17621c..14396bf 100644
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -363,7 +363,12 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
> >
> >         mm->locked_vm = 0;
> >         mm->mmap = NULL;
> > -       mm->mmap_cache = NULL;
> > +       mm->vmacache_seqnum = oldmm->vmacache_seqnum + 1;
> > +
> > +       /* deal with overflows */
> > +       if (unlikely(mm->vmacache_seqnum == 0))
> > +               vmacache_invalidate_all();
> 
> Correct me if I'm wrong, but this can not possibly be correct.
> 
> vmacache_invalidate_all() walks over all the threads of the current
> process, but "mm" here is the mm of the *new* process that is getting
> created, and is unrelated in all ways to the threads of the old
> process.

vmacache_invalidate_all() is actually a misleading name since we really
aren't invalidating but just clearing the cache. I'll rename it.
Anyways...

> So it walks completely the wrong list of threads.

But we still need to deal with the rest of the tasks in the system, so
anytime there's an overflow we need to nullify all cached vmas, not just
current's. Am I missing something special about fork?

> In fact, the sequence number of the old vm and the sequence number of
> the new vm cannot in any way be related.
> 
> As far as I can tell, the only sane thing to do at fork/clone() time is to:
> 
>  - clear all the cache entries (of the new 'struct task_struct'! - so
> not in dup_mmap, but make sure it's zeroed when allocating!)(

Right, but that's done upon the first lookup, when vmacache_valid() is
false.

>  - set vmcache_seqnum to 0 in dup_mmap (since any sequence number is
> fine when it got invalidated, and 0 is best for "avoid overflow").

Assuming your referring to curr->vmacache_seqnum (since mm's is already
set).. isn't it irrelevant since we set it anyways when the first lookup
fails?

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
