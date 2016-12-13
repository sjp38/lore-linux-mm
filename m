Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 22B156B0260
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 07:33:02 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id j10so36483972wjb.3
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 04:33:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 6si2124008wmq.165.2016.12.13.04.33.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Dec 2016 04:33:01 -0800 (PST)
Subject: Re: [PATCH] mm: fadvise: avoid expensive remote LRU cache draining
 after FADV_DONTNEED
References: <20161210172658.5182-1-hannes@cmpxchg.org>
 <5cc0eb6f-bede-a34a-522b-e30d06723ffa@suse.cz>
 <20161212155552.GA7148@cmpxchg.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d52c53fc-60c7-21ca-08ab-f58cd4b403f1@suse.cz>
Date: Tue, 13 Dec 2016 13:32:58 +0100
MIME-Version: 1.0
In-Reply-To: <20161212155552.GA7148@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 12/12/2016 04:55 PM, Johannes Weiner wrote:
> On Mon, Dec 12, 2016 at 10:21:24AM +0100, Vlastimil Babka wrote:
>> On 12/10/2016 06:26 PM, Johannes Weiner wrote:
>>> When FADV_DONTNEED cannot drop all pages in the range, it observes
>>> that some pages might still be on per-cpu LRU caches after recent
>>> instantiation and so initiates remote calls to all CPUs to flush their
>>> local caches. However, in most cases, the fadvise happens from the
>>> same context that instantiated the pages, and any pre-LRU pages in the
>>> specified range are most likely sitting on the local CPU's LRU cache,
>>> and so in many cases this results in unnecessary remote calls, which,
>>> in a loaded system, can hold up the fadvise() call significantly.
>>
>> Got any numbers for this part?
>
> I didn't record it in the extreme case we observed, unfortunately. We
> had a slow-to-respond system and noticed it spending seconds in
> lru_add_drain_all() after fadvise calls, and this patch came out of
> thinking about the code and how we commonly call FADV_DONTNEED.
>
> FWIW, I wrote a silly directory tree walker/searcher that recurses
> through /usr to read and FADV_DONTNEED each file it finds. On a 2
> socket 40 ht machine, over 1% is spent in lru_add_drain_all(). With
> the patch, that cost is gone; the local drain cost shows at 0.09%.

Thanks, worth adding to changelog :)

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
