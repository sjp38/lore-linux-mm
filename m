Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 55B6C6B0204
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 16:35:06 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o7JKZ8Dn005217
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 13:35:09 -0700
Received: from pzk4 (pzk4.prod.google.com [10.243.19.132])
	by wpaz21.hot.corp.google.com with ESMTP id o7JKZ1mB008804
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 13:35:02 -0700
Received: by pzk4 with SMTP id 4so1052079pzk.7
        for <linux-mm@kvack.org>; Thu, 19 Aug 2010 13:35:01 -0700 (PDT)
Date: Thu, 19 Aug 2010 13:34:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: __task_cred() need rcu_read_lock()
In-Reply-To: <20100819152618.21246.68223.stgit@warthog.procyon.org.uk>
Message-ID: <alpine.DEB.2.00.1008191334340.18994@chino.kir.corp.google.com>
References: <20100819152618.21246.68223.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: torvalds@osdl.org, akpm@linux-foundation.org, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Aug 2010, David Howells wrote:

> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> dump_tasks() needs to hold the RCU read lock around its access of the target
> task's UID.  To this end it should use task_uid() as it only needs that one
> thing from the creds.
> 
> The fact that dump_tasks() holds tasklist_lock is insufficient to prevent the
> target process replacing its credentials on another CPU.
> 
> Then, this patch change to call rcu_read_lock() explicitly.
> 
> 
> 	===================================================
> 	[ INFO: suspicious rcu_dereference_check() usage. ]
> 	---------------------------------------------------
> 	mm/oom_kill.c:410 invoked rcu_dereference_check() without protection!
> 
> 	other info that might help us debug this:
> 
> 	rcu_scheduler_active = 1, debug_locks = 1
> 	4 locks held by kworker/1:2/651:
> 	 #0:  (events){+.+.+.}, at: [<ffffffff8106aae7>]
> 	process_one_work+0x137/0x4a0
> 	 #1:  (moom_work){+.+...}, at: [<ffffffff8106aae7>]
> 	process_one_work+0x137/0x4a0
> 	 #2:  (tasklist_lock){.+.+..}, at: [<ffffffff810fafd4>]
> 	out_of_memory+0x164/0x3f0
> 	 #3:  (&(&p->alloc_lock)->rlock){+.+...}, at: [<ffffffff810fa48e>]
> 	find_lock_task_mm+0x2e/0x70
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: David Howells <dhowells@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
