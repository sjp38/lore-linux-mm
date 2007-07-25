Message-ID: <46A6CC56.6040307@yahoo.com.au>
Date: Wed, 25 Jul 2007 14:06:46 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: -mm merge plans for 2.6.23
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>	 <200707102015.44004.kernel@kolivas.org>	 <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>	 <46A57068.3070701@yahoo.com.au>	 <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>	 <46A58B49.3050508@yahoo.com.au> <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
In-Reply-To: <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Lee <ray-lk@madrabbit.org>
Cc: Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ray Lee wrote:
> On 7/23/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:

>> Also a random day at the desktop, it is quite a broad scope and
>> pretty well impossible to analyse.
> 
> 
> It is pretty broad, but that's also what swap prefetch is targetting.
> As for hard to analyze, I'm not sure I agree. One can black-box test
> this stuff with only a few controls. e.g., if I use the same apps each
> day (mercurial, firefox, xorg, gcc), and the total I/O wait time
> consistently goes down on a swap prefetch kernel (normalized by some
> control statistic, such as application CPU time or total I/O, or
> something), then that's a useful measurement.

I'm not saying that we can't try to tackle that problem, but first of
all you have a really nice narrow problem where updatedb seems to be
causing the kernel to completely do the wrong thing. So we start on
that.


>> If we can first try looking at
>> some specific problems that are easily identified.
> 
> 
> Always easier, true. Let's start with "My mouse jerks around under
> memory load." A Google Summer of Code student working on X.Org claims
> that mlocking the mouse handling routines gives a smooth cursor under
> load ([1]). It's surprising that the kernel would swap that out in the
> first place.
> 
> [1] 
> http://vignatti.wordpress.com/2007/07/06/xorg-input-thread-summary-or-something/ 

OK, I'm not sure what the point is though. Under heavy memory load,
things are going to get swapped out... and swap prefetch isn't going
to help there (at least, not during the memory load).

There are also other issues like whether the CPU scheduler is at fault,
etc. Interactive workloads are always the hardest to work out. updatedb
is a walk in the park by comparison.


>> Looking at your past email, you have a 1GB desktop system and your
>> overnight updatedb run is causing stuff to get swapped out such that
>> swap prefetch makes it significantly better. This is really
>> intriguing to me, and I would hope we can start by making this
>> particular workload "not suck" without swap prefetch (and hopefully
>> make it even better than it currently is with swap prefetch because
>> we'll try not to evict useful file backed pages as well).
> 
> 
> updatedb is an annoying case, because one would hope that there would
> be a better way to deal with that highly specific workload. It's also
> pretty stat dominant, which puts it roughly in the same category as a
> git diff. (They differ in that updatedb does a lot of open()s and
> getdents on directories, git merely does a ton of lstat()s instead.)

Yeah, and I suspect we might be able to do better use-once of
inode and dentry caches. It isn't really highly specific: lots
of things tend to just scan over a few files once -- updatedb
just scans a lot so the problem becomes more noticable.


> Anyway, my point is that I worry that tuning for an unusual and
> infrequent workload (which updatedb certainly is), is the wrong way to
> go.

Well it runs every day or so for every desktop Linux user, and
it has similarities with other workloads. We don't want to optimise
it at the expense of other things, but it _really_ should not be
pushing a 1-2GB desktop into swap, I don't think.


>> After that we can look at other problems that swap prefetch helps
>> with, or think of some ways to measure your "whole day" scenario.
>>
>> So when/if you have time, I can cook up a list of things to monitor
>> and possibly a patch to add some instrumentation over this updatedb
>> run.
> 
> 
> That would be appreciated. Don't spend huge amounts of time on it,
> okay? Point me the right direction, and we'll see how far I can run
> with it.

I guess /proc/meminfo, /proc/zoneinfo, /proc/vmstat, /proc/slabinfo
before and after the updatedb run with the latest kernel would be a
first step. top and vmstat output during the run wouldn't hurt either.

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
