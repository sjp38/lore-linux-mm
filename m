Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B42016B0026
	for <linux-mm@kvack.org>; Mon, 16 May 2011 04:29:44 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2420F3EE081
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:29:41 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F1B9A45DE97
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:29:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CE78445DE91
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:29:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BFF401DB802F
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:29:40 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B7941DB803E
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:29:40 +0900 (JST)
Date: Mon, 16 May 2011 17:22:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] vmscan: implement swap token priority decay
Message-Id: <20110516172258.c7dcd982.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4DCD1913.2090200@jp.fujitsu.com>
References: <4DCD1824.1060801@jp.fujitsu.com>
	<4DCD1913.2090200@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, minchan.kim@gmail.com, riel@redhat.com

On Fri, 13 May 2011 20:42:11 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> While testing for memcg aware swap token, I observed a swap token
> was often grabbed an intermittent running process (eg init, auditd)
> and they never release a token.
> 
> Why? Currently, swap toke priority is only decreased at page fault
> path. Then, if the process sleep immediately after to grab swap
> token, their swap token priority never be decreased. That makes
> obviously undesired result.
> 
> This patch implement very poor (and lightweight) priority decay
> mechanism. It only be affect to the above corner case and doesn't
> change swap tendency workload performance (eg multi process qsbench
> load)
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

But...

> ---
>  include/trace/events/vmscan.h |   12 ++++++++----
>  mm/thrash.c                   |    5 ++++-
>  2 files changed, 12 insertions(+), 5 deletions(-)
> 
> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> index 1798e0c..ba18137 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -366,9 +366,10 @@ DEFINE_EVENT_CONDITION(put_swap_token_template, disable_swap_token,
> 
>  TRACE_EVENT_CONDITION(update_swap_token_priority,
>  	TP_PROTO(struct mm_struct *mm,
> -		 unsigned int old_prio),
> +		 unsigned int old_prio,
> +		 struct mm_struct *swap_token_mm),
> 
> -	TP_ARGS(mm, old_prio),
> +	TP_ARGS(mm, old_prio, swap_token_mm),
> 
>  	TP_CONDITION(mm->token_priority != old_prio),
> 
> @@ -376,16 +377,19 @@ TRACE_EVENT_CONDITION(update_swap_token_priority,
>  		__field(struct mm_struct*, mm)
>  		__field(unsigned int, old_prio)
>  		__field(unsigned int, new_prio)
> +		__field(unsigned int, token_prio)
>  	),
> 
>  	TP_fast_assign(
>  		__entry->mm = mm;
>  		__entry->old_prio = old_prio;
>  		__entry->new_prio = mm->token_priority;
> +		__entry->token_prio = swap_token_mm ? swap_token_mm->token_priority : 0;
>  	),
> 
> -	TP_printk("mm=%p old_prio=%u new_prio=%u",
> -		  __entry->mm, __entry->old_prio, __entry->new_prio)
> +	TP_printk("mm=%p old_prio=%u new_prio=%u token_prio=%u",
> +		  __entry->mm, __entry->old_prio, __entry->new_prio,
> +		  __entry->token_prio)
>  );
> 
>  #endif /* _TRACE_VMSCAN_H */
> diff --git a/mm/thrash.c b/mm/thrash.c
> index 14c6c9f..0c4f0a8 100644
> --- a/mm/thrash.c
> +++ b/mm/thrash.c
> @@ -47,6 +47,9 @@ void grab_swap_token(struct mm_struct *mm)
>  	if (!swap_token_mm)
>  		goto replace_token;
> 
> +	if (!(global_faults & 0xff))
> +		mm->token_priority /= 2;
> +

I personally don't like this kind of checking counter with mask.
Hmm. How about this ?

==
	#define TOKEN_AGE_MASK	~(0xff)
	/*
	 * If current global_fault is in different age from previous global_fault,
	 * Aging priority and starts new era.
	 */
	if ((mm->faultstamp & TOKEN_AGE_MASK) != (global_faults & MM_TOKEN_MASK))
		mm->token_priority /= 2;
==

But I'm not sure 0xff is a proper value or not...

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
