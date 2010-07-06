Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2FFE66B0248
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 19:49:51 -0400 (EDT)
Subject: Re: [PATCH 2/2] sched: make sched_param arugment static variables
 in some sched_setscheduler() caller
From: Steven Rostedt <rostedt@goodmis.org>
Reply-To: rostedt@goodmis.org
In-Reply-To: <20100706161253.79bfb761.akpm@linux-foundation.org>
References: <20100702144941.8fa101c3.akpm@linux-foundation.org>
	 <20100706091607.CCCC.A69D9226@jp.fujitsu.com>
	 <20100706095013.CCD9.A69D9226@jp.fujitsu.com>
	 <1278454438.1537.54.camel@gandalf.stny.rr.com>
	 <20100706161253.79bfb761.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Tue, 06 Jul 2010 19:49:47 -0400
Message-ID: <1278460187.1537.107.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, James Morris <jmorris@namei.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-07-06 at 16:12 -0700, Andrew Morton wrote:

> Well if we're so worried about resource wastage then how about making
> all boot-time-only text and data reside in __init and __initdata
> sections rather than hanging around uselessly in memory for ever?

That would be a patch I would like :-)

I could probably do that when I get some time.

> 
> Only that's going to be hard because we went and added pointers into
> .init.text from .data due to `struct tracer.selftest', which will cause
> a storm of section mismatch warnings.  Doh, should have invoked the
> selftests from initcalls.  That might open the opportunity of running
> the selftests by modprobing the selftest module, too.

They are called by initcalls. The initcalls register the tracers and
that is the time we call the selftest. No other time.

Is there a way that we set up a function pointer to let the section
checks know that it is only called at bootup?

> 
> And I _do_ wish the selftest module was modprobeable, rather than this
> monstrosity:

The selftests are done by individual tracers at boot up. It would be
hard to modprobe them at that time.


> #ifdef CONFIG_FTRACE_SELFTEST
> /* Let selftest have access to static functions in this file */
> #include "trace_selftest.c"
> #endif
> 
> Really?  Who had a tastebudectomy over there?  At least call it
> trace_selftest.inc or something, so poor schmucks don't go scrabbling
> around wondering "how the hell does this thing get built oh no they
> didn't really go and #include it did they?"


Well this is also the way sched.c adds all its extra code. Making it
trace_selftest.inc would make it hard to know what the hell it was. And
also hard for editors to know what type of file it is, or things can be
missed with a 'find . -name "*.[ch]" | xargs grep blahblah'

Yes, the self tests are ugly and can probably go with an overhaul. Since
we are trying to get away from the tracer plugins anyway, they will
start disappearing when the plugins do.

We should have some main selftests anyway. Those are for the TRACE_EVENT
tests (which are not even in the trace_selftest.c file, and the function
testing which currently are, as well as the latency testers.

The trace_selftest.c should eventually be replaced with more compact
tests for the specific types of tracing.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
