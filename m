Date: Thu, 17 Nov 2005 19:38:17 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH] NUMA policies in the slab allocator V2
In-Reply-To: <200511180359.17598.ak@suse.de>
Message-ID: <Pine.LNX.4.62.0511171925090.22785@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0511171745410.22486@schroedinger.engr.sgi.com>
 <200511180359.17598.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Fri, 18 Nov 2005, Andi Kleen wrote:

> On Friday 18 November 2005 02:51, Christoph Lameter wrote:
> > This patch fixes a regression in 2.6.14 against 2.6.13 that causes an
> > imbalance in memory allocation during bootup.
> 
> I still think it's wrongly implemented. We shouldn't be slowing down the slab 
> fast path for this. Also BTW if anything your check would need to be 
> dependent on !in_interrupt(), otherwise the policy of slab allocations
> in interrupt context will change randomly based on what the current
> process is doing (that's wrong, interrupts should be always local)
> But of course that would make the fast path even slower ...

We can add that check to slab_node() to avoid these issues and it will be 
out of the fast path then. I would like to hear about alternatives to 
this. You really want to run the useless fastpath? Examine lists etc for 
the local node despite the policy telling you to get off node?

Hmm. Is a hugepage ever allocated from interrupt context? We may have the 
same issues there.

Index: linux-2.6/mm/mempolicy.c
===================================================================
--- linux-2.6.orig/mm/mempolicy.c	2005-11-17 19:30:10.862617183 -0800
+++ linux-2.6/mm/mempolicy.c	2005-11-17 19:31:47.040578059 -0800
@@ -774,6 +774,9 @@
  */
 unsigned slab_node(struct mempolicy *policy)
 {
+	if (in_interrupt())
+		return numa_node_id();
+
 	switch (policy->policy) {
 	case MPOL_INTERLEAVE:
 		return interleave_nodes(policy);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
