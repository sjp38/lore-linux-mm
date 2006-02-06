Subject: Re: [PATCH 6/9] clockpro-clockpro.patch
From: Peter Zijlstra <peter@programming.kicks-ass.net>
In-Reply-To: <20060206093023.E4F227402D@sv1.valinux.co.jp>
References: <20051230223952.765.21096.sendpatchset@twins.localnet>
	 <20051230224312.765.58575.sendpatchset@twins.localnet>
	 <20051231002417.GA4913@dmt.cnet> <1136028546.17853.69.camel@twins>
	 <20060105094722.897C574030@sv1.valinux.co.jp>
	 <Pine.LNX.4.63.0601050830530.18976@cuia.boston.redhat.com>
	 <20060106090135.3525D74031@sv1.valinux.co.jp>
	 <20060124063010.B85C77402D@sv1.valinux.co.jp>
	 <20060124072503.BAF6A7402F@sv1.valinux.co.jp>
	 <1138958705.5450.9.camel@localhost.localdomain>
	 <20060206093023.E4F227402D@sv1.valinux.co.jp>
Content-Type: text/plain
Date: Mon, 06 Feb 2006 11:07:27 +0100
Message-Id: <1139220448.11539.17.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
Cc: Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Christoph Lameter <christoph@lameter.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, Nick Piggin <npiggin@suse.de>, Marijn Meijles <marijn@bitpit.net>
List-ID: <linux-mm.kvack.org>

> > > Environment: Dell 1850 4GB EM64T CPUx2 HT disabled, x86_64 kernel
> > > Kernel 1: linux-2.6.15-rc5
> > > Kernel 2: linux-2.6.15-rc5 + clockpro patch posted in 2005/12/31
> > > Kernel 3: linux-2.6.15-rc5 + clockpro patch posted in 2005/12/31 +
> > > 	  modification to disable page cache usage from ZONE_DMA
> > > 	  (to rule out possible zone balancing related problem)

> > >  n     Kernel 1    Kernel 2   Kernel 3
> > > ======================================
> > > 100    373600      298720     395818
> > > 200    385639	   272749     272166
> > > 300    371047	   243734     262370
> > > 400    367691	   213974     169714
> > > 500    147130	   126284     103038

> I've built kernels with CONFIG_MM_POLICY_CLOCKPRO enabled and disabled
> and ran the same tests.
> 
>  n   disabled    enabled
> ========================
> 100   366962     392283
> 200   342172	 393087
> 300   339325	 309595
> 400   230029	 283340
> 500   121352	 132298
> 
> The non-clockpro version (left) has got slower in n >= 400, and the
> clockpro version has got faster in n <= 400.  The clockpro version is
> still slower than the "kernel 1" for n=300,400.  There seem to be a
> few percents of measurement variances, so I shouldn't judge something
> from small differences in values.

Hmm, better but still some ways to go. Thanks for the results.

> > esp. the last patch in the series:
> > http://programming.kicks-ass.net/kernel-patches/page-replace/2.6.16-rc1-3/kswapd-writeout-wait.patch
> 
> This change doesn't seem to be related to clockpro.  I wonder if (and
> why) it is significant.

Ah, no patch description there yet. What happens is that most of the new
policies (can) require quite a lot of scanning and are hitting:

 			blk_congestion_wait(WRITE, HZ/10);

way too often without actually having submitted IO.

> I haven't tried but it should be possible to create similar workloads
> by scaling down the arguments to 2read.c.
> 
> BTW, I made some detailed measurments with older kernels.  I'll mail
> the results later.

Yes, I did that, however your results show a greater decrease in
throughput than I was able to get. Will investigate my setup.


Kind regards,

Peter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
