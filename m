Date: Fri, 6 Apr 2007 11:08:22 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: preemption and rwsems (was: Re: missing madvise functionality)
Message-ID: <20070406090822.GA2425@elte.hu>
References: <46128051.9000609@redhat.com> <p73648dz5oa.fsf@bingen.suse.de> <46128CC2.9090809@redhat.com> <20070403172841.GB23689@one.firstfloor.org> <20070403125903.3e8577f4.akpm@linux-foundation.org> <4612B645.7030902@redhat.com> <20070403202937.GE355@devserv.devel.redhat.com> <19526.1175777338@redhat.com> <20070405191129.GC22092@elte.hu> <20070405133742.88abc4f8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="pWyiEgJYm5f9v55/"
Content-Disposition: inline
In-Reply-To: <20070405133742.88abc4f8.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Howells <dhowells@redhat.com>, Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

--pWyiEgJYm5f9v55/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


* Andrew Morton <akpm@linux-foundation.org> wrote:

> > getting a good trace of it is easy: pick up the latest -rt kernel 
> > from:
> > 
> > 	http://redhat.com/~mingo/realtime-preempt/
> > 
> > enable EVENT_TRACING in that kernel, run the workload and do:
> > 
> > 	scripts/trace-it > to-ingo.txt
> > 
> > and send me the output.
> 
> Did that - no output was generated.  config at
> http://userweb.kernel.org/~akpm/config-akpm2.txt

sorry, i forgot to mention that you should turn off 
CONFIG_WAKEUP_TIMING.

i've attached an updated version of trace-it.c, which will turn this off 
itself, using a sysctl. I also made WAKEUP_TIMING default-off.

> I did get an interesting dmesg spew:
> http://userweb.kernel.org/~akpm/dmesg-akpm2.txt

yeah, it's stack footprint measurement/instrumentation. It's 
particularly effective at tracking the worst-case stack footprint if you 
have FUNCTION_TRACING enabled - because in that case the kernel measures 
the stack's size at every function entry point. It does a maximum search 
so after bootup (in search of the 'largest' stack frame) so it's a bit 
verbose, but gets alot rarer later on. If it bothers you then disable:

  CONFIG_DEBUG_STACKOVERFLOW=y

it could interfere with getting a quality scheduling trace anyway.

	Ingo

--pWyiEgJYm5f9v55/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="trace-it.c"


/*
 * Copyright (C) 2005, Ingo Molnar <mingo@redhat.com>
 *
 * user-triggered tracing.
 *
 * The -rt kernel has a built-in kernel tracer, which will trace
 * all kernel function calls (and a couple of special events as well),
 * by using a build-time gcc feature that instruments all kernel
 * functions.
 *
 * The tracer is highly automated for a number of latency tracing purposes,
 * but it can also be switched into 'user-triggered' mode, which is a
 * half-automatic tracing mode where userspace apps start and stop the
 * tracer. This file shows a dumb example how to turn user-triggered
 * tracing on, and how to start/stop tracing. Note that if you do
 * multiple start/stop sequences, the kernel will do a maximum search
 * over their latencies, and will keep the trace of the largest latency
 * in /proc/latency_trace. The maximums are also reported to the kernel
 * log. (but can also be read from /proc/sys/kernel/preempt_max_latency)
 *
 * For the tracer to be activated, turn on CONFIG_EVENT_TRACING
 * in the .config, rebuild the kernel and boot into it. The trace will
 * get _alot_ more verbose if you also turn on CONFIG_FUNCTION_TRACING,
 * every kernel function call will be put into the trace. Note that
 * CONFIG_FUNCTION_TRACING has significant runtime overhead, so you dont
 * want to use it for performance testing :)
 */

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <sys/wait.h>
#include <sys/prctl.h>
#include <linux/unistd.h>

int main (int argc, char **argv)
{
	int ret;

	if (getuid() != 0) {
		fprintf(stderr, "needs to run as root.\n");
		exit(1);
	}
	ret = system("cat /proc/sys/kernel/mcount_enabled >/dev/null 2>/dev/null");
	if (ret) {
		fprintf(stderr, "CONFIG_LATENCY_TRACING not enabled?\n");
		exit(1);
	}
	system("echo 1 > /proc/sys/kernel/trace_user_triggered");
	system("[ -e /proc/sys/kernel/wakeup_timing ] && echo 0 > /proc/sys/kernel/wakeup_timing");
	system("echo 1 > /proc/sys/kernel/trace_enabled");
	system("echo 1 > /proc/sys/kernel/mcount_enabled");
	system("echo 0 > /proc/sys/kernel/trace_freerunning");
	system("echo 0 > /proc/sys/kernel/trace_print_on_crash");
	system("echo 0 > /proc/sys/kernel/trace_verbose");
	system("echo 0 > /proc/sys/kernel/preempt_thresh 2>/dev/null");
	system("echo 0 > /proc/sys/kernel/preempt_max_latency 2>/dev/null");

	// start tracing
	if (prctl(0, 1)) {
		fprintf(stderr, "trace-it: couldnt start tracing!\n");
		return 1;
	}
	usleep(1000000);
	if (prctl(0, 0)) {
		fprintf(stderr, "trace-it: couldnt stop tracing!\n");
		return 1;
	}

	system("echo 0 > /proc/sys/kernel/trace_user_triggered");
	system("echo 0 > /proc/sys/kernel/trace_enabled");
	system("cat /proc/latency_trace");

	return 0;
}



--pWyiEgJYm5f9v55/--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
