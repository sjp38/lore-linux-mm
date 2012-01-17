Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 87E616B0099
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 05:31:29 -0500 (EST)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 17 Jan 2012 03:31:28 -0700
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 214191FF0050
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 03:31:24 -0700 (MST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0HAVO6H280412
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 05:31:24 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0HAVMpg001896
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 05:31:24 -0500
Date: Tue, 17 Jan 2012 15:52:32 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v9 3.2 7/9] tracing: uprobes trace_event interface
Message-ID: <20120117102231.GB15447@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
 <20120110114943.17610.28293.sendpatchset@srdronam.in.ibm.com>
 <20120116131137.GB5265@m.brq.redhat.com>
 <20120117092838.GB10397@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20120117092838.GB10397@elte.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Jiri Olsa <jolsa@redhat.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>

> > 
> > and commands like:
> >         perf record -a -e probe_libc:free  --filter "common_pid == 1127"
> >         perf record -e probe_libc:free --filter "arg1 == 0xa" ls
> > 
> > got me proper results.
> 
> Btw., Srikar, if that's the primary UI today then we'll need to 
> make it a *lot* more user-friendly than the above usage 
> workflow.
> 
> In particular this line:
> 
> >         echo "p:probe_libc/free /lib64/libc-2.13.so:0x7a4f0 %ax" > ./uprobe_events
> 
> is not something a mere mortal will be able to figure out.

Agree, perf probe is the primary interface to use uprobes.

> 
> There needs to be perf probe integration, that allows intuitive 
> usage, such as:
> 
>    perf probe add libc:free

Current usage is like perf probe -x <executable> -a <func1> -a <func2>
So we could use
perf probe -x /lib64/libc.so.6 free

or 
perf probe -x /lib64/libc.so.6 -a free -a malloc -a strcpy

The -x option helps perf to identify  that its a user space based probing.
This currently restricts that all probes defined per "perf probe"
invocation to just one executable. This usage was suggested by Masami.

Earlier we used perf probe free@/lib/libc.so.6 malloc@/lib/libc.so.6
The objection for this was that perf was already using @ to signify
source file. Similarly : is already used for Relative line number.

This also goes with perf probe -F -x /lib64/libc.so to list the
available probes in libc.

> 
> Using the perf symbols code it should first search a libc*so DSO 
> in the system, finding say /lib64/libc-2.15.so. The 'free' 
> symbol is readily available there:

While I understand the ease of using a libc instead of the full path, I
think it does have few issues.
- Do we need to keep checking if the new files created in the system
  match the pattern and if they match the pattern, dynamically add the
  files?

- Also the current model helps if the user wants to restrict his trace
  to particular executable where there are more that one executable with
  the same name.

> 
>   aldebaran:~> eu-readelf -s /lib64/libc-2.15.so  | grep ' free$'
>   7186: 00000039ff47f080    224 FUNC    GLOBAL DEFAULT       12 free
> 
> then the tool can automatically turn that symbol information 
> into the specific probe.
> 

Given a function in an executable, we are 

> Will it all work with DSO randomization, prelinking and default 
> placement as well?

Works with DSO randomization, I havent tried with prelinking.  did you
mean http://en.wikipedia.org/wiki/Placement_syntax#Default_placement
when you said default placement?


> 
> Users should not be expected to enter magic hexa numbers to get 
> a trivial usecase going ...

yes, that why we dont allow perf probe -x /lib/libc.so.6 0x1234

> 
> this bit:
> 
> >         perf record -a -e probe_libc:free  --filter "common_pid == 1127"
> >         perf record -e probe_libc:free --filter "arg1 == 0xa" ls
> 
> looks good and intuitive and 'perf list' should list all the 
> available uprobes.

Currently "perf probe -F -x /bin/zsh" lists all available functions in
zsh. perf probe --list has been enhanced to show uprobes that are
already registered.

Similar to kprobes based probes, available user space probes are not
part of "perf list".
> 
> Thanks,
> 
> 	Ingo
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
