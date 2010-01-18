Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 193856B0083
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 15:54:29 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was: Re: [linux-pm] Memory allocations in .suspend became very unreliable)
Date: Mon, 18 Jan 2010 21:55:09 +0100
References: <201001162317.39940.rjw@sisk.pl> <201001170138.37283.rjw@sisk.pl> <20100118110324.AE30.A69D9226@jp.fujitsu.com>
In-Reply-To: <20100118110324.AE30.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201001182155.09727.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Maxim Levitsky <maximlevitsky@gmail.com>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Monday 18 January 2010, KOSAKI Motohiro wrote:
> > Hi,
> > 
> > I thing the snippet below is a good summary of what this is about.
> > 
> > On Saturday 16 January 2010, Rafael J. Wysocki wrote:
> > > On Saturday 16 January 2010, Maxim Levitsky wrote:
> > > > On Sat, 2010-01-16 at 01:57 +0100, Rafael J. Wysocki wrote: 
> > > > > On Saturday 16 January 2010, Maxim Levitsky wrote:
> > > > > > On Fri, 2010-01-15 at 23:03 +0100, Rafael J. Wysocki wrote: 
> > > > > > > On Friday 15 January 2010, Maxim Levitsky wrote:
> > > > > > > > Hi,
> > > > > > > 
> > > > > > > Hi,
> > > > > > > 
> > > > > > > > I know that this is very controversial, because here I want to describe
> > > > > > > > a problem in a proprietary driver that happens now in 2.6.33-rc3
> > > > > > > > I am taking about nvidia driver.
> > > > > > > > 
> > > > > > > > Some time ago I did very long hibernate test and found no errors after
> > > > > > > > more that 200 cycles.
> > > > > > > > 
> > > > > > > > Now I update to 2.6.33 and notice that system will hand when nvidia
> > > > > > > > driver allocates memory is their .suspend functions. 
> > > > > > > 
> > > > > > > They shouldn't do that, there's no guarantee that's going to work at all.
> > > > > > > 
> > > > > > > > This could fail in 2.6.32 if I would run many memory hungry
> > > > > > > > applications, but now this happens with most of memory free.
> > > > > > > 
> > > > > > > This sounds a little strange.  What's the requested size of the image?
> > > > > > Don't know, but system has to be very tight on memory.
> > > > > 
> > > > > Can you send full dmesg, please?
> > > > 
> > > > I deleted it, but for this case I think that hang was somewhere else.
> > > > This task was hand on doing forking, which probably happened even before
> > > > the freezer.
> > > > 
> > > > Anyway, the problem is clear. Now __get_free_pages blocks more often,
> > > > and can block in .suspend even if there is plenty of memory free.
> > 
> > This is suspicious, but I leave it to the MM people for consideration.
> > 
> > > > I now patched nvidia to use GFP_ATOMIC _always_, and problem disappear.
> > > > It isn't such great solution when memory is tight though....
> > > > 
> > > > This is going to hit hard all nvidia users...
> > > 
> > > Well, generally speaking, no driver should ever allocate memory using
> > > GFP_KERNEL in its .suspend() routine, because that's not going to work, as you
> > > can readily see.  So this is a NVidia bug, hands down.
> > > 
> > > Now having said that, we've been considering a change that will turn all
> > > GFP_KERNEL allocations into GFP_NOIO during suspend/resume, so perhaps I'll
> > > prepare a patch to do that and let's see what people think.
> > 
> > If I didn't confuse anything (which is likely, because it's a bit late here
> > now), the patch below should do the trick.  I have only checked that it doesn't
> > break compilation, so please take it with a grain of salt.
> > 
> > Comments welcome.
> 
> Hmm..
> I don't think this is good idea.
> 
> GFP_NOIO mean "Please don't reclaim if the page is dirty". It mean the system
> have lots dirty pages, this patch might makes hung up.

The point is to prevent the mm subsystem from using I/O.  If there's a better
way, please tell me. :-)

> If suspend need lots memory, we need to make free memory before starting IO
> suspending, I think.

Suspend as such doesn't need a lot of memory, except for some drivers doing
things they shouldn't do.

However, there are a few problems that need to be addressed in general.

First, we can't really guarantee that there's a lot of free memory available
during suspend and some memory allocations are done indirectly, using
GFP_KERNEL (for example, when new kernel threads are started).  If one of
these is done during suspend and it happens to cause the mm subsystem to
start I/O on a suspended devices, the kernel will lock up.

Second, there may be a memory allocation in progress when suspend is started
that causes I/O to happen and races with the suspend process.  If the latter
wins the race, the I/O may be attempted on a suspended device and the kernel
will lock up.

My patch attempts to avoid these two problems as well as the problem with
drivers using GFP_KERNEL allocations during suspend which I admit might be
solved by reworking the drivers.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
