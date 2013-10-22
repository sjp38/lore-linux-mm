Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id E792B6B00D2
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 13:54:22 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so8161486pad.2
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 10:54:22 -0700 (PDT)
Received: from psmtp.com ([74.125.245.183])
        by mx.google.com with SMTP id fk10si12878163pab.261.2013.10.22.10.54.21
        for <linux-mm@kvack.org>;
        Tue, 22 Oct 2013 10:54:21 -0700 (PDT)
Received: by mail-pa0-f50.google.com with SMTP id fa1so10126372pad.37
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 10:54:20 -0700 (PDT)
Message-ID: <5266BBC7.9030207@mit.edu>
Date: Tue, 22 Oct 2013 10:54:15 -0700
From: Andy Lutomirski <luto@amacapital.net>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] mm,vdso: preallocate new vmas
References: <1382057438-3306-1-git-send-email-davidlohr@hp.com> <20131022154802.GA25490@localhost>
In-Reply-To: <20131022154802.GA25490@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: walken@google.com, Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, aswin@hp.com, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On 10/22/2013 08:48 AM, walken@google.com wrote:
> On Thu, Oct 17, 2013 at 05:50:35PM -0700, Davidlohr Bueso wrote:
>> Linus recently pointed out[1] some of the amount of unnecessary work 
>> being done with the mmap_sem held. This patchset is a very initial 
>> approach on reducing some of the contention on this lock, and moving
>> work outside of the critical region.
>>
>> Patch 1 adds a simple helper function.
>>
>> Patch 2 moves out some trivial setup logic in mlock related calls.
>>
>> Patch 3 allows managing new vmas without requiring the mmap_sem for
>> vdsos. While it's true that there are many other scenarios where
>> this can be done, few are actually as straightforward as this in the
>> sense that we *always* end up allocating memory anyways, so there's really
>> no tradeoffs. For this reason I wanted to get this patch out in the open.
>>
>> There are a few points to consider when preallocating vmas at the start
>> of system calls, such as how many new vmas (ie: callers of split_vma can
>> end up calling twice, depending on the mm state at that point) or the probability
>> that we end up merging the vma instead of having to create a new one, like the 
>> case of brk or copy_vma. In both cases the overhead of creating and freeing
>> memory at every syscall's invocation might outweigh what we gain in not holding
>> the sem.
> 
> Hi Davidlohr,
> 
> I had a quick look at the patches and I don't see anything wrong with them.
> However, I must also say that I have 99 problems with mmap_sem and the one
> you're solving doesn't seem to be one of them, so I would be interested to
> see performance numbers showing how much difference these changes make.
> 
> Generally the problems I see with mmap_sem are related to long latency
> operations. Specifically, the mmap_sem write side is currently held
> during the entire munmap operation, which iterates over user pages to
> free them, and can take hundreds of milliseconds for large VMAs.

This is the leading cause of my "egads, something that should have been
fast got delayed for several ms" detector firing.  I've been wondering:

Could we replace mmap_sem with some kind of efficient range lock?  The
operations would be:

 - mm_lock_all_write (drop-in replacement for down_write(&...->mmap_sem))
 - mm_lock_all_read (same for down_read)
 - mm_lock_write_range(mm, start, end)
 - mm_lock_read_range(mm, start_end)

and corresponding unlock functions (that maybe take a cookie that the
lock functions return or that take a pointer to some small on-stack data
structure).

I think that all the mm functions except get_unmapped_area could use an
interface like this, possibly with considerably less code than they use
now.  get_unmapped_area is the main exception -- it would want trylock
operations or something so it didn't get stuck.

The easiest way to implement this that I can think of is a doubly-linked
list or even just an array, which should be fine for a handful of
threads.  Beyond that, I don't really know.  Creating a whole trie for
these things would be expensive, and fine-grained locking on rbtree-like
things isn't so easy.

This could be a huge win: operations on non-overlapping addresses
wouldn't get in each others' way, except for TLB shootdown interrupts.
(Hey, CPU vendors: give us a real remote TLB shootdown mechanism!)

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
