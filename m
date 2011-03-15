Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9BDF98D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 09:48:02 -0400 (EDT)
Subject: Re: [PATCH v2 2.6.38-rc8-tip 7/20]  7: uprobes: store/restore
 original instruction.
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <20110315092247.GW24254@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
	 <20110314133522.27435.45121.sendpatchset@localhost6.localdomain6>
	 <20110314180914.GA18855@fibrous.localdomain>
	 <20110315092247.GW24254@linux.vnet.ibm.com>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Tue, 15 Mar 2011 09:47:59 -0400
Message-ID: <1300196879.9910.271.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Stephen Wilson <wilsons@start.ca>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Tue, 2011-03-15 at 14:52 +0530, Srikar Dronamraju wrote:
> * Stephen Wilson <wilsons@start.ca> [2011-03-14 14:09:14]:
> 

Nitpick:

> Guess checking for tsk != NULL would only help if and only if we are doing
> within rcu.  i.e we have to change to something like this
> 

	tsk = NULL;

> 	rcu_read_lock()
> 	if (mm->owner) {
> 		get_task_struct(mm->owner)
> 		tsk = mm->owner;
> 	}
> 	rcu_read_unlock()
> 	if (!tsk)
> 		return ret;
> 
> Agree?

Or:

	rcu_read_lock();
	tsk = mm->owner;
	if (tsk)
		get_task_struct(tsk);
	rcu_read_unlock();
	if (!tsk)
		return ret;

Probably looks cleaner.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
