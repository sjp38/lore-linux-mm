Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 13B068D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 13:14:14 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3LH0dXU001845
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 11:00:39 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p3LHE2e4196252
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 11:14:03 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3LHDrM7027832
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 11:13:54 -0600
Date: Thu, 21 Apr 2011 22:29:45 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 2.6.39-rc1-tip 12/26] 12: uprobes: slot allocation
 for uprobes
Message-ID: <20110421165945.GA29472@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
 <20110401143457.15455.64839.sendpatchset@localhost6.localdomain6>
 <1303145171.32491.886.camel@twins>
 <20110419062654.GB10698@linux.vnet.ibm.com>
 <BANLkTimw7dV9_aSsrUfzwSdwr6UwZDsRwg@mail.gmail.com>
 <20110421141125.GG10698@linux.vnet.ibm.com>
 <1303397133.1708.41.camel@unknown001a4b0c2895>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1303397133.1708.41.camel@unknown001a4b0c2895>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Paris <eparis@redhat.com>
Cc: Eric Paris <eparis@parisplace.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, sds@tycho.nsa.gov

* Eric Paris <eparis@redhat.com> [2011-04-21 10:45:33]:

> > > 1) chcon -t unconfined_execmem_t /path/to/your/binary
> > > 2) setsebool -P allow_execmem 1
> > > 
> > > The first will cause the binary to execute in a domain with
> > > permissions to execute anonymous memory, the second will allow all
> > > unconfined domains to execute anonymous memory.
> > 
> > We arent restricted to a particular binary/binaries. We want an
> > infrastructure that can trace all user-space applications. So the
> > first option doesnt seem to help us.
> > 
> > If I understand the second option. we would want this command to be
> > run on any selinux enabled machines that wants uprobes to be working.
> 
> The check which I'm guessing you ran into problems is done using the
> permissions of the 'current' task.  I don't know how your code works at
> all, but I would have guessed that the task allocating and adding this
> magic page was either perf or systemtap or something like that.  Not the
> 'victim' task where the page would actually show up.  Is that true?  If
> so, method1 (or 2) works.  If not, and 'current' is actually the victim,
> method2 would work some of the time, but not always.


The vma addition is done in the 'victim' context and not in the
debugger context. Victim hits the breakpoint and requests a
xol_vma for itself.

> 
> If current can be the victim (or some completely random task) we can
> probably switch the credentials of the current task as we do the
> allocation to the initial creds (or something like that) so the
> permission will be granted.

Okay, I will use the switching the credentials logic.

> 
> Unrelated note: I'd prefer to see that page be READ+EXEC only once it
> has been mapped into the victim task.  Obviously the portion of the code
> that creates this page and sets up the instructions to run is going to
> need write.  Maybe this isn't feasible.  Maybe this magic pages gets
> written a lot even after it's been mapped in.  But I'd rather, if
> possible, know that my victim tasks didn't have a WRITE+EXEC page
> available......
> 

We dont need write permissions on this vma, READ+EXEC is good enuf.
As Roland said, userspace never writes to this vma.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
