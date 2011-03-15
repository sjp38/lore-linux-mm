Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 445968D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 14:10:28 -0400 (EDT)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2FHjNhT007362
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 13:45:23 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 0A78D6E8041
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 14:10:26 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2FIAPFm406546
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 14:10:25 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2FIANkQ013319
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 14:10:25 -0400
Date: Tue, 15 Mar 2011 23:34:23 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 5/20] 5: Uprobes: register/unregister
 probes.
Message-ID: <20110315180423.GA10429@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
 <20110314133454.27435.81020.sendpatchset@localhost6.localdomain6>
 <alpine.LFD.2.00.1103151439400.2787@localhost6.localdomain6>
 <20110315171536.GA24254@linux.vnet.ibm.com>
 <1300211262.9910.295.camel@gandalf.stny.rr.com>
 <1300211411.2203.290.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1300211411.2203.290.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

* Peter Zijlstra <peterz@infradead.org> [2011-03-15 18:50:11]:

> On Tue, 2011-03-15 at 13:47 -0400, Steven Rostedt wrote:
> > On Tue, 2011-03-15 at 22:45 +0530, Srikar Dronamraju wrote:
> > > > > +   }
> > > > > +   list_for_each_entry_safe(mm, tmpmm, &tmp_list, uprobes_list) {
> > > > > +           down_read(&mm->mmap_sem);
> > > > > +           if (!install_uprobe(mm, uprobe))
> > > > > +                   ret = 0;
> > > > 
> > > > Installing it once is success ?
> > > 
> > > This is a little tricky. My intention was to return success even if one
> > > install is successful. If we return error, then the caller can go
> > > ahead and free the consumer. Since we return success if there are
> > > currently no processes that have mapped this inode, I was tempted to
> > > return success on atleast one successful install.
> > 
> > What about an all or nothing approach. If one fails, remove all that
> > were installed, and give up.
> 
> That sounds like a much saner semantic and is what we generally do in
> the kernel.

One of the install_uprobe could be failing because the process was
almost exiting, something like there was no mm->owner. Also lets
assume that the first few install_uprobes go thro and the last
install_uprobe fails. There could be breakpoint hits corresponding to
the already installed uprobes that get displayed. i.e all
breakpoint hits from the first install_uprobe to the time we detect a
failed a install_uprobe and revert all inserted breakpoints will be
shown as being captured.

Also register_uprobe will only install probes for processes that are
actively and have mapped the inode.  However install_uprobe called from
uprobe_mmap which also registers the probe can fail. Now should we take
the same yardstick and remove all the probes corresponding to the
successful register_uprobe?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
