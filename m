Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 843698D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 01:27:30 -0400 (EDT)
Date: Tue, 15 Mar 2011 10:51:33 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 0/20] 0: Inode based uprobes
Message-ID: <20110315052133.GT24254@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
 <20110314163028.a05cec49.akpm@linux-foundation.org>
 <y0maagxuqx6.fsf@fche.csb>
 <alpine.LFD.2.00.1103150224260.2787@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1103150224260.2787@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "Frank Ch. Eigler" <fche@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, int-list-linux-mm@kvack.orglinux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

Hi Thomas,

> > 
> > > [...]  How do you envisage these features actually get used?
> > 
> > Patch #20/20 in the set includes an ftrace-flavoured debugfs frontend.
> 
> And you really think that:
> 
> # cd /sys/kernel/debug/tracing/
> 
> # cat /proc/`pgrep  zsh`/maps | grep /bin/zsh | grep r-xp
> 00400000-0048a000 r-xp 00000000 08:03 130904 /bin/zsh
> 
> # objdump -T /bin/zsh | grep -w zfree
> 0000000000446420 g    DF .text  0000000000000012  Base        zfree
> 
> # echo 'p /bin/zsh:0x46420 %ip %ax' > uprobe_events
> 
> # cat uprobe_events
> p:uprobes/p_zsh_0x46420 /bin/zsh:0x0000000000046420
> 
> > TODO: Documentation/trace/uprobetrace.txt
> 
> without a reasonable documentation how to use that is a brilliant
> argument?

We had a fairly decent documentation for uprobes and
uprobetracer. But that had to be changed with  the change in
underlying design of uprobes infrastructure. Since uprobetrace is one
the user interface, I plan to document it soon. However it would be
great if we had inputs on how we should be designing the syscall.

> 
> > Previous versions of the patchset included perf front-ends too, which
> > are probably to be seen again.
> 
> Ahh, probably. What does that mean?
> 
>      And if that probably happens, what interface is that supposed to
>      use?
> 
> 	The above magic wrapped into perf ?

For the initial perf probe thing, yes it would be a wrapper over
uprobe_tracer.  That is because we can reuse most of the current perf
probe and we could prototype and show users what all can be
achieved. However we plan to make perf probe depend on the syscall when
the syscall takes shape.  

> 
> 	Or some sensible implementation ?

Would syscall based perf probe implementation count as a sensible
implementation? My current plan was to code up the perf probe for
uprobes and then draft a proposal for how the syscall should look. 
There are still some areas on how we should be allowing the
filter, and what restrictions we should place on the syscall
defined handler. I would like to hear from you and others on your
ideas for the same. If you have ideas on doing it other than using a
syscall then please do let me know about the same.

I know that getting the user interface right is very important.
However I think it kind of depends on what the infrastructure can
provide too. So if we can decide on the kernel ABI and the
underlying design (i.e can we use replace_page() based background page
replacement, Are there issues with the Xol slot based mechanism that
we are using, etc), we can work towards providing a stable User ABI that
even normal users can use. For now I am concentrating on getting the
underlying infrastructure correct.


Please let me know your thoughts.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
