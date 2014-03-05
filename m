Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9553C6B0099
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 22:58:45 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id r10so486138pdi.30
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 19:58:45 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id ki1si945566pbc.55.2014.03.04.19.58.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Mar 2014 19:58:43 -0800 (PST)
Received: by mail-pa0-f53.google.com with SMTP id ld10so503003pab.40
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 19:58:43 -0800 (PST)
Date: Tue, 4 Mar 2014 19:58:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 01/11] fork: collapse copy_flags into copy_process
In-Reply-To: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1403041953570.8067@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

copy_flags() does not use the clone_flags formal and can be collapsed
into copy_process() for cleaner code.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 kernel/fork.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1069,15 +1069,6 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
 	return 0;
 }
 
-static void copy_flags(unsigned long clone_flags, struct task_struct *p)
-{
-	unsigned long new_flags = p->flags;
-
-	new_flags &= ~(PF_SUPERPRIV | PF_WQ_WORKER);
-	new_flags |= PF_FORKNOEXEC;
-	p->flags = new_flags;
-}
-
 SYSCALL_DEFINE1(set_tid_address, int __user *, tidptr)
 {
 	current->clear_child_tid = tidptr;
@@ -1227,7 +1218,8 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 		goto bad_fork_cleanup_count;
 
 	delayacct_tsk_init(p);	/* Must remain after dup_task_struct() */
-	copy_flags(clone_flags, p);
+	p->flags &= ~(PF_SUPERPRIV | PF_WQ_WORKER);
+	p->flags |= PF_FORKNOEXEC;
 	INIT_LIST_HEAD(&p->children);
 	INIT_LIST_HEAD(&p->sibling);
 	rcu_copy_process(p);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
