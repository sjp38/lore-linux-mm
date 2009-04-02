Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9B16B6B003D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 12:24:24 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 0/6] Guest page hinting version 7.
Date: Fri, 3 Apr 2009 03:23:36 +1100
References: <20090327150905.819861420@de.ibm.com> <200904022232.02185.nickpiggin@yahoo.com.au> <20090402175249.3c4a6d59@skybase>
In-Reply-To: <20090402175249.3c4a6d59@skybase>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200904030323.37523.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.osdl.org, akpm@osdl.org, frankeh@watson.ibm.com, riel@redhat.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Friday 03 April 2009 02:52:49 Martin Schwidefsky wrote:
> On Thu, 2 Apr 2009 22:32:00 +1100
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> > On Monday 30 March 2009 01:23:36 Martin Schwidefsky wrote:
> > > On Sat, 28 Mar 2009 17:05:28 +1030
> > >
> > > Rusty Russell <rusty@rustcorp.com.au> wrote:
> > > > On Saturday 28 March 2009 01:39:05 Martin Schwidefsky wrote:
> > > > > Greetings,
> > > > > the circus is back in town -- another version of the guest page hinting
> > > > > patches. The patches differ from version 6 only in the kernel version,
> > > > > they apply against 2.6.29. My short sniff test showed that the code
> > > > > is still working as expected.
> > > > >
> > > > > To recap (you can skip this if you read the boiler plate of the last
> > > > > version of the patches):
> > > > > The main benefit for guest page hinting vs. the ballooner is that there
> > > > > is no need for a monitor that keeps track of the memory usage of all
> > > > > the guests, a complex algorithm that calculates the working set sizes
> > > > > and for the calls into the guest kernel to control the size of the
> > > > > balloons.
> > > >
> > > > I thought you weren't convinced of the concrete benefits over ballooning,
> > > > or am I misremembering?
> > >
> > > The performance test I have seen so far show that the benefits of
> > > ballooning vs. guest page hinting are about the same. I am still
> > > convinced that the guest page hinting is the way to go because you do
> > > not need an external monitor. Calculating the working set size for a
> > > guest is a challenge. With guest page hinting there is no need for a
> > > working set size calculation.
> > 
> > Sounds backwards to me. If the benefits are the same, then having
> > complexity in an external monitor (which, by the way, shares many
> > problems and goals of single-kernel resource/workload management),
> > rather than putting a huge chunk of crap in the guest kernel's core
> > mm code.
> 
> The benefits are the same but the algorithmic complexity is reduced.
> The patch to the memory management has complexity in itself but from a
> 1000 feet standpoint guest page hinting is simpler, no?

Yeah but that's a tradeoff I'll begrudgingly make, considering
a) lots of people doing workload management inside cgroups/containers
   need similar algorithmic complexity so improvements to those
   algorithms will help one another
b) it may be adding complexity, but it isn't adding complexity to a
   subsystem that is already among the most complex in the kernel
c) i don't have to help maintain it


> The question
> how much memory each guest has to release does not exist. With the
> balloner I have seen a few problematic cases where the size of
> the balloon in principle killed the guest. My favorite is the "clever"
> monitor script that queried the guests free memory and put all free
> memory into the balloon. Now gues what happened with a guest that just
> booted..
> 
> And could you please explain with a few more words >what< you consider
> to be "crap"? I can't do anything with a general statement "this is
> crap". Which translates to me: leave me alone..

:) No it's cool code, interesting idea etc, and last time I looked I
don't think I saw any fundamental (or even any significant incidental)
bugs.

So I guess my problem with it is that it adds complexity to benefit a
small portion of users where there is already another solution that
another set of users already require.

 
> > I still think this needs much more justification.
>  
> Ok, I can understand that. We probably need a KVM based version to show
> that benefits exist on non-s390 hardware as well.
 
Should be significantly better than ballooning too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
