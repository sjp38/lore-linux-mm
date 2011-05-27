Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0B9D36B0022
	for <linux-mm@kvack.org>; Fri, 27 May 2011 19:17:11 -0400 (EDT)
Date: Sat, 28 May 2011 01:17:08 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] cpusets: randomize node rotor used in
 cpuset_mem_spread_node()
Message-ID: <20110527231708.GB3214@tiehlicka.suse.cz>
References: <20110414065146.GA19685@tiehlicka.suse.cz>
 <20110414160145.0830.A69D9226@jp.fujitsu.com>
 <20110415161831.12F8.A69D9226@jp.fujitsu.com>
 <20110415082051.GB8828@tiehlicka.suse.cz>
 <20110526153319.b7e8c0b6.akpm@linux-foundation.org>
 <20110527124705.GB4067@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1105271157350.2533@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1105271157350.2533@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Jack Steiner <steiner@sgi.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Robin Holt <holt@sgi.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Fri 27-05-11 12:07:30, David Rientjes wrote:
> On Fri, 27 May 2011, Michal Hocko wrote:
> 
> > > alpha allmodconfig:
> > > 
> > > kernel/built-in.o: In function `cpuset_slab_spread_node':
> > > (.text+0x67360): undefined reference to `node_random'
> > > kernel/built-in.o: In function `cpuset_slab_spread_node':
> > > (.text+0x67368): undefined reference to `node_random'
> > > kernel/built-in.o: In function `cpuset_mem_spread_node':
> > > (.text+0x673b8): undefined reference to `node_random'
> > > kernel/built-in.o: In function `cpuset_mem_spread_node':
> > > (.text+0x673c0): undefined reference to `node_random'
> > > 
> > > because it has CONFIG_NUMA=n, CONFIG_NODES_SHIFT=7.
> > 
> > non-NUMA with MAX_NUMA_NODES? Hmm, really weird and looks like a numa
> > misuse.
> > 
> 
> CONFIG_NODES_SHIFT is used for UMA machines that are using DISCONTIGMEM 
> usually because they have very large holes; such machines don't need 
> things like mempolicies but do need the data structures that abstract 
> ranges of memory in the physical address space.  This build breakage 
> probably isn't restricted to only alpha, you could probably see it with at 
> least ia64 and mips as well.

Hmmm. I just find strange that some UMA arch uses functions like
{first,next}_online_node.

[...]
> > +/*
> > + * Return the bit number of a random bit set in the nodemask.
> > + * (returns -1 if nodemask is empty)
> > + */
> > +static inline int node_random(const nodemask_t *maskp)
> > +{
> > +	int w, bit = -1;
> > +
> > +	w = nodes_weight(*maskp);
> > +	if (w)
> > +		bit = bitmap_ord_to_pos(maskp->bits,
> > +			get_random_int() % w, MAX_NUMNODES);
> > +	return bit;
> > +}
> >  
> >  #else
> >  
> 
> Probably should have a no-op definition when MAX_NUMNODES == 1 that just 
> returns 0?

There is one, which has been added by the patch which introduced the
function. This is just an incremental patch for the compilation fix.

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
