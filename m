Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 359289000C2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 14:07:37 -0400 (EDT)
Received: by bwb11 with SMTP id 11so1157321bwb.9
        for <linux-mm@kvack.org>; Thu, 07 Jul 2011 11:07:34 -0700 (PDT)
Date: Thu, 7 Jul 2011 21:07:27 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH] slub: reduce overhead of slub_debug
In-Reply-To: <20110626193918.GA3339@joi.lan>
Message-ID: <alpine.DEB.2.00.1107072106560.6693@tiger>
References: <20110626193918.GA3339@joi.lan>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcin Slusarz <marcin.slusarz@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, LKML <linux-kernel@vger.kernel.org>, rientjes@google.com, linux-mm@kvack.org

On Sun, 26 Jun 2011, Marcin Slusarz wrote:
> slub checks for poison one byte by one, which is highly inefficient
> and shows up frequently as a highest cpu-eater in perf top.
>
> Joining reads gives nice speedup:
>
> (Compiling some project with different options)
>                                 make -j12    make clean
> slub_debug disabled:             1m 27s       1.2 s
> slub_debug enabled:              1m 46s       7.6 s
> slub_debug enabled + this patch: 1m 33s       3.2 s
>
> check_bytes still shows up high, but not always at the top.
>
> Signed-off-by: Marcin Slusarz <marcin.slusarz@gmail.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Matt Mackall <mpm@selenic.com>
> Cc: linux-mm@kvack.org
> ---

Looks good to me. Christoph, David, ?

> mm/slub.c |   36 ++++++++++++++++++++++++++++++++++--
> 1 files changed, 34 insertions(+), 2 deletions(-)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 35f351f..a40ef2d 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -557,10 +557,10 @@ static void init_object(struct kmem_cache *s, void *object, u8 val)
> 		memset(p + s->objsize, val, s->inuse - s->objsize);
> }
>
> -static u8 *check_bytes(u8 *start, unsigned int value, unsigned int bytes)
> +static u8 *check_bytes8(u8 *start, u8 value, unsigned int bytes)
> {
> 	while (bytes) {
> -		if (*start != (u8)value)
> +		if (*start != value)
> 			return start;
> 		start++;
> 		bytes--;
> @@ -568,6 +568,38 @@ static u8 *check_bytes(u8 *start, unsigned int value, unsigned int bytes)
> 	return NULL;
> }
>
> +static u8 *check_bytes(u8 *start, u8 value, unsigned int bytes)
> +{
> +	u64 value64;
> +	unsigned int words, prefix;
> +
> +	if (bytes <= 16)
> +		return check_bytes8(start, value, bytes);
> +
> +	value64 = value | value << 8 | value << 16 | value << 24;
> +	value64 = value64 | value64 << 32;
> +	prefix = 8 - ((unsigned long)start) % 8;
> +
> +	if (prefix) {
> +		u8 *r = check_bytes8(start, value, prefix);
> +		if (r)
> +			return r;
> +		start += prefix;
> +		bytes -= prefix;
> +	}
> +
> +	words = bytes / 8;
> +
> +	while (words) {
> +		if (*(u64 *)start != value64)
> +			return check_bytes8(start, value, 8);
> +		start += 8;
> +		words--;
> +	}
> +
> +	return check_bytes8(start, value, bytes % 8);
> +}
> +
> static void restore_bytes(struct kmem_cache *s, char *message, u8 data,
> 						void *from, void *to)
> {
> -- 
> 1.7.5.3
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
