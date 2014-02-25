Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f173.google.com (mail-ve0-f173.google.com [209.85.128.173])
	by kanga.kvack.org (Postfix) with ESMTP id B69426B004D
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 13:45:52 -0500 (EST)
Received: by mail-ve0-f173.google.com with SMTP id jw12so924321veb.18
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 10:45:52 -0800 (PST)
Received: from mail-vc0-x22a.google.com (mail-vc0-x22a.google.com [2607:f8b0:400c:c03::22a])
        by mx.google.com with ESMTPS id zp2si7054828vec.46.2014.02.25.10.45.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 10:45:52 -0800 (PST)
Received: by mail-vc0-f170.google.com with SMTP id hu8so7867721vcb.1
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 10:45:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzPYZnkSQa=Y4Uo3zMVUVdchVxN2S266KyZLu-yJ314pw@mail.gmail.com>
References: <1393352206.2577.36.camel@buesod1.americas.hpqcorp.net>
	<CA+55aFzPYZnkSQa=Y4Uo3zMVUVdchVxN2S266KyZLu-yJ314pw@mail.gmail.com>
Date: Tue, 25 Feb 2014 10:45:51 -0800
Message-ID: <CA+55aFxdUOALfQketaSAA9B_Da+n=hSvC5XswV+5cpmnyLwiFw@mail.gmail.com>
Subject: Re: [PATCH v2] mm: per-thread vma caching
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, "Norton, Scott J" <scott.norton@hp.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Feb 25, 2014 at 10:37 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
>  - clear all the cache entries (of the new 'struct task_struct'! - so
> not in dup_mmap, but make sure it's zeroed when allocating!)(
>
>  - set vmcache_seqnum to 0 in dup_mmap (since any sequence number is
> fine when it got invalidated, and 0 is best for "avoid overflow").

Btw, as far as I can tell, that also makes the per-thread vmacache
automatically do the right thing for the non-MMU case, so that you
could just remove the difference between CONFIG_MMU and NOMMU.

Basically, dup_mmap() should no longer have anything to do with the
vmacache, since it is now per-thread, not per-mm.

So :

 - allocating a new "struct mm_struct" should clear the
vmacache_seqnum for that new mm, to try to minimize unnecessary future
overflow.

 - thread allocation should just zero the cache entries, and set
"tsk->vmacache_seqnum = mm->vmacache_seqnum" (after dup_mm()) to avoid
future unnecessary flushes.

and as far as I can tell, the logic would be exactly the same on NOMMU
(the dup_mm just doesn't happen, since all forks are basically sharing
mm).

And maybe you'd want to make VMACACHE_SIZE be 1 on NOMMU (and make
sure to change the "& 3" to "& (VMACACHE_SIZE-1)". Just to keep the
size down on small systems that really don't need it.

          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
