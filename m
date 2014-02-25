Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f170.google.com (mail-ve0-f170.google.com [209.85.128.170])
	by kanga.kvack.org (Postfix) with ESMTP id AE15E6B00D6
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 13:37:38 -0500 (EST)
Received: by mail-ve0-f170.google.com with SMTP id c14so935067vea.29
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 10:37:38 -0800 (PST)
Received: from mail-vc0-x22e.google.com (mail-vc0-x22e.google.com [2607:f8b0:400c:c03::22e])
        by mx.google.com with ESMTPS id dp5si7045853vec.33.2014.02.25.10.37.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 10:37:38 -0800 (PST)
Received: by mail-vc0-f174.google.com with SMTP id im17so7587113vcb.5
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 10:37:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1393352206.2577.36.camel@buesod1.americas.hpqcorp.net>
References: <1393352206.2577.36.camel@buesod1.americas.hpqcorp.net>
Date: Tue, 25 Feb 2014 10:37:37 -0800
Message-ID: <CA+55aFzPYZnkSQa=Y4Uo3zMVUVdchVxN2S266KyZLu-yJ314pw@mail.gmail.com>
Subject: Re: [PATCH v2] mm: per-thread vma caching
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, "Norton, Scott J" <scott.norton@hp.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Feb 25, 2014 at 10:16 AM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> index a17621c..14396bf 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -363,7 +363,12 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
>
>         mm->locked_vm = 0;
>         mm->mmap = NULL;
> -       mm->mmap_cache = NULL;
> +       mm->vmacache_seqnum = oldmm->vmacache_seqnum + 1;
> +
> +       /* deal with overflows */
> +       if (unlikely(mm->vmacache_seqnum == 0))
> +               vmacache_invalidate_all();

Correct me if I'm wrong, but this can not possibly be correct.

vmacache_invalidate_all() walks over all the threads of the current
process, but "mm" here is the mm of the *new* process that is getting
created, and is unrelated in all ways to the threads of the old
process.

So it walks completely the wrong list of threads.

In fact, the sequence number of the old vm and the sequence number of
the new vm cannot in any way be related.

As far as I can tell, the only sane thing to do at fork/clone() time is to:

 - clear all the cache entries (of the new 'struct task_struct'! - so
not in dup_mmap, but make sure it's zeroed when allocating!)(

 - set vmcache_seqnum to 0 in dup_mmap (since any sequence number is
fine when it got invalidated, and 0 is best for "avoid overflow").

but I haven't thought deeply about this, but I pretty much guarantee
that the quoted sequence above is wrong as-is.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
