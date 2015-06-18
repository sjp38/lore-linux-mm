Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7A5ED6B0074
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 23:46:58 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so56465435pdb.2
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 20:46:58 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id dd9si9311346pac.228.2015.06.17.20.46.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 20:46:57 -0700 (PDT)
Received: by padev16 with SMTP id ev16so51284049pad.0
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 20:46:57 -0700 (PDT)
Date: Thu, 18 Jun 2015 12:46:50 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCHv2 8/8] zsmalloc: register a shrinker to trigger
 auto-compaction
Message-ID: <20150618034650.GC2370@bgram>
References: <1433505838-23058-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1433505838-23058-9-git-send-email-sergey.senozhatsky@gmail.com>
 <20150616144730.GD31387@blaptop>
 <20150616154529.GE20596@swordfish>
 <20150618015028.GA2370@bgram>
 <20150618023906.GC3422@swordfish>
 <20150618030136.GD3422@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150618030136.GD3422@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 18, 2015 at 12:01:36PM +0900, Sergey Senozhatsky wrote:
> On (06/18/15 11:41), Sergey Senozhatsky wrote:
> [..]
> > > My concern is not a compacion overhead but higher memory footprint
> > > consumed by zram in reserved memory.
> > > It might hang system if zram used up reserved memory of system with
> > > ALLOC_NO_WATERMARKS. With auto-compaction, userspace has a higher chance
> > > to use more memory with uncompressible pages or file-backed pages
> > > so zram-swap can use more reserved memory. We need to evaluate it, I think.
> > > 
> 
> a couple of _not really related_ ideas that I want to voice.
> 
> (a) I'm thinking of extending zramX/compact attr. right now it's WO,
>   and I think it makes sense to make it RW:
>     ->write will trigger compaction
>     ->read will return estimated number of bytes
>   "zs_can_compact() * pages per zspage * page_size" that can be freed.
>   so user-space will have at least minimal idea whether compaction is
>   reasonable. but sure, this is racy and in general case things may
>   change between `cat compact` and `echo 1 > compact`.

It's a good idea. with that, memory manager on platform could be smart.

if memory pressure == soft and zram.can_compact > 20M
        do zram.compact
if memory pressure == hard and zram.can_compact > 5M
        do zram.compact

With this, userspace have more flexibility. :)

However, FYI, I want to make auto-compact default in future
so let's see how auto-compact is going.

> 
> 
> (b) adding a knob (yeah, like we don't have enough knobs already :-))
> that will allow 'enable/disable auto compaction'.

I agree.

> 
> 	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
