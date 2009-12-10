Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7736D60021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 21:03:17 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBA1vqrl004600
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 10 Dec 2009 10:57:52 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1472445DE4F
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 10:57:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id ECD7E45DE4E
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 10:57:51 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D09911DB8040
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 10:57:51 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 905191DB8038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 10:57:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 4/9] oom: Add missing rcu protection of __task_cred() in dump_tasks
In-Reply-To: <20091210004703.148689096@linutronix.de>
References: <20091210001308.247025548@linutronix.de> <20091210004703.148689096@linutronix.de>
Message-Id: <20091210104500.F500.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 10 Dec 2009 10:57:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Thomas Gleixner <tglx@linutronix.de>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Dipankar Sarma <dipankar@in.ibm.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@tv-sign.ru>, Al Viro <viro@zeniv.linux.org.uk>, James Morris <jmorris@namei.org>, David Howells <dhowells@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> dump_tasks accesses __task_cred() without being in a RCU read side
> critical section. tasklist_lock is not protecting that when
> CONFIG_TREE_PREEMPT_RCU=y.
> 
> Add a rcu_read_lock/unlock() section around the code which accesses
> __task_cred().
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: linux-mm@kvack.org
> ---
>  mm/oom_kill.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> Index: linux-2.6-tip/mm/oom_kill.c
> ===================================================================
> --- linux-2.6-tip.orig/mm/oom_kill.c
> +++ linux-2.6-tip/mm/oom_kill.c
> @@ -329,10 +329,13 @@ static void dump_tasks(const struct mem_
>  			task_unlock(p);
>  			continue;
>  		}
> +		/* Protect __task_cred() access */
> +		rcu_read_lock();
>  		printk(KERN_INFO "[%5d] %5d %5d %8lu %8lu %3d     %3d %s\n",
>  		       p->pid, __task_cred(p)->uid, p->tgid, mm->total_vm,
>  		       get_mm_rss(mm), (int)task_cpu(p), p->signal->oom_adj,
>  		       p->comm);
> +		rcu_read_unlock();
>  		task_unlock(p);
>  	} while_each_thread(g, p);
>  }

Looks straight forward and correct to me.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
