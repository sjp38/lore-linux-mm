Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 619B19000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 16:07:29 -0400 (EDT)
Date: Tue, 26 Apr 2011 13:07:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: (resend) [PATCH] vmscan,memcg: memcg aware swap token
Message-Id: <20110426130724.f2ae18e3.akpm@linux-foundation.org>
In-Reply-To: <20110426170146.F396.A69D9226@jp.fujitsu.com>
References: <20110426170146.F396.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>

On Tue, 26 Apr 2011 16:59:19 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> @@ -75,3 +76,19 @@ void __put_swap_token(struct mm_struct *mm)
>  		swap_token_mm = NULL;
>  	spin_unlock(&swap_token_lock);
>  }
> +
> +int has_swap_token_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
> +{
> +	if (memcg) {
> +		struct mem_cgroup *swap_token_memcg;
> +
> +		/*
> +		 * memcgroup reclaim can disable swap token only if token task
> +		 * is in the same cgroup.
> +		 */
> +		swap_token_memcg = try_get_mem_cgroup_from_mm(swap_token_mm);
> +		return ((mm == swap_token_mm) && (memcg == swap_token_memcg));
> +	} else
> +		return (mm == swap_token_mm);
> +}

Seems to be missing a css_put()?

Either I'm mistaken or that's a bug.  Perhaps neither of these would
have happened if we'd bothered to document
try_get_mem_cgroup_from_mm().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
