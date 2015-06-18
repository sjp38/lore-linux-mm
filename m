Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 595776B0074
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 23:57:55 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so56444755pdb.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 20:57:55 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id kj7si9392745pab.150.2015.06.17.20.57.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 20:57:54 -0700 (PDT)
Received: by pabvl15 with SMTP id vl15so5372920pab.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 20:57:54 -0700 (PDT)
Date: Thu, 18 Jun 2015 12:58:20 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCHv2 8/8] zsmalloc: register a shrinker to trigger
 auto-compaction
Message-ID: <20150618035820.GE3422@swordfish>
References: <1433505838-23058-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1433505838-23058-9-git-send-email-sergey.senozhatsky@gmail.com>
 <20150616144730.GD31387@blaptop>
 <20150616154529.GE20596@swordfish>
 <20150618015028.GA2370@bgram>
 <20150618023906.GC3422@swordfish>
 <20150618033922.GB2370@bgram>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150618033922.GB2370@bgram>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (06/18/15 12:39), Minchan Kim wrote:
[..]
> > ah, I see.
> > it doesn't hold the lock `until all the pages are done`. it holds it
> > as long as zs_can_compact() returns > 0. hm, I'm not entirely sure that
> > this patch set has increased the locking time (in average).
> 
> I see your point. Sorry for the consusing.
> My point is not average but max time. I bet your patch will increase
> it and it will affect others who want to allocate zspage in parallel on
> another CPU.

makes sense.

[..]
> > > Yes, it's not easy and I believe a few artificial testing are not enough
> > > to prove no regression but we don't have any choice.
> > > Actually, I think this patchset does make sense. Although it might have
> > > a problem on situation heavy memory pressure by lacking of fragment space,
> > 
> > 
> > I tested exactly this scenario yesterday (and sent an email). We leave `no holes'
> > in classes only in ~1.35% of cases. so, no, this argument is not valid. we preserve
> > fragmentation.
> 
> Thanks, Sergey.
> 
> I want to test by myself to simulate worst case scenario to make to use up
> reserved memory by zram. For it, please fix below first and resubmit, please.
> 
> 1. doesn't hold lock until class compation is done.
>    It could prevent another allocation on another CPU.
>    I want to make worst case scenario and it needs it.
> 
> 2. No touch ZS_ALMOST_FULL waterline. It can put more zspages
>    in ZS_ALMOST_FULL list so it couldn't be selected by migration
>    source.
> 
> With new patchset, I want to watch min(free_pages of the system),
> zram.max_used_pages, testing time and so on.
> 
> Really sorry for bothering you, Sergey but I think it's important
> feature on zram so I want to be careful because risk management is
> my role.

ok. will take a day or two to gather new numbers.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
