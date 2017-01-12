Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 85CBA6B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 11:38:04 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id q20so32664461ioi.0
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 08:38:04 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id f128si8574764ioe.103.2017.01.12.08.38.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 08:38:03 -0800 (PST)
Date: Thu, 12 Jan 2017 17:37:57 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v4 06/15] lockdep: Make save_trace can skip stack tracing
 of the current
Message-ID: <20170112163757.GC3144@twins.programming.kicks-ass.net>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-7-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1481260331-360-7-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Fri, Dec 09, 2016 at 02:12:02PM +0900, Byungchul Park wrote:
> Currently, save_trace() always performs save_stack_trace() for the
> current. However, crossrelease needs to use stack trace data of another
> context instead of the current. So add a parameter for skipping stack
> tracing of the current and make it use trace data, which is already
> saved by crossrelease framework.
> 
> Signed-off-by: Byungchul Park <byungchul.park@lge.com>
> ---
>  kernel/locking/lockdep.c | 33 ++++++++++++++++++++-------------
>  1 file changed, 20 insertions(+), 13 deletions(-)
> 
> diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
> index 3eaa11c..11580ec 100644
> --- a/kernel/locking/lockdep.c
> +++ b/kernel/locking/lockdep.c
> @@ -387,15 +387,22 @@ static void print_lockdep_off(const char *bug_msg)
>  #endif
>  }
>  
> -static int save_trace(struct stack_trace *trace)
> +static int save_trace(struct stack_trace *trace, int skip_tracing)
>  {
> -	trace->nr_entries = 0;
> -	trace->max_entries = MAX_STACK_TRACE_ENTRIES - nr_stack_trace_entries;
> -	trace->entries = stack_trace + nr_stack_trace_entries;
> +	unsigned int nr_avail = MAX_STACK_TRACE_ENTRIES - nr_stack_trace_entries;
>  
> -	trace->skip = 3;
> -
> -	save_stack_trace(trace);
> +	if (skip_tracing) {
> +		trace->nr_entries = min(trace->nr_entries, nr_avail);
> +		memcpy(stack_trace + nr_stack_trace_entries, trace->entries,
> +				trace->nr_entries * sizeof(trace->entries[0]));
> +		trace->entries = stack_trace + nr_stack_trace_entries;
> +	} else {
> +		trace->nr_entries = 0;
> +		trace->max_entries = nr_avail;
> +		trace->entries = stack_trace + nr_stack_trace_entries;
> +		trace->skip = 3;
> +		save_stack_trace(trace);
> +	}
>  
>  	/*
>  	 * Some daft arches put -1 at the end to indicate its a full trace.

That's pretty nasty semantics.. so when skip_tracing it modifies trace
in-place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
