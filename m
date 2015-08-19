Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id C11BB6B0038
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 10:02:10 -0400 (EDT)
Received: by wijp15 with SMTP id p15so127788226wij.0
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 07:02:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fl7si5757837wib.61.2015.08.19.07.02.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Aug 2015 07:02:09 -0700 (PDT)
Subject: Re: [PATCH] zswap: update docs for runtime-changeable attributes
References: <1439924830-29275-1-git-send-email-ddstreet@ieee.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55D48C5E.7010004@suse.cz>
Date: Wed, 19 Aug 2015 16:02:06 +0200
MIME-Version: 1.0
In-Reply-To: <1439924830-29275-1-git-send-email-ddstreet@ieee.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>, Jonathan Corbet <corbet@lwn.net>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08/18/2015 09:07 PM, Dan Streetman wrote:
> Change the Documentation/vm/zswap.txt doc to indicate that the "zpool"
> and "compressor" params are now changeable at runtime.
> 
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> ---
>  Documentation/vm/zswap.txt | 31 +++++++++++++++++++++++--------
>  1 file changed, 23 insertions(+), 8 deletions(-)
> 
> diff --git a/Documentation/vm/zswap.txt b/Documentation/vm/zswap.txt
> index 8458c08..06f7ce2 100644
> --- a/Documentation/vm/zswap.txt
> +++ b/Documentation/vm/zswap.txt
> @@ -32,7 +32,7 @@ can also be enabled and disabled at runtime using the sysfs interface.
>  An example command to enable zswap at runtime, assuming sysfs is mounted
>  at /sys, is:
>  
> -echo 1 > /sys/modules/zswap/parameters/enabled
> +echo 1 > /sys/module/zswap/parameters/enabled
>  
>  When zswap is disabled at runtime it will stop storing pages that are
>  being swapped out.  However, it will _not_ immediately write out or fault
> @@ -49,14 +49,27 @@ Zswap receives pages for compression through the Frontswap API and is able to
>  evict pages from its own compressed pool on an LRU basis and write them back to
>  the backing swap device in the case that the compressed pool is full.
>  
> -Zswap makes use of zbud for the managing the compressed memory pool.  Each
> -allocation in zbud is not directly accessible by address.  Rather, a handle is
> +Zswap makes use of zpool for the managing the compressed memory pool.  Each
> +allocation in zpool is not directly accessible by address.  Rather, a handle is
>  returned by the allocation routine and that handle must be mapped before being
>  accessed.  The compressed memory pool grows on demand and shrinks as compressed
> -pages are freed.  The pool is not preallocated.
> +pages are freed.  The pool is not preallocated.  By default, a zpool of type
> +zbud is created, but it can be selected at boot time by setting the "zpool"
> +attribute, e.g. zswap.zpool=zbud.  It can also be changed at runtime using the
> +sysfs "zpool" attribute, e.g.
> +
> +echo zbud > /sys/module/zswap/parameters/zpool

What exactly happens if zswap is already being used and has allocated pages in
one type of pool, and you're changing it to the other one?

> +
> +The zbud type zpool allocates exactly 1 page to store 2 compressed pages, which
> +means the compression ratio will always be exactly 2:1 (not including half-full
> +zbud pages), and any page that compresses to more than 1/2 page in size will be
> +rejected (and written to the swap disk).

Hm is this correct? I've been going through the zbud code briefly (as of Linus'
tree) and it seems to me that it will accept pages larger than 1/2, but they
will sit in the unbuddied list until a small enough "buddy" comes.

> The zsmalloc type zpool has a more
> +complex compressed page storage method, and it can achieve greater storage
> +densities.  However, zsmalloc does not implement compressed page eviction, so
> +once zswap fills it cannot evict the oldest page, it can only reject new pages.

I still wonder why anyone would use zsmalloc with zswap given this limitation.
It seems only fine for zram which has no real swap as fallback. And even zbud
doesn't have any shrinker interface that would react to memory pressure, so
there's a possibility of premature OOM... sigh.

>  When a swap page is passed from frontswap to zswap, zswap maintains a mapping
> -of the swap entry, a combination of the swap type and swap offset, to the zbud
> +of the swap entry, a combination of the swap type and swap offset, to the zpool
>  handle that references that compressed swap page.  This mapping is achieved
>  with a red-black tree per swap type.  The swap offset is the search key for the
>  tree nodes.
> @@ -74,9 +87,11 @@ controlled policy:
>  * max_pool_percent - The maximum percentage of memory that the compressed
>      pool can occupy.
>  
> -Zswap allows the compressor to be selected at kernel boot time by setting the
> -a??compressora?? attribute.  The default compressor is lzo.  e.g.
> -zswap.compressor=deflate
> +The default compressor is lzo, but it can be selected at boot time by setting
> +the a??compressora?? attribute, e.g. zswap.compressor=lzo.  It can also be changed
> +at runtime using the sysfs "compressor" attribute, e.g.
> +
> +echo lzo > /sys/module/zswap/parameters/compressor

Again, what happens to pages already compressed? Are they freed? Recompressed?
Does zswap remember it has to decompress them differently than the currently
used compressor?

>  A debugfs interface is provided for various statistic about pool size, number
>  of pages stored, and various counters for the reasons pages are rejected.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
