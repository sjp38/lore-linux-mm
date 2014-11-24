Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6103B6B008A
	for <linux-mm@kvack.org>; Sun, 23 Nov 2014 21:54:20 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lj1so8606238pab.18
        for <linux-mm@kvack.org>; Sun, 23 Nov 2014 18:54:20 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id j4si16622199pdp.72.2014.11.23.18.54.17
        for <linux-mm@kvack.org>;
        Sun, 23 Nov 2014 18:54:19 -0800 (PST)
Date: Mon, 24 Nov 2014 11:57:13 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 5/7] stacktrace: introduce snprint_stack_trace for
 buffer output
Message-ID: <20141124025713.GB10828@js1304-P5Q-DELUXE>
References: <1416557646-21755-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1416557646-21755-6-git-send-email-iamjoonsoo.kim@lge.com>
 <20141121153759.c6a502e824207d517dd2f994@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141121153759.c6a502e824207d517dd2f994@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave@sr71.net>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Nov 21, 2014 at 03:37:59PM -0800, Andrew Morton wrote:
> On Fri, 21 Nov 2014 17:14:04 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > Current stacktrace only have the function for console output.
> > page_owner that will be introduced in following patch needs to print
> > the output of stacktrace into the buffer for our own output format
> > so so new function, snprint_stack_trace(), is needed.
> > 
> > ...
> >
> > --- a/include/linux/stacktrace.h
> > +++ b/include/linux/stacktrace.h
> > @@ -20,6 +20,8 @@ extern void save_stack_trace_tsk(struct task_struct *tsk,
> >  				struct stack_trace *trace);
> >  
> >  extern void print_stack_trace(struct stack_trace *trace, int spaces);
> > +extern int  snprint_stack_trace(char *buf, int buf_len,
> > +				struct stack_trace *trace, int spaces);
> >  
> >  #ifdef CONFIG_USER_STACKTRACE_SUPPORT
> >  extern void save_stack_trace_user(struct stack_trace *trace);
> > @@ -32,6 +34,7 @@ extern void save_stack_trace_user(struct stack_trace *trace);
> >  # define save_stack_trace_tsk(tsk, trace)		do { } while (0)
> >  # define save_stack_trace_user(trace)			do { } while (0)
> >  # define print_stack_trace(trace, spaces)		do { } while (0)
> > +# define snprint_stack_trace(buf, len, trace, spaces)	do { } while (0)
> 
> Doing this with macros instead of C functions is pretty crappy - it
> defeats typechecking and can lead to unused-var warnings when the
> feature is disabled.
> 
> Fixing this might not be practical if struct stack_trace isn't
> available, dunno.

struct stack_trace is defined only if CONFIG_STACKTRACE, and,
most call sites seems to be defined only if CONFIG_STACKTRACE.
I guess that removing all of them would works fine, but, dunno. :)

> 
> > --- a/kernel/stacktrace.c
> > +++ b/kernel/stacktrace.c
> > @@ -25,6 +25,30 @@ void print_stack_trace(struct stack_trace *trace, int spaces)
> >  }
> >  EXPORT_SYMBOL_GPL(print_stack_trace);
> >  
> > +int snprint_stack_trace(char *buf, int buf_len, struct stack_trace *trace,
> > +			int spaces)
> > +{
> > +	int i, printed;
> > +	unsigned long ip;
> > +	int ret = 0;
> > +
> > +	if (WARN_ON(!trace->entries))
> > +		return 0;
> > +
> > +	for (i = 0; i < trace->nr_entries && buf_len; i++) {
> > +		ip = trace->entries[i];
> > +		printed = snprintf(buf, buf_len, "%*c[<%p>] %pS\n",
> > +				1 + spaces, ' ', (void *) ip, (void *) ip);
> > +
> > +		buf_len -= printed;
> > +		ret += printed;
> > +		buf += printed;
> > +	}
> > +
> > +	return ret;
> > +}
> 
> I'm not liking this much.  The behaviour when the output buffer is too
> small is scary.  snprintf() will return "the number of characters which
> would be generated for the given input", so local variable `buf_len'
> will go negative and we pass a negative int into snprintf()'s `size_t
> size'.  snprintf() says "goody, lots and lots of buffer!" and your
> machine crashes.
> 
> buf_len should be a size_t and snprint_stack_trace() will need to be
> changed to handle this.

Okay. I will fix overflow problem. And, current implementation doesn't
comply snprint* functions sementic that returns generated string
length rather than printed string length. I will fix it, too.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
