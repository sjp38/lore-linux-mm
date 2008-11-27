Date: Thu, 27 Nov 2008 13:03:30 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC v1][PATCH]page_fault retry with NOPAGE_RETRY
Message-ID: <20081127120330.GM28285@wotan.suse.de>
References: <604427e00811212247k1fe6b63u9efe8cfe37bddfb5@mail.gmail.com> <20081123091843.GK30453@elte.hu> <604427e00811251042t1eebded6k9916212b7c0c2ea0@mail.gmail.com> <20081126123246.GB23649@wotan.suse.de> <492DAA24.8040100@google.com> <20081127085554.GD28285@wotan.suse.de> <492E6849.6090205@google.com> <492E8708.4060601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <492E8708.4060601@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?iso-8859-1?B?VPZy9ms=?= Edwin <edwintorok@gmail.com>
Cc: Mike Waychison <mikew@google.com>, Ying Han <yinghan@google.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 27, 2008 at 01:39:52PM +0200, Torok Edwin wrote:
> On 2008-11-27 11:28, Mike Waychison wrote:
> > Correct.  I don't recall the numbers from the pathelogical cases we
> > were seeing, but iirc, it was on the order of 10s of seconds, likely
> > exascerbated by slower than usual disks.  I've been digging through my
> > inbox to find numbers without much success -- we've been using a
> > variant of this patch since 2.6.11.
> >
> > Torok however identified mmap taking on the order of several
> > milliseconds due to this exact problem:
> >
> > http://lkml.org/lkml/2008/9/12/185
> 
> 
> Hi,
> 
> Thanks for the patch. I just tested it on top of 2.6.28-rc6-tip, see
> /proc/lock_stat output at the end.
> 
> Running my testcase shows no significant performance difference. What am
> I doing wrong?
 
Software may just be doing a lot of mmap/munmap activity. threads +
mmap is never going to be pretty because it is always going to involve
broadcasting tlb flushes to other cores... Software writers shouldn't
be scared of using processes (possibly with some shared memory).
Actually, a lot of things get faster (like malloc, or file descriptor
operations) because locks aren't needed.

Despite common perception, processes are actually much *faster* than
threads when doing common operations like these. They are slightly slower
sometimes with things like creation and exit, or context switching, but
if you're doing huge numbers of those operations, then it is unlikely
to be a performance critical app... :)

(end rant; sorry, that may not have been helpful to your immediate problem,
but we need to be realistic in what complexity we are ging to add where in
the kernel in order to speed things up. And we need to steer userspace
away from problems that are fundamentally hard and not going to get easier
with trends -- like virtual address activity with multiple threads)


> ...............................................................................................................................................................................................
> 
>                          &sem->wait_lock:        122700        
> 126641           0.42          77.94      125372.37       
> 1779026        7368894           0.27        1099.42     3085559.16
>                          ---------------
>                          &sem->wait_lock           5943         
> [<ffffffff8043a768>] __up_write+0x28/0x170
>                          &sem->wait_lock           8615         
> [<ffffffff805ce3ac>] __down_write_nested+0x1c/0xc0
>                          &sem->wait_lock          13568         
> [<ffffffff8043a5a0>] __down_write_trylock+0x20/0x60
>                          &sem->wait_lock          49377         
> [<ffffffff8043a600>] __down_read_trylock+0x20/0x60
>                          ---------------
>                          &sem->wait_lock           8097         
> [<ffffffff8043a5a0>] __down_write_trylock+0x20/0x60
>                          &sem->wait_lock          31540         
> [<ffffffff8043a768>] __up_write+0x28/0x170
>                          &sem->wait_lock           5501         
> [<ffffffff805ce3ac>] __down_write_nested+0x1c/0xc0
>                          &sem->wait_lock          33342         
> [<ffffffff8043a600>] __down_read_trylock+0x20/0x60
> 

Interesting. I have some (ancient) patches to make rwsems more scalable
under heavy load by reducing contention on this lock. They should really
have been merged... Not sure how much it would help, but if you're
interested in testing, I could dust them off.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
