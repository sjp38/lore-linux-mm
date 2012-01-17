Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 28A2A6B00A3
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 07:12:31 -0500 (EST)
Date: Tue, 17 Jan 2012 13:11:59 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v9 3.2 7/9] tracing: uprobes trace_event interface
Message-ID: <20120117121159.GA4959@elte.hu>
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
 <20120110114943.17610.28293.sendpatchset@srdronam.in.ibm.com>
 <20120116131137.GB5265@m.brq.redhat.com>
 <20120117092838.GB10397@elte.hu>
 <20120117102231.GB15447@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120117102231.GB15447@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Jiri Olsa <jolsa@redhat.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>


A couple of 'perf probe' usability issues.

When running it as unprivileged user right now it fails with:

 $ perf probe -x /lib64/libc.so.6 free
 Failed to open uprobe_events file: Permission denied

That error message should reference the full file name in 
question, i.e. /sys/kernel/debug/tracing/uprobe_events - that 
way the user can make that file writable if it's secure to do 
that on that system.

The other thing is the text that gets printed:

 $ perf probe --del free
 Remove event: probe_libc:free

that's not how tools generally communicate - it should be 
something like:

 $ perf probe --del free
 Removed event: probe_libc:free

Note the past tense - this tells the user that the action has 
been performed successfully.

Likewise, 'perf probe --add' should talk in past tense as well, 
to indicate success. So it should say something like:

 $ perf probe -x /lib64/libc.so.6 free
 Added new event:
  probe_libc:free      (on 0x7f080)

 You can now use it in all perf tools, such as:

	perf record -e probe_libc:free -aR sleep 1

(Also note the s/on/in change in the other text.)

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
