Date: Thu, 9 Aug 2007 20:11:04 -0500
From: Dean Nelson <dcn@sgi.com>
Subject: Re: [RFC 1/3] SGI Altix cross partition memory (XPMEM)
Message-ID: <20070810011104.GB25427@sgi.com>
References: <20070810010659.GA25427@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070810010659.GA25427@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, jes@sgi.com
List-ID: <linux-mm.kvack.org>

This patch exports __put_task_struct as it is needed by XPMEM.

Signed-off-by: Dean Nelson <dcn@sgi.com>

---

One struct file_operations registered by XPMEM, xpmem_open(), calls
'get_task_struct(current->group_leader)' and another, xpmem_flush(), calls
'put_task_struct(tg->group_leader)'. The reason for this is given in the
comment block that appears in xpmem_open().

        /*
         * Increment 'usage' and 'mm->mm_users' for the current task's thread
         * group leader. This ensures that both its task_struct and mm_struct
         * will still be around when our thread group exits. (The Linux kernel
         * normally tears down the mm_struct prior to calling a module's
         * 'flush' function.) Since all XPMEM thread groups must go through
         * this path, this extra reference to mm_users also allows us to
         * directly inc/dec mm_users in xpmem_ensure_valid_PFNs() and avoid
         * mmput() which has a scaling issue with the mmlist_lock.
         */

Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c	2007-08-09 07:07:55.426611601 -0500
+++ linux-2.6/kernel/fork.c	2007-08-09 07:15:43.246391700 -0500
@@ -127,6 +127,7 @@
 	if (!profile_handoff_task(tsk))
 		free_task(tsk);
 }
+EXPORT_SYMBOL_GPL(__put_task_struct);
 
 void __init fork_init(unsigned long mempages)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
