Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8FE3D6B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 00:53:52 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id fl4so44519918pad.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 21:53:52 -0800 (PST)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id z63si14317470pfi.63.2016.02.18.21.53.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 21:53:51 -0800 (PST)
Received: by mail-pf0-x22d.google.com with SMTP id e127so45231033pfe.3
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 21:53:51 -0800 (PST)
Date: Fri, 19 Feb 2016 14:55:07 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC PATCH 3/3] mm/zsmalloc: change ZS_MAX_PAGES_PER_ZSPAGE
Message-ID: <20160219055507.GC16230@swordfish>
References: <1455764556-13979-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1455764556-13979-4-git-send-email-sergey.senozhatsky@gmail.com>
 <CAAmzW4O-yQ5GBTE-6WvCL-hZeqyW=k3Fzn4_9G2qkMmp=ceuJg@mail.gmail.com>
 <20160218095536.GA503@swordfish>
 <20160218101909.GB503@swordfish>
 <CAAmzW4NQt4jD2q92Hh4XFzt5fV=-i3J9eoxS3now6Y4Xw7OqGg@mail.gmail.com>
 <20160219041601.GA820@swordfish>
 <20160219044604.GA16230@swordfish>
 <20160219053814.GB16230@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160219053814.GB16230@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (02/19/16 14:38), Sergey Senozhatsky wrote:
[..]
> #define OBJ_ALLOCATED_TAG 1
> #define OBJ_TAG_BITS 1
> #define OBJ_INDEX_BITS	(BITS_PER_LONG - _PFN_BITS - OBJ_TAG_BITS)
> #define OBJ_INDEX_MASK	((_AC(1, UL) << OBJ_INDEX_BITS) - 1)
> 
> #define ZS_MIN_ALLOC_SIZE \
> 	MAX(32, (ZS_MAX_PAGES_PER_ZSPAGE << PAGE_SHIFT >> OBJ_INDEX_BITS))
[..]

> -- on 32 bit system, PAGE_SHIFT 12
> 
> ZS_MAX_PAGES_PER_ZSPAGE 1 << 4						16
> OBJ_INDEX_BITS (32 - (32 - 12) - 1)					11
> OBJ_INDEX_MASK ((1 << (32 - (32 - 12) - 1)) - 1)			2047
> ZS_MIN_ALLOC_SIZE MAX(32, ((1 << 4) << 12 >> (32 - (32 - 12) - 1)))	32
> 
> -- on 64 bit system, PAGE_SHIFT 12
> 
> ZS_MAX_PAGES_PER_ZSPAGE 1 << 4						16
> OBJ_INDEX_BITS (64 - (64 - 12) - 1)					11
> OBJ_INDEX_MASK ((1 << (64 - (64 - 12) - 1)) - 1)			2047
> ZS_MIN_ALLOC_SIZE MAX(32, ((1 << 4) << 12 >> (64 - (64 - 12) - 1)))	32

even if it's missing  "HANDLE_PIN_BIT 0", it's still OBJ_INDEX_BITS 10,
2<<10 should be enough to keep 32 bytes class around.


> -- on 64 bit system, PAGE_SHIFT 14
> 
> ZS_MAX_PAGES_PER_ZSPAGE 1 << 4						16
> OBJ_INDEX_BITS (64 - (64 - 14) - 1)					13
> OBJ_INDEX_MASK ((1 << (64 - (64 - 14) - 1)) - 1)			8191
> ZS_MIN_ALLOC_SIZE MAX(32, ((1 << 4) << 14 >> (64 - (64 - 14) - 1)))	32

OBJ_INDEX_BITS 2<<12 still looks to be good enough.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
