Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3B28E6B0248
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 19:13:27 -0400 (EDT)
Date: Tue, 6 Jul 2010 16:12:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] sched: make sched_param arugment static variables
 in some sched_setscheduler() caller
Message-Id: <20100706161253.79bfb761.akpm@linux-foundation.org>
In-Reply-To: <1278454438.1537.54.camel@gandalf.stny.rr.com>
References: <20100702144941.8fa101c3.akpm@linux-foundation.org>
	<20100706091607.CCCC.A69D9226@jp.fujitsu.com>
	<20100706095013.CCD9.A69D9226@jp.fujitsu.com>
	<1278454438.1537.54.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: rostedt@goodmis.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, James Morris <jmorris@namei.org>
List-ID: <linux-mm.kvack.org>

On Tue, 06 Jul 2010 18:13:58 -0400 Steven Rostedt <rostedt@goodmis.org> wrote:

> On Tue, 2010-07-06 at 09:51 +0900, KOSAKI Motohiro wrote:
> > Andrew Morton pointed out almost sched_setscheduler() caller are
> > using fixed parameter and it can be converted static. it reduce
> > runtume memory waste a bit.
> 
> We are replacing runtime waste with permanent waste?

Confused.  kernel/trace/ appears to waste resources by design, so what's
the issue?

I don't think this change will cause more waste.  It'll consume 4 bytes
of .data and will save a little more .text.

> > 
> > Reported-by: Andrew Morton <akpm@linux-foundation.org>
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> 
> 
> > --- a/kernel/trace/trace_selftest.c
> > +++ b/kernel/trace/trace_selftest.c
> > @@ -560,7 +560,7 @@ trace_selftest_startup_nop(struct tracer *trace, struct trace_array *tr)
> >  static int trace_wakeup_test_thread(void *data)
> >  {
> >  	/* Make this a RT thread, doesn't need to be too high */
> > -	struct sched_param param = { .sched_priority = 5 };
> > +	static struct sched_param param = { .sched_priority = 5 };
> >  	struct completion *x = data;
> >  
> 
> This is a thread that runs on boot up to test the sched_wakeup tracer.
> Then it is deleted and all memory is reclaimed.
> 
> Thus, this patch just took memory that was usable at run time and
> removed it permanently.
> 
> Please Cc me on all tracing changes.

Well if we're so worried about resource wastage then how about making
all boot-time-only text and data reside in __init and __initdata
sections rather than hanging around uselessly in memory for ever?

Only that's going to be hard because we went and added pointers into
.init.text from .data due to `struct tracer.selftest', which will cause
a storm of section mismatch warnings.  Doh, should have invoked the
selftests from initcalls.  That might open the opportunity of running
the selftests by modprobing the selftest module, too.

And I _do_ wish the selftest module was modprobeable, rather than this
monstrosity:

#ifdef CONFIG_FTRACE_SELFTEST
/* Let selftest have access to static functions in this file */
#include "trace_selftest.c"
#endif

Really?  Who had a tastebudectomy over there?  At least call it
trace_selftest.inc or something, so poor schmucks don't go scrabbling
around wondering "how the hell does this thing get built oh no they
didn't really go and #include it did they?"


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
