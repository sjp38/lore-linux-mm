Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j620WTnk017131
	for <linux-mm@kvack.org>; Fri, 1 Jul 2005 17:32:29 -0700
Date: Fri, 1 Jul 2005 15:41:17 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050701224117.542.82297.28813@jackhammer.engr.sgi.com>
In-Reply-To: <20050701224038.542.60558.44109@jackhammer.engr.sgi.com>
References: <20050701224038.542.60558.44109@jackhammer.engr.sgi.com>
Subject: [PATCH 2.6.13-rc1 6/11] mm: manual page migration-rc4 -- sys_migrate_pages-mempolicy-migration-shared-policy-fixup-rc4.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Ray Bryant <raybry@sgi.com>, Paul Jackson <pj@sgi.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

This code fixes a problem with migrating mempolicies for shared
objects (System V shared memory, tmpfs, etc) that Andi Kleen pointed
out in his review of the -rc3 version of the page migration code.
As currently implemented, this only really matters for System V shared
memory, since AFAIK that is the only shared object that has its own
vma->vm_policy->policy code.  As code is added for the other cases,
the code below will work with the other shared objects.

One can argue that since the shared object exists outside of the
application, that one shouldn't migrate it at all.  The approach taken
here is that if a shared object is mapped into the address space of a
process that is being migrated, then the mapped pages of the shared object
should be migrated with the process.  (Pages in the shared object that are
not mapped will not be migrated.  This is not perfect, but so it goes.)

Signed-off-by: Ray Bryant <raybry@sgi.com>

 mempolicy.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6.12-rc5-mhp1-page-migration-export/mm/mempolicy.c
===================================================================
--- linux-2.6.12-rc5-mhp1-page-migration-export.orig/mm/mempolicy.c	2005-06-27 12:28:33.000000000 -0700
+++ linux-2.6.12-rc5-mhp1-page-migration-export/mm/mempolicy.c	2005-06-27 12:29:19.000000000 -0700
@@ -1245,12 +1245,13 @@ int migrate_process_policy(struct task_s
 int migrate_vma_policy(struct vm_area_struct *vma, int *node_map)
 {
 
+	struct mempolicy *old = get_vma_policy(vma, vma->vm_start);
 	struct mempolicy *new;
 
-	if (!vma->vm_policy || vma->vm_policy->policy == MPOL_DEFAULT)
+	if (old->policy == MPOL_DEFAULT)
 		return 0;
 
-	new = migrate_policy(vma->vm_policy, node_map);
+	new = migrate_policy(old, node_map);
 	if (IS_ERR(new))
 		return (PTR_ERR(new));
 

-- 
Best Regards,
Ray
-----------------------------------------------
Ray Bryant                       raybry@sgi.com
The box said: "Requires Windows 98 or better",
           so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
