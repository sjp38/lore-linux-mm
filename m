Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CADF96B0218
	for <linux-mm@kvack.org>; Thu, 29 Apr 2010 09:43:37 -0400 (EDT)
Subject: Re: vmalloc performance
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <h2g28c262361004190712v131bf7a3q2a82fd1168faeefe@mail.gmail.com>
References: <1271089672.7196.63.camel@localhost.localdomain>
	 <1271249354.7196.66.camel@localhost.localdomain>
	 <m2g28c262361004140813j5d70a80fy1882d01436d136a6@mail.gmail.com>
	 <1271262948.2233.14.camel@barrios-desktop>
	 <1271320388.2537.30.camel@localhost>
	 <1271350270.2013.29.camel@barrios-desktop>
	 <1271427056.7196.163.camel@localhost.localdomain>
	 <1271603649.2100.122.camel@barrios-desktop>
	 <1271681929.7196.175.camel@localhost.localdomain>
	 <h2g28c262361004190712v131bf7a3q2a82fd1168faeefe@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 29 Apr 2010 14:43:22 +0100
Message-Id: <1272548602.7196.371.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 2010-04-19 at 23:12 +0900, Minchan Kim wrote:
> On Mon, Apr 19, 2010 at 9:58 PM, Steven Whitehouse <swhiteho@redhat.com> wrote:
> > Hi,
> >
> > On Mon, 2010-04-19 at 00:14 +0900, Minchan Kim wrote:
> >> On Fri, 2010-04-16 at 15:10 +0100, Steven Whitehouse wrote:
> >> > Hi,
> >> >
> >> > On Fri, 2010-04-16 at 01:51 +0900, Minchan Kim wrote:
> >> > [snip]
> >> > > Thanks for the explanation. It seems to be real issue.
> >> > >
> >> > > I tested to see effect with flush during rb tree search.
> >> > >
> >> > > Before I applied your patch, the time is 50300661 us.
> >> > > After your patch, 11569357 us.
> >> > > After my debug patch, 6104875 us.
> >> > >
> >> > > I tested it as changing threshold value.
> >> > >
> >> > > threshold time
> >> > > 1000              13892809
> >> > > 500               9062110
> >> > > 200               6714172
> >> > > 100               6104875
> >> > > 50                6758316
> >> > >
> >> > My results show:
> >> >
> >> > threshold        time
> >> > 100000           139309948
> >> > 1000             13555878
> >> > 500              10069801
> >> > 200              7813667
> >> > 100              18523172
> >> > 50               18546256
> >> >
> >> > > And perf shows smp_call_function is very low percentage.
> >> > >
> >> > > In my cases, 100 is best.
> >> > >
> >> > Looks like 200 for me.
> >> >
> >> > I think you meant to use the non _minmax version of proc_dointvec too?
> >>
> >> Yes. My fault :)
> >>
> >> > Although it doesn't make any difference for this basic test.
> >> >
> >> > The original reporter also has 8 cpu cores I've discovered. In his case
> >> > divided by 4 cpus where as mine are divided by 2 cpus, but I think that
> >> > makes no real difference in this case.
> >> >
> >> > I'll try and get some further test results ready shortly. Many thanks
> >> > for all your efforts in tracking this down,
> >> >
> >> > Steve.
> >>
> >> I voted "free area cache".
> > My results with this patch are:
> >
> > vmalloc took 5419238 us
> > vmalloc took 5432874 us
> > vmalloc took 5425568 us
> > vmalloc took 5423867 us
> >
> > So thats about a third of the time it took with my original patch, so
> > very much going in the right direction :-)
> 
> Good. :)
> 
> >
> > I did get a compile warning:
> >  CC      mm/vmalloc.o
> > mm/vmalloc.c: In function a??__free_vmap_areaa??:
> > mm/vmalloc.c:454: warning: unused variable a??preva??
> >
> > ....harmless, but it should be fixed before the final version,
> 
> Of course. It's not formal patch but for showing concept  . :)
> 
> Thanks for consuming precious your time. :)
> As Nick comments, I have to do further work.
> Maybe Nick could do it faster than me.
> Anyway, I hope it can solve your problem.
> 
> Thanks, Steven.
> 
> >
> > Steve.
> >
> >

Your latest patch has now been run though the GFS2 tests which
originally triggered my investigation. It seems to solve the problem
completely. Maybe thanks for your efforts in helping us find and fix the
problem. The next question is what remains to be done in order to get
the patch into a form suitable for upstream merge?

Steve.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
