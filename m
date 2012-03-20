Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id AF18C6B0044
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 11:46:24 -0400 (EDT)
Received: by yhr47 with SMTP id 47so239050yhr.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2012 08:46:23 -0700 (PDT)
Date: Tue, 20 Mar 2012 08:46:19 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH 6/6] workqueue: use kmalloc_align() instead of
 hacking
Message-ID: <20120320154619.GA5684@google.com>
References: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com>
 <1332238884-6237-7-git-send-email-laijs@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1332238884-6237-7-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 20, 2012 at 06:21:24PM +0800, Lai Jiangshan wrote:
> kmalloc_align() makes the code simpler.
> 
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> ---
>  kernel/workqueue.c |   23 +++++------------------
>  1 files changed, 5 insertions(+), 18 deletions(-)
> 
> diff --git a/kernel/workqueue.c b/kernel/workqueue.c
> index 5abf42f..beec5fd 100644
> --- a/kernel/workqueue.c
> +++ b/kernel/workqueue.c
> @@ -2897,20 +2897,9 @@ static int alloc_cwqs(struct workqueue_struct *wq)
>  
>  	if (!(wq->flags & WQ_UNBOUND))
>  		wq->cpu_wq.pcpu = __alloc_percpu(size, align);
> -	else {
> -		void *ptr;
> -
> -		/*
> -		 * Allocate enough room to align cwq and put an extra
> -		 * pointer at the end pointing back to the originally
> -		 * allocated pointer which will be used for free.
> -		 */
> -		ptr = kzalloc(size + align + sizeof(void *), GFP_KERNEL);
> -		if (ptr) {
> -			wq->cpu_wq.single = PTR_ALIGN(ptr, align);
> -			*(void **)(wq->cpu_wq.single + 1) = ptr;
> -		}
> -	}
> +	else
> +		wq->cpu_wq.single = kmalloc_align(size,
> +				GFP_KERNEL | __GFP_ZERO, align);
>  
>  	/* just in case, make sure it's actually aligned */
>  	BUG_ON(!IS_ALIGNED(wq->cpu_wq.v, align));
> @@ -2921,10 +2910,8 @@ static void free_cwqs(struct workqueue_struct *wq)
>  {
>  	if (!(wq->flags & WQ_UNBOUND))
>  		free_percpu(wq->cpu_wq.pcpu);
> -	else if (wq->cpu_wq.single) {
> -		/* the pointer to free is stored right after the cwq */
> -		kfree(*(void **)(wq->cpu_wq.single + 1));
> -	}
> +	else if (wq->cpu_wq.single)
> +		kfree(wq->cpu_wq.single);

Yes, this is hacky but I don't think building the whole
kmalloc_align() for only this is a good idea.  If the open coded hack
bothers you just write a simplistic wrapper somewhere.  We can make
that better integrated / more efficient when there are multiple users
of the interface, which I kinda doubt would happen.  The reason why
cwq requiring larger alignment is more historic than anything else
after all.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
