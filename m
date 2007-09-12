Date: Wed, 12 Sep 2007 15:06:49 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 3/5] Mem Policy:  MPOL_PREFERRED fixups for "local
 allocation"
In-Reply-To: <20070830185114.22619.61260.sendpatchset@localhost>
Message-ID: <Pine.LNX.4.64.0709121502420.3835@schroedinger.engr.sgi.com>
References: <20070830185053.22619.96398.sendpatchset@localhost>
 <20070830185114.22619.61260.sendpatchset@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 30 Aug 2007, Lee Schermerhorn wrote:

> 1)  [do_]get_mempolicy() calls the now renamed get_policy_nodemask()
>     to fetch the nodemask associated with a policy.  Currently,
>     get_policy_nodemask() returns the set of nodes with memory, when
>     the policy 'mode' is 'PREFERRED, and the preferred_node is < 0.
>     Return the set of allowed nodes instead.  This will already have
>     been masked to include only nodes with memory.

Ok.
 
> 2)  When a task is moved into a [new] cpuset, mpol_rebind_policy() is
>     called to adjust any task and vma policy nodes to be valid in the
>     new cpuset.  However, when the policy is MPOL_PREFERRED, and the
>     preferred_node is <0, no rebind is necessary.  The "local allocation"
>     indication is valid in any cpuset.  Existing code will "do the right
>     thing" because node_remap() will just return the argument node when
>     it is outside of the valid range of node ids.  However, I think it is
>     clearer and cleaner to skip the remap explicitly in this case.

Sounds good. This is on the way to having cpuset relative node 
numbering???
 
> 3)  mpol_to_str() produces a printable, "human readable" string from a
>     struct mempolicy.  For MPOL_PREFERRED with preferred_node <0,  show
>     the entire set of valid nodes.  Although, technically, MPOL_PREFERRED
>     takes only a single node, preferred_node <0 is a local allocation policy,
>     with the preferred node determined by the context where the task
>     is executing.  All of the allowed nodes are possible, as the task
>     migrates amoung the nodes in the cpuset.  Without this change, I believe
>     that node_set() [via set_bit()] will set bit 31, resulting in a misleading
>     display.

Hmmm. But one wants mpol_to_str to represent the memory policy not the 
context information that may change through migration. What you 
do there is provide information from the context. You could add the 
nodemask but I think we need to have some indicator that this policy is 
referring to the local policy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
