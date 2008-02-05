Date: Tue, 05 Feb 2008 18:26:59 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [2.6.24 regression][BUGFIX] numactl --interleave=all doesn't works on memoryless node.
In-Reply-To: <1202149243.5028.61.camel@localhost>
References: <20080202180536.F494.KOSAKI.MOTOHIRO@jp.fujitsu.com> <1202149243.5028.61.camel@localhost>
Message-Id: <20080205163406.270B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi Lee-san

I change subject because 2.6.24 reproduce too.


> I have a patch that takes a different approach to "interleave=all" that
> doesn't solve Paul's and David's requirements.  I also have patches to
> libnuma and numactl that work with my patches, but I saw no sense in
> posting them unless my kernel patches got some traction.  If interested,
> you can find them at:
> 
>  http://free.linux.hp.com/~lts/Patches/Numactl/

unfortunately it doesn't works on my test environment ;-)

				numactl-orig		numactl-with-lee-patch
	2.6.24			  failed		  failed
	2.6.24-rc8-mm1		  failed		  failed


I got below error messages by all case.

	$ numactl --interleave=all ls
	set_mempolicy: Invalid argument
	setting interleave mask: Invalid argument


I think kernel is need changed too.
I attached bellow.
kernel2.6.24-rc8-mm1 + mypatch + numactl-1.0.2 + leepatch works good.

> > and I made simple patch that has_high_memory exposed however CONFIG_HIGHMEM disabled.
> > if CONFIG_HIGHMEM disabled, the has_high_memory file show 
> > the same as the has_normal_memory.
> > may be, userland process should check has_high_memory file.
> 
> Regarding the patch itself:  If others have no problems with displaying
> a "has_high_memory" node mask for systems w/o HIGH_MEM configured, I can
> live with it.  
> 
> The current upstream kernel [2.6.24] supports a MPOL_MEMS_ALLOWED flag
> to get_mempolicy() to return the nodes allowed in the caller's cpuset.
> My numactl patches, mentioned above, support this.

OK, I cancel my previous has_high_memory patch.
and, I understood anyone doesn't use 32bit numa.


> However, as Andi says, we really can't break application behavior.  All
> applications that use mempolicy don't necessarily use libnuma APIs.  So,
> a fully populated interleave node mask should be allowed and should
> probably mean "all allowed nodes with memory". 

Agreed.

> I think we'd still need to reduce the interleave policy mask to nodes
> with memory when it's installed or find another way to skip memoryless
> nodes when interleaving, else we don't get even distribution of
> interleaved pages over the nodes that do have memory.  This is one of
> the memoryless nodes fixes.  I THINK this is one of the areas that Paul
> and David are investigating.

this is good news for me :)
I'll wait his patch post.



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/mempolicy.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

Index: b/mm/mempolicy.c
===================================================================
--- a/mm/mempolicy.c    2008-02-02 17:54:33.000000000 +0900
+++ b/mm/mempolicy.c    2008-02-05 17:49:47.000000000 +0900
@@ -187,9 +187,12 @@ static struct mempolicy *mpol_new(int mo
        atomic_set(&policy->refcnt, 1);
        switch (mode) {
        case MPOL_INTERLEAVE:
-               policy->v.nodes = *nodes;
-               nodes_and(policy->v.nodes, policy->v.nodes,
-                                       node_states[N_HIGH_MEMORY]);
+               if (nodes) {
+                       policy->v.nodes = *nodes;
+                       nodes_and(policy->v.nodes, policy->v.nodes,
+                                 node_states[N_HIGH_MEMORY]);
+               } else
+                       policy->v.nodes = node_states[N_HIGH_MEMORY];
                if (nodes_weight(policy->v.nodes) == 0) {
                        kmem_cache_free(policy_cache, policy);
                        return ERR_PTR(-EINVAL);
@@ -934,7 +937,7 @@ asmlinkage long sys_set_mempolicy(int mo
        err = get_nodes(&nodes, nmask, maxnode);
        if (err)
                return err;
-       return do_set_mempolicy(mode, &nodes);
+       return do_set_mempolicy(mode, nodes_empty(nodes) ? NULL : &nodes);
 }

 asmlinkage long sys_migrate_pages(pid_t pid, unsigned long maxnode,



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
