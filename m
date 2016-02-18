Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 45C64828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 05:17:54 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id c10so29843743pfc.2
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 02:17:54 -0800 (PST)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id pj4si1253831pac.45.2016.02.18.02.17.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 02:17:53 -0800 (PST)
Received: by mail-pf0-x22b.google.com with SMTP id e127so28935762pfe.3
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 02:17:53 -0800 (PST)
Date: Thu, 18 Feb 2016 19:19:09 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC PATCH 3/3] mm/zsmalloc: change ZS_MAX_PAGES_PER_ZSPAGE
Message-ID: <20160218101909.GB503@swordfish>
References: <1455764556-13979-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1455764556-13979-4-git-send-email-sergey.senozhatsky@gmail.com>
 <CAAmzW4O-yQ5GBTE-6WvCL-hZeqyW=k3Fzn4_9G2qkMmp=ceuJg@mail.gmail.com>
 <20160218095536.GA503@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160218095536.GA503@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (02/18/16 18:55), Sergey Senozhatsky wrote:
> > There is a reason that it is order of 2. Increasing ZS_MAX_PAGES_PER_ZSPAGE
> > is related to ZS_MIN_ALLOC_SIZE. If we don't have enough OBJ_INDEX_BITS,
> > ZS_MIN_ALLOC_SIZE would be increase and it causes regression on some
> > system.
> 
> Thanks!
> 
> do you mean PHYSMEM_BITS != BITS_PER_LONG systems? PAE/LPAE? isn't it
> the case that on those systems ZS_MIN_ALLOC_SIZE already bigger than 32?

I mean, yes, there are ZS_ALIGN requirements that I completely ignored,
thanks for pointing that out.

just saying, not insisting on anything, theoretically, trading 32 bit size
objects in exchange of reducing a much bigger memory wastage is sort of
interesting. zram stores objects bigger than 3072 as huge objects, leaving
4096-3072 bytes unused, and it'll take 4096-3072/32 = 4000  32 bit objects
to beat that single 'bad' compression object in storing inefficiency...

well, patches 0001/0002 are trying to address this a bit, but the biggest
problem is still there: we have too many ->huge classes and they are a bit
far from good.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
