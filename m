Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 7AE266B13F1
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 05:13:18 -0500 (EST)
Date: Thu, 2 Feb 2012 12:14:10 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] memcg: make threshold index in the right position
Message-ID: <20120202101410.GA12291@shutemov.name>
References: <1328175919-11209-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1328175919-11209-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu, Feb 02, 2012 at 05:45:19PM +0800, Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> Index current_threshold may point to threshold that just equal to
> usage after __mem_cgroup_threshold is triggerd.

I don't see it. Could you describe conditions?

> But after registering
> a new event, it will change (pointing to threshold just below usage).
> So make it consistent here.
> 
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
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

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
