Message-ID: <42BB22C3.7070602@engr.sgi.com>
Date: Thu, 23 Jun 2005 15:59:47 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc5 5/10] mm: manual page migration-rc3
 -- sys_migrate_pages-mempolicy-migration-rc3.patch
References: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com> <20050622163941.25515.38103.92916@tomahawk.engr.sgi.com> <20050623015121.GI14251@wotan.suse.de>
In-Reply-To: <20050623015121.GI14251@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Christoph Hellwig <hch@infradead.org>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, lhms-devel@lists.sourceforge.net, Paul Jackson <pj@sgi.com>, Nathan Scott <nathans@sgi.com>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On Wed, Jun 22, 2005 at 09:39:41AM -0700, Ray Bryant wrote:
> 
>>This patch adds code that translates the memory policy structures
>>as they are encountered so that they continue to represent where
>>memory should be allocated after the page migration has completed.
> 
> 
> 
> That won't work for shared memory objects though (which store
> their mempolicies separately). Is that intended?
> 

No, it looks like I dropped the ball there.  I thought that the
vma->vm_policy field was used in that case as well, but it appears
that the policy is looked up in the tree every time it is used.
(Can that be right?)  If so, I need to do something else.

Anyway, I shouldn't be updating the vma policy if I am also not
migrating the VMA, so there is some work there that needs to be
done as well.  (The update to the per vma policy needs to be moved
into migrate_vma()).

> 
>>+
>>+	if (task->mempolicy->policy == MPOL_INTERLEAVE) {
>>+		/*
>>+		 * If the task is still running and allocating storage, this
>>+		 * is racy, but there is not much that can be done about it.
>>+		 */
>>+		tmp = task->il_next;
>>+		if (node_map[tmp] >= 0)
>>+			task->il_next = node_map[tmp];
> 
> 
> RCU (synchronize_kernel) could do better, but that might be slow. However the 
> code might BUG when il_next ends up in a node that is not part of 
> the policy anymore. Have you checked that?  
> 
> -Andi
> 

I don't think this particular case will bug().  The worst thing that could
happen, as I read the code is that if we change the policy at the same time
that a page is being allocated via the interleaved policy, that one page
could be allocated on a node according to the old policy even after the
policy has been updated.

(That is, we update the policy and before task->il_next can be updated
to match the new policy, a page gets allocated.)  Since we update the
policy, then migrate the pages, then that one page will get migrated
anyway, so as near as I can tell this is not a problem.

However, (looking at the code some more) there is a different case where a
BUG() could be called.  That is in offset_il_node().  If the node mask
(p->v.nodes) changes after the last find_next_bit() and before the
BUG_ON(!test_bit(nid, pol->v.nodes)), then the system could BUG() because
of the policy migration.

A simple solution to this would be to delete that BUG_ON().  :-)
(Is this required?  It looks almost like a debugging statement.)

In that case, we have the same kind of situation as with the il->next
case, that is, if a process is actively allocating storage at the same
time as we do a migration, then one page (per vma?) could be allocated
on the old set of nodes after the policy is updated.  However, since
we update the policy first, then migrate the pages, it still seems to
me that all such pages will get migrated to the new nodes.

Unfortunately, I've not tested this.  For the cases I am looking at
we suspend the task before migration and resume it after.  Indeed,
the system call in question will sometimes fail (the migrated process
will die) it we don't suspend/resume the migrated tasks.  I was hoping
that would be good enough, but if migrating non-suspended tasks is
thought to be important, then I will go fix that as well.  (The
unresolved issues paragraph in the note I sent out about this patch
points out this issue.)

I don't see any other BUG() calls that could be tripped by changing
the node mask underneath a process that is actively allocating
storage, at least not in mempolicy.c.  Am I overlooking something?

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
