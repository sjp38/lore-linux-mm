Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4FD9D6B007B
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 06:02:30 -0500 (EST)
Date: Mon, 15 Feb 2010 22:01:36 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [4/4] SLAB: Fix node add timer race in cache_reap
Message-ID: <20100215110135.GN5723@laptop>
References: <20100211953.850854588@firstfloor.org>
 <20100211205404.085FEB1978@basil.firstfloor.org>
 <20100215061535.GI5723@laptop>
 <20100215103250.GD21783@one.firstfloor.org>
 <20100215104135.GM5723@laptop>
 <20100215105253.GE21783@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100215105253.GE21783@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Mon, Feb 15, 2010 at 11:52:53AM +0100, Andi Kleen wrote:
> On Mon, Feb 15, 2010 at 09:41:35PM +1100, Nick Piggin wrote:
> > On Mon, Feb 15, 2010 at 11:32:50AM +0100, Andi Kleen wrote:
> > > On Mon, Feb 15, 2010 at 05:15:35PM +1100, Nick Piggin wrote:
> > > > On Thu, Feb 11, 2010 at 09:54:04PM +0100, Andi Kleen wrote:
> > > > > 
> > > > > cache_reap can run before the node is set up and then reference a NULL 
> > > > > l3 list. Check for this explicitely and just continue. The node
> > > > > will be eventually set up.
> > > > 
> > > > How, may I ask? cpuup_prepare in the hotplug notifier should always
> > > > run before start_cpu_timer.
> > > 
> > > I'm not fully sure, but I have the oops to prove it :)
> > 
> > Hmm, it would be nice to work out why it's happening. If it's completely
> > reproducible then could I send you a debug patch to test?
> 
> Looking at it again I suspect it happened this way:
> 
> cpuup_prepare fails (e.g. kmalloc_node returns NULL). The later
> patches might have cured that. Nothing stops the timer from
> starting in this case anyways.

Hmm, but it should, because if cpuup_prepare fails  then the
CPU_ONLINE notifiers should never be called I think.

 
> So given that the first patches might not be needed, but it's
> safer to have anyways.

I'm just worried there is still an underlying problem here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
