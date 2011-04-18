Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E4BB3900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 17:29:19 -0400 (EDT)
Date: Mon, 18 Apr 2011 23:29:16 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH incremental] cpusets: initialize spread rotor lazily
Message-ID: <20110418212915.GA17376@tiehlicka.suse.cz>
References: <20110414065146.GA19685@tiehlicka.suse.cz>
 <20110414160145.0830.A69D9226@jp.fujitsu.com>
 <20110415161831.12F8.A69D9226@jp.fujitsu.com>
 <20110415082051.GB8828@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1104151639080.3967@chino.kir.corp.google.com>
 <20110418084248.GB8925@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1104181316110.31186@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1104181316110.31186@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Jack Steiner <steiner@sgi.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Robin Holt <holt@sgi.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Mon 18-04-11 13:19:09, David Rientjes wrote:
> On Mon, 18 Apr 2011, Michal Hocko wrote:
[...]
> > > Andrew could easily drop the earlier version and merge this v2, but I'm 
> > > asking for selfish reasons:
> > 
> > Just out of curiosity. What is the reason? Don't want to wait for new mmotm?
> > 
> 
> Because lazy initialization is another feature on top of the existing 
> patch so it should be done incrementally instead of proposing an entirely 
> new patch which is already mostly in -mm.

ok, makes sense

> > 
> > [Here is the follow-up patch based on top of
> > http://userweb.kernel.org/~akpm/mmotm/broken-out/cpusets-randomize-node-rotor-used-in-cpuset_mem_spread_node.patch]
> > ---
> > From: Michal Hocko <mhocko@suse.cz>
> > Subject: cpusets: initialize spread mem/slab rotor lazily
> > 
[...]
> > Also do not use -1 for unitialized nodes and rather use NUMA_NO_NODE
> > instead.
> > 
> 
> Don't need to refer to a previous version that used -1 since it will never 
> be committed and nobody will know what you're talking about in the git 
> log.

removed

[...]
> >  int cpuset_mem_spread_node(void)
> >  {
> > +	if (current->cpuset_mem_spread_rotor == NUMA_NO_NODE)
> > +		current->cpuset_mem_spread_rotor =
> > +			node_random(&current->mems_allowed);
> > +
> >  	return cpuset_spread_node(&current->cpuset_mem_spread_rotor);
> >  }
> >  
> >  int cpuset_slab_spread_node(void)
> >  {
> > +	if (current->cpuset_slab_spread_rotor == NUMA_NO_NODE)
> > +		current->cpuset_slab_spread_rotor
> > +			= node_random(&current->mems_allowed);
> > +
> 
> So one function has the `=' on the line with the assignment (preferred) 
> and the other has it on the new value?

fixed

Thanks! Updated patch bellow.

Changes from v3:
 - code style fix
Changes from v2:
 - use NUMA_NO_NODE rather than hardcoded -1
 - make the patch incremental to the original one because that one is in
   -mm tree already.
Changes from v1:
 - initialize cpuset_{mem,slab}_spread_rotor lazily}
---
From: Michal Hocko <mhocko@suse.cz>
Subject: cpusets: initialize spread mem/slab rotor lazily

Kosaki Motohiro raised a concern that copy_process is hot path and we do
not want to initialize cpuset_{mem,slab}_spread_rotor if they are not
used most of the time.

I think that we should rather initialize it lazily when rotors are used
for the first time.
This will also catch the case when we set up spread mem/slab later.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Index: linus_tree/kernel/cpuset.c
===================================================================
--- linus_tree.orig/kernel/cpuset.c	2011-04-18 10:33:15.000000000 +0200
+++ linus_tree/kernel/cpuset.c	2011-04-18 23:24:02.000000000 +0200
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
+		current->cpuset_slab_spread_rotor =
+			node_random(&current->mems_allowed);
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
