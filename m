Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1D1198D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 00:57:04 -0400 (EDT)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2G4VwqC008130
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 00:31:58 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 780EF38C803F
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 00:56:54 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2G4uvgg2519164
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 00:56:57 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2G4utg3026428
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 01:56:56 -0300
Date: Wed, 16 Mar 2011 10:20:50 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 11/20] 11: uprobes: slot allocation
 for uprobes
Message-ID: <20110316045050.GE24254@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
 <20110314133610.27435.93666.sendpatchset@localhost6.localdomain6>
 <20110315203117.GA27063@fibrous.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110315203117.GA27063@fibrous.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Wilson <wilsons@start.ca>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

* Stephen Wilson <wilsons@start.ca> [2011-03-15 16:31:17]:

> 
> On Mon, Mar 14, 2011 at 07:06:10PM +0530, Srikar Dronamraju wrote:
> > diff --git a/kernel/fork.c b/kernel/fork.c
> > index de3d10a..0afa0cd 100644
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -551,6 +551,7 @@ void mmput(struct mm_struct *mm)
> >  	might_sleep();
> >  
> >  	if (atomic_dec_and_test(&mm->mm_users)) {
> > +		uprobes_free_xol_area(mm);
> >  		exit_aio(mm);
> >  		ksm_exit(mm);
> >  		khugepaged_exit(mm); /* must run before exit_mmap */
> > @@ -677,6 +678,9 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
> >  	memcpy(mm, oldmm, sizeof(*mm));
> >  
> >  	/* Initializing for Swap token stuff */
> > +#ifdef CONFIG_UPROBES
> > +	mm->uprobes_xol_area = NULL;
> > +#endif
> >  	mm->token_priority = 0;
> >  	mm->last_interval = 0;
> 
> Perhaps move the uprobes_xol_area initialization away from that comment?
> A few lines down beside the hugepage #ifdef would read a bit better.


Okay, Will do.


-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
