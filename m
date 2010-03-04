Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 323876B0099
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 11:58:44 -0500 (EST)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 04 Mar 2010 12:06:54 -0500
Message-Id: <20100304170654.10606.32225.sendpatchset@localhost.localdomain>
Subject: [PATCH/RFC 0/8] Numa: Use Generic Per-cpu Variables for numa_*_id()
Sender: owner-linux-mm@kvack.org
To: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, akpm@linux-foundation.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

Use Generic Per cpu infrastructure for numa_*_id() V3

Series against 2.6.33-mmotm-100302-1838

Just getting back to this series as the original issue that got me on this
track is still a problem for us.  For context, see my inital posting:

	http://marc.info/?l=linux-arch&amp;m=125814673120678&amp;w=4
	http://marc.info/?l=linux-mm&amp;m=125814674120706&amp;w=4
	http://marc.info/?l=linux-mm&amp;m=125814677520784&amp;w=4
	http://marc.info/?l=linux-mm&amp;m=125814678120803&amp;w=4
	http://marc.info/?l=linux-arch&amp;m=125814678120803&amp;w=4
	...

This series resolved the problem on our ia64 platforms and caused no
regression in x86_64 [a slight improvement even] for the admittedly
few tests that I ran.  However, reviewers raised a couple of issues:

1) I hacked up {linux|asm-generic}/percpu.h quite heavily to break a
circular header dependency.  Tejun reviewed my patches and sent
suggestions off-list.  I'll respond to his comments below.

2) Using the generic percpu.h would require all archs to adjust their
asm/percpu.h to utilize the generic percpu verion of numa_*_id().
However, I think my series did not require changes to other archs just
to build with the old behavior.

On Tue, 2009-12-15 at 17:05 +0900, Tejun Heo wrote:

>Hello,
>On 12/01/2009 09:49 PM, Lee Schermerhorn wrote:
> On Tue, 2009-12-01 at 14:56 +0900, Tejun Heo wrote:
>> Hello,
>>
>> (private reply)
>>
>> On 12/01/2009 05:28 AM, Lee Schermerhorn wrote:
>>> So here's what happened:
>>>
>>> linux/topology.h now depends on */percpu.h to implement numa_node_id()
>>> and numa_mem_id().  Not so much an issue for x86 because its
>>> asm/topology.h already depended on its asm/percpu.h.  But ia64, for
>>> instance--maybe any arch that doesn't already implement numa_node_id()
>>> as a percpu variable--didn't define this_cpu_read() for
>>> linux/topology.h.
>>
>> Can you please send me the patches?
>>
>> Tejun:
>>
>> I have attached the entire series as a tarball.  If you'd like me to
>> send you the patches as separate messages, let me know.
>>
>> I should have copied you directly on the original posting [13nov on -mm
>> and -arch].  I intended to, but forgot last minute.

> Sorry about the delay.  Several comments.

Thank you for the review.  No problem with the "delay".  I've been busy
with other matters myself.

> nid-01:
>
> * Is moving this_cpu ops to asm-generic/percpu.h necessary?  I know
>   the current ops / defs organization is a bit messy and intend to
>   clean things up but I'm not quite sure those ops belong to
>   asm-generic/percpu.h which I kind of want to remove and move stuff
>   to either linux/percpu-defs.h or linux/percpu.h.

Is it necessary?  If we want to keep the definition of numa_node_id() in
topology.h, where it currently resides, and use the generic percpu
infrastructure, as Christoph suggested, we need to break the circular
dependency:
	  topology.h -> percpu.h [added] -> slab.h -> gfp.h -> topology.h

Willy suggested that I un-inline __alloc_percpu() and free_percpu() for
the !SMP case.  This would allow me to remove the include of slab.h from
percpu.h.  I tried this.  In allyesconfig w/ !SMP, this results in over
700 files failing to build.  Apparently, they depend on percpu.h to
include slab.h [?!!!].   I can generate patches to fix these, but
I'm wondering whether that's the right approach.

My first generic percpu numa_node_id series followed models I saw for other
{linux|asm|asm-generic}/foo.h stacks.  I wanted to be able to continue to
have percpu.h include slab.h for all the places that assume this [:(], while
giving topology.h access to the generic definitions via the arch specific
percpu.h.  Of course, I did this by assuming that the asm/topology.h will
include asm/percpu.h -- smaller patch :).  I'll fix that.  Then arch won't
need to modify their asm/topology.h to use the generic numa_*_id() defs,
unless they already implement numa_node_id() using percpu variables and
want to back that out to use the generic versions [like x86].

So, if we can sort this issue out -- how to break the circular header
dependency in a manner acceptable to all -- we should be able to use the
generic percpu infrastructure for the numa_*_id() functions, as Christoph
suggested.  The 7th patch in the series [slab use numa_mem_id], which is
my primary reason for working this, may still need work to handle node
hotplug and zonelist rebuild.  I'll address that as a separate series/thread,
if Andi Kleen's and others' slab hotplug work doesn't handle it.

Tejun's suggestion of using a linux/percpu-defs.h for the generic defs
appears to work, enabling me to include the generic definitions in topology.h
w/o pulling in slab.h.  This version of the series takes that approach.

>* Also, please separate out the changes to implement the numa stuff
>  from percpu changes.  It's a bit confusing to review.

Patch 1 of this series separates out the percpu.h changes.

>nid-02:
>
>* If you define __this_cpu_read/write() in
>  arch/x86/include/asm/percpu.h, you don't need to define any of
>  __this_cpu_read/write_n() versions, right?

The *_n versions were already there.

In the previous version asked whether we could at least define the '*_n()'
wrappers in terms of _this_cpu_read/write().  I recall that Christoph
responded [offlist, maybe?] that we need the '_n versions as they're defined.
But, I agree that the basic x86 implementation seems to handle any sized
argument.

> Also, I think this belongs to a separate patch.

Will do.

>nid-03:
>
>* I think numa_node and numa_mem variables are better defined in
>  page_alloc (or some other file which has more to do with numa aware
>  memory allocation).  Till now, mm/percpu.c only contains the percpu
>  allocator itself, so adding numa stuff there seems a bit strange.

Done.  =>page_alloc.c

>nid-04:
>
>* Isn't #define numa_mem numa_node a bit dangerous?  Someone might use
>  numa_mem as a local variable name.  Why not define it as a inline
>  function or at least a macro which takes argument.

numa_mem and numa_node are the names of the per cpu variables, referenced
by __this_cpu_read().  So, I suppose we can rename them both something like:
percpu_numa_*.  Would satisfy your concern?

What do others think?

Currently I've left them as numa_mem and numa_node.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
