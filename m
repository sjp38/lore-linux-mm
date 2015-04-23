Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id DBB836B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 16:51:08 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so5992956pac.0
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 13:51:08 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id pt7si14177770pdb.96.2015.04.23.13.51.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Apr 2015 13:51:07 -0700 (PDT)
Date: Thu, 23 Apr 2015 13:51:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] mm/slab_common: Support the slub_debug boot option
 on specific object size
Message-Id: <20150423135106.1411031c362de2a5ef75fd50@linux-foundation.org>
In-Reply-To: <1429795560-29131-1-git-send-email-gavin.guo@canonical.com>
References: <1429795560-29131-1-git-send-email-gavin.guo@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Guo <gavin.guo@canonical.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@rasmusvillemoes.dk

On Thu, 23 Apr 2015 21:26:00 +0800 Gavin Guo <gavin.guo@canonical.com> wrote:

> The slub_debug=PU,kmalloc-xx cannot work because in the
> create_kmalloc_caches() the s->name is created after the
> create_kmalloc_cache() is called. The name is NULL in the
> create_kmalloc_cache() so the kmem_cache_flags() would not set the
> slub_debug flags to the s->flags. The fix here set up a kmalloc_names
> string array for the initialization purpose and delete the dynamic
> name creation of kmalloc_caches.

This code is still pretty horrid :(

What's all that stuff fiddling around with size_index[], magic
constants everywhere.  Surely there's some way of making this nice and
clear: table-driven, robust to changes.

> +/*
> + * The KMALLOC_LOOP_LOW is the definition for the for loop index start number
> + * to create the kmalloc_caches object in create_kmalloc_caches(). The first
> + * and the second are 96 and 192. You can see that in the kmalloc_index(), if
> + * the KMALLOC_MIN_SIZE <= 32, then return 1 (96). If KMALLOC_MIN_SIZE <= 64,
> + * then return 2 (192). If the KMALLOC_MIN_SIZE is bigger than 64, we don't
> + * need to initialize 96 and 192. Go directly to start the KMALLOC_SHIFT_LOW.
> + */
> +#if KMALLOC_MIN_SIZE <= 32
> +#define KMALLOC_LOOP_LOW 1
> +#elif KMALLOC_MIN_SIZE <= 64
> +#define KMALLOC_LOOP_LOW 2
> +#else
> +#define KMALLOC_LOOP_LOW KMALLOC_SHIFT_LOW
> +#endif
> +
>  #else
>  #define ARCH_KMALLOC_MINALIGN __alignof__(unsigned long long)
> +/*
> + * The KMALLOC_MIN_SIZE of slub/slab/slob is 2^3/2^5/2^3. So, even slab is used.
> + * The KMALLOC_MIN_SIZE <= 32. The kmalloc-96 and kmalloc-192 should also be
> + * initialized.
> + */
> +#define KMALLOC_LOOP_LOW 1

Hopefully we can remove the above.

>  /*
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 999bb34..05c6439 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -784,6 +784,31 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
>  }
>  
>  /*
> + * The kmalloc_names is to make slub_debug=,kmalloc-xx option work in the boot
> + * time. The kmalloc_index() support to 2^26=64MB. So, the final entry of the
> + * table is kmalloc-67108864.
> + */
> +static struct {
> +	const char *name;
> +	unsigned long size;
> +} const kmalloc_names[] __initconst = {

OK.  This table is __initconst, so the kstrtoul() trick isn't needed.

> +	{NULL,                      0},		{"kmalloc-96",             96},
> +	{"kmalloc-192",           192},		{"kmalloc-8",               8},
> +	{"kmalloc-16",             16},		{"kmalloc-32",             32},
> +	{"kmalloc-64",             64},		{"kmalloc-128",           128},
> +	{"kmalloc-256",           256},		{"kmalloc-512",           512},
> +	{"kmalloc-1024",         1024},		{"kmalloc-2048",         2048},
> +	{"kmalloc-4096",         4096},		{"kmalloc-8192",         8192},
> +	{"kmalloc-16384",       16384},		{"kmalloc-32768",       32768},
> +	{"kmalloc-65536",       65536},		{"kmalloc-131072",     131072},
> +	{"kmalloc-262144",     262144},		{"kmalloc-524288",     524288},
> +	{"kmalloc-1048576",   1048576},		{"kmalloc-2097152",   2097152},
> +	{"kmalloc-4194304",   4194304},		{"kmalloc-8388608",   8388608},
> +	{"kmalloc-16777216", 16777216},		{"kmalloc-33554432", 33554432},
> +	{"kmalloc-67108864", 67108864}
> +};
> +
>
> ...
>
> +		if (i == 2)
> +			i = (KMALLOC_SHIFT_LOW - 1);

Can we get rid of this by using something like

static struct {
	const char *name;
	unsigned long size;
} const kmalloc_names[] __initconst = {
//	{NULL,                      0},
	{"kmalloc-96",             96},
	{"kmalloc-192",           192},
#if KMALLOC_MIN_SIZE <= 8
	{"kmalloc-8",               8},
#endif
#if KMALLOC_MIN_SIZE <= 16
	{"kmalloc-16",             16},
#endif
#if KMALLOC_MIN_SIZE <= 32
	{"kmalloc-32",             32},
#endif
	{"kmalloc-64",             64},
	{"kmalloc-128",           128},
	{"kmalloc-256",           256},
	{"kmalloc-512",           512},
	{"kmalloc-1024",         1024},
	{"kmalloc-2048",         2048},
	{"kmalloc-4096",         4096},
	{"kmalloc-8192",         8192},
	...
};

(remove the zeroeth entry from kmalloc_names)

(rename kmalloc_names to kmalloc_info or something: it now holds more
than names)

and make the initialization loop do

	for (i = 0; i < ARRAY_SIZE(kmalloc_names); i++)
		kmalloc_caches[i] = ...


Why does the initialization code do the

	if (!kmalloc_caches[i]) {

test?  Can any of these really be initialized?  If so, why is it
legitimate for create_kmalloc_caches() to go altering size_index[]
after some caches have already been set up?


If this is all done right, KMALLOC_LOOP_LOW, KMALLOC_SHIFT_LOW and
KMALLOC_SHIFT_HIGH should just go away - we should be able to implement
all the logic using only KMALLOC_MIN_SIZE and MAX_ORDER.


Perhaps the manipulation of size_index[] should be done while we're
initalizing the caches, perhaps driven by additional fields in
kmalloc_info.


Finally, why does create_kmalloc_caches() use GFP_NOWAIT?  We're in
__init code!  Makes no sense.  Or if it *does* make sense, the reason
should be clearly commented.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
