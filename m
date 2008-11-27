Date: Thu, 27 Nov 2008 13:39:26 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC v1][PATCH]page_fault retry with NOPAGE_RETRY
Message-ID: <20081127123926.GN28285@wotan.suse.de>
References: <604427e00811212247k1fe6b63u9efe8cfe37bddfb5@mail.gmail.com> <20081123091843.GK30453@elte.hu> <604427e00811251042t1eebded6k9916212b7c0c2ea0@mail.gmail.com> <20081126123246.GB23649@wotan.suse.de> <492DAA24.8040100@google.com> <20081127085554.GD28285@wotan.suse.de> <492E6849.6090205@google.com> <492E8708.4060601@gmail.com> <20081127120330.GM28285@wotan.suse.de> <492E90BC.1090208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <492E90BC.1090208@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?iso-8859-1?B?VPZy9ms=?= Edwin <edwintorok@gmail.com>
Cc: Mike Waychison <mikew@google.com>, Ying Han <yinghan@google.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 27, 2008 at 02:21:16PM +0200, Torok Edwin wrote:
> On 2008-11-27 14:03, Nick Piggin wrote:
> >> Running my testcase shows no significant performance difference. What am
> >> I doing wrong?
> >>     
> >  
> > Software may just be doing a lot of mmap/munmap activity. threads +
> > mmap is never going to be pretty because it is always going to involve
> > broadcasting tlb flushes to other cores... Software writers shouldn't
> > be scared of using processes (possibly with some shared memory).
> >   
> 
> It would be interesting to compare the performance of a threaded clamd,
> and of a clamd that uses multiple processes.
> Distributing tasks will be a bit more tricky, since it would need to use
> IPC, instead of mutexes and condition variables.

Yes, although you could use PTHREAD_PROCESS_SHARED pthread mutexes on
the shared memory I believe (having never tried it myself).

 
> > Actually, a lot of things get faster (like malloc, or file descriptor
> > operations) because locks aren't needed.
> >
> > Despite common perception, processes are actually much *faster* than
> > threads when doing common operations like these. They are slightly slower
> > sometimes with things like creation and exit, or context switching, but
> > if you're doing huge numbers of those operations, then it is unlikely
> > to be a performance critical app... :)
> >   
> 
> How about distributing tasks to a set of worked threads, is the overhead
> of using IPC instead of
> mutexes/cond variables acceptable?

It is really going to depend on a lot of things. What is involved in
distributing tasks, how many cores and cache/TLB architecture of the
system running on, etc.

You want to distribute as much work as possible while touching as
little memory as possible, in general.

But if you're distributing threads over cores, and shared caches are
physically tagged (which I think all x86 CPUs are), then you should
be able to have multiple processes operate on shared memory just as
efficiently as multiple threads I think.

And then you also get the advantages of reduced contention on other
shared locks and resources.

 
> > (end rant; sorry, that may not have been helpful to your immediate problem,
> > but we need to be realistic in what complexity we are ging to add where in
> > the kernel in order to speed things up. And we need to steer userspace
> > away from problems that are fundamentally hard and not going to get easier
> > with trends -- like virtual address activity with multiple threads)
> >   
> 
> I understood that mmap() is not scalable, however look  at
> http://lkml.org/lkml/2008/9/12/185, even fopen/fdopen does
> an (anonymous) mmap internally.

Well, I guess that would be all the more reason to avoid threads (and
things like fopen/fdopen fundamentally have to be synchronized between
threads regardless of whether they use mmap() or not, so you're going
to see a win on any OS avoiding threaded code that uses fopen/fdopen).


> That does not affect performance that much, since the overhead of a
> file-backed mmap + pagefaults is higher.
> Rewriting libclamav to not use mmap() would take a significant amount of
> time, however  I will try to avoid using mmap()
> in new code (and prefer pread/read).
> 
> Also clamd is a CPU bound application [given fast enough disks ;)] and
> having to wait for mmap_sem prevents it from doing "real work".
> Most of the time it reads files from /tmp, that should either be in the
> page cache, or (in my case) they are always in RAM (I use tmpfs).
> 
> So mmaping, and reading from these files does not involve disk I/O, yet
> threads working with /tmp files still need to wait
> for disk I/O to complete because it has to wait on mmap_sem (held by
> another thread).

Yeah, it's costly. Even if it didn't take mmap_sem, then it still
needs to broadcast TLB invalidates over the machine, so it would
probably go even faster if it weren't threaded and/or didn't use
mmap/munmap so heavily.


> >> ...............................................................................................................................................................................................
> >>
> >>                          &sem->wait_lock:        122700        
> >> 126641           0.42          77.94      125372.37       
> >> 1779026        7368894           0.27        1099.42     3085559.16
> >>                          ---------------
> >>                          &sem->wait_lock           5943         
> >> [<ffffffff8043a768>] __up_write+0x28/0x170
> >>                          &sem->wait_lock           8615         
> >> [<ffffffff805ce3ac>] __down_write_nested+0x1c/0xc0
> >>                          &sem->wait_lock          13568         
> >> [<ffffffff8043a5a0>] __down_write_trylock+0x20/0x60
> >>                          &sem->wait_lock          49377         
> >> [<ffffffff8043a600>] __down_read_trylock+0x20/0x60
> >>                          ---------------
> >>                          &sem->wait_lock           8097         
> >> [<ffffffff8043a5a0>] __down_write_trylock+0x20/0x60
> >>                          &sem->wait_lock          31540         
> >> [<ffffffff8043a768>] __up_write+0x28/0x170
> >>                          &sem->wait_lock           5501         
> >> [<ffffffff805ce3ac>] __down_write_nested+0x1c/0xc0
> >>                          &sem->wait_lock          33342         
> >> [<ffffffff8043a600>] __down_read_trylock+0x20/0x60
> >>
> >>     
> >
> > Interesting. I have some (ancient) patches to make rwsems more scalable
> > under heavy load by reducing contention on this lock. They should really
> > have been merged... Not sure how much it would help, but if you're
> > interested in testing, I could dust them off.
> 
> Sure, I can test patches (preferably against 2.6.28-rc6-tip ).

OK, I'll see if I can find them (am overseas at the moment, and I suspect
they are stranded on some stationary rust back home, but I might be able
to find them on the web).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
