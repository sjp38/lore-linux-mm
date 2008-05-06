Date: Tue, 06 May 2008 15:18:35 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: on CONFIG_MM_OWNER=y, kernel panic is possible.
In-Reply-To: <20080506150213.AC63.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <481FF115.8030503@linux.vnet.ibm.com> <20080506150213.AC63.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080506151510.AC66.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > That is not possible. If you look at where mm_update_next_owner() is called
> > from, we call it from
> > 
> > exit_mm() and exec_mmap()
> > 
> > In both cases, we ensure that the task's mm has changed (to NULL and the new mm
> > respectively), before we call mm_update_next_owner(), hence c->mm can never be
> > equal to p->mm.
> 
> if so, following patch is needed instead.

and, one more.

comment of owner member of mm_struct is bogus.
that is not guranteed point to thread-group-leader.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 include/linux/mm_types.h |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

Index: b/include/linux/mm_types.h
===================================================================
--- a/include/linux/mm_types.h  2008-05-04 22:56:52.000000000 +0900
+++ b/include/linux/mm_types.h  2008-05-06 15:53:04.000000000 +0900
@@ -231,8 +231,7 @@ struct mm_struct {
        rwlock_t                ioctx_list_lock;        /* aio lock */
        struct kioctx           *ioctx_list;
 #ifdef CONFIG_MM_OWNER
-       struct task_struct *owner;      /* The thread group leader that */
-                                       /* owns the mm_struct.          */
+       struct task_struct *owner;      /* point to one of task that owns the mm_struct. */
 #endif

 #ifdef CONFIG_PROC_FS



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
