Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id WAA28685
	for <linux-mm@kvack.org>; Thu, 12 Sep 2002 22:31:18 -0700 (PDT)
Message-ID: <3D817BC8.785F5C44@digeo.com>
Date: Thu, 12 Sep 2002 22:46:49 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] per-zone kswapd process
References: <3D815C8C.4050000@us.ibm.com> <3D81643C.4C4E862C@digeo.com> <20020913045938.GG2179@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> On Thu, Sep 12, 2002 at 09:06:20PM -0700, Andrew Morton wrote:
> > I still don't see why it's per zone and not per node.  It seems strange
> > that a wee little laptop would be running two kswapds?
> > kswapd can get a ton of work done in the development VM and one per
> > node would, I expect, suffice?
> 
> Machines without observable NUMA effects can benefit from it if it's
> per-zone. It also follows that if there's more than one task doing this,
> page replacement is less likely to block entirely. Last, but not least,
> when I devised it, "per-zone" was the theme.

Maybe, marginally.  You could pass a gfp mask to sys_kswapd to select
the zones if that's really a benefit.  But if this _is_ a benefit then
it's a VM bug.  

Because if a single kswapd cannot service three zones then it cannot
service one zone. (Maybe.  We need to do per-zone throttling soon to
fix your OOM problems properly, but then, that shouldn't throttle
kswapd).

> On Thu, Sep 12, 2002 at 09:06:20PM -0700, Andrew Morton wrote:
> > Also, I'm wondering why the individual kernel threads don't have
> > their affinity masks set to make them run on the CPUs to which the
> > zone (or zones) are local?
> > Isn't it the case that with this code you could end up with a kswapd
> > on node 0 crunching on node 1's pages while a kswapd on node 1 crunches
> > on node 0's pages?
> 
> Without some architecture-neutral method of topology detection, there's
> no way to do this. A follow-up when it's there should fix it.

Sorry, I don't buy that.

a) It does not need to be architecture neutral.  

b) You surely need a way of communicating the discovered topology
   to userspace anyway.

c) $EDITOR /etc/numa-layouf.conf

d) $EDITOR /etc/kswapd.conf
 
> On Thu, Sep 12, 2002 at 09:06:20PM -0700, Andrew Morton wrote:
> > If I'm not totally out to lunch on this, I'd have thought that a
> > better approach would be
> >       int sys_kswapd(int nid)
> >       {
> >               return kernel_thread(kswapd, ...);
> >       }
> > Userspace could then set up the CPU affinity based on some topology
> > or config information and would then parent a kswapd instance.  That
> > kswapd instance would then be bound to the CPUs which were on the
> > node identified by `nid'.
> > Or something like that?
> 
> I'm very very scared of handing things like that to userspace, largely
> because I don't trust userspace at all.

Me either.  I've seen workloads in which userspace consumes
over 50% of the CPU resources.  It should be banned!

> At this point, we need to enumerate nodes and provide a cpu to node
> correspondence to userspace, and the kernel can obey, aside from the
> question of "What do we do if we need to scan a node without a kswapd
> started yet?".

kswapd is completely optional.  Put a `do_exit(0)' into the current
one and watch.   You'll get crappy dbench numbers, but it stays up.

> I think mbligh recently got the long-needed arch code in
> for cpu to node... But I'm just not able to make the leap of faith that
> memory detection is something that can ever comfortably be given to
> userspace.

A simple syscall which alows you to launch a kswapd instance against
a group of zones on any group of CPUs provides complete generality 
and flexibility to userspace.  And it is architecture neutral.

If it really is incredibly hard to divine the topology from userspace
then you need to fix that up.  Provide the topology to userspace.
Which has the added benefit of providing, umm, the topology to userspace ;)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
