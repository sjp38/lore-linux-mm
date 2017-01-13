Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id E0D8D6B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 19:18:39 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id d9so40838758itc.4
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 16:18:39 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id f83si2639573pfd.13.2017.01.12.16.18.38
        for <linux-mm@kvack.org>;
        Thu, 12 Jan 2017 16:18:39 -0800 (PST)
Date: Fri, 13 Jan 2017 09:18:36 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v4 06/15] lockdep: Make save_trace can skip stack tracing
 of the current
Message-ID: <20170113001835.GA3326@X58A-UD3R>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-7-git-send-email-byungchul.park@lge.com>
 <20170112163757.GC3144@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170112163757.GC3144@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Thu, Jan 12, 2017 at 05:37:57PM +0100, Peter Zijlstra wrote:
> On Fri, Dec 09, 2016 at 02:12:02PM +0900, Byungchul Park wrote:
> > Currently, save_trace() always performs save_stack_trace() for the
> > current. However, crossrelease needs to use stack trace data of another
> > context instead of the current. So add a parameter for skipping stack
> > tracing of the current and make it use trace data, which is already
> > saved by crossrelease framework.
> > 
> > Signed-off-by: Byungchul Park <byungchul.park@lge.com>
> > ---
> >  kernel/locking/lockdep.c | 33 ++++++++++++++++++++-------------
> >  1 file changed, 20 insertions(+), 13 deletions(-)
> > 
> > diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
> > index 3eaa11c..11580ec 100644
> > --- a/kernel/locking/lockdep.c
> > +++ b/kernel/locking/lockdep.c
> > @@ -387,15 +387,22 @@ static void print_lockdep_off(const char *bug_msg)
> >  #endif
> >  }
> >  
> > -static int save_trace(struct stack_trace *trace)
> > +static int save_trace(struct stack_trace *trace, int skip_tracing)
> >  {
> > -	trace->nr_entries = 0;
> > -	trace->max_entries = MAX_STACK_TRACE_ENTRIES - nr_stack_trace_entries;
> > -	trace->entries = stack_trace + nr_stack_trace_entries;
> > +	unsigned int nr_avail = MAX_STACK_TRACE_ENTRIES - nr_stack_trace_entries;
> >  
> > -	trace->skip = 3;
> > -
> > -	save_stack_trace(trace);
> > +	if (skip_tracing) {
> > +		trace->nr_entries = min(trace->nr_entries, nr_avail);
> > +		memcpy(stack_trace + nr_stack_trace_entries, trace->entries,
> > +				trace->nr_entries * sizeof(trace->entries[0]));
> > +		trace->entries = stack_trace + nr_stack_trace_entries;
> > +	} else {
> > +		trace->nr_entries = 0;
> > +		trace->max_entries = nr_avail;
> > +		trace->entries = stack_trace + nr_stack_trace_entries;
> > +		trace->skip = 3;
> > +		save_stack_trace(trace);
> > +	}
> >  
> >  	/*
> >  	 * Some daft arches put -1 at the end to indicate its a full trace.
> 
> That's pretty nasty semantics.. so when skip_tracing it modifies trace
> in-place.

I agree. Let me think more and enhance it.

Thank you,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
