Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 26B5F6B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 05:56:01 -0400 (EDT)
Received: by lbbzk7 with SMTP id zk7so9316408lbb.0
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 02:56:00 -0700 (PDT)
Received: from mail-la0-x233.google.com (mail-la0-x233.google.com. [2a00:1450:4010:c03::233])
        by mx.google.com with ESMTPS id rm3si5650135lbb.5.2015.04.23.02.55.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Apr 2015 02:55:58 -0700 (PDT)
Received: by laat2 with SMTP id t2so8866361laa.1
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 02:55:58 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH v2] mm/slab_common: Support the slub_debug boot option on specific object size
References: <1429691618-13884-1-git-send-email-gavin.guo@canonical.com>
Date: Thu, 23 Apr 2015 11:55:56 +0200
In-Reply-To: <1429691618-13884-1-git-send-email-gavin.guo@canonical.com>
	(Gavin Guo's message of "Wed, 22 Apr 2015 16:33:38 +0800")
Message-ID: <87egnbmamr.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Guo <gavin.guo@canonical.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 22 2015, Gavin Guo <gavin.guo@canonical.com> wrote:

>  	/*
> +	 * The kmalloc_names is for temporary usage to make
> +	 * slub_debug=,kmalloc-xx option work in the boot time. The
> +	 * kmalloc_index() support to 2^26=64MB. So, the final entry of the
> +	 * table is kmalloc-67108864.
> +	 */
> +	static const char *kmalloc_names[] = {

The array itself could be const, but more importantly it should be
marked __initconst so that the 27*sizeof(char*) bytes can be released after init.

> +		"0",			"kmalloc-96",		"kmalloc-192",
> +		"kmalloc-8",		"kmalloc-16",		"kmalloc-32",
> +		"kmalloc-64",		"kmalloc-128",		"kmalloc-256",
> +		"kmalloc-512",		"kmalloc-1024",		"kmalloc-2048",
> +		"kmalloc-4196",		"kmalloc-8192",		"kmalloc-16384",

"kmalloc-4096"

> +		"kmalloc-32768",	"kmalloc-65536",
> +		"kmalloc-131072",	"kmalloc-262144",
> +		"kmalloc-524288",	"kmalloc-1048576",
> +		"kmalloc-2097152",	"kmalloc-4194304",
> +		"kmalloc-8388608",	"kmalloc-16777216",
> +		"kmalloc-33554432",	"kmalloc-67108864"
> +	};

On Wed, Apr 22 2015, Andrew Morton <akpm@linux-foundation.org> wrote:

> You could do something like
>
> 		kmalloc_caches[i] = create_kmalloc_cache(
> 					kmalloc_names[i],
> 					kstrtoul(kmalloc_names[i] + 8),
> 					flags);
>
> here, and remove those weird "96" and "192" cases.

Eww. At least spell 8 as strlen("kmalloc-").

> Or if that's considered too messy, make it
>
> 	static const struct {
> 		const char *name;
> 		unsigned size;
> 	} kmalloc_cache_info[] = {
> 		{ NULL, 0 },
> 		{ "kmalloc-96", 96 },
> 		...
> 	};

I'd vote for this color for the bikeshed :-)

Rasmus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
