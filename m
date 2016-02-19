Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id AFDF56B0009
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 00:36:59 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id c10so46304968pfc.2
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 21:36:59 -0800 (PST)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id 68si14222353pfj.77.2016.02.18.21.36.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 21:36:58 -0800 (PST)
Received: by mail-pa0-x234.google.com with SMTP id fl4so44281908pad.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 21:36:58 -0800 (PST)
Date: Fri, 19 Feb 2016 14:38:14 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC PATCH 3/3] mm/zsmalloc: change ZS_MAX_PAGES_PER_ZSPAGE
Message-ID: <20160219053814.GB16230@swordfish>
References: <1455764556-13979-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1455764556-13979-4-git-send-email-sergey.senozhatsky@gmail.com>
 <CAAmzW4O-yQ5GBTE-6WvCL-hZeqyW=k3Fzn4_9G2qkMmp=ceuJg@mail.gmail.com>
 <20160218095536.GA503@swordfish>
 <20160218101909.GB503@swordfish>
 <CAAmzW4NQt4jD2q92Hh4XFzt5fV=-i3J9eoxS3now6Y4Xw7OqGg@mail.gmail.com>
 <20160219041601.GA820@swordfish>
 <20160219044604.GA16230@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160219044604.GA16230@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (02/19/16 13:46), Sergey Senozhatsky wrote:
> On (02/19/16 13:16), Sergey Senozhatsky wrote:
> > ok, this sets us on a  "do we need 32 and 48 bytes classes at all"  track?
> > 
> 
> seems that lz4 defines a minimum length to be at least
> 
>  61 #define COPYLENGTH 8
>  67 #define MINMATCH        4
>  70 #define MFLIMIT         (COPYLENGTH + MINMATCH)
>  71 #define MINLENGTH       (MFLIMIT + 1)
> 
> bytes.

hm, on a second look, zsmalloc defines the following macros:

#define ZS_MAX_ZSPAGE_ORDER 2
#define ZS_MAX_PAGES_PER_ZSPAGE (_AC(1, UL) << ZS_MAX_ZSPAGE_ORDER)

#ifndef MAX_PHYSMEM_BITS
#ifdef CONFIG_HIGHMEM64G
#define MAX_PHYSMEM_BITS 36
#else /* !CONFIG_HIGHMEM64G */
/*
 * If this definition of MAX_PHYSMEM_BITS is used, OBJ_INDEX_BITS will just
 * be PAGE_SHIFT
 */
#define MAX_PHYSMEM_BITS BITS_PER_LONG
#endif
#endif

#define _PFN_BITS		(MAX_PHYSMEM_BITS - PAGE_SHIFT)

#define OBJ_ALLOCATED_TAG 1
#define OBJ_TAG_BITS 1
#define OBJ_INDEX_BITS	(BITS_PER_LONG - _PFN_BITS - OBJ_TAG_BITS)
#define OBJ_INDEX_MASK	((_AC(1, UL) << OBJ_INDEX_BITS) - 1)

#define ZS_MIN_ALLOC_SIZE \
	MAX(32, (ZS_MAX_PAGES_PER_ZSPAGE << PAGE_SHIFT >> OBJ_INDEX_BITS))





so let's do some calculations, hopefuly I'm not mistaken anywhere.

with ZS_MAX_ZSPAGE_ORDER 4

-- on 32 bit system, PAGE_SHIFT 12

ZS_MAX_PAGES_PER_ZSPAGE 1 << 4						16
OBJ_INDEX_BITS (32 - (32 - 12) - 1)					11
OBJ_INDEX_MASK ((1 << (32 - (32 - 12) - 1)) - 1)			2047
ZS_MIN_ALLOC_SIZE MAX(32, ((1 << 4) << 12 >> (32 - (32 - 12) - 1)))	32

-- on 64 bit system, PAGE_SHIFT 12

ZS_MAX_PAGES_PER_ZSPAGE 1 << 4						16
OBJ_INDEX_BITS (64 - (64 - 12) - 1)					11
OBJ_INDEX_MASK ((1 << (64 - (64 - 12) - 1)) - 1)			2047
ZS_MIN_ALLOC_SIZE MAX(32, ((1 << 4) << 12 >> (64 - (64 - 12) - 1)))	32

-- on 64 bit system, PAGE_SHIFT 14

ZS_MAX_PAGES_PER_ZSPAGE 1 << 4						16
OBJ_INDEX_BITS (64 - (64 - 14) - 1)					13
OBJ_INDEX_MASK ((1 << (64 - (64 - 14) - 1)) - 1)			8191
ZS_MIN_ALLOC_SIZE MAX(32, ((1 << 4) << 14 >> (64 - (64 - 14) - 1)))	32

-- on 64 bit system, PAGE_SHIFT 16

ZS_MAX_PAGES_PER_ZSPAGE 1 << 4						16
OBJ_INDEX_BITS (64 - (64 - 16) - 1)					15
OBJ_INDEX_MASK ((1 << (64 - (64 - 16) - 1)) - 1)			32767
ZS_MIN_ALLOC_SIZE MAX(32, ((1 << 4) << 16 >> (64 - (64 - 14) - 1)))	128     << bad


so, isn't it enough OBJ_INDEX_BITS bits to even keep 32 bytes class around?

we probably would prefer to lower ZS_MAX_ZSPAGE_ORDER on PAGE_SHIFT 16 systems.
for example to ZS_MAX_PAGES_PER_ZSPAGE 1 << 3, or 1 << 2.
and of course LPAE/PAE enabled systems -- leave ZS_MAX_ZSPAGE_ORDER 2 there.




ZS_MAX_PAGES_PER_ZSPAGE 1 << 4  gives us

# cat /sys/kernel/debug/zsmalloc/zram0/classes 
  class  size  huge almost_full almost_empty obj_allocated   obj_used pages_used pages_per_zspage
     0    32             0            0             0          0          0                1
...
   238  3840             0            0             0          0          0               15
   254  4096 Y           0            0             0          0          0                1


so starting from 3840+ we have huge classes, the rest are 'normal' classes and will
save memory there in theory.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
