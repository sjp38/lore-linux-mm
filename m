Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1C8C29000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 06:16:07 -0400 (EDT)
Date: Wed, 27 Apr 2011 13:11:30 +0300
From: Phil Carmody <ext-phil.2.carmody@nokia.com>
Subject: Re: [PATCH] kmemleak: Never return a pointer you didn't 'get'
Message-ID: <20110427101129.GA5763@esdhcp04044.research.nokia.com>
References: <1303385972-2518-1-git-send-email-ext-phil.2.carmody@nokia.com> <1303896680.15101.1.camel@e102109-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1303896680.15101.1.camel@e102109-lin.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ext Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 27/04/11 10:31 +0100, ext Catalin Marinas wrote:
> On Thu, 2011-04-21 at 12:39 +0100, Phil Carmody wrote:
> > Old - If you don't get the last pointer that you looked at, then it will
> > still be put, as there's no way of knowing you didn't get it.
> > 
> > New - If you didn't get it, then it refers to something deleted, and
> > your work is done, so return NULL.
> > 
> > Signed-off-by: Phil Carmody <ext-phil.2.carmody@nokia.com>
> 
> Good catch. But I think the code may look slightly simpler as below:
> 
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index c1d5867..aacee45 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -1414,9 +1414,12 @@ static void *kmemleak_seq_next(struct seq_file *seq, void *v, loff_t *pos)
>  	++(*pos);
>  
>  	list_for_each_continue_rcu(n, &object_list) {
> -		next_obj = list_entry(n, struct kmemleak_object, object_list);
> -		if (get_object(next_obj))
> +		struct kmemleak_object *obj =
> +			list_entry(n, struct kmemleak_object, object_list);
> +		if (get_object(obj)) {
> +			next_obj = obj;
>  			break;
> +		}
>  	}
>  
>  	put_object(prev_obj);

I did consider that way too, but had no strong preference. I think I now
prefer yours, so please add:

Signed-off-by: Phil Carmody <ext-phil.2.carmody@nokia.com>

Cheers,
Phil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
