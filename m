Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 94CE36B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 10:12:45 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0QEs3DF015443
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 09:55:03 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id D9BF5728C71
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 10:06:40 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0QF6UP52216184
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 10:06:30 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0QF6Ssg011209
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 13:06:30 -0200
Date: Wed, 26 Jan 2011 20:29:55 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [RFC] [PATCH 2.6.37-rc5-tip 8/20]  8: uprobes: mmap and fork
 hooks.
Message-ID: <20110126145955.GJ19725@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20101216095714.23751.52601.sendpatchset@localhost6.localdomain6>
 <20101216095848.23751.73144.sendpatchset@localhost6.localdomain6>
 <1295957739.28776.717.camel@laptop>
 <20110126090346.GH19725@linux.vnet.ibm.com>
 <1296037239.28776.1149.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1296037239.28776.1149.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra <peterz@infradead.org> [2011-01-26 11:20:39]:

> On Wed, 2011-01-26 at 14:33 +0530, Srikar Dronamraju wrote:
> > 
> > 
> > I actually dont like to release the write_lock and then reacquire it.
> > write_opcode, which is called thro install_uprobe, i.e to insert the
> > actual breakpoint instruction takes a read lock on the mmap_sem.
> > Hence uprobe_mmap gets called in context with write lock on mmap_sem
> > held, I had to release it before calling install_uprobe. 
> 
> Ah, right, so that's going to give you a head-ache ;-)
> 
> The moment you release this mmap_sem, the map you're going to install
> the probe point in can go away.
> 
> The only way to make this work seems to start by holding the mmap_sem
> for writing and make a breakpoint install function that assumes its
> taken and doesn't try to acquire it again.
> 


Yes, this can be done.
I would have to do something like this in register_uprobe().

list_for_each_entry_safe(mm, tmpmm, &tmp_list, uprobes_list) {
		down_read(&mm->map_sem);
                if (!install_uprobe(mm, uprobe))
                        ret = 0;
		up_read(&mm->map_sem);
                list_del(&mm->uprobes_list);
                mmput(mm);
}

Agree that this is much better than what we have now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
