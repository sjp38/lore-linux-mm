Date: Thu, 27 Nov 2008 14:05:25 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC v1][PATCH]page_fault retry with NOPAGE_RETRY
Message-ID: <20081127130525.GO28285@wotan.suse.de>
References: <604427e00811251042t1eebded6k9916212b7c0c2ea0@mail.gmail.com> <20081126123246.GB23649@wotan.suse.de> <492DAA24.8040100@google.com> <20081127085554.GD28285@wotan.suse.de> <492E6849.6090205@google.com> <492E8708.4060601@gmail.com> <20081127120330.GM28285@wotan.suse.de> <492E90BC.1090208@gmail.com> <20081127123926.GN28285@wotan.suse.de> <492E97FA.5000804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <492E97FA.5000804@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?iso-8859-1?B?VPZy9ms=?= Edwin <edwintorok@gmail.com>
Cc: Mike Waychison <mikew@google.com>, Ying Han <yinghan@google.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 27, 2008 at 02:52:10PM +0200, Torok Edwin wrote:
> On 2008-11-27 14:39, Nick Piggin wrote:
> > And then you also get the advantages of reduced contention on other
> > shared locks and resources.
> >   
> 
> Thanks for the tips, but lets get back to the original question:
> why don't I see any performance improvement with the fault-retry patches?

Because as you said, your app is CPU bound and page faults aren't needing
to sleep very much. There is too much contention on the write side, rather
than too much contention/hold time on the read side.

 
> My testcase only compares reads file with mmap, vs. reading files with
> read, with different number of threads.
> Leaving aside other reasons why mmap is slower, there should be some
> speedup by running 4 threads vs 1 thread, but:
> 
> 1 thread: read:27,18 28.76
> 1 thread: mmap: 25.45, 25.24
> 2 thread: read: 16.03, 15.66
> 2 thread: mmap: 22.20, 20.99
> 4 thread: read: 9.15, 9.12
> 4 thread: mmap: 20.38, 20.47
> 
> The speed of 4 threads is about the same as for 2 threads with mmap, yet
> with read it scales nicely.
> And the patch doesn't seem to improve scalability.
> How can I find out if the patch works as expected? [i.e. verify that
> faults are actually retried, and that they don't keep the semaphore locked]

Yeah, that workload will be completely contended on the mmap_sem write-side
if the files are in cache. The google patch won't help at all in that
case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
