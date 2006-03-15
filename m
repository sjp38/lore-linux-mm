Date: Tue, 14 Mar 2006 16:33:29 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Inconsistent capabilites associated with MPOL_MOVE_ALL
In-Reply-To: <23583.1142382327@www015.gmx.net>
Message-ID: <Pine.LNX.4.64.0603141632210.23051@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603141608350.22835@schroedinger.engr.sgi.com>
 <23583.1142382327@www015.gmx.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Michael Kerrisk <mtk-manpages@gmx.net>, ak@suse.de, linux-mm@kvack.org, michael.kerrisk@gmx.net
List-ID: <linux-mm.kvack.org>

On Wed, 15 Mar 2006, Michael Kerrisk wrote:

> It seems to me that setting scheduling policy and 
> priorities is also the kind of thing that might be performed 
> in apps that also use the NUMA API, so it would seem consistent 
> to use CAP_SYS_NICE for NUMA also.

Use CAP_SYS_NICE for controlling migration permissions.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc6/mm/mempolicy.c
===================================================================
--- linux-2.6.16-rc6.orig/mm/mempolicy.c	2006-03-11 14:12:55.000000000 -0800
+++ linux-2.6.16-rc6/mm/mempolicy.c	2006-03-14 16:31:15.000000000 -0800
@@ -748,7 +748,7 @@ long do_mbind(unsigned long start, unsig
 				      MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
 	    || mode > MPOL_MAX)
 		return -EINVAL;
-	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_RESOURCE))
+	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
 		return -EPERM;
 
 	if (start & ~PAGE_MASK)
@@ -942,20 +942,20 @@ asmlinkage long sys_migrate_pages(pid_t 
 	 */
 	if ((current->euid != task->suid) && (current->euid != task->uid) &&
 	    (current->uid != task->suid) && (current->uid != task->uid) &&
-	    !capable(CAP_SYS_ADMIN)) {
+	    !capable(CAP_SYS_NICE)) {
 		err = -EPERM;
 		goto out;
 	}
 
 	task_nodes = cpuset_mems_allowed(task);
 	/* Is the user allowed to access the target nodes? */
-	if (!nodes_subset(new, task_nodes) && !capable(CAP_SYS_ADMIN)) {
+	if (!nodes_subset(new, task_nodes) && !capable(CAP_SYS_NICE)) {
 		err = -EPERM;
 		goto out;
 	}
 
 	err = do_migrate_pages(mm, &old, &new,
-		capable(CAP_SYS_ADMIN) ? MPOL_MF_MOVE_ALL : MPOL_MF_MOVE);
+		capable(CAP_SYS_NICE) ? MPOL_MF_MOVE_ALL : MPOL_MF_MOVE);
 out:
 	mmput(mm);
 	return err;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
