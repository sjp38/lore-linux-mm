Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 67EA76B0044
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 11:51:45 -0400 (EDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 12 Apr 2012 09:51:44 -0600
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 28C86C90065
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 11:51:33 -0400 (EDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3CFkHnG300602
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 11:51:34 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3CEnJJV023130
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 08:49:20 -0600
Date: Thu, 12 Apr 2012 20:11:48 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: Re: [PATCH] perf/probe: Provide perf interface for uprobes
Message-ID: <20120412144148.GA21587@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20120411135742.29198.45061.sendpatchset@srdronam.in.ibm.com>
 <20120411144918.GD16257@infradead.org>
 <20120411170343.GB29831@linux.vnet.ibm.com>
 <20120411181727.GK16257@infradead.org>
 <4F864BB3.3090405@hitachi.com>
 <20120412140751.GM16257@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20120412140751.GM16257@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@infradead.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

* Arnaldo Carvalho de Melo <acme@infradead.org> [2012-04-12 11:07:51]:

> Em Thu, Apr 12, 2012 at 12:27:47PM +0900, Masami Hiramatsu escreveu:
> > > * Arnaldo Carvalho de Melo <acme@infradead.org> [2012-04-11 11:49:18]:
> > > Yeah, if one needs to disambiguate, sure, use these keywords, but for
> > > things like:
> > > 
> > > $ perf probe /lib/libc.so.6 malloc
> > > 
> > > I think it is easy to figure out it is userspace. I.e. some regex would
> > > figure it out.
> > 
> > That's interessting to me too. Maybe it is also useful syntax for
> > module specifying too.
> > 
> > e.g.
> >   perf probe -m kvm kvm_timer_fn
> > 
> > can be
> > 
> >   perf probe kvm.ko kvm_timer_fn
> > 
> > (.ko is required) or if unloaded
> > 
> >   perf probe /lib/modules/XXX/kernel/virt/kvm.ko kvm_timer_fn
> 
> 	It may not even be required, since we can check in /proc/modules
> if "kvm" is there and as well if it has a function named "kvm_timer_fn".
> 
> 	Also probably there is no library or binary on the current
> directory with such a name :-)
> 

> 	Likewise, if we do:
> 
>  $ perf probe libc-2.12.so malloc
> 
> 	It should just figure out it is the /lib64/libc-2.12.so
> 
> 	Heck, even:
> 
>  $ perf probe libc malloc
> 
> 	Makes it even easier to use.
> 
> 	Its just when one asks for something that has ambiguities that
> the tool should ask the user to be a bit more precise to remove such
> ambiguity.
> 
> 	After all...
> 

I do understand/agree that the short form looks better. However each
user in the system might have different library /executable paths (and
different ordering of paths. The session in which perf is called may
find just one unique library or executable. But the used binary maynot
be the one that is being traced.

For example: I may have my perf in /home/srikar/bin/perf which may be
picked up. But when I use "perf probe perf cmd_probe" as a root user,
the root may only see /usr/bin/perf. It might look intuitive for us.
However it may not look so for ordinary users and system admins. 

The other choice would be to probe all executables/libraries by the give
name. Here also getting a exhaustive list is debatable.

So I think its okay for people to type a bit more than allow perf to guess
and make a wrong choice. After all we have bash history and tab
completion, command alias to lessen the typing.


> [acme@sandy linux]$ locate libc-2.12.so
> /home/acme/.debug/lib64/libc-2.12.so
> /home/acme/.debug/lib64/libc-2.12.so/293f8b6f5e6cea240d1bb0b47ec269ee91f31673
> /home/acme/.debug/lib64/libc-2.12.so/5a7fad9dfcbb67af098a258bc2a20137cc954424
> /lib64/libc-2.12.so
> /usr/lib/debug/lib64/libc-2.12.so.debug
> [acme@sandy linux]$
> 
> 	Only /lib64/libc-2.12.so is on the ld library path :-)
> 
> 	And after people really start depending on this tool for day to
> day use, they may do like me:

But what if the /lib/libc.so.6 is around on the same machine to cater for 32
bit apps and the user only wanted to trace 32 bit apps.

As you pointed out earlier, some user might have a text file by name
libc in the current directory which he inadvertently could have given
execute permissions. 

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
