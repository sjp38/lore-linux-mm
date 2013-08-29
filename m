Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 91F786B0032
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 05:28:39 -0400 (EDT)
Date: Thu, 29 Aug 2013 10:28:29 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] cpuset: mm: Reduce large amounts of memory barrier
 related damage v3
Message-ID: <20130829092828.GB22421@suse.de>
References: <20120307180852.GE17697@suse.de>
 <20130823130332.GY31370@twins.programming.kicks-ass.net>
 <20130823181546.GA31370@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130823181546.GA31370@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Miao Xie <miaox@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@redhat.com

On Fri, Aug 23, 2013 at 08:15:46PM +0200, Peter Zijlstra wrote:
> On Fri, Aug 23, 2013 at 03:03:32PM +0200, Peter Zijlstra wrote:
> > So I think this patch is broken (still).

I am assuming the lack of complaints is that it is not a heavily executed
path. I expect that you (and Rik) are hitting this as part of automatic
NUMA balancing. Still a bug, just slightly less urgent if NUMA balancing
is the reproduction case.

> > Suppose we have an
> > INTERLEAVE mempol like 0x3 and change it to 0xc.
> > 
> > Original:	0x3
> > Rebind Step 1:	0xf /* set bits */
> > Rebind Step 2:	0xc /* clear bits */
> > 
> > Now look at what can happen with offset_il_node() when its ran
> > concurrently with step 2:
> > 
> >   nnodes = nodes_weight(pol->v.nodes); /* observes 0xf and returns 4 */
> > 
> >   /* now we clear the actual bits */
> >   
> >   target = (unsigned int)off % nnodes; /* assume target >= 2 */
> >   c = 0;
> >   do {
> >   	nid = next_node(nid, pol->v.nodes);
> > 	c++;
> >   } while (c <= target);
> > 
> >   /* here nid := MAX_NUMNODES */
> > 
> > 
> > This nid is then blindly inserted into node_zonelist() which does an
> > NODE_DATA() array access out of bounds and off we go.
> > 
> > This would suggest we put the whole seqcount thing inside
> > offset_il_node().
> 
> Oh bloody grrr. Its not directly related at all, the patch in question
> fixes a cpuset task_struct::mems_allowed problem while the above is a
> mempolicy issue and of course the cpuset and mempolicy code are
> completely bloody different :/
> 
> So I guess the quick and ugly solution is something like the below. 
> 
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1762,19 +1762,21 @@ unsigned slab_node(void)
>  static unsigned offset_il_node(struct mempolicy *pol,
>  		struct vm_area_struct *vma, unsigned long off)
>  {
> -	unsigned nnodes = nodes_weight(pol->v.nodes);
> -	unsigned target;
> -	int c;
> -	int nid = -1;
> +	unsigned nnodes, target;
> +	int c, nid;
>  
> +again:
> +	nnodes = nodes_weight(pol->v.nodes);
>  	if (!nnodes)
>  		return numa_node_id();
> +
>  	target = (unsigned int)off % nnodes;
> -	c = 0;
> -	do {
> +	for (c = 0, nid = -1; c <= target; c++)
>  		nid = next_node(nid, pol->v.nodes);
> -		c++;
> -	} while (c <= target);
> +
> +	if (unlikely((unsigned)nid >= MAX_NUMNODES))
> +		goto again;
> +

MAX_NUMNODES is unrelated to anything except that it might prevent a crash
and even then nr_online_nodes is probably what you wanted and even that
assumes the NUMA node numbering is contiguous. The real concern is whether
the updated mask is an allowed target for the updated memory policy. If
it's not then "nid" can be pointing off the deep end somewhere.  With this
conversion to a for loop there is race after you check nnodes where target
gets set to 0 and then return a nid of -1 which I suppose will just blow
up differently but it's fixable.

This? Untested. Fixes implicit types while it's there. Note the use of
first node and (c < target) to guarantee nid gets set and that the first
potential node is still used as an interleave target.

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 7431001..ae880c3 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1755,22 +1755,24 @@ unsigned slab_node(void)
 }
 
 /* Do static interleaving for a VMA with known offset. */
-static unsigned offset_il_node(struct mempolicy *pol,
+static unsigned int offset_il_node(struct mempolicy *pol,
 		struct vm_area_struct *vma, unsigned long off)
 {
-	unsigned nnodes = nodes_weight(pol->v.nodes);
-	unsigned target;
-	int c;
-	int nid = -1;
+	unsigned int nr_nodes, target;
+	int i, nid;
 
-	if (!nnodes)
+again:
+	nr_nodes = nodes_weight(pol->v.nodes);
+	if (!nr_nodes)
 		return numa_node_id();
-	target = (unsigned int)off % nnodes;
-	c = 0;
-	do {
+	target = (unsigned int)off % nr_nodes;
+	for (i = 0, nid = first_node(pol->v.nodes); i < target; i++)
 		nid = next_node(nid, pol->v.nodes);
-		c++;
-	} while (c <= target);
+
+	/* Policy nodemask can potentially update in parallel */
+	if (unlikely(!node_isset(nid, pol->v.nodes)))
+		goto again;
+
 	return nid;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
