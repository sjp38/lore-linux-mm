Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 500826B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 10:24:58 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0QF002J008353
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 10:00:13 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 2B4B3728244
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 10:20:55 -0500 (EST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0QFKsXo465088
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 10:20:54 -0500
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0QFKqC8017875
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 08:20:54 -0700
Date: Wed, 26 Jan 2011 20:44:18 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [RFC] [PATCH 2.6.37-rc5-tip 14/20] 14: uprobes: Handing int3
 and singlestep exception.
Message-ID: <20110126151418.GL19725@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20101216095714.23751.52601.sendpatchset@localhost6.localdomain6>
 <20101216095957.23751.57040.sendpatchset@localhost6.localdomain6>
 <1295963779.28776.1059.camel@laptop>
 <20110126085203.GG19725@linux.vnet.ibm.com>
 <1296037031.28776.1146.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1296037031.28776.1146.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra <peterz@infradead.org> [2011-01-26 11:17:11]:

> On Wed, 2011-01-26 at 14:22 +0530, Srikar Dronamraju wrote:
> > * Peter Zijlstra <peterz@infradead.org> [2011-01-25 14:56:19]:
> > 
> > > On Thu, 2010-12-16 at 15:29 +0530, Srikar Dronamraju wrote:
> > > > +               down_read(&mm->mmap_sem);
> > > > +               for (vma = mm->mmap; vma; vma = vma->vm_next) {
> > > > +                       if (!valid_vma(vma))
> > > > +                               continue;
> > > > +                       if (probept < vma->vm_start || probept > vma->vm_end)
> > > > +                               continue;
> > > > +                       u = find_uprobe(vma->vm_file->f_mapping->host,
> > > > +                                       probept - vma->vm_start);
> > > > +                       if (u)
> > > > +                               break;
> > > > +               }
> > > > +               up_read(&mm->mmap_sem); 
> > > 
> > > One has to ask, what's wrong with find_vma() ?
> > 
> > Are you looking for something like this.
> > 
> >        down_read(&mm->mmap_sem);
> > 	for (vma = find_vma(mm, probept); ; vma = vma->vm_next) {
> > 	       if (!valid_vma(vma))
> > 		       continue;
> > 	       u = find_uprobe(vma->vm_file->f_mapping->host,
> > 			       probept - vma->vm_start);
> > 	       if (u)
> > 		       break;
> >        }
> >        up_read(&mm->mmap_sem); 
> 
> How could you ever need to iterate here? There is only a single vma that
> covers the probe point, if that doesn't find a uprobe, there isn't any.

Agree.
So it simplifies to 

        down_read(&mm->mmap_sem);
 	vma = find_vma(mm, probept);
        if (valid_vma(vma)) {
 	       u = find_uprobe(vma->vm_file->f_mapping->host,
 			       probept - vma->vm_start);
        }
        up_read(&mm->mmap_sem); 

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
