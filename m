Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A3C666B01F1
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 09:22:48 -0400 (EDT)
Subject: Re: [PATCH 1/8] numa:  add generic percpu var numa_node_id()
 implementation
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20100416133324.fcb1c168.akpm@linux-foundation.org>
References: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>
	 <20100415172956.8801.18133.sendpatchset@localhost.localdomain>
	 <20100416133324.fcb1c168.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Mon, 19 Apr 2010 09:22:31 -0400
Message-Id: <1271683352.10937.34.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, andi@firstfloor.org, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2010-04-16 at 13:33 -0700, Andrew Morton wrote:
> On Thu, 15 Apr 2010 13:29:56 -0400
> Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:
> 
> > Rework the generic version of the numa_node_id() function to use the
> > new generic percpu variable infrastructure.
> > 
> > Guard the new implementation with a new config option:
> > 
> >         CONFIG_USE_PERCPU_NUMA_NODE_ID.
> > 
> > Archs which support this new implemention will default this option
> > to 'y' when NUMA is configured.  This config option could be removed
> > if/when all archs switch over to the generic percpu implementation
> > of numa_node_id().  Arch support involves:
> > 
> >   1) converting any existing per cpu variable implementations to use
> >      this implementation.  x86_64 is an instance of such an arch.
> >   2) archs that don't use a per cpu variable for numa_node_id() will
> >      need to initialize the new per cpu variable "numa_node" as cpus
> >      are brought on-line.  ia64 is an example.
> >   3) Defining USE_PERCPU_NUMA_NODE_ID in arch dependent Kconfig--e.g.,
> >      when NUMA is configured.  This is required because I have
> >      retained the old implementation by default to allow archs to
> >      be modified incrementally, as desired.
> > 
> > Subsequent patches will convert x86_64 and ia64 to use this
> > implemenation.
> 
> So which arches _aren't_ converted?  powerpc, sparc and alpha?

Right.  Plus ARM, mips, ...

I could take a cut at other archs, but can't test them.  I'm hoping that
this patch doesn't break the existing implementation for them.  It
should be a no-op until the new support is enabled via Kconfig.  The
fact that both x86_64 and ia64 build with just this patch gives me some
hope but not a lot of confidence.

I see that you've merged the series with into -mm.  We'll see what
happens.  Of course, no reports of errors could just mean no testing.

> 
> Is there sufficient info here for the maintainers to be able to
> perform the conversion with minimal head-scratching?

Arch maintainers will need to chime in on that.  I'd hoped that the list
above and the examples of x86_64 and ia64 in the subsequent patches
would suffice.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
