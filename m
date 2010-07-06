Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 395336B0249
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 18:14:03 -0400 (EDT)
Subject: Re: [PATCH 2/2] sched: make sched_param arugment static variables
 in some sched_setscheduler() caller
From: Steven Rostedt <rostedt@goodmis.org>
Reply-To: rostedt@goodmis.org
In-Reply-To: <20100706095013.CCD9.A69D9226@jp.fujitsu.com>
References: <20100702144941.8fa101c3.akpm@linux-foundation.org>
	 <20100706091607.CCCC.A69D9226@jp.fujitsu.com>
	 <20100706095013.CCD9.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Tue, 06 Jul 2010 18:13:58 -0400
Message-ID: <1278454438.1537.54.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, James Morris <jmorris@namei.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-07-06 at 09:51 +0900, KOSAKI Motohiro wrote:
> Andrew Morton pointed out almost sched_setscheduler() caller are
> using fixed parameter and it can be converted static. it reduce
> runtume memory waste a bit.

We are replacing runtime waste with permanent waste?

> 
> Reported-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



> --- a/kernel/trace/trace_selftest.c
> +++ b/kernel/trace/trace_selftest.c
> @@ -560,7 +560,7 @@ trace_selftest_startup_nop(struct tracer *trace, struct trace_array *tr)
>  static int trace_wakeup_test_thread(void *data)
>  {
>  	/* Make this a RT thread, doesn't need to be too high */
> -	struct sched_param param = { .sched_priority = 5 };
> +	static struct sched_param param = { .sched_priority = 5 };
>  	struct completion *x = data;
>  

This is a thread that runs on boot up to test the sched_wakeup tracer.
Then it is deleted and all memory is reclaimed.

Thus, this patch just took memory that was usable at run time and
removed it permanently.

Please Cc me on all tracing changes.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
