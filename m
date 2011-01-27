Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E852F8D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 05:08:39 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0R9xGEG013235
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 04:59:32 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 6B346728051
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 05:08:37 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0RA8bCm332938
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 05:08:37 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0RA8Zfa020963
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 05:08:36 -0500
Date: Thu, 27 Jan 2011 15:31:57 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [RFC] [PATCH 2.6.37-rc5-tip 5/20]  5: Uprobes:
 register/unregister probes.
Message-ID: <20110127100157.GS19725@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20101216095714.23751.52601.sendpatchset@localhost6.localdomain6>
 <20101216095817.23751.76989.sendpatchset@localhost6.localdomain6>
 <1295957744.28776.722.camel@laptop>
 <20110126075558.GB19725@linux.vnet.ibm.com>
 <1296036708.28776.1138.camel@laptop>
 <20110126153036.GN19725@linux.vnet.ibm.com>
 <1296056756.28776.1247.camel@laptop>
 <20110126165645.GP19725@linux.vnet.ibm.com>
 <1296061949.28776.1343.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1296061949.28776.1343.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra <peterz@infradead.org> [2011-01-26 18:12:29]:

> On Wed, 2011-01-26 at 22:26 +0530, Srikar Dronamraju wrote:
> 
> > >  - lookup the vma relating to the address you stored,
> > 
> > We already do this thro get_user_pages in write_opcode().
> 
> Ah, I didn't read that far..
> 
> > >  - validate that the vma is indeed a map of the right inode
> > 
> > We can add a check in write_opcode( we need to pass the inode to
> > write_opcode).
> 
> sure..
> 
> > >  - validate that the offset of the probe corresponds with the stored
> > > address
> > 
> > I am not clear on this. We would have derived the address from the
> > offset. So is that we check for
> >  (vaddr == vma->vm_start + uprobe->offset)
> 
> Sure, but the vma might have changed since you computed the offset -)

If the vma has changed then it would fail the 2nd validation i.e vma
corresponds to the uprobe inode right. If the vma was unmapped and
mapped back at the same place, then I guess we are okay to probe.

> 
> > > 
> > > Otherwise you can race with unmap/map and end up installing the probe in
> > > a random location.
> > > 
> > > Also, I think the whole thing goes funny if someone maps the same text
> > > twice ;-)
> > 
> > I am not sure if we can map the same text twice. If something like
> > this is possible then we would have 2 addresses for each function.
> > So how does the linker know which address to jump to out of the 2 or
> > multiple matching addresses. What would be the usecases for same
> > text being mapped multiple times and both being executable?
> 
> You can, if only to wreck your thing, you can call mmap() as often as
> you like (until your virtual memory space runs out) and get many many
> mapping of the same file.
> 
> It doesn't need to make sense to the linker, all it needs to do is
> confuse your code ;-)

Currently if there are multiple mappings of the same executable
code, only one mapped area would have the breakpoint inserted.

If the code were to execute from some other mapping, then it would
work as if there are no probes.  However if the code from the
mapping that had the breakpoint executes then we would see the
probes.

If we want to insert breakpoints in each of the maps then we
would have to extend mm->uprobes_vaddr.

Do you have any other ideas to tackle this?
Infact do you think we should be handling this case?

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
