Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 3E7436B00F4
	for <linux-mm@kvack.org>; Thu, 24 May 2012 18:12:33 -0400 (EDT)
Date: Thu, 24 May 2012 15:12:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mm: fix faulty initialization in vmalloc_init()
Message-Id: <20120524151231.e3a18ac5.akpm@linux-foundation.org>
In-Reply-To: <001c01cd3987$d1a71a50$74f54ef0$%cho@samsung.com>
References: <001c01cd3987$d1a71a50$74f54ef0$%cho@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KyongHo <pullip.cho@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-samsung-soc@vger.kernel.org

On Thu, 24 May 2012 17:32:56 +0900
KyongHo <pullip.cho@samsung.com> wrote:

> vmalloc_init() adds 'vmap_area's for early 'vm_struct's.
> This patch fixes vmalloc_init() to correctly initialize
> vmap_area for the given vm_struct.
> 

<daily message>
Insufficient information.  When fixing a bug please always always
always describe the user-visible effects of the bug.  Does the kernel
instantly crash?  Is it a comestic cleanliness thing which has no
effect?  Something in between?  I have simply no idea, and am dependent
upon you to tell me.

> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1185,9 +1185,10 @@ void __init vmalloc_init(void)
>  	/* Import existing vmlist entries. */
>  	for (tmp = vmlist; tmp; tmp = tmp->next) {
>  		va = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
> -		va->flags = tmp->flags | VM_VM_AREA;
> +		va->flags = VM_VM_AREA;

This change is a mystery.  Why do we no longer transfer ->flags?

>  		va->va_start = (unsigned long)tmp->addr;
>  		va->va_end = va->va_start + tmp->size;
> +		va->vm = tmp;

OK, I can see how this might be important.  But why did you find it
necessary?  Why was this change actually needed?

>  		__insert_vmap_area(va);
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
