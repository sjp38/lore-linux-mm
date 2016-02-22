Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2B8EC6B0009
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 22:53:32 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id yy13so83678788pab.3
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 19:53:32 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id m80si36619918pfi.252.2016.02.21.19.53.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Feb 2016 19:53:31 -0800 (PST)
Received: by mail-pa0-x22c.google.com with SMTP id fy10so83623731pac.1
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 19:53:31 -0800 (PST)
Date: Mon, 22 Feb 2016 12:54:48 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH v2 2/3] zram: use zs_get_huge_class_size_watermark()
Message-ID: <20160222035448.GB11961@swordfish>
References: <1456061274-20059-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1456061274-20059-3-git-send-email-sergey.senozhatsky@gmail.com>
 <20160222000436.GA21710@bbox>
 <20160222004047.GA4958@swordfish>
 <20160222012758.GA27829@bbox>
 <20160222015912.GA488@swordfish>
 <20160222025709.GD27829@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160222025709.GD27829@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (02/22/16 11:57), Minchan Kim wrote:
[..]
> > > Yes, I mean if we have backing storage, we could mitigate the problem
> > > like the mentioned approach. Otherwise, we should solve it in allocator
> > > itself and you suggested the idea and I commented first step.
> > > What's the problem, now?
> > 
> > well, I didn't say I have problems.
> > so you want a backing device that will keep only 'bad compression'
> > objects and use zsmalloc to keep there only 'good compression' objects?
> > IOW, no huge classes in zsmalloc at all? well, that can work out. it's
> > a bit strange though that to solve zram-zsmalloc issues we would ask
> > someone to create a additional device. it looks (at least for now) that
> > we can address those issues in zram-zsmalloc entirely; w/o user
> > intervention or a 3rd party device.
> 
> Agree. That's what I want. zram shouldn't be aware of allocator's
> internal implementation. IOW, zsmalloc should handle it without
> exposing any internal limitation.

well, at the same time zram must not dictate what to do. zram simply spoils
zsmalloc; it does not offer guaranteed good compression, and it does not let
zsmalloc to do it's job. zram has only excuses to be the way it is.
the existing zram->zsmalloc dependency looks worse than zsmalloc->zram to me.

> Backing device issue is orthogonal but what I said about thing
> was it could solve the issue too without exposing zsmalloc's
> limitation to the zram.

well, backing device would not reduce the amount of pages we request.
and that's the priority issue, especially if we are talking about
embedded system with a low free pages capability. we would just move huge
objects from zsmalloc to backing device. other than that we would still
request 1000 (for example) pages to store 1000 objects. it's zsmalloc's
"page sharing" that permits us to request less than 1000 pages to store
1000 objects.

so yes, I agree, increasing ZS_MAX_ZSPAGE_ORDER and do more tests is
the step #1 to take.

> Let's summary my points in here.
> 
> Let's make zsmalloc smarter to reduce wasted space. One of option is
> dynamic page creation which I agreed.
>
> Before the feature, we should test how memory footprint is bigger
> without the feature if we increase ZS_MAX_ZSPAGE_ORDER.
> If it's not big, we could go with your patch easily without adding
> more complex stuff(i.e, dynamic page creation).

yes, agree. alloc_zspage()/init_zspage() and friends must be the last
thing to touch. only if increased ZS_MAX_ZSPAGE_ORDER will turn out not
to be good enough.

> Please, check max_used_pages rather than mem_used_total for seeing
> memory footprint at the some moment and test very fragmented scenario
> (creating files and free part of files) rather than just full coping.

sure, more tests will follow.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
