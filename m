Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E59026B0044
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 08:48:46 -0500 (EST)
Date: Fri, 23 Jan 2009 15:04:06 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090123140406.GR15750@one.firstfloor.org>
References: <20090121143008.GV24891@wotan.suse.de> <87hc3qcpo1.fsf@basil.nowhere.org> <20090123112555.GF19986@wotan.suse.de> <20090123115731.GO15750@one.firstfloor.org> <20090123131800.GH19986@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090123131800.GH19986@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

[dropping lameters' outdated address]

On Fri, Jan 23, 2009 at 02:18:00PM +0100, Nick Piggin wrote:
>  
> > > Probably the best way would
> > > be to have dynamic cpu and node allocs for them, I agree.
> > 
> > It's really needed.
> > 
> > > Any plans for an alloc_pernode?
> > 
> > It shouldn't be very hard to implement. Or do you ask if I'm volunteering? @)
> 
> Just if you knew about plans. I won't get too much time to work on

Not aware of anyone working on it.

> it next week, so I hope to have something in slab tree in the
> meantime. I think it is OK to leave now, with a mind to improving

Sorry, the NR_CPUS/MAX_NUMNODE arrays are a merge blocker imho
because they explode with CONFIG_MAXSMP.

> it before a possible mainline merge (there will possibly be more
> serious issues discovered anyway).

I see you fixed the static arrays.

Doing the same for the kmem_cache arrays with making them a pointer
and then using num_possible_{cpus,nodes}() would seem straight forward,
wouldn't it?

Although I think I would prefer alloc_percpu, possibly with
per_cpu_ptr(first_cpu(node_to_cpumask(node)), ...)

> > > > > + * - investiage performance with memoryless nodes. Perhaps CPUs can be given
> > > > > + *   a default closest home node via which it can use fastpath functions.
> > > > 
> > > > FWIW that is what x86-64 always did. Perhaps you can just fix ia64 to do 
> > > > that too and be happy.
> > > 
> > > What if the node is possible but not currently online?
> > 
> > Nobody should allocate on it then.
> 
> But then it goes online and what happens? 

You already have a node online notifier that should handle that then, don't you?

x86-64 btw currently doesn't support node hotplug (but I expect it will
be added at some point), but it should be ok even on architectures
that do.

> Your numa_node_id() changes?

What do you mean?

> How does that work? Or you mean x86-64 does not do that same trick for
> possible but offline nodes?

All I'm saying is that when x86-64 finds a memory less node it assigns
its CPUs to other nodes. Hmm ok perhaps there's a backdoor when someone
sets it with kmalloc_node() but that should normally not happen I think.

> 
> > > git grep -l -e cache_line_size arch/ | egrep '\.h$'
> > > 
> > > Only ia64, mips, powerpc, sparc, x86...
> > 
> > It's straight forward to that define everywhere.
> 
> OK, but this code is just copied straight from SLAB... I don't want
> to add such dependency at this point I'm trying to get something

I'm sure such a straight forward change could be still put into .29

> reasonable to merge. But it would be a fine cleanup.

Hmm to be honest it's a little weird to post so much code and then
say you can't change large parts of it.

Could you perhaps mark all the code you don't want to change?

I'm not sure I follow the rationale for not changing code that has been
copied from elsewhere. If you copied it why can't you change it?
 
> > 
> > Hmm, then fix slub? 
> 
> That's my plan, but I go about it a different way ;) I don't want to
> spend too much time on other allocators or cleanup etc code too much
> right now (except cleanups in SLQB, which of course is required).

But still if you copy code from slub you can improve it, can't you?
The sysfs code definitely could be done much nicer (ok for small values
of "nice"; sysfs is always ugly of course @). But at least it can be
done in a way that doesn't bloat the text so much.

Thanks for the patch.

One thing I'm not sure about is using a private lock to hold off hotplug.
I don't have a concrete scenario, but it makes me uneasy considering
deadlocks when someone sleeps etc. Safer is get/put_online_cpus() 

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
