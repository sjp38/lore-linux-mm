Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4B0626B00EE
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 10:38:44 -0400 (EDT)
Date: Mon, 15 Aug 2011 09:38:40 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] slub: name kmalloc slabs at creation time
In-Reply-To: <1312839071-18064-1-git-send-email-malchev@google.com>
Message-ID: <alpine.DEB.2.00.1108150934590.24941@router.home>
References: <1312839071-18064-1-git-send-email-malchev@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Iliyan Malchev <malchev@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 8 Aug 2011, Iliyan Malchev wrote:

> This patch reserves a small static array to hold the names of the kmalloc
> slabs, and uses a small helper function __uitoa (unsigned integer to ascii) to
> format names as appropriately

simple_strtoull etc is not satisfactory?

> +/* Convert a positive integer to its decimal string representation, starting at
> + * the end of the buffer and going backwards, not exceeding maxlen characters.
> + */
> +static __init char *__pos_int_to_string(unsigned int value, char* string,
> +					int maxindex, int maxlen)
> +{
> +	int i = maxindex - 1;
> +	string[maxindex] = 0;
> +	for (; value && i && maxlen; i--, maxlen--, value /= 10)
> +		string[i] = '0' + (value % 10);
> +	return string + i + 1;
> +}

Please use the standard string operations of the kernel.

> @@ -3652,8 +3671,15 @@ void __init kmem_cache_init(void)
>  		caches++;
>  	}
>
> +	name_start = kmalloc_cache_names;
>  	for (i = KMALLOC_SHIFT_LOW; i < SLUB_PAGE_SHIFT; i++) {
> -		kmalloc_caches[i] = create_kmalloc_cache("kmalloc", 1 << i, 0);
> +		char *name = __pos_int_to_string(1 << i, name_start,
> +					KMALLOC_NAME_MAX - 1,
> +					KMALLOC_NAME_SUFFIX_MAX);
> +		name -= 8;

8 is what? The length of "kmalloc-" right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
