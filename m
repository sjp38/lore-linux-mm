Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id D57276B0072
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 07:30:40 -0400 (EDT)
Date: Tue, 10 Jul 2012 12:30:36 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [MMTests] Interactivity during IO on ext3
Message-ID: <20120710113036.GE14154@suse.de>
References: <20120620113252.GE4011@suse.de>
 <20120629111932.GA14154@suse.de>
 <20120705145652.GN14154@suse.de>
 <20120710094940.GC13539@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120710094940.GC13539@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Tue, Jul 10, 2012 at 11:49:40AM +0200, Jan Kara wrote:
> > ===========================================================
> > Machine:	arnold
> > Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-interactive-performance-ext3/arnold/comparison.html
> > Arch:		x86
> > CPUs:		1 socket, 2 threads
> > Model:		Pentium 4
> > Disk:		Single Rotary Disk
> > ===========================================================
> > 
> > fsmark-single
> > -------------
> >   Completion times since 3.2 have been badly affected which coincides with
> >   the introduction of IO-less dirty page throttling. 3.3 was particularly
> >   bad.
> > 
> >   2.6.32 was TERRIBLE in terms of read-latencies with the average latency
> >   and max latencies looking awful. The 90th percentile was close to 4
> >   seconds and as a result the graphs are even more of a complete mess than
> >   they might have been otherwise.
> > 
> >   Otherwise it's worth looking closely at 3.0 and 3.2. In 3.0, 95% of the
> >   reads were below 206ms but in 3.2 this had grown to 273ms. The latency
> >   of the other 5% results increased from 481ms to 774ms.
> > 
> >   3.4 is looking better at least.
>
>   Yeah, 3.4 looks OK and I'd be interested in 3.5 results since I've merged
> one more fix which should help the read latency.

When 3.5 comes out, I'll be queue up the same tests. Ideally I would be
running against each rc but the machines are used for other tests as well
and these ones take too long for continual testing to be practical.

> But all in all it's hard
> to tackle the latency problems with ext3 - we have a journal which
> synchronizes all the writes so we write to it with a high priority
> (we use WRITE_SYNC when there's some contention on the journal). But that
> naturally competes with reads and creates higher read latency.
>  

Thanks for the good explanation. I'll just know to look out for this in
interactivity-related or IO-latency bugs.

> > <SNIP>
> > ==========================================================
> > Machine:	hydra
> > Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-interactive-performance-ext3/hydra/comparison.html
> > Arch:		x86-64
> > CPUs:		1 socket, 4 threads
> > Model:		AMD Phenom II X4 940
> > Disk:		Single Rotary Disk
> > ==========================================================
> > 
> > fsmark-single
> > -------------
> >   Completion times are all over the place with a big increase in 3.2 that
> >   improved a bit since but not as good as 3.1 kernels were.
> > 
> >   Unlike arnold, 2.6.32 is not a complete mess and makes a comparison more
> >   meaningful. Our maximum latencies have jumped around a lot with 3.2
> >   being particularly bad and 3.4 not being much better. 3.1 and 3.3 were
> >   both good in terms of maximum latency.
> > 
> >   Average latency is shot to hell. In 2.6.32 it was 349ms and it's now 781ms.
> >   3.2 was really bad but it's not like 3.0 or 3.1 were fantastic either.
>
>   So I wonder what makes a difference between this machine and the previous
> one. The results seem completely different. Is it the amount of memory? Is
> it the difference in the disk? Or even the difference in the CPU?
> 

Two big differences are 32-bit versus 64-bit and the 32-bit machine having
4G of RAM and the 64-bit machine having 8G.  On the 32-bit machine, bounce
buffering may have been an issue but as -S0 was specified (no sync) there
would also be differences on when dirty page balancing took place.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
