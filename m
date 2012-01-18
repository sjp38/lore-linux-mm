Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 891096B004D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 05:17:43 -0500 (EST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 18 Jan 2012 03:17:42 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 553DE19D8026
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 03:16:57 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0IAGw0c129458
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 03:16:58 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0IAGqRX015658
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 03:16:54 -0700
Date: Wed, 18 Jan 2012 15:37:52 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v9 3.2 7/9] tracing: uprobes trace_event interface
Message-ID: <20120118100752.GF15447@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
 <20120110114943.17610.28293.sendpatchset@srdronam.in.ibm.com>
 <20120116131137.GB5265@m.brq.redhat.com>
 <20120117092838.GB10397@elte.hu>
 <20120117102231.GB15447@linux.vnet.ibm.com>
 <20120117122133.GB4959@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20120117122133.GB4959@elte.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Jiri Olsa <jolsa@redhat.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>

> 
> Have you tried to use 'perf probe' to achieve any useful 
> instrumentation on a real app?
> 
> I just tried out the 'glibc:free' usecase and it's barely 
> usable.
> 

Thanks for trying.

Yes, I have actually place probes on free and malloc while building a
kernel and it has worked for me.

> Firstly, the recording very frequently produces overruns:
> 
>  $ perf record -e probe_libc:free -aR sleep 1
>  [ perf record: Woken up 169 times to write data ]
>  [ perf record: Captured and wrote 89.674 MB perf.data (~3917919 samples) ]
>  Warning:Processed 1349133 events and lost 1 chunks!
> 

I have seen the "lost chunks" but thats not always and mostly when I
have run perf record for a very long time. But I have seen this even
with just kernel probes too. So I didnt debug that.

> Using -m 4096 made it work better.
> 
> Adding -g for call-graph profiling caused 'perf report' to lock 
> up:
> 
>   perf record -m 4096 -e probe_libc:free -agR sleep 1
>   perf report
>   [ loops forever ]
> 

This actually works for me.
I had CONFIG_PREEMPT not set. So I set it and tried with and without
Jiri's fix. It still worked for me. Can you pass me your config that
shows this hang so that I can try and fix it.

> I've sent a testcase to Arnaldo separately. Note that perf 
> report --stdio appears to work.

There are no changes in perf report because of uprobes. So the data
collected from uprobes could trigger the hang. I was speculating that
not disabling preemption that Jiri pointed out could be causing this. So
I tried with and without but couldnt reproduce. Can I request you to see
if Jiri's patch helps?

Today with -g option, on one machine I do see a 
$ sudo perf report
perf: Floating point exception

I will take a look at this too. Other machines dont seem to show this
error.

> Regular '-e cycles -g' works fine, so this is a uprobes specific 
> bug.
> 

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
