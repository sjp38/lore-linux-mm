Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 8EF636B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 05:45:33 -0400 (EDT)
Message-ID: <508515B4.1090303@parallels.com>
Date: Mon, 22 Oct 2012 13:45:24 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: CK2 [07/15] Common kmalloc slab index determination
References: <20121019142254.724806786@linux.com> <0000013a798237ec-faa35541-43fa-4257-b7dc-da955393004f-000000@email.amazonses.com>
In-Reply-To: <0000013a798237ec-faa35541-43fa-4257-b7dc-da955393004f-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On 10/19/2012 06:51 PM, Christoph Lameter wrote:
> Extract the function to determine the index of the slab within
> the array of kmalloc caches as well as a function to determine
> maximum object size from the nr of the kmalloc slab.
> 
> This is used here only to simplify slub bootstrap but will
> be used later also for SLAB.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com> 
> 

> +static __always_inline int kmalloc_index(size_t size)
> +{
> +	if (!size)
> +		return 0;
> +
> +	if (size <= KMALLOC_MIN_SIZE)
> +		return KMALLOC_SHIFT_LOW;
> +
> +	if (KMALLOC_MIN_SIZE <= 32 && size > 64 && size <= 96)
> +		return 1;
> +	if (KMALLOC_MIN_SIZE <= 64 && size > 128 && size <= 192)
> +		return 2;
> +	if (size <=          8) return 3;
> +	if (size <=         16) return 4;
> +	if (size <=         32) return 5;
> +	if (size <=         64) return 6;
> +	if (size <=        128) return 7;
> +	if (size <=        256) return 8;
> +	if (size <=        512) return 9;
> +	if (size <=       1024) return 10;
> +	if (size <=   2 * 1024) return 11;
> +	if (size <=   4 * 1024) return 12;
> +	if (size <=   8 * 1024) return 13;
> +	if (size <=  16 * 1024) return 14;
> +	if (size <=  32 * 1024) return 15;
> +	if (size <=  64 * 1024) return 16;
> +	if (size <= 128 * 1024) return 17;
> +	if (size <= 256 * 1024) return 18;
> +	if (size <= 512 * 1024) return 19;
> +	if (size <= 1024 * 1024) return 20;
> +	if (size <=  2 * 1024 * 1024) return 21;
> +	if (size <=  4 * 1024 * 1024) return 22;
> +	if (size <=  8 * 1024 * 1024) return 23;
> +	if (size <=  16 * 1024 * 1024) return 24;
> +	if (size <=  32 * 1024 * 1024) return 25;
> +	if (size <=  64 * 1024 * 1024) return 26;
> +	BUG();
> +
> +	/* Will never be reached. Needed because the compiler may complain */
> +	return -1;
> +}
> +

It is still unclear to me if the above is really better than
ilog2(size -1) + 1

For that case, gcc seems to generate dec + brs + inc which at some point
will be faster than walking a jump table. At least for dynamically-sized
allocations. The code size is definitely smaller, and this is always
inline... Anyway, this is totally separate.

The patch also seem to have some churn for the slob for no reason: you
have a patch just to move the kmalloc definitions, would maybe be better
to do it in there to decrease the # of changes in this one, which is
more complicated.

The change itself looks fine.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
