Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id CB0256B0088
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 04:29:13 -0500 (EST)
Date: Tue, 17 Jan 2012 10:28:38 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v9 3.2 7/9] tracing: uprobes trace_event interface
Message-ID: <20120117092838.GB10397@elte.hu>
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
 <20120110114943.17610.28293.sendpatchset@srdronam.in.ibm.com>
 <20120116131137.GB5265@m.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120116131137.GB5265@m.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Olsa <jolsa@redhat.com>, Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>


* Jiri Olsa <jolsa@redhat.com> wrote:

> I've tested following event:
>         echo "p:probe_libc/free /lib64/libc-2.13.so:0x7a4f0 %ax" > ./uprobe_events
> 
> and commands like:
>         perf record -a -e probe_libc:free  --filter "common_pid == 1127"
>         perf record -e probe_libc:free --filter "arg1 == 0xa" ls
> 
> got me proper results.

Btw., Srikar, if that's the primary UI today then we'll need to 
make it a *lot* more user-friendly than the above usage 
workflow.

In particular this line:

>         echo "p:probe_libc/free /lib64/libc-2.13.so:0x7a4f0 %ax" > ./uprobe_events

is not something a mere mortal will be able to figure out.

There needs to be perf probe integration, that allows intuitive 
usage, such as:

   perf probe add libc:free

Using the perf symbols code it should first search a libc*so DSO 
in the system, finding say /lib64/libc-2.15.so. The 'free' 
symbol is readily available there:

  aldebaran:~> eu-readelf -s /lib64/libc-2.15.so  | grep ' free$'
  7186: 00000039ff47f080    224 FUNC    GLOBAL DEFAULT       12 free

then the tool can automatically turn that symbol information 
into the specific probe.

Will it all work with DSO randomization, prelinking and default 
placement as well?

Users should not be expected to enter magic hexa numbers to get 
a trivial usecase going ...

this bit:

>         perf record -a -e probe_libc:free  --filter "common_pid == 1127"
>         perf record -e probe_libc:free --filter "arg1 == 0xa" ls

looks good and intuitive and 'perf list' should list all the 
available uprobes.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
