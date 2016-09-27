Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4F6F66B029A
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 04:13:50 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id b71so11288534lfg.2
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 01:13:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jd5si1161032wjb.63.2016.09.27.01.13.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 01:13:17 -0700 (PDT)
Subject: Re: [PATCH v2] fs/select: add vmalloc fallback for select(2)
References: <20160922164359.9035-1-vbabka@suse.cz>
 <20160926170105.517f74cd67ecdd5ef73e1865@linux-foundation.org>
 <1474940324.28155.44.camel@edumazet-glaptop3.roam.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6e62a278-4ac3-a866-51c6-e32511406aba@suse.cz>
Date: Tue, 27 Sep 2016 10:13:16 +0200
MIME-Version: 1.0
In-Reply-To: <1474940324.28155.44.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, netdev@vger.kernel.org

On 09/27/2016 03:38 AM, Eric Dumazet wrote:
> On Mon, 2016-09-26 at 17:01 -0700, Andrew Morton wrote:
>
>> I don't share Eric's concerns about performance here.  If the vmalloc()
>> is called, we're about to write to that quite large amount of memory
>> which we just allocated, and the vmalloc() overhead will be relatively
>> low.
>
> I did not care of the performance of this particular select() system
> call really, but other cpus because of more TLB invalidations.

There are many other ways to cause those, AFAIK. The reclaim/compaction
for order-3 allocation has its own impact on system, including TLB flushes.
Or a flood of mmap(MAP_POPULATE) and madvise(MADV_DONTNEED) calls...
This vmalloc() would however require raising RLIMIT_NOFILE above the defaults.

> At least CONFIG_DEBUG_PAGEALLOC=y builds should be impacted, but maybe
> we do not care.

I doubt anyone runs that in production, especially if performance is of concern.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
