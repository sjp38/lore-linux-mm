Date: Mon, 1 Dec 2008 12:45:50 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC v1][PATCH]page_fault retry with NOPAGE_RETRY
Message-ID: <20081201114550.GA10790@wotan.suse.de>
References: <20081123091843.GK30453@elte.hu> <604427e00811251042t1eebded6k9916212b7c0c2ea0@mail.gmail.com> <20081126123246.GB23649@wotan.suse.de> <492DAA24.8040100@google.com> <20081127085554.GD28285@wotan.suse.de> <492E6849.6090205@google.com> <20081127130817.GP28285@wotan.suse.de> <492EEF0C.9040607@google.com> <20081128093713.GB1818@wotan.suse.de> <49307893.4030708@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <49307893.4030708@google.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Waychison <mikew@google.com>
Cc: Ying Han <yinghan@google.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, edwintorok@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, Nov 28, 2008 at 03:02:43PM -0800, Mike Waychison wrote:
> Nick Piggin wrote:
> >On Thu, Nov 27, 2008 at 11:03:40AM -0800, Mike Waychison wrote:
> >>Nick Piggin wrote:
> >>>On Thu, Nov 27, 2008 at 01:28:41AM -0800, Mike Waychison wrote:
> >>>>Torok however identified mmap taking on the order of several 
> >>>>milliseconds due to this exact problem:
> >>>>
> >>>>http://lkml.org/lkml/2008/9/12/185
> >>>Turns out to be a different problem.
> >>>
> >>What do you mean?
> >
> >His is just contending on the write side. The retry patch doesn't help.
> >
> 
> I disagree.  How do you get 'write contention' from the following paragraph:
> 
> "Just to confirm that the problem is with pagefaults and mmap, I dropped
> the mmap_sem in filemap_fault, and then
> I got same performance in my testprogram for mmap and read. Of course
> this is totally unsafe, because the mapping could change at any time."
> 
> It reads to me that the writers were held off by the readers sleeping in IO.

Yeah, I didn't look closely at your patch. I assumed it was dropping the
mmap_sem for the duration of the IO, so I didn't think there could be
significant read hold time there. Of course reads would still show up
somewhat if there is a lot of write contention, but they would not
necessarily be the cause of the problem.

Anyway...


> >>>>We generally try to avoid such things, but sometimes it a) can't be 
> >>>>easily avoided (third party libraries for instance) and b) when it hits 
> >>>>us, it affects the overall health of the machine/cluster (the 
> >>>>monitoring daemons get blocked, which isn't very healthy).
> >>>Are you doing appropriate posix_fadvise to prefetch in the files before
> >>>faulting, and madvise hints if appropriate?
> >>>
> >>Yes, we've been slowly rolling out fadvise hints out, though not to 
> >>prefetch, and definitely not for faulting.  I don't see how issuing a 
> >>prefetch right before we try to fault in a page is going to help 
> >>matters.  The pages may appear in pagecache, but they won't be uptodate 
> >>by the time we look at them anyway, so we're back to square one.
> >
> >The whole point of a prefetch is to issue it sufficiently early so
> >it makes a difference. Actually if you can tell quite well where the
> >major faults will be, but don't know it sufficiently in advance to
> >do very good prefetching, then perhaps we could add a new madvise hint
> >to synchronously bring the page in (dropping the mmap_sem over the IO).
> >
> 
> Or we could just fix the faulting code to drop the mmap_sem for us?  I'm 

Yeah... I don't exactly call it a "fix"... It's tricky code... In other
cases you slow down.

Of course we should try to improve the kernel for user workloads, but we
also need to steer users toward workloads that are going to work well and
be nice for us to work with and optimise in future.

Threads are more often than not, not a good solution. There is lots of
other locks in the kernel (and userspace) that are going to slow things
down. I bet this workload would actually be much faster if the app was
designed with processes (and shared memory in the cases where it needs
to be shared).


> not sure a new madvise flag could help with the 'starvation hole' issue 
> you brought up.

Because the madvise is just a hint, but you still go through with the
fault, so in rare cases yes perhaps the fault will need to re-read the
page if it has been reclaimed in the meantime, but those are the cases
where the fault retry code has a chance to have a starvation issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
