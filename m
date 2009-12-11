Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2D32D6B0044
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 08:49:51 -0500 (EST)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20091210004703.148689096@linutronix.de>
References: <20091210004703.148689096@linutronix.de> <20091210001308.247025548@linutronix.de>
Subject: Re: [patch 4/9] oom: Add missing rcu protection of __task_cred() in dump_tasks
Date: Fri, 11 Dec 2009 13:49:31 +0000
Message-ID: <13284.1260539371@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Thomas Gleixner <tglx@linutronix.de>
Cc: dhowells@redhat.com, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Dipankar Sarma <dipankar@in.ibm.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@tv-sign.ru>, Al Viro <viro@zeniv.linux.org.uk>, James Morris <jmorris@namei.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thomas Gleixner <tglx@linutronix.de> wrote:

> +		/* Protect __task_cred() access */
> +		rcu_read_lock();
>  		printk(KERN_INFO "[%5d] %5d %5d %8lu %8lu %3d     %3d %s\n",
>  		       p->pid, __task_cred(p)->uid, p->tgid, mm->total_vm,
>  		       get_mm_rss(mm), (int)task_cpu(p), p->signal->oom_adj,
>  		       p->comm);
> +		rcu_read_unlock();

No.  If there's only one access to __task_cred() like this, use
task_cred_xxx() or one of its wrappers instead:

-		       p->pid, __task_cred(p)->uid, p->tgid, mm->total_vm,
+		       p->pid, task_uid(p), p->tgid, mm->total_vm,

that limits the size of the critical section.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
