Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BCBA16B0027
	for <linux-mm@kvack.org>; Fri, 27 May 2011 08:47:09 -0400 (EDT)
Date: Fri, 27 May 2011 14:47:05 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] cpusets: randomize node rotor used in
 cpuset_mem_spread_node()
Message-ID: <20110527124705.GB4067@tiehlicka.suse.cz>
References: <20110414065146.GA19685@tiehlicka.suse.cz>
 <20110414160145.0830.A69D9226@jp.fujitsu.com>
 <20110415161831.12F8.A69D9226@jp.fujitsu.com>
 <20110415082051.GB8828@tiehlicka.suse.cz>
 <20110526153319.b7e8c0b6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110526153319.b7e8c0b6.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Jack Steiner <steiner@sgi.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Robin Holt <holt@sgi.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Thu 26-05-11 15:33:19, Andrew Morton wrote:
> On Fri, 15 Apr 2011 10:20:51 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > Some workloads that create a large number of small files tend to assign
> > too many pages to node 0 (multi-node systems).  Part of the reason is that
> > the rotor (in cpuset_mem_spread_node()) used to assign nodes starts at
> > node 0 for newly created tasks.
> > 
> > This patch changes the rotor to be initialized to a random node number of
> > the cpuset. We are initializating it lazily in cpuset_mem_spread_node
> > resp. cpuset_slab_spread_node.
> > 
> >
> > ...
> >
> > --- a/kernel/cpuset.c
> > +++ b/kernel/cpuset.c
> > @@ -2465,11 +2465,19 @@ static int cpuset_spread_node(int *rotor)
> >  
> >  int cpuset_mem_spread_node(void)
> >  {
> > +	if (current->cpuset_mem_spread_rotor == -1)
> > +		current->cpuset_mem_spread_rotor =
> > +			node_random(&current->mems_allowed);
> > +
> >  	return cpuset_spread_node(&current->cpuset_mem_spread_rotor);
> >  }
> >  
> >  int cpuset_slab_spread_node(void)
> >  {
> > +	if (current->cpuset_slab_spread_rotor == -1)
> > +		current->cpuset_slab_spread_rotor
> > +			= node_random(&current->mems_allowed);
> > +
> >  	return cpuset_spread_node(&current->cpuset_slab_spread_rotor);
> >  }
> >  
> 
> alpha allmodconfig:
> 
> kernel/built-in.o: In function `cpuset_slab_spread_node':
> (.text+0x67360): undefined reference to `node_random'
> kernel/built-in.o: In function `cpuset_slab_spread_node':
> (.text+0x67368): undefined reference to `node_random'
> kernel/built-in.o: In function `cpuset_mem_spread_node':
> (.text+0x673b8): undefined reference to `node_random'
> kernel/built-in.o: In function `cpuset_mem_spread_node':
> (.text+0x673c0): undefined reference to `node_random'
> 
> because it has CONFIG_NUMA=n, CONFIG_NODES_SHIFT=7.

non-NUMA with MAX_NUMA_NODES? Hmm, really weird and looks like a numa
misuse.

> We use "#if MAX_NUMNODES > 1" in nodemask.h, but we use CONFIG_NUMA
> when deciding to build mempolicy.o.  That's a bit odd - why didn't
> nodemask.h use CONFIG_NUMA?

We have this since the kernel git age. I guess this is just for
optimizations where some functions can be NOOP when there is only one
node.

I know that this is ugly but what if we just define node_random in the
header?
---

Define node_random directly in the mempolicy header

Alpha allows a strange configuration CONFIG_NUMA=n and CONFIG_NODES_SHIFT=7
which means that mempolicy.c is not compiled and linked while we still have
MAX_NUMNODES>1 which means that node_random is not defined.

Let's move node_random definition into the header. We will be consistent with
other node_* functions.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
Index: linus_tree/include/linux/nodemask.h
===================================================================
--- linus_tree.orig/include/linux/nodemask.h	2011-05-27 14:15:52.000000000 +0200
+++ linus_tree/include/linux/nodemask.h	2011-05-27 14:36:30.000000000 +0200
@@ -433,7 +433,21 @@ static inline void node_set_offline(int
 	nr_online_nodes = num_node_state(N_ONLINE);
 }
 
-extern int node_random(const nodemask_t *maskp);
+unsigned int get_random_int(void );
+/*
+ * Return the bit number of a random bit set in the nodemask.
+ * (returns -1 if nodemask is empty)
+ */
+static inline int node_random(const nodemask_t *maskp)
+{
+	int w, bit = -1;
+
+	w = nodes_weight(*maskp);
+	if (w)
+		bit = bitmap_ord_to_pos(maskp->bits,
+			get_random_int() % w, MAX_NUMNODES);
+	return bit;
+}
 
 #else
 
Index: linus_tree/mm/mempolicy.c
===================================================================
--- linus_tree.orig/mm/mempolicy.c	2011-05-27 14:16:05.000000000 +0200
+++ linus_tree/mm/mempolicy.c	2011-05-27 14:16:34.000000000 +0200
@@ -1650,21 +1650,6 @@ static inline unsigned interleave_nid(st
 		return interleave_nodes(pol);
 }
 
-/*
- * Return the bit number of a random bit set in the nodemask.
- * (returns -1 if nodemask is empty)
- */
-int node_random(const nodemask_t *maskp)
-{
-	int w, bit = -1;
-
-	w = nodes_weight(*maskp);
-	if (w)
-		bit = bitmap_ord_to_pos(maskp->bits,
-			get_random_int() % w, MAX_NUMNODES);
-	return bit;
-}
-
 #ifdef CONFIG_HUGETLBFS
 /*
  * huge_zonelist(@vma, @addr, @gfp_flags, @mpol)
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
