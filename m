Date: Tue, 1 Apr 2003 17:34:02 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.66-mm2
Message-Id: <20030401173402.2a6f728f.akpm@digeo.com>
In-Reply-To: <151780000.1049245829@flay>
References: <20030401000127.5acba4bc.akpm@digeo.com>
	<151780000.1049245829@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: bzzz@tmi.comex.ru, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
> Ho hum. All very strange. Kernbench seems to be really behaving itself
> quite well now, but SDET sucks worse than ever. The usual 16x NUMA-Q 
> machine .... 
> 
> Kernbench: (make -j N vmlinux, where N = 2 x num_cpus)
>                               Elapsed      System        User         CPU
>                2.5.66-mm2       44.04       81.12      569.40     1476.75
>           2.5.66-mm2-ext3       44.43       84.10      568.82     1469.00

Is this ext2 versus ext3?  If so, that's a pretty good result isn't it?  I
forget what kernbench looked like for stock ext3.

> SDET 32  (see disclaimer)
>                            Throughput    Std. Dev
>                2.5.66-mm2       100.0%         0.7%
>           2.5.66-mm2-ext3         4.7%         1.5%

Yes, this is presumably a lot more metadata-intensive, so we're just
hammering the journal semaphore to death.  We're working on it.

> ftp://ftp.kernel.org/pub/linux/kernel/people/mbligh/benchmarks/2.5.66-mm2-ext3/

Offtopic, a raw sdet64 profile says:

5392317 total
4478683 default_idle
307163 __down
169770 .text.lock.sched
106769 schedule
88092 __wake_up
57280 .text.lock.transaction

I'm slightly surprised that the high context switch rate is showing up so
much contention in sched.c.  I'm assuming that it's on the sleep/wakeup path
and not in the context switch path.  It would be interesting to inline the
spinlock code and reprofile.

We really should be using the waker-removes-wakee facility in the semaphore
code, but that's not completely trivial.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
