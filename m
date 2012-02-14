Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 2D9F46B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 02:31:08 -0500 (EST)
Received: by lbbgg6 with SMTP id gg6so3928189lbb.14
        for <linux-mm@kvack.org>; Mon, 13 Feb 2012 23:31:06 -0800 (PST)
Date: Tue, 14 Feb 2012 09:31:01 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH] slab: warning if total alloc size overflow
In-Reply-To: <1329204499-2671-1-git-send-email-hamo.by@gmail.com>
Message-ID: <alpine.LFD.2.02.1202140929040.2721@tux.localdomain>
References: <1329204499-2671-1-git-send-email-hamo.by@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Bai <hamo.by@gmail.com>
Cc: cl@linux-foundation.org, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Tue, 14 Feb 2012, Yang Bai wrote:
> Before, if the total alloc size is overflow,
> we just return NULL like alloc fail. But they
> are two different type problems. The former looks
> more like a programming problem. So add a warning
> here.
>
> Signed-off-by: Yang Bai <hamo.by@gmail.com>
> ---
> include/linux/slab.h |    4 +++-
> 1 files changed, 3 insertions(+), 1 deletions(-)
>
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 573c809..5865237 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -242,8 +242,10 @@ size_t ksize(const void *);
>  */
> static inline void *kcalloc(size_t n, size_t size, gfp_t flags)
> {
> -	if (size != 0 && n > ULONG_MAX / size)
> +	if (size != 0 && n > ULONG_MAX / size) {
> +		WARN(1, "Alloc memory size (%lu * %lu) overflow.", n, size);
> 		return NULL;
> +	}
> 	return __kmalloc(n * size, flags | __GFP_ZERO);
> }

Did you check how much kernel text size increases? I'm pretty sure we'd 
need to wrap this with CONFIG_SLAB_OVERFLOW ifdef.

 			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
