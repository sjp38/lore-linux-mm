Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6588E6B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 03:58:48 -0500 (EST)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0Q8rh6K017611
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 01:53:43 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p0Q8weV1191024
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 01:58:40 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0Q8wb3r011069
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 01:58:40 -0700
Date: Wed, 26 Jan 2011 14:22:03 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [RFC] [PATCH 2.6.37-rc5-tip 14/20] 14: uprobes: Handing int3
 and singlestep exception.
Message-ID: <20110126085203.GG19725@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20101216095714.23751.52601.sendpatchset@localhost6.localdomain6>
 <20101216095957.23751.57040.sendpatchset@localhost6.localdomain6>
 <1295963779.28776.1059.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1295963779.28776.1059.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra <peterz@infradead.org> [2011-01-25 14:56:19]:

> On Thu, 2010-12-16 at 15:29 +0530, Srikar Dronamraju wrote:
> > +               down_read(&mm->mmap_sem);
> > +               for (vma = mm->mmap; vma; vma = vma->vm_next) {
> > +                       if (!valid_vma(vma))
> > +                               continue;
> > +                       if (probept < vma->vm_start || probept > vma->vm_end)
> > +                               continue;
> > +                       u = find_uprobe(vma->vm_file->f_mapping->host,
> > +                                       probept - vma->vm_start);
> > +                       if (u)
> > +                               break;
> > +               }
> > +               up_read(&mm->mmap_sem); 
> 
> One has to ask, what's wrong with find_vma() ?

Are you looking for something like this.

       down_read(&mm->mmap_sem);
	for (vma = find_vma(mm, probept); ; vma = vma->vm_next) {
	       if (!valid_vma(vma))
		       continue;
	       u = find_uprobe(vma->vm_file->f_mapping->host,
			       probept - vma->vm_start);
	       if (u)
		       break;
       }
       up_read(&mm->mmap_sem); 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
