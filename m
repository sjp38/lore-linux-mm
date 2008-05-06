Date: Tue, 06 May 2008 15:03:52 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: on CONFIG_MM_OWNER=y, kernel panic is possible.
In-Reply-To: <481FF115.8030503@linux.vnet.ibm.com>
References: <20080506142255.AC5D.KOSAKI.MOTOHIRO@jp.fujitsu.com> <481FF115.8030503@linux.vnet.ibm.com>
Message-Id: <20080506150213.AC63.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> That is not possible. If you look at where mm_update_next_owner() is called
> from, we call it from
> 
> exit_mm() and exec_mmap()
> 
> In both cases, we ensure that the task's mm has changed (to NULL and the new mm
> respectively), before we call mm_update_next_owner(), hence c->mm can never be
> equal to p->mm.

if so, following patch is needed instead.



---
 fs/exec.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: b/fs/exec.c
===================================================================
--- a/fs/exec.c 2008-05-04 22:57:09.000000000 +0900
+++ b/fs/exec.c 2008-05-06 15:40:35.000000000 +0900
@@ -735,7 +735,7 @@ static int exec_mmap(struct mm_struct *m
        tsk->active_mm = mm;
        activate_mm(active_mm, mm);
        task_unlock(tsk);
-       mm_update_next_owner(mm);
+       mm_update_next_owner(old_mm);
        arch_pick_mmap_layout(mm);
        if (old_mm) {
                up_read(&old_mm->mmap_sem);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
