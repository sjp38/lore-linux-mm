Date: Fri, 1 Feb 2008 05:58:41 -0600
From: Robin Holt <holt@sgi.com>
Subject: Extending mmu_notifiers to handle __xip_unmap in a sleepable
	context?
Message-ID: <20080201115841.GM26420@sgi.com>
References: <20080201050439.009441434@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080201050439.009441434@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

With this set of patches, I think we have enough to get xpmem working
with most types of mappings.  In the past, we operated without any of
these callouts by significantly restricting why types of mappings could
remotely fault and what types of operations the user could do.  With
this set, I am certain we can continue to meet the above assumptions.

That said, I would like to discuss __xip_unmap in more detail.

Currently, it is calling mmu_notifier _begin and _end under the
i_mmap_lock.  I _THINK_ the following will make it so we could support
__xip_unmap (although I don't recall ever seeing that done on ia64 and
don't even know what the circumstances are for its use).

Thanks,
Robin

Index: mmu_notifiers-cl-v5/mm/filemap_xip.c
===================================================================
--- mmu_notifiers-cl-v5.orig/mm/filemap_xip.c	2008-02-01 05:38:32.000000000 -0600
+++ mmu_notifiers-cl-v5/mm/filemap_xip.c	2008-02-01 05:39:08.000000000 -0600
@@ -184,6 +184,7 @@ __xip_unmap (struct address_space * mapp
 	if (!page)
 		return;
 
+	mmu_rmap_notifier(invalidate_page, page);
 	spin_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		mm = vma->vm_mm;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
