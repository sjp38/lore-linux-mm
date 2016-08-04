Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 07FED6B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 11:20:06 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id x130so191272156ite.3
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 08:20:06 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0196.hostedemail.com. [216.40.44.196])
        by mx.google.com with ESMTPS id z68si3554193itd.12.2016.08.04.08.19.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 08:19:51 -0700 (PDT)
Date: Thu, 4 Aug 2016 11:19:46 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/2] mm: page_alloc.c: Add tracepoints for slowpath
Message-ID: <20160804111946.6cbbd30b@gandalf.local.home>
In-Reply-To: <0AF03F78-AA34-4531-899A-EA1076B6B3A1@gmail.com>
References: <cover.1469629027.git.janani.rvchndrn@gmail.com>
	<6b12aed89ad75cb2b3525a24265fa1d622409b42.1469629027.git.janani.rvchndrn@gmail.com>
	<20160727112303.11409a4e@gandalf.local.home>
	<0AF03F78-AA34-4531-899A-EA1076B6B3A1@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@linux-foundation.org, hannes@compxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On Fri, 29 Jul 2016 01:41:20 +0530
Janani Ravichandran <janani.rvchndrn@gmail.com> wrote:

Sorry for the late reply, I've been swamped with other things since
coming back from my vacation.

> I looked at function graph trace, as you=E2=80=99d suggested. I saw that =
I could set a threshold=20
> there using tracing_thresh. But the problem was that slowpath trace infor=
mation was printed
> for all the cases (even when __alloc_pages_nodemask latencies were below =
the threshold).
> Is there a way to print tracepoint information only when __alloc_pages_no=
demask
> exceeds the threshold?

One thing you could do is to create your own module and hook into the
function graph tracer yourself!

It would require a patch to export two functions in
kernel/trace/ftrace.c:

 register_ftrace_graph()
 unregister_ftrace_graph()

Note, currently only one user of these functions is allowed at a time.
If function_graph tracing is already enabled, the register function
will return -EBUSY.

You pass in a "retfunc" and a "entryfunc" (I never understood why they
were backwards), and these are the functions that are called when a
function returns and when a function is entered respectively.

The retfunc looks like this:

static void my_retfunc(struct ftrace_graph_ret *trace)
{
	[...]
}

static int my_entryfunc(struct ftrace_graph_ent *trace)
{
	[...]
}


The ftrace_graph_ret structure looks like this:

struct ftrace_graph_ret {
	unsigned long func;
	unsigned long overrun;
	unsigned long calltime;
	unsigned long rettime;
	int depth;
};

Where func is actually the instruction pointer of the function that is
being traced.

You can ignore "overrun".

calltime is the trace_clock_local() (sched_clock() like timestamp) of
when the function was entered.

rettime is the trace_clock_local() timestamp of when the function
returns.

 rettime - calltime is the time difference of the entire function.

And that's the time you want to look at.

depth is how deep into the call chain the current function is. There's
a limit (50 I think), of how deep it will record, and anything deeper
will go into that "overrun" field I told you to ignore.


Hmm, looking at the code, it appears setting tracing_thresh should
work. Could you show me exactly what you did?

Either way, adding your own function graph hook may be a good exercise
in seeing how all this works.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
