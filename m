Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA066B00E3
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 12:20:43 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id y10so6416400pdj.10
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 09:20:43 -0700 (PDT)
Received: from psmtp.com ([74.125.245.164])
        by mx.google.com with SMTP id sg3si12101283pbb.193.2013.10.22.09.20.41
        for <linux-mm@kvack.org>;
        Tue, 22 Oct 2013 09:20:42 -0700 (PDT)
Received: by mail-vc0-f177.google.com with SMTP id ib11so1393322vcb.8
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 09:20:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131022154802.GA25490@localhost>
References: <1382057438-3306-1-git-send-email-davidlohr@hp.com>
	<20131022154802.GA25490@localhost>
Date: Tue, 22 Oct 2013 17:20:40 +0100
Message-ID: <CA+55aFzwRoM4w8mGqSeeVuDGhQgnnomu=vxoWC6dbHD9w-9A+Q@mail.gmail.com>
Subject: Re: [PATCH 0/3] mm,vdso: preallocate new vmas
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Oct 22, 2013 at 4:48 PM,  <walken@google.com> wrote:

>
> Generally the problems I see with mmap_sem are related to long latency
> operations. Specifically, the mmap_sem write side is currently held
> during the entire munmap operation, which iterates over user pages to
> free them, and can take hundreds of milliseconds for large VMAs.

So this would be the *perfect* place to just downgrade the semaphore
from a write to a read.

Do the vma ops under the write semaphore, then downgrade it to a
read-sem, and do the page teardown with just mmap_sem held for
reading..

Comments? Anybody want to try that? It should be fairly
straightforward, and we had a somewhat similar issue when it came to
mmap() having to populate the mapping for mlock. For that case, it was
sufficient to just move the "populate" phase outside the lock entirely
(for that case, we actually drop the write lock and then take the
read-lock and re-lookup the vma, for unmap we'd have to do a proper
downgrade so that there is no window where the virtual address area
could be re-allocated)

The big issue is that we'd have to split up do_munmap() into those two
phases, since right now callers take the write semaphore before
calling it, and drop it afterwards. And some callers do it in a loop.
But we should be fairly easily able to make the *common* case (ie
normal "munmap()") do something like

    down_write(&mm->mmap_sem);
    phase1_munmap(..);
    downgrade_write(&mm->mmap_sem);
    phase2_munmap(..);
    up_read(&mm->mmap_sem);

instead of what it does now (which is to just do
down_write()/up_write() around do_munmap()).

I don't see any fundamental problems, but maybe there's some really
annoying detail that makes this nasty (right now we do
"remove_vma_list() -> remove_vma()" *after* tearing down the page
tables, and since that calls the ->close function, I think it has to
be done that way. I'm wondering if any of that code relies on the
mmap_sem() being held for exclusively for writing. I don't see why it
possibly could, but..

So maybe I'm being overly optimistic and it's not as easy as just
splitting do_mmap() into two phases, but it really *looks* like it
might be just a ten-liner or so.. And if a real munmap() is the common
case (as opposed to a do_munmap() that gets triggered by somebody
doing a "mmap()" on top of an old mapping), then we'd at least allow
page faults from other threads to be done concurrently with tearing
down the page tables for the unmapped vma..

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
