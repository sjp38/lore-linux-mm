Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4D40B6B0038
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 10:45:09 -0400 (EDT)
Received: by iedfl3 with SMTP id fl3so25769236ied.1
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 07:45:08 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0054.hostedemail.com. [216.40.44.54])
        by mx.google.com with ESMTP id i17si2623994ich.22.2015.04.06.07.45.07
        for <linux-mm@kvack.org>;
        Mon, 06 Apr 2015 07:45:07 -0700 (PDT)
Date: Mon, 6 Apr 2015 10:45:04 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 9/9] tools lib traceevent: Honor operator priority
Message-ID: <20150406104504.41e398d3@gandalf.local.home>
In-Reply-To: <1428298576-9785-10-git-send-email-namhyung@kernel.org>
References: <1428298576-9785-1-git-send-email-namhyung@kernel.org>
	<1428298576-9785-10-git-send-email-namhyung@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@kernel.org>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org

On Mon,  6 Apr 2015 14:36:16 +0900
Namhyung Kim <namhyung@kernel.org> wrote:

> Currently it ignores operator priority and just sets processed args as a
> right operand.  But it could result in priority inversion in case that
> the right operand is also a operator arg and its priority is lower.
> 
> For example, following print format is from new kmem events.
> 
>   "page=%p", REC->pfn != -1UL ? (((struct page *)(0xffffea0000000000UL)) + (REC->pfn)) : ((void *)0)
> 
> But this was treated as below:
> 
>   REC->pfn != ((null - 1UL) ? ((struct page *)0xffffea0000000000UL + REC->pfn) : (void *) 0)
> 
> In this case, the right arg was '?' operator which has lower priority.
> But it just sets the whole arg so making the output confusing - page was
> always 0 or 1 since that's the result of logical operation.
> 
> With this patch, it can handle it properly like following:
> 
>   ((REC->pfn != (null - 1UL)) ? ((struct page *)0xffffea0000000000UL + REC->pfn) : (void *) 0)

Nice catch. One nit.

> 
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Signed-off-by: Namhyung Kim <namhyung@kernel.org>
> ---
>  tools/lib/traceevent/event-parse.c | 17 ++++++++++++++++-
>  1 file changed, 16 insertions(+), 1 deletion(-)
> 
> diff --git a/tools/lib/traceevent/event-parse.c b/tools/lib/traceevent/event-parse.c
> index 6d31b6419d37..604bea5c3fb0 100644
> --- a/tools/lib/traceevent/event-parse.c
> +++ b/tools/lib/traceevent/event-parse.c
> @@ -1939,7 +1939,22 @@ process_op(struct event_format *event, struct print_arg *arg, char **tok)
>  			goto out_warn_free;
>  
>  		type = process_arg_token(event, right, tok, type);
> -		arg->op.right = right;
> +
> +		if (right->type == PRINT_OP &&
> +		    get_op_prio(arg->op.op) < get_op_prio(right->op.op)) {
> +			struct print_arg tmp;
> +
> +			/* swap ops according to the priority */

This isn't really a swap. Better term to use is "rotate".

But other than that,

Acked-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve

> +			arg->op.right = right->op.left;
> +
> +			tmp = *arg;
> +			*arg = *right;
> +			*right = tmp;
> +
> +			arg->op.left = right;
> +		} else {
> +			arg->op.right = right;
> +		}
>  
>  	} else if (strcmp(token, "[") == 0) {
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
