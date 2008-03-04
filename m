Subject: [PATCH] 2.6.25-rc3-mm1 - Mempolicy - update stale documentation
	and comments
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080228230140.321581a4.pj@sgi.com>
References: <20071109143226.23540.12907.sendpatchset@skynet.skynet.ie>
	 <20071109143406.23540.41284.sendpatchset@skynet.skynet.ie>
	 <20080228230140.321581a4.pj@sgi.com>
Content-Type: text/plain
Date: Tue, 04 Mar 2008 15:20:56 -0500
Message-Id: <1204662057.5338.104.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>, akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, nacc@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Was Re: [PATCH 5/6] Filter based on a nodemask as well as a gfp_mask

On Thu, 2008-02-28 at 23:01 -0600, Paul Jackson wrote:
> Mel wrote:
> > A positive benefit of
> > this is that allocations using MPOL_BIND now use the local-node-ordered
> > zonelist instead of a custom node-id-ordered zonelist.
> 
> Could you update the now obsolete documentation (perhaps just delete
> the no longer correct remark):
> 
> Documentation/vm/numa_memory_policy.txt:
> 
>         MPOL_BIND:  This mode specifies that memory must come from the
>         set of nodes specified by the policy.
> 
>             The memory policy APIs do not specify an order in which the nodes
>             will be searched.  However, unlike "local allocation", the Bind
>             policy does not consider the distance between the nodes.  Rather,
>             allocations will fallback to the nodes specified by the policy in
>             order of numeric node id.  Like everything in Linux, this is subject
>             to change.
> 

How's this:

PATCH Mempolicy:  update documentation and comments

Address stale comments and numa_memory_policy.txt discussion
based on Mel Gorman's changes to page allocation zonelist handling.

Specifically:  mpol_free() and mpol_copy() no longer need to deal
with a custom zonelist for MPOL_BIND policy, and MPOL_BIND now
allocates memory from the nearest node with available memory in the
specified nodemask.

In "fixing" the mpol_free() and mpol_copy() comments in mempolicy.h,
I wanted to replace them with something, rather than just deleting
them.  So, I described the reference counting.  Not directly related
to the zonelist changes, but useful, IMO.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 Documentation/vm/numa_memory_policy.txt |   11 +++--------
 include/linux/mempolicy.h               |    8 +++++---
 2 files changed, 8 insertions(+), 11 deletions(-)

Index: linux-2.6.25-rc3-mm1/Documentation/vm/numa_memory_policy.txt
===================================================================
--- linux-2.6.25-rc3-mm1.orig/Documentation/vm/numa_memory_policy.txt	2008-01-24 17:58:37.000000000 -0500
+++ linux-2.6.25-rc3-mm1/Documentation/vm/numa_memory_policy.txt	2008-03-04 14:44:51.000000000 -0500
@@ -182,14 +182,9 @@ Components of Memory Policies
 	    The Default mode does not use the optional set of nodes.
 
 	MPOL_BIND:  This mode specifies that memory must come from the
-	set of nodes specified by the policy.
-
-	    The memory policy APIs do not specify an order in which the nodes
-	    will be searched.  However, unlike "local allocation", the Bind
-	    policy does not consider the distance between the nodes.  Rather,
-	    allocations will fallback to the nodes specified by the policy in
-	    order of numeric node id.  Like everything in Linux, this is subject
-	    to change.
+	set of nodes specified by the policy.  Memory will be allocated from
+	the node in the set with sufficient free memory that is closest to
+	the node where the allocation takes place.
 
 	MPOL_PREFERRED:  This mode specifies that the allocation should be
 	attempted from the single node specified in the policy.  If that
Index: linux-2.6.25-rc3-mm1/include/linux/mempolicy.h
===================================================================
--- linux-2.6.25-rc3-mm1.orig/include/linux/mempolicy.h	2008-03-04 14:19:06.000000000 -0500
+++ linux-2.6.25-rc3-mm1/include/linux/mempolicy.h	2008-03-04 14:38:29.000000000 -0500
@@ -54,11 +54,13 @@ struct mm_struct;
  * mmap_sem.
  *
  * Freeing policy:
- * When policy is MPOL_BIND v.zonelist is kmalloc'ed and must be kfree'd.
- * All other policies don't have any external state. mpol_free() handles this.
+ * Mempolicy objects are reference counted.  A mempolicy will be freed when
+ * mpol_free() decrements the reference count to zero.
  *
  * Copying policy objects:
- * For MPOL_BIND the zonelist must be always duplicated. mpol_clone() does this.
+ * mpol_copy() allocates a new mempolicy and copies the specified mempolicy
+ * to the new storage.  The reference count of the new object is initialized
+ * to 1, representing the caller of mpol_copy().
  */
 struct mempolicy {
 	atomic_t refcnt;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
