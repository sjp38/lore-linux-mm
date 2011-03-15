Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 492028D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 12:31:10 -0400 (EDT)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2FGACpT003132
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 12:10:13 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 75D2038C8038
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 12:31:04 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2FGV7Np224160
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 12:31:07 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2FGV6Aj014665
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 12:31:07 -0400
Date: Tue, 15 Mar 2011 21:55:08 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 7/20] 7: uprobes: store/restore
 original instruction.
Message-ID: <20110315162508.GZ24254@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
 <20110314133522.27435.45121.sendpatchset@localhost6.localdomain6>
 <alpine.LFD.2.00.1103151538200.2787@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1103151538200.2787@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

* Thomas Gleixner <tglx@linutronix.de> [2011-03-15 15:41:20]:

> On Mon, 14 Mar 2011, Srikar Dronamraju wrote:
> >  static int install_uprobe(struct mm_struct *mm, struct uprobe *uprobe)
> >  {
> > -	int ret = 0;
> > +	struct task_struct *tsk;
> > +	int ret = -EINVAL;
> >  
> > -	/*TODO: install breakpoint */
> > -	if (!ret)
> > +	get_task_struct(mm->owner);
> 
> Increment task ref before checking for NULL ?

In response to earlier comments/suggestions from Stephen Wilson, we
resolved to handle it this way 


static uprobes_get_mm_owner() {
	struct task_struct *tsk; 

	rcu_read_lock()
	tsk = rcu_dereference(mm->owner);
	if (tsk)
		get_task_struct(tsk);	
	rcu_read_unlock();
	return tsk;
}

Both install_uprobe and remove_uprobe will end up calling uprobes_get_mm_owner().


-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
