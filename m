Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B11256B0253
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 10:59:34 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id i130so16601833pgc.5
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 07:59:34 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q84si4097323pfl.535.2017.09.25.07.59.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 07:59:33 -0700 (PDT)
Date: Mon, 25 Sep 2017 07:59:32 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 1/2] xxHash: create arch dependent 32/64-bit xxhash()
Message-ID: <20170925145932.GA17029@bombadil.infradead.org>
References: <20170921231818.10271-1-nefelim4ag@gmail.com>
 <20170921231818.10271-2-nefelim4ag@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170921231818.10271-2-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <nefelim4ag@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 22, 2017 at 02:18:17AM +0300, Timofey Titovets wrote:
> diff --git a/include/linux/xxhash.h b/include/linux/xxhash.h
> index 9e1f42cb57e9..195a0ae10e9b 100644
> --- a/include/linux/xxhash.h
> +++ b/include/linux/xxhash.h
> @@ -76,6 +76,7 @@
>  #define XXHASH_H
> 
>  #include <linux/types.h>
> +#include <linux/bitops.h> /* BITS_PER_LONG */
> 
>  /*-****************************
>   * Simple Hash Functions

Huh?  linux/types.h already brings in BITS_PER_LONG.  Look:

linux/types.h
  uapi/linux/types.h
  uapi/asm/types.h
  uapi/asm-generic/types.h
  uapi/asm-generic/int-ll64.h
  asm/bitsperlong.h

> @@ -107,6 +108,29 @@ uint32_t xxh32(const void *input, size_t length, uint32_t seed);
>   */
>  uint64_t xxh64(const void *input, size_t length, uint64_t seed);
> 
> +#if BITS_PER_LONG == 64
> +typedef	u64	xxhash_t;
> +#else
> +typedef	u32	xxhash_t;
> +#endif

This is a funny way to spell 'unsigned long' ...

> +/**
> + * xxhash() - calculate 32/64-bit hash based on cpu word size
> + *
> + * @input:  The data to hash.
> + * @length: The length of the data to hash.
> + * @seed:   The seed can be used to alter the result predictably.
> + *
> + * This function always work as xxh32() for 32-bit systems
> + * and as xxh64() for 64-bit systems.
> + * Because result depends on cpu work size,
> + * the main proporse of that function is for  in memory hashing.
> + *
> + * Return:  32/64-bit hash of the data.
> + */
> +

> +xxhash_t xxhash(const void *input, size_t length, uint64_t seed)
> +{
> +#if BITS_PER_LONG == 64
> +	return xxh64(input, length, seed);
> +#else
> +	return xxh32(input, length, seed);
> +#endif
> +}

Let's move that to the header file and make it a static inline.  That way
it doesn't need to be an EXPORT_SYMBOL.

Also, I think the kerneldoc could do with a bit of work.  Try this:

/**
 * xxhash() - calculate wordsize hash of the input with a given seed
 * @input:  The data to hash.
 * @length: The length of the data to hash.
 * @seed:   The seed can be used to alter the result predictably.
 *
 * If the hash does not need to be comparable between machines with
 * different word sizes, this function will call whichever of xxh32()
 * or xxh64() is faster.
 *
 * Return:  wordsize hash of the data.
 */
static inline
unsigned long xxhash(const void *input, size_t length, unsigned long seed)
{
#if BITS_PER_LONG == 64
	return xxh64(input, length, seed);
#else
	return xxh32(input, length, seed);
#endif
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
