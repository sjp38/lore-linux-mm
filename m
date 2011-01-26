Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 009F96B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 10:37:27 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0QFHmsU011603
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 10:19:10 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 1279472807A
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 10:37:12 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0QFbBGM180908
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 10:37:11 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0QFb9vt030765
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 13:37:11 -0200
Date: Wed, 26 Jan 2011 21:00:36 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [RFC] [PATCH 2.6.37-rc5-tip 5/20]  5: Uprobes:
 register/unregister probes.
Message-ID: <20110126153036.GN19725@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20101216095714.23751.52601.sendpatchset@localhost6.localdomain6>
 <20101216095817.23751.76989.sendpatchset@localhost6.localdomain6>
 <1295957744.28776.722.camel@laptop>
 <20110126075558.GB19725@linux.vnet.ibm.com>
 <1296036708.28776.1138.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1296036708.28776.1138.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra <peterz@infradead.org> [2011-01-26 11:11:48]:

> On Wed, 2011-01-26 at 13:25 +0530, Srikar Dronamraju wrote:
> > 
> > > > +
> > > > +               list_add(&mm->uprobes_list, &tmp_list);
> > > > +               mm->uprobes_vaddr = vma->vm_start + offset;
> > > > +       }
> > > > +       spin_unlock(&mapping->i_mmap_lock);
> > > 
> > > Both this and unregister are racy, what is to say:
> > >  - the vma didn't get removed from the mm
> > >  - no new matching vma got added
> > > 
> > 
> > register_uprobe, unregister_uprobe, uprobe_mmap are all synchronized by
> > uprobes_mutex. So I dont see one unregister_uprobe getting thro when
> > another register_uprobe is working with a vma.
> > 
> > If I am missing something elementary, please explain a bit more.
> 
> afaict you're not holding the mmap_sem, so userspace can simply unmap
> the vma.

When we do the actual insert/remove of the breakpoint we hold the
mmap_sem. During the actual insertion/removal, if the vma for the
specific inode is not found, we just come out without doing the
actual insertion/deletion.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
