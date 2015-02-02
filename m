Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 780A76B006C
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 09:07:23 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id a1so38839688wgh.12
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 06:07:23 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ho6si37316592wjb.152.2015.02.02.06.07.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 06:07:22 -0800 (PST)
Message-ID: <54CF8495.8010602@suse.cz>
Date: Mon, 02 Feb 2015 15:07:17 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 3/3] mm/compaction: enhance compaction finish condition
References: <1422861348-5117-1-git-send-email-iamjoonsoo.kim@lge.com>	<1422861348-5117-3-git-send-email-iamjoonsoo.kim@lge.com>	<54CF4F61.3070905@suse.cz> <CAAmzW4P2MoRzo_CA5i9X0ARrLrzzSD8SQXTsvX+6JJ2q_P1Tng@mail.gmail.com>
In-Reply-To: <CAAmzW4P2MoRzo_CA5i9X0ARrLrzzSD8SQXTsvX+6JJ2q_P1Tng@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 02/02/2015 02:23 PM, Joonsoo Kim wrote:
> 2015-02-02 19:20 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
>> On 02/02/2015 08:15 AM, Joonsoo Kim wrote:
>>
>> So I've realized that this problaby won't always work as intended :/ Because we
>> still differ from what page allocator does.
>> Consider we compact for UNMOVABLE allocation. First we try RECLAIMABLE fallback.
>> Turns out we could fallback, but not steal, hence we skip it due to
>> only_stealable == true. So we try MOVABLE, and turns out we can steal, so we
>> finish compaction.
>> Then the allocation attempt follows, and it will fallback to RECLAIMABLE,
>> without extra stealing. The compaction decision for MOVABLE was moot.
>> Is it a big problem? Probably not, the compaction will still perform some extra
>> anti-fragmentation on average, but we should consider it.
> 
> Hello,
> 
> First of all, thanks for quick review. :)
> 
> Hmm... I don't get it. Is this case possible in current implementation?
> can_steal_fallback() decides whether steal is possible or not, based
> on freepage order
> and start_migratetype. If fallback freepage is on RECLAIMABLE and
> MOVABLE type and
> they are same order, can_steal could be true for both or false for
> neither. If order is
> different, compaction decision would be recognized by
> __rmqueue_fallback() since it
> try to find freepage from high order to low order.

Ah, right, I got confused into thinking that the result of can_steal depends on
how many freepages it found within the pageblock to steal. Sorry about the noise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
