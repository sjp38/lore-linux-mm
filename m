Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 62AE86B0038
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 03:58:38 -0400 (EDT)
Received: by paboj16 with SMTP id oj16so70767567pab.0
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 00:58:38 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id fe5si10200064pdb.39.2015.04.07.00.58.36
        for <linux-mm@kvack.org>;
        Tue, 07 Apr 2015 00:58:37 -0700 (PDT)
Date: Tue, 7 Apr 2015 16:52:26 +0900
From: Namhyung Kim <namhyung@kernel.org>
Subject: Re: [PATCH 9/9] tools lib traceevent: Honor operator priority
Message-ID: <20150407075226.GE23913@sejong>
References: <1428298576-9785-1-git-send-email-namhyung@kernel.org>
 <1428298576-9785-10-git-send-email-namhyung@kernel.org>
 <20150406104504.41e398d3@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20150406104504.41e398d3@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org

Hi Steve,

On Mon, Apr 06, 2015 at 10:45:04AM -0400, Steven Rostedt wrote:
> On Mon,  6 Apr 2015 14:36:16 +0900
> Namhyung Kim <namhyung@kernel.org> wrote:
> 
> > Currently it ignores operator priority and just sets processed args as a
> > right operand.  But it could result in priority inversion in case that
> > the right operand is also a operator arg and its priority is lower.
> > 
> > For example, following print format is from new kmem events.
> > 
> >   "page=%p", REC->pfn != -1UL ? (((struct page *)(0xffffea0000000000UL)) + (REC->pfn)) : ((void *)0)
> > 
> > But this was treated as below:
> > 
> >   REC->pfn != ((null - 1UL) ? ((struct page *)0xffffea0000000000UL + REC->pfn) : (void *) 0)
> > 
> > In this case, the right arg was '?' operator which has lower priority.
> > But it just sets the whole arg so making the output confusing - page was
> > always 0 or 1 since that's the result of logical operation.
> > 
> > With this patch, it can handle it properly like following:
> > 
> >   ((REC->pfn != (null - 1UL)) ? ((struct page *)0xffffea0000000000UL + REC->pfn) : (void *) 0)
> 
> Nice catch. One nit.
> 
> > 
> > Cc: Steven Rostedt <rostedt@goodmis.org>
> > Signed-off-by: Namhyung Kim <namhyung@kernel.org>
> > ---
> >  tools/lib/traceevent/event-parse.c | 17 ++++++++++++++++-
> >  1 file changed, 16 insertions(+), 1 deletion(-)
> > 
> > diff --git a/tools/lib/traceevent/event-parse.c b/tools/lib/traceevent/event-parse.c
> > index 6d31b6419d37..604bea5c3fb0 100644
> > --- a/tools/lib/traceevent/event-parse.c
> > +++ b/tools/lib/traceevent/event-parse.c
> > @@ -1939,7 +1939,22 @@ process_op(struct event_format *event, struct print_arg *arg, char **tok)
> >  			goto out_warn_free;
> >  
> >  		type = process_arg_token(event, right, tok, type);
> > -		arg->op.right = right;
> > +
> > +		if (right->type == PRINT_OP &&
> > +		    get_op_prio(arg->op.op) < get_op_prio(right->op.op)) {
> > +			struct print_arg tmp;
> > +
> > +			/* swap ops according to the priority */
> 
> This isn't really a swap. Better term to use is "rotate".

You're right!

> 
> But other than that,
> 
> Acked-by: Steven Rostedt <rostedt@goodmis.org>

Thanks for the review
Namhyung


> 
> > +			arg->op.right = right->op.left;
> > +
> > +			tmp = *arg;
> > +			*arg = *right;
> > +			*right = tmp;
> > +
> > +			arg->op.left = right;
> > +		} else {
> > +			arg->op.right = right;
> > +		}
> >  
> >  	} else if (strcmp(token, "[") == 0) {
> >  
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
