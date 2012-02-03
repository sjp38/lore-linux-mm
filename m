Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 2D2656B13F1
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 20:36:58 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 10A3E3EE0C1
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 10:36:56 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EAD8E45DEF2
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 10:36:55 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D0A6545DEF0
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 10:36:55 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C44171DB803E
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 10:36:55 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B4F41DB803C
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 10:36:55 +0900 (JST)
Date: Fri, 3 Feb 2012 10:35:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: make threshold index in the right position
Message-Id: <20120203103530.417b7d9c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1328175919-11209-1-git-send-email-handai.szj@taobao.com>
References: <1328175919-11209-1-git-send-email-handai.szj@taobao.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Thu,  2 Feb 2012 17:45:19 +0800
Sha Zhengju <handai.szj@gmail.com> wrote:

> From: Sha Zhengju <handai.szj@taobao.com>
> 
> Index current_threshold may point to threshold that just equal to
> usage after __mem_cgroup_threshold is triggerd. But after registering
> a new event, it will change (pointing to threshold just below usage).
> So make it consistent here.
> 
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>

Could you add the explanation you did to Kirill into the patch description ?

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Thanks,
-Kame


> ---
>  mm/memcontrol.c |    7 ++++---
>  1 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 22d94f5..79f4a58 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -183,7 +183,7 @@ struct mem_cgroup_threshold {
>  
>  /* For threshold */
>  struct mem_cgroup_threshold_ary {
> -	/* An array index points to threshold just below usage. */
> +	/* An array index points to threshold just below or equal to usage. */
>  	int current_threshold;
>  	/* Size of entries[] */
>  	unsigned int size;
> @@ -4319,14 +4319,15 @@ static int mem_cgroup_usage_register_event(struct cgroup *cgrp,
>  	/* Find current threshold */
>  	new->current_threshold = -1;
>  	for (i = 0; i < size; i++) {
> -		if (new->entries[i].threshold < usage) {
> +		if (new->entries[i].threshold <= usage) {
>  			/*
>  			 * new->current_threshold will not be used until
>  			 * rcu_assign_pointer(), so it's safe to increment
>  			 * it here.
>  			 */
>  			++new->current_threshold;
> -		}
> +		} else
> +			break;
>  	}
>  
>  	/* Free old spare buffer and save old primary buffer as spare */
> -- 
> 1.7.4.1
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
