Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9C5916B00AA
	for <linux-mm@kvack.org>; Sat,  6 Nov 2010 11:00:34 -0400 (EDT)
Message-ID: <4CD56D94.2000806@cs.helsinki.fi>
Date: Sat, 06 Nov 2010 17:00:36 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 6/7] mm: Convert sprintf_symbol to %pS
References: <1288998760-11775-1-git-send-email-joe@perches.com> <1288998760-11775-7-git-send-email-joe@perches.com>
In-Reply-To: <1288998760-11775-7-git-send-email-joe@perches.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Joe Perches <joe@perches.com>
Cc: Jiri Kosina <trivial@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 6.11.2010 1.12, Joe Perches wrote:
> Signed-off-by: Joe Perches<joe@perches.com>

Acked-by: Pekka Enberg <penberg@kernel.org>

I think this ought to go through Andrew's tree rather than the trivial tree.

> ---
>   mm/slub.c    |   11 ++++-------
>   mm/vmalloc.c |    9 ++-------
>   2 files changed, 6 insertions(+), 14 deletions(-)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 8fd5401..43b3857 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3660,7 +3660,7 @@ static int list_locations(struct kmem_cache *s, char *buf,
>   		len += sprintf(buf + len, "%7ld ", l->count);
>
>   		if (l->addr)
> -			len += sprint_symbol(buf + len, (unsigned long)l->addr);
> +			len += sprintf(buf + len, "%pS", (void *)l->addr);
>   		else
>   			len += sprintf(buf + len, "<not-available>");
>
> @@ -3969,12 +3969,9 @@ SLAB_ATTR(min_partial);
>
>   static ssize_t ctor_show(struct kmem_cache *s, char *buf)
>   {
> -	if (s->ctor) {
> -		int n = sprint_symbol(buf, (unsigned long)s->ctor);
> -
> -		return n + sprintf(buf + n, "\n");
> -	}
> -	return 0;
> +	if (!s->ctor)
> +		return 0;
> +	return sprintf(buf, "%pS\n", s->ctor);
>   }
>   SLAB_ATTR_RO(ctor);
>
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index a3d66b3..b7e18f6 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2450,13 +2450,8 @@ static int s_show(struct seq_file *m, void *p)
>   	seq_printf(m, "0x%p-0x%p %7ld",
>   		v->addr, v->addr + v->size, v->size);
>
> -	if (v->caller) {
> -		char buff[KSYM_SYMBOL_LEN];
> -
> -		seq_putc(m, ' ');
> -		sprint_symbol(buff, (unsigned long)v->caller);
> -		seq_puts(m, buff);
> -	}
> +	if (v->caller)
> +		seq_printf(m, " %pS", v->caller);
>
>   	if (v->nr_pages)
>   		seq_printf(m, " pages=%d", v->nr_pages);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
