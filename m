Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 8DBC26B0022
	for <linux-mm@kvack.org>; Thu, 26 May 2011 16:36:12 -0400 (EDT)
Date: Thu, 26 May 2011 13:35:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/3] vmscan,memcg: memcg aware swap token
Message-Id: <20110526133551.8c158f1c.akpm@linux-foundation.org>
In-Reply-To: <4DD480DD.2040307@jp.fujitsu.com>
References: <4DD480DD.2040307@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com

On Thu, 19 May 2011 11:30:53 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Currently, memcg reclaim can disable swap token even if the swap token
> mm doesn't belong in its memory cgroup. It's slightly risky. If an
> admin creates very small mem-cgroup and silly guy runs contentious heavy
> memory pressure workload, every tasks are going to lose swap token and
> then system may become unresponsive. That's bad.
> 
> This patch adds 'memcg' parameter into disable_swap_token(). and if
> the parameter doesn't match swap token, VM doesn't disable it.
> 
>
> ...
>
> --- a/mm/thrash.c
> +++ b/mm/thrash.c
> @@ -21,14 +21,17 @@
>  #include <linux/mm.h>
>  #include <linux/sched.h>
>  #include <linux/swap.h>
> +#include <linux/memcontrol.h>
> 
>  static DEFINE_SPINLOCK(swap_token_lock);
>  struct mm_struct *swap_token_mm;
> +struct mem_cgroup *swap_token_memcg;
>  static unsigned int global_faults;
> 
>  void grab_swap_token(struct mm_struct *mm)
>  {
>  	int current_interval;
> +	struct mem_cgroup *memcg;
> 
>  	global_faults++;
> 
> @@ -38,40 +41,72 @@ void grab_swap_token(struct mm_struct *mm)
>  		return;
> 
>  	/* First come first served */
> -	if (swap_token_mm == NULL) {
> -		mm->token_priority = mm->token_priority + 2;
> -		swap_token_mm = mm;
> +	if (!swap_token_mm)
> +		goto replace_token;
> +
> +	if (mm == swap_token_mm) {
> +		mm->token_priority += 2;
>  		goto out;
>  	}
> 
> -	if (mm != swap_token_mm) {
> -		if (current_interval < mm->last_interval)
> -			mm->token_priority++;
> -		else {
> -			if (likely(mm->token_priority > 0))
> -				mm->token_priority--;
> -		}
> -		/* Check if we deserve the token */
> -		if (mm->token_priority > swap_token_mm->token_priority) {
> -			mm->token_priority += 2;
> -			swap_token_mm = mm;
> -		}
> -	} else {
> -		/* Token holder came in again! */
> -		mm->token_priority += 2;
> +	if (current_interval < mm->last_interval)
> +		mm->token_priority++;
> +	else {
> +		if (likely(mm->token_priority > 0))
> +			mm->token_priority--;
>  	}
> 
> +	/* Check if we deserve the token */
> +	if (mm->token_priority > swap_token_mm->token_priority)
> +		goto replace_token;
> +
>  out:
>  	mm->faultstamp = global_faults;
>  	mm->last_interval = current_interval;
>  	spin_unlock(&swap_token_lock);
> +	return;
> +
> +replace_token:
> +	mm->token_priority += 2;
> +	memcg = try_get_mem_cgroup_from_mm(mm);
> +	if (memcg)
> +		css_put(mem_cgroup_css(memcg));
> +	swap_token_mm = mm;
> +	swap_token_memcg = memcg;
> +	goto out;
>  }

CONFIG_CGROUPS=n:

mm/thrash.c: In function 'grab_swap_token':
mm/thrash.c:73: error: implicit declaration of function 'css_put'

I don't think that adding a null stub for css_put() is the right fix
here...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
