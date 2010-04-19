Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E2A416B01F0
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 08:58:56 -0400 (EDT)
Subject: Re: vmalloc performance
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <1271603649.2100.122.camel@barrios-desktop>
References: <1271089672.7196.63.camel@localhost.localdomain>
	 <1271249354.7196.66.camel@localhost.localdomain>
	 <m2g28c262361004140813j5d70a80fy1882d01436d136a6@mail.gmail.com>
	 <1271262948.2233.14.camel@barrios-desktop>
	 <1271320388.2537.30.camel@localhost>
	 <1271350270.2013.29.camel@barrios-desktop>
	 <1271427056.7196.163.camel@localhost.localdomain>
	 <1271603649.2100.122.camel@barrios-desktop>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 19 Apr 2010 13:58:49 +0100
Message-Id: <1271681929.7196.175.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 2010-04-19 at 00:14 +0900, Minchan Kim wrote:
> On Fri, 2010-04-16 at 15:10 +0100, Steven Whitehouse wrote:
> > Hi,
> > 
> > On Fri, 2010-04-16 at 01:51 +0900, Minchan Kim wrote:
> > [snip]
> > > Thanks for the explanation. It seems to be real issue. 
> > > 
> > > I tested to see effect with flush during rb tree search.
> > > 
> > > Before I applied your patch, the time is 50300661 us. 
> > > After your patch, 11569357 us. 
> > > After my debug patch, 6104875 us.
> > > 
> > > I tested it as changing threshold value.
> > > 
> > > threshold	time
> > > 1000		13892809
> > > 500		9062110
> > > 200		6714172
> > > 100		6104875
> > > 50		6758316
> > > 
> > My results show:
> > 
> > threshold        time
> > 100000           139309948
> > 1000             13555878
> > 500              10069801
> > 200              7813667
> > 100              18523172
> > 50               18546256
> > 
> > > And perf shows smp_call_function is very low percentage.
> > > 
> > > In my cases, 100 is best. 
> > > 
> > Looks like 200 for me.
> > 
> > I think you meant to use the non _minmax version of proc_dointvec too?
> 
> Yes. My fault :)
> 
> > Although it doesn't make any difference for this basic test.
> > 
> > The original reporter also has 8 cpu cores I've discovered. In his case
> > divided by 4 cpus where as mine are divided by 2 cpus, but I think that
> > makes no real difference in this case.
> > 
> > I'll try and get some further test results ready shortly. Many thanks
> > for all your efforts in tracking this down,
> > 
> > Steve.
> 
> I voted "free area cache".
My results with this patch are:

vmalloc took 5419238 us
vmalloc took 5432874 us
vmalloc took 5425568 us
vmalloc took 5423867 us

So thats about a third of the time it took with my original patch, so
very much going in the right direction :-)

I did get a compile warning:
  CC      mm/vmalloc.o
mm/vmalloc.c: In function a??__free_vmap_areaa??:
mm/vmalloc.c:454: warning: unused variable a??preva??

....harmless, but it should be fixed before the final version,

Steve.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
