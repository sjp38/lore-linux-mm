Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 954D760080E
	for <linux-mm@kvack.org>; Tue, 10 Aug 2010 11:06:48 -0400 (EDT)
Message-ID: <4C616AB8.2090001@kernel.org>
Date: Tue, 10 Aug 2010 17:05:28 +0200
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] percpu: simplify the pcpu_alloc()
References: <1281452440-22346-1-git-send-email-shijie8@gmail.com>
In-Reply-To: <1281452440-22346-1-git-send-email-shijie8@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/10/2010 05:00 PM, Huang Shijie wrote:
>    The `while' is not needed, replaced it with `if' to reduce
>    an unnecessary check.
> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>
> ---
>  mm/percpu.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/percpu.c b/mm/percpu.c
> index e61dc2c..2e50004 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -724,7 +724,8 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved)
>  			goto fail_unlock;
>  		}
>  
> -		while ((new_alloc = pcpu_need_to_extend(chunk))) {
> +		new_alloc = pcpu_need_to_extend(chunk);
> +		if (new_alloc) {
>  			spin_unlock_irqrestore(&pcpu_lock, flags);
>  			if (pcpu_extend_area_map(chunk, new_alloc) < 0) {
>  				err = "failed to extend area map of reserved chunk";

I'd leave it as is.  The check may be spurious now but if we ever end
up updating locking there to allow allocations from atomic contexts,
that while loop will be needed to check whether race hasn't happened
while the lock was dropped.  This change would just make the code more
fragile without actually gaining anything.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
