Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E7E366B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 12:04:07 -0500 (EST)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0QGsSOs017084
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 11:54:29 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 45B2B4DE8048
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 11:59:51 -0500 (EST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0QH3Mnt469126
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 12:03:22 -0500
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0QH3KFB023437
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 10:03:22 -0700
Date: Wed, 26 Jan 2011 22:26:45 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [RFC] [PATCH 2.6.37-rc5-tip 5/20]  5: Uprobes:
 register/unregister probes.
Message-ID: <20110126165645.GP19725@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20101216095714.23751.52601.sendpatchset@localhost6.localdomain6>
 <20101216095817.23751.76989.sendpatchset@localhost6.localdomain6>
 <1295957744.28776.722.camel@laptop>
 <20110126075558.GB19725@linux.vnet.ibm.com>
 <1296036708.28776.1138.camel@laptop>
 <20110126153036.GN19725@linux.vnet.ibm.com>
 <1296056756.28776.1247.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1296056756.28776.1247.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra <peterz@infradead.org> [2011-01-26 16:45:56]:

> On Wed, 2011-01-26 at 21:00 +0530, Srikar Dronamraju wrote:
> > * Peter Zijlstra <peterz@infradead.org> [2011-01-26 11:11:48]:
> > 
> > > On Wed, 2011-01-26 at 13:25 +0530, Srikar Dronamraju wrote:
> > > > 
> > > > > > +
> > > > > > +               list_add(&mm->uprobes_list, &tmp_list);
> > > > > > +               mm->uprobes_vaddr = vma->vm_start + offset;
> > > > > > +       }
> > > > > > +       spin_unlock(&mapping->i_mmap_lock);
> > > > > 
> > > > > Both this and unregister are racy, what is to say:
> > > > >  - the vma didn't get removed from the mm
> > > > >  - no new matching vma got added
> > > > > 
> > > > 
> > > > register_uprobe, unregister_uprobe, uprobe_mmap are all synchronized by
> > > > uprobes_mutex. So I dont see one unregister_uprobe getting thro when
> > > > another register_uprobe is working with a vma.
> > > > 
> > > > If I am missing something elementary, please explain a bit more.
> > > 
> > > afaict you're not holding the mmap_sem, so userspace can simply unmap
> > > the vma.
> > 
> > When we do the actual insert/remove of the breakpoint we hold the
> > mmap_sem. During the actual insertion/removal, if the vma for the
> > specific inode is not found, we just come out without doing the
> > actual insertion/deletion.
> 
> Right, but then install_uprobe() should:
> 
>  - lookup the vma relating to the address you stored,

We already do this thro get_user_pages in write_opcode().

>  - validate that the vma is indeed a map of the right inode

We can add a check in write_opcode( we need to pass the inode to
write_opcode).

>  - validate that the offset of the probe corresponds with the stored
> address

I am not clear on this. We would have derived the address from the
offset. So is that we check for
 (vaddr == vma->vm_start + uprobe->offset)

> 
> Otherwise you can race with unmap/map and end up installing the probe in
> a random location.
> 
> Also, I think the whole thing goes funny if someone maps the same text
> twice ;-)

I am not sure if we can map the same text twice. If something like
this is possible then we would have 2 addresses for each function.
So how does the linker know which address to jump to out of the 2 or
multiple matching addresses. What would be the usecases for same
text being mapped multiple times and both being executable?

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
