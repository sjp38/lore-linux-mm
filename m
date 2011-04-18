Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5C7F2900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 04:42:54 -0400 (EDT)
Date: Mon, 18 Apr 2011 10:42:49 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH incremental] cpusets: initialize spread rotor lazily
Message-ID: <20110418084248.GB8925@tiehlicka.suse.cz>
References: <20110414065146.GA19685@tiehlicka.suse.cz>
 <20110414160145.0830.A69D9226@jp.fujitsu.com>
 <20110415161831.12F8.A69D9226@jp.fujitsu.com>
 <20110415082051.GB8828@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1104151639080.3967@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1104151639080.3967@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Jack Steiner <steiner@sgi.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Robin Holt <holt@sgi.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Fri 15-04-11 16:42:13, David Rientjes wrote:
> On Fri, 15 Apr 2011, Michal Hocko wrote:
> 
> > You are right. I was thinking about lazy approach and initialize those
> > values when they are used for the first time. What about the patch
> > below?
> > 
> > Change from v1:
> > - initialize cpuset_{mem,slab}_spread_rotor lazily
> > 
> 
> The difference between this v2 patch and what is already in the -mm tree 
> (http://userweb.kernel.org/~akpm/mmotm/broken-out/cpusets-randomize-node-rotor-used-in-cpuset_mem_spread_node.patch) 
> is the lazy initialization by adding cpuset_{mem,slab}_spread_node()?

Yes.
 
> It'd probably be better to just make an incremental patch on top of 
> mmotm-2011-04-14-15-08 with a new changelog and then propose with with 
> your list of reviewed-by lines.

Sure, no problems. Maybe it will be easier for Andrew as well.

> 
> Andrew could easily drop the earlier version and merge this v2, but I'm 
> asking for selfish reasons:

Just out of curiosity. What is the reason? Don't want to wait for new mmotm?

> please use NUMA_NO_NODE instead of -1.

Good idea. I have updated the patch.

Changes from v2:
 - use NUMA_NO_NODE rather than hardcoded -1
 - make the patch incremental to the original one because that one is in
   -mm tree already.
Changes from v1:
 - initialize cpuset_{mem,slab}_spread_rotor lazily}

[Here is the follow-up patch based on top of
http://userweb.kernel.org/~akpm/mmotm/broken-out/cpusets-randomize-node-rotor-used-in-cpuset_mem_spread_node.patch]
---
From: Michal Hocko <mhocko@suse.cz>
Subject: cpusets: initialize spread mem/slab rotor lazily

Kosaki Motohiro raised a concern that copy_process is hot path and we do
not want to initialize cpuset_{mem,slab}_spread_rotor if they are not
used most of the time.

I think that we should rather intialize it lazily when rotors are used
for the first time.
This will also catch the case when we set up spread mem/slab later.

Also do not use -1 for unitialized nodes and rather use NUMA_NO_NODE
instead.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 cpuset.c |    8 ++++++++
 fork.c   |    4 ++--
 2 files changed, 10 insertions(+), 2 deletions(-)
Index: linus_tree/kernel/cpuset.c
===================================================================
--- linus_tree.orig/kernel/cpuset.c	2011-04-18 10:33:15.000000000 +0200
+++ linus_tree/kernel/cpuset.c	2011-04-18 10:33:56.000000000 +0200
@@ -2460,11 +2460,19 @@ static int cpuset_spread_node(int *rotor
 
 int cpuset_mem_spread_node(void)
 {
+	if (current->cpuset_mem_spread_rotor == NUMA_NO_NODE)
+		current->cpuset_mem_spread_rotor =
+			node_random(&current->mems_allowed);
+
 	return cpuset_spread_node(&current->cpuset_mem_spread_rotor);
 }
 
 int cpuset_slab_spread_node(void)
 {
+	if (current->cpuset_slab_spread_rotor == NUMA_NO_NODE)
+		current->cpuset_slab_spread_rotor
+			= node_random(&current->mems_allowed);
+
 	return cpuset_spread_node(&current->cpuset_slab_spread_rotor);
 }
 
Index: linus_tree/kernel/fork.c
===================================================================
--- linus_tree.orig/kernel/fork.c	2011-04-18 10:33:15.000000000 +0200
+++ linus_tree/kernel/fork.c	2011-04-18 10:33:56.000000000 +0200
@@ -1126,8 +1126,8 @@ static struct task_struct *copy_process(
 	mpol_fix_fork_child_flag(p);
 #endif
 #ifdef CONFIG_CPUSETS
-	p->cpuset_mem_spread_rotor = node_random(&p->mems_allowed);
-	p->cpuset_slab_spread_rotor = node_random(&p->mems_allowed);
+	p->cpuset_mem_spread_rotor = NUMA_NO_NODE;
+	p->cpuset_slab_spread_rotor = NUMA_NO_NODE;
 #endif
 #ifdef CONFIG_TRACE_IRQFLAGS
 	p->irq_events = 0;
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
