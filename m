Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6F43C6B0159
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 09:04:41 -0400 (EDT)
Date: Mon, 21 Sep 2009 14:04:41 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3] slqb: Do not use DEFINE_PER_CPU for per-node data
Message-ID: <20090921130440.GN12726@csn.ul.ie>
References: <1253302451-27740-1-git-send-email-mel@csn.ul.ie> <1253302451-27740-2-git-send-email-mel@csn.ul.ie> <84144f020909200145w74037ab9vb66dae65d3b8a048@mail.gmail.com> <4AB5FD4D.3070005@kernel.org> <4AB5FFF8.7000602@cs.helsinki.fi> <4AB6508C.4070602@kernel.org> <4AB739A6.5060807@in.ibm.com> <20090921084248.GC12726@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090921084248.GC12726@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Sachin Sant <sachinp@in.ibm.com>
Cc: Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 21, 2009 at 09:42:48AM +0100, Mel Gorman wrote:
> On Mon, Sep 21, 2009 at 02:00:30PM +0530, Sachin Sant wrote:
> > Tejun Heo wrote:
> >> Pekka Enberg wrote:
> >>   
> >>> Tejun Heo wrote:
> >>>     
> >>>> Pekka Enberg wrote:
> >>>>       
> >>>>> On Fri, Sep 18, 2009 at 10:34 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> >>>>>         
> >>>>>> SLQB used a seemingly nice hack to allocate per-node data for the
> >>>>>> statically
> >>>>>> initialised caches. Unfortunately, due to some unknown per-cpu
> >>>>>> optimisation, these regions are being reused by something else as the
> >>>>>> per-node data is getting randomly scrambled. This patch fixes the
> >>>>>> problem but it's not fully understood *why* it fixes the problem at the
> >>>>>> moment.
> >>>>>>           
> >>>>> Ouch, that sounds bad. I guess it's architecture specific bug as x86
> >>>>> works ok? Lets CC Tejun.
> >>>>>         
> >>>> Is the corruption being seen on ppc or s390?
> >>>>       
> >>> On ppc.
> >>>     
> >>
> >> Can you please post full dmesg showing the corruption? 
> 
> There isn't a useful dmesg available and my evidence that it's within the
> pcpu allocator is a bit weak. Symptons are crashing within SLQB when a
> second CPU is brought up due to a bad data access with a declared per-cpu
> area. Sometimes it'll look like the value was NULL and other times it's a
> random.
> 
> The "per-cpu" area in this case is actually a per-node area. This implied that
> it was either racing (but the locking looked sound), a buffer overflow (but
> I couldn't find one) or the per-cpu areas were being written to by something
> else unrelated.

This latter guess was close to the mark but not for the reasons I was
guessing. There isn't magic per-cpu-area-freeing going on. Once I examined
the implementation of per-cpu data, it was clear that the per-cpu areas for
the node IDs were never being allocated in the first place on PowerPC. It's
probable that this never worked but that it took a long time before SLQB
was run on a memoryless configuration.

This patch would replace patch 1 of the first hatchet job I did. It's possible
a similar patch is needed for S390. I haven't looked at the implementation
there and I don't have a means of testing it.

=====
powerpc: Allocate per-cpu areas for node IDs for SLQB to use as per-node areas

SLQB uses DEFINE_PER_CPU to define per-node areas. An implicit
assumption is made that all valid node IDs will have matching valid CPU
ids. In memoryless configurations, it is possible to have a node ID with
no CPU having the same ID. When this happens, a per-cpu are is not
created and the value of paca[cpu].data_offset is some random value.
This is later deferenced and the system crashes after accessing some
invalid address.

This patch hacks powerpc to allocate per-cpu areas for node IDs that
have no corresponding CPU id. This gets around the immediate problem but
it should be discussed if there is a requirement for a DEFINE_PER_NODE
and how it should be implemented.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 arch/powerpc/kernel/setup_64.c |   20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
index 1f68160..a5f52d4 100644
--- a/arch/powerpc/kernel/setup_64.c
+++ b/arch/powerpc/kernel/setup_64.c
@@ -588,6 +588,26 @@ void __init setup_per_cpu_areas(void)
 		paca[i].data_offset = ptr - __per_cpu_start;
 		memcpy(ptr, __per_cpu_start, __per_cpu_end - __per_cpu_start);
 	}
+#ifdef CONFIG_SLQB
+	/* 
+	 * SLQB abuses DEFINE_PER_CPU to setup a per-node area. This trick
+	 * assumes that ever node ID will have a CPU of that ID to match.
+	 * On systems with memoryless nodes, this may not hold true. Hence,
+	 * we take a second pass initialising a "per-cpu" area for node-ids
+	 * that SLQB can use
+	 */
+	for_each_node_state(i, N_NORMAL_MEMORY) {
+
+		/* Skip node IDs that a valid CPU id exists for */
+		if (paca[i].data_offset)
+			continue;
+
+		ptr = alloc_bootmem_pages_node(NODE_DATA(cpu_to_node(i)), size);
+
+		paca[i].data_offset = ptr - __per_cpu_start;
+		memcpy(ptr, __per_cpu_start, __per_cpu_end - __per_cpu_start);
+	}
+#endif /* CONFIG_SLQB */
 }
 #endif
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
