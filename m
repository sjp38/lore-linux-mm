Date: Mon, 1 Dec 2008 09:58:44 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC v1][PATCH]page_fault retry with NOPAGE_RETRY
Message-ID: <20081201085844.GC4926@wotan.suse.de>
References: <604427e00811251042t1eebded6k9916212b7c0c2ea0@mail.gmail.com> <20081126123246.GB23649@wotan.suse.de> <492DAA24.8040100@google.com> <20081127085554.GD28285@wotan.suse.de> <492E6849.6090205@google.com> <20081127130817.GP28285@wotan.suse.de> <492EEF0C.9040607@google.com> <20081128093713.GB1818@wotan.suse.de> <49307893.4030708@google.com> <4932EF90.9070601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4932EF90.9070601@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?iso-8859-1?B?VPZy9ms=?= Edwin <edwintorok@gmail.com>
Cc: Mike Waychison <mikew@google.com>, Ying Han <yinghan@google.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Sun, Nov 30, 2008 at 09:54:56PM +0200, Torok Edwin wrote:
> On 2008-11-29 01:02, Mike Waychison wrote:
> > Nick Piggin wrote:
> >> On Thu, Nov 27, 2008 at 11:03:40AM -0800, Mike Waychison wrote:
> >>> Nick Piggin wrote:
> >>>> On Thu, Nov 27, 2008 at 01:28:41AM -0800, Mike Waychison wrote:
> >>>>> Torok however identified mmap taking on the order of several
> >>>>> milliseconds due to this exact problem:
> >>>>>
> >>>>> http://lkml.org/lkml/2008/9/12/185
> >>>> Turns out to be a different problem.
> >>>>
> >>> What do you mean?
> >>
> >> His is just contending on the write side. The retry patch doesn't help.
> >>
> >
> > I disagree.  How do you get 'write contention' from the following
> > paragraph:
> >
> > "Just to confirm that the problem is with pagefaults and mmap, I dropped
> > the mmap_sem in filemap_fault, and then
> > I got same performance in my testprogram for mmap and read. Of course
> > this is totally unsafe, because the mapping could change at any time."
> >
> > It reads to me that the writers were held off by the readers sleeping
> > in IO.
> 
> It is true that I have a write/write contention too, but do_page_fault
> shows up too on lock_stat.
> 
> This is my guess at what happens:
> * filemap_fault used to sleep with mmap_sem held while waiting for the
> page lock.
> * the google patch avoids that, which is fine: if page lock can't be
> taken, it drops mmap_sem, waits, then retries the fault once
> * however after we acquired the page lock, mapping->a_ops->readpage is
> invoked, mmap_sem is NOT dropped here:
> 
>     error = mapping->a_ops->readpage(file, page);
>     if (!error) {
>         wait_on_page_locked(page);
> 
> If my understanding is correct ->readpage does the actual disk I/O, and
> it keeps the page locked, when the lock is released we know it has finished.
> So wait_on_page_locked(page)  holds mmap_sem locked for read during the
> disk I/O, preventing sys_mmap/sys_munmap from making progress.

Yes that's exactly right. Ahh, the google patch doesn't solve this
case? Interesting...


> I don't know how to prove/disprove my guess above, suggestions welcome.
> 
> Could the patch be changed to also release the mmap_sem after readpage,
> and before wait_on_page_locked?

It should be possible somehow, but it is difficult because after
dropping mmap_sem, then we have to basically retry the whole fault
because the vma might have gone away.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
