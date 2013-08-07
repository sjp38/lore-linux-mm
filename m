Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 036B06B0032
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 15:08:17 -0400 (EDT)
Received: by mail-vb0-f42.google.com with SMTP id e12so2271970vbg.29
        for <linux-mm@kvack.org>; Wed, 07 Aug 2013 12:08:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130806152357.40031f6702c92ce9f0d10fca@linux-foundation.org>
References: <1375778440-31503-1-git-send-email-iamjoonsoo.kim@lge.com>
	<20130806152357.40031f6702c92ce9f0d10fca@linux-foundation.org>
Date: Thu, 8 Aug 2013 04:08:16 +0900
Message-ID: <CAAmzW4NMPLKae8kRDmGtciTPBam+mPF+qPtf8HindD+-xn2siQ@mail.gmail.com>
Subject: Re: [PATCH] mm, page_alloc: optimize batch count in free_pcppages_bulk()
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

Hello, Andrew.

2013/8/7 Andrew Morton <akpm@linux-foundation.org>:
> On Tue,  6 Aug 2013 17:40:40 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>
>> If we use a division operation, we can compute a batch count more closed
>> to ideal value. With this value, we can finish our job within
>> MIGRATE_PCPTYPES iteration. In addition, batching to free more pages
>> may be helpful to cache usage.
>>
>
> hm, maybe.  The .text got 120 bytes larger so the code now will
> eject two of someone else's cachelines, which can't be good.  I need
> more convincing, please ;)
>
> (bss got larger too - I don't have a clue why this happens).

In my testing, it makes .text just 64 byes larger.
I think that I cannot avoid such few increasing size.

Current round-robin freeing algorithm access 'struct page' at random
order, because
it change it's migrate type and list on every iteration and a page on
different list
may be far from each other. If we do more batch free, we have more
probability to access
adjacent 'struct page' than before, so I think that this is
cache-friendly. But this is just
theoretical argument, so I'm not sure whether it is useful or not :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
