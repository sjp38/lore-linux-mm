Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 672276B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 00:23:11 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 13 Jan 2012 00:23:10 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0D5N53l195574
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 00:23:06 -0500
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0D5N1qL002448
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 22:23:04 -0700
Date: Fri, 13 Jan 2012 10:44:48 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v8 3.2.0-rc5 9/9] perf: perf interface for uprobes
Message-ID: <20120113051447.GD10189@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20111216122756.2085.95791.sendpatchset@srdronam.in.ibm.com>
 <20111216122951.2085.95511.sendpatchset@srdronam.in.ibm.com>
 <4F06D22D.9060906@hitachi.com>
 <20120109112236.GA10189@linux.vnet.ibm.com>
 <4F0F8F41.3060806@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4F0F8F41.3060806@hitachi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>, yrl.pp-manager.tt@hitachi.com

> 
> I mean that tp->module always !NULL if uprobe, then, we don't need
> to change the code. (thus we can reduce the patch size :))
> 

Agree, the new patch that I sent does this.

> 
> >>> +
> >>> +#define DEFAULT_FUNC_FILTER "!_*"
> >>
> >> This is a hidden rule for users ... please remove it.
> >> (or, is there any reason why we need to have it?)
> >>
> >
> > This is to be in sync with your commit
> > 3c42258c9a4db70133fa6946a275b62a16792bb5
> 
> I see, but that commit also provides filter option for changing
> the function filter. Here, user can not change the filter rule.
> 
> I think, currently, we don't need to filter any function by name
> here, since the user obviously intends to probe given function :)

Actually this was discussed in LKML here
https://lkml.org/lkml/2010/7/20/5, please refer the sub-thread.

Basically without this filter, the list of functions is too large
including labels, weak, and local binding function which arent traced.

We can make this filter settable at a later point of time.

> >
> > If the user provides a symbolic link, convert_name_to_addr would get the
> > target executable for the given executable. This would handy if we were
> > to compare existing probes registered on the same application using a
> > different name (symbolic links). Since you seem to like that we register
> > with the name the user has provided, I will just feed address here.
> 
> Hmm, why do we need to compare the probe points? Of course, event-name
> conflict should be solved, but I think it is acceptable that user puts
> several probes on the same exec:vaddr. Since different users may want
> to use it concurrently bit different ways.
> 

The event-names themselves are generated from the probe points. There is
no problem as such if two or more people use a different symlinks to
create probes. I was just trying to see if we could solve the
inconsitency where we warn a person if he is trying to place a probe on
a existing probe but allow the same if he is trying to place a probe on
a existing probe using a different symlink.

This again I have changed as you suggested in the latest patches that I
sent this week.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
