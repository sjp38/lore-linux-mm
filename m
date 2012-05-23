Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 1295A6B0083
	for <linux-mm@kvack.org>; Wed, 23 May 2012 07:48:19 -0400 (EDT)
Date: Wed, 23 May 2012 12:48:13 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: 3.4-rc7 numa_policy slab poison.
Message-ID: <20120523114813.GB3353@suse.de>
References: <20120517213120.GA12329@redhat.com>
 <20120518185851.GA5728@redhat.com>
 <20120521154709.GA8697@redhat.com>
 <CA+55aFyqMJ1X08kQwJ7snkYo6MxfVKqFJx7LXBkP_ug4LTCZ=Q@mail.gmail.com>
 <20120521200118.GA12123@redhat.com>
 <20120522115910.GA3353@suse.de>
 <CA+55aFwdyt310Mcsk==58Qa-sZD05A=M+R06xwOisbg2gex=RA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFwdyt310Mcsk==58Qa-sZD05A=M+R06xwOisbg2gex=RA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Stephen Wilson <wilsons@start.ca>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, May 22, 2012 at 08:42:55AM -0700, Linus Torvalds wrote:
> On Tue, May 22, 2012 at 4:59 AM, Mel Gorman <mgorman@suse.de> wrote:
> >
> > This bug is really old as it triggers as far back as 2.6.32.58. I don't
> > know why yet.
> 
> Would somebody humor me, and try it without the MPOL_F_SHARED games?
> The whole reference counting in the presense of setting and clearing
> that bit looks totally crazy. I really cannot see how it could ever
> work.
> 

Following the refernece counting is likely to induce a bad temper.  For
example, the rules say that a newly allocated policy has a refcount of 1 that
is dropped after the policy is inserted.  However, in places like dup_mmap()
we copy the new policy (refcnt==1 for installation), call vma_set_policy()
(which leaves the refcnt alone even sanity says it should increment the
count) and then avoid calling mpol_dup on success. The installation reference
count of 1 is then treated as VMA reference count.  This avoids  unnecessary
atomic operations but does not make the implementation easy to validate.

The reference counting for MPOL_F_SHARED is further complicated by the
fact that it is tracking policy reference counts on both a VMA level and
on ranges tracked on an inode basis via struct shared policy. I was wary of
tearing that out and replacing it with something else without understanding
what went wrong in the first place. As it turns out, it wasn't MPOL_F_SHARED
trickery per-se. The problem area is quite old code as expected.

---8<---
mm: mempolicy: Let vma_merge and vma_split handle vma->vm_policy linkages

Dave Jones' system call fuzz testing tool "trinity" triggered the following
bug error with slab debugging enabled

[ 7613.229315] =============================================================================
[ 7613.229955] BUG numa_policy (Not tainted): Poison overwritten
[ 7613.230560] -----------------------------------------------------------------------------
[ 7613.230560]
[ 7613.231834] INFO: 0xffff880146498250-0xffff880146498250. First byte 0x6a instead of 0x6b
[ 7613.232518] INFO: Allocated in mpol_new+0xa3/0x140 age=46310 cpu=6 pid=32154
[ 7613.233188]  __slab_alloc+0x3d3/0x445
[ 7613.233877]  kmem_cache_alloc+0x29d/0x2b0
[ 7613.234564]  mpol_new+0xa3/0x140
[ 7613.235236]  sys_mbind+0x142/0x620
[ 7613.235929]  system_call_fastpath+0x16/0x1b
[ 7613.236640] INFO: Freed in __mpol_put+0x27/0x30 age=46268 cpu=6 pid=32154
[ 7613.237354]  __slab_free+0x2e/0x1de
[ 7613.238080]  kmem_cache_free+0x25a/0x260
[ 7613.238799]  __mpol_put+0x27/0x30
[ 7613.239515]  remove_vma+0x68/0x90
[ 7613.240223]  exit_mmap+0x118/0x140
[ 7613.240939]  mmput+0x73/0x110
[ 7613.241651]  exit_mm+0x108/0x130
[ 7613.242367]  do_exit+0x162/0xb90
[ 7613.243074]  do_group_exit+0x4f/0xc0
[ 7613.243790]  sys_exit_group+0x17/0x20
[ 7613.244507]  system_call_fastpath+0x16/0x1b
[ 7613.245212] INFO: Slab 0xffffea0005192600 objects=27 used=27 fp=0x          (null) flags=0x20000000004080
[ 7613.246000] INFO: Object 0xffff880146498250 @offset=592 fp=0xffff88014649b9d0

This implied a reference counting bug and the problem happened during
mbind().

mbind() applies a new memory policy to a range and uses mbind_range()
to merge existing VMAs or split them as necessary. In the event
of splits, mpol_dup() will allocate a new struct mempolicy and
maintain existing reference counts whose rules are documented in
Documentation/vm/numa_memory_policy.txt .

The problem occurs with shared memory policies. The vm_op->set_policy
increments the reference count if necessary and split_vma() and vma_merge()
have already handled the existing reference counts. However, policy_vma()
screws it up by replacing an existing vma->vm_policy with one that
potentially has the wrong reference count leading to a premature free. This
patch removes the damage caused by policy_vma().

With this patch applied Dave's trinity tool runs an mbind test for 5 minutes
without error. /proc/slabinfo reported that there are no numa_policy or
shared_policy_node objects allocated after the test completed and the
shared memory region was deleted.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Cc: <stable@vger.kernel.org>
---
 mm/mempolicy.c |   41 +++++++++++++++++------------------------
 1 file changed, 17 insertions(+), 24 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index b195691..72c83d8 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -607,27 +607,6 @@ check_range(struct mm_struct *mm, unsigned long start, unsigned long end,
 	return first;
 }
 
-/* Apply policy to a single VMA */
-static int policy_vma(struct vm_area_struct *vma, struct mempolicy *new)
-{
-	int err = 0;
-	struct mempolicy *old = vma->vm_policy;
-
-	pr_debug("vma %lx-%lx/%lx vm_ops %p vm_file %p set_policy %p\n",
-		 vma->vm_start, vma->vm_end, vma->vm_pgoff,
-		 vma->vm_ops, vma->vm_file,
-		 vma->vm_ops ? vma->vm_ops->set_policy : NULL);
-
-	if (vma->vm_ops && vma->vm_ops->set_policy)
-		err = vma->vm_ops->set_policy(vma, new);
-	if (!err) {
-		mpol_get(new);
-		vma->vm_policy = new;
-		mpol_put(old);
-	}
-	return err;
-}
-
 /* Step 2: apply policy to a range and do splits. */
 static int mbind_range(struct mm_struct *mm, unsigned long start,
 		       unsigned long end, struct mempolicy *new_pol)
@@ -676,9 +655,23 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
 			if (err)
 				goto out;
 		}
-		err = policy_vma(vma, new_pol);
-		if (err)
-			goto out;
+
+		/*
+		 * Apply policy to a single VMA. The reference counting of
+		 * policy for vma_policy linkages has already been handled by
+		 * vma_merge and split_vma as necessary. If this is a shared
+		 * policy then ->set_policy will increment the reference count
+		 * for an sp node.
+		 */
+		pr_debug("vma %lx-%lx/%lx vm_ops %p vm_file %p set_policy %p\n",
+		 	vma->vm_start, vma->vm_end, vma->vm_pgoff,
+		 	vma->vm_ops, vma->vm_file,
+		 	vma->vm_ops ? vma->vm_ops->set_policy : NULL);
+		if (vma->vm_ops && vma->vm_ops->set_policy) {
+			err = vma->vm_ops->set_policy(vma, new_pol);
+			if (err)
+				goto out;
+		}
 	}
 
  out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
