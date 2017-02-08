Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id A06AF6B0038
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 16:54:06 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id 101so3167910iom.7
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 13:54:06 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u91si8186425plb.142.2017.02.08.13.54.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 13:54:05 -0800 (PST)
Date: Wed, 8 Feb 2017 13:54:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, slab: rename kmalloc-node cache to kmalloc-<size>
Message-Id: <20170208135404.fa003c62eb6b75cefbe13d49@linux-foundation.org>
In-Reply-To: <d3a1f708-efdd-98c3-9c26-dab600501679@suse.cz>
References: <20170203181008.24898-1-vbabka@suse.cz>
	<201702080139.e2GzXRQt%fengguang.wu@intel.com>
	<20170207133839.f6b1f1befe4468770991f5e0@linux-foundation.org>
	<d3a1f708-efdd-98c3-9c26-dab600501679@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>

On Wed, 8 Feb 2017 10:12:13 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:

> On 02/07/2017 10:38 PM, Andrew Morton wrote:
> > On Wed, 8 Feb 2017 01:15:17 +0800 kbuild test robot <lkp@intel.com> wrote:
> > 
> >> Hi Vlastimil,
> >> 
> >> [auto build test WARNING on mmotm/master]
> >> [also build test WARNING on v4.10-rc7 next-20170207]
> >> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> >> 
> >> url:    https://github.com/0day-ci/linux/commits/Vlastimil-Babka/mm-slab-rename-kmalloc-node-cache-to-kmalloc-size/20170204-021843
> >> base:   git://git.cmpxchg.org/linux-mmotm.git master
> >> config: arm-allyesconfig (attached as .config)
> >> compiler: arm-linux-gnueabi-gcc (Debian 6.1.1-9) 6.1.1 20160705
> >> reproduce:
> >>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
> >>         chmod +x ~/bin/make.cross
> >>         # save the attached .config to linux build tree
> >>         make.cross ARCH=arm 
> >> 
> >> All warnings (new ones prefixed by >>):
> >> 
> >> >> WARNING: mm/built-in.o(.text+0x3b49c): Section mismatch in reference from the function get_kmalloc_cache_name() to the (unknown reference) .init.rodata:(unknown)
> >>    The function get_kmalloc_cache_name() references
> >>    the (unknown reference) __initconst (unknown).
> >>    This is often because get_kmalloc_cache_name lacks a __initconst
> >>    annotation or the annotation of (unknown) is wrong.
> > 
> > yup, thanks.
> 
> Thanks for the fix.
> 
> I was going to implement Christoph's suggestion and export the whole structure
> in mm/slab.h, but gcc was complaining that I'm redefining it, until I created a
> typedef first. Is it worth the trouble? Below is how it would look like.
> 
> ...
>
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -71,6 +71,13 @@ extern struct list_head slab_caches;
>  /* The slab cache that manages slab cache information */
>  extern struct kmem_cache *kmem_cache;
>  
> +/* A table of kmalloc cache names and sizes */
> +typedef struct {
> +	const char *name;
> +	unsigned long size;
> +} kmalloc_info_t;
> +extern const kmalloc_info_t kmalloc_info[];

Why is the typedef needed?  Can't we use something like

extern const struct kmalloc_info_struct {
	const char *name;
	unsigned long size;
} kmalloc_info[];

...

const struct kmalloc_info_struct kmalloc_info[] __initconst = {
 	{NULL,                      0},		{"kmalloc-96",             96},
 	{"kmalloc-192",           192},		{"kmalloc-8",               8},
 	{"kmalloc-16",             16},		{"kmalloc-32",             32},
	...
	{"kmalloc-67108864", 67108864}
};

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
