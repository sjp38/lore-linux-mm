Subject: Re: [PATCH 6/9] clockpro-clockpro.patch
From: Peter Zijlstra <peter@programming.kicks-ass.net>
In-Reply-To: <20060124072503.BAF6A7402F@sv1.valinux.co.jp>
References: <20051230223952.765.21096.sendpatchset@twins.localnet>
	 <20051230224312.765.58575.sendpatchset@twins.localnet>
	 <20051231002417.GA4913@dmt.cnet> <1136028546.17853.69.camel@twins>
	 <20060105094722.897C574030@sv1.valinux.co.jp>
	 <Pine.LNX.4.63.0601050830530.18976@cuia.boston.redhat.com>
	 <20060106090135.3525D74031@sv1.valinux.co.jp>
	 <20060124063010.B85C77402D@sv1.valinux.co.jp>
	 <20060124072503.BAF6A7402F@sv1.valinux.co.jp>
Content-Type: text/plain
Date: Fri, 03 Feb 2006 10:25:04 +0100
Message-Id: <1138958705.5450.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Christoph Lameter <christoph@lameter.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, Nick Piggin <npiggin@suse.de>, Marijn Meijles <marijn@bitpit.net>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-01-24 at 16:25 +0900, IWAMOTO Toshihiro wrote:
> (Removed linux-kernel@ from Cc:)
> 
> At Tue, 24 Jan 2006 15:30:10 +0900,
> IWAMOTO Toshihiro wrote:
> > I thought this situation means that page access frequencies cannot be
> > correctly compared and leads to suboptimal performance, but I couldn't
> > prove that.  However, I've managed to create an example workload where
> > clockpro performs worse.  I'm not sure if the example is related to
> > this hand problem.  I'll describe it in the next mail.
> 
> Environment: Dell 1850 4GB EM64T CPUx2 HT disabled, x86_64 kernel
> Kernel 1: linux-2.6.15-rc5
> Kernel 2: linux-2.6.15-rc5 + clockpro patch posted in 2005/12/31
> Kernel 3: linux-2.6.15-rc5 + clockpro patch posted in 2005/12/31 +
> 	  modification to disable page cache usage from ZONE_DMA
> 	  (to rule out possible zone balancing related problem)
> Kernel 1 and 2 were booted with "mem=1008m", Kernel 3 was booted with
> "mem=1024m".
> 
> The test program: 2read.c (attached below)
> 	2read.c repeatedly reads from two files zero and zero2.
> 	Command line arguments specify the ranges to be read. (See the
> 	code for detail)
> 	It prints the number of read operations/2 every 5 seconds and
> 	terminates in 5 minutes.
> 
> $ cc -O 2read.c
> $ ls -l zero*
> -rw-r--r--  1 toshii users 1073741824 2006-01-13 17:27 zero
> -rw-r--r--  1 toshii users 1572864000 2006-01-20 18:20 zero2
> 
> (with Kernel 1)
> $ for n in 100 200 300 400 500; do
> > ./a.out -n $n $((1100-$n)) > /tmp/2d.$n ; done
> (with Kernel 2)
> $ for n in 100 200 300 400 500; do
> > ./a.out -n $n $((1100-$n)) > /tmp/2d.c.$n ; done
> (with Kernel 3)
> $ for n in 100 200 300 400 500; do
> > ./a.out -n $n $((1100-$n)) > /tmp/2d.c.nodma.$n ; done
> 
> The table below is the last numbers printed by the test program
> ((number of reads)/2 in 5 minutes).  Clockpro (with or without the
> ZONE_DMA modification) is always slower with one exception, and
> the slowdown can be as large as 42-54%.
> 
> I've put the complete data and some generated figures at
> http://people.valinux.co.jp/~iwamoto/clockpro-20051231/
> 
>  n     Kernel 1    Kernel 2   Kernel 3
> ======================================
> 100    373600      298720     395818
> 200    385639	   272749     272166
> 300    371047	   243734     262370
> 400    367691	   213974     169714
> 500    147130	   126284     103038

<snip code>

Iwamoto-San,

Could you test again with my latest patches found at:
http://programming.kicks-ass.net/kernel-patches/page-replace/2.6.16-rc1-3/

esp. the last patch in the series:
http://programming.kicks-ass.net/kernel-patches/page-replace/2.6.16-rc1-3/kswapd-writeout-wait.patch

which is what I needed to do in order to fix some regressions found with
your test case. It seems to work on my system, although it is admittedly
quite a bit smaller than your machine.

Kind regards,

Peter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
