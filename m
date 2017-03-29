Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8FD9A6B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 11:31:02 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l43so3781057wre.4
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 08:31:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v30si6110219wra.229.2017.03.29.08.31.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Mar 2017 08:31:00 -0700 (PDT)
Subject: Re: [PATCH v3 2/8] mm, compaction: remove redundant watermark check
 in compact_finished()
References: <20170307131545.28577-1-vbabka@suse.cz>
 <20170307131545.28577-3-vbabka@suse.cz>
 <20170316013018.GA14063@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6af76744-260d-fc39-b6e0-fb47d7d6348b@suse.cz>
Date: Wed, 29 Mar 2017 17:30:58 +0200
MIME-Version: 1.0
In-Reply-To: <20170316013018.GA14063@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, kernel-team@fb.com, kernel-team@lge.com

On 03/16/2017 02:30 AM, Joonsoo Kim wrote:
> Hello,

Hi, sorry for the late replies.

> On Tue, Mar 07, 2017 at 02:15:39PM +0100, Vlastimil Babka wrote:
>> When detecting whether compaction has succeeded in forming a high-order page,
>> __compact_finished() employs a watermark check, followed by an own search for
>> a suitable page in the freelists. This is not ideal for two reasons:
>> 
>> - The watermark check also searches high-order freelists, but has a less strict
>>   criteria wrt fallback. It's therefore redundant and waste of cycles. This was
>>   different in the past when high-order watermark check attempted to apply
>>   reserves to high-order pages.
> 
> Although it looks redundant now, I don't like removal of the watermark
> check here. Criteria in watermark check would be changed to more strict
> later and we would easily miss to apply it on compaction side if the
> watermark check is removed.

I see, but compaction is already full of various watermark(-like) checks that
have to be considered/updated if watermark checking changes significantly, or
things will go subtly wrong. I doubt this extra check can really help much in
such cases.

>> 
>> - The watermark check might actually fail due to lack of order-0 pages.
>>   Compaction can't help with that, so there's no point in continuing because of
>>   that. It's possible that high-order page still exists and it terminates.
> 
> If lack of order-0 pages is the reason for stopping compaction, we
> need to insert the watermark check for order-0 to break the compaction
> instead of removing it. Am I missing something?

You proposed that once IIRC, but didn't follow up? Currently we learn about
insufficient order-0 watermark in __isolate_free_page() from the free scanner.
We could potentially stop compacting earlier by checking it also in
compact_finished(), but maybe it doesn't happen that often and it's just extra
checking overhead.

So I wouldn't be terribly opposed by converting the current check to an order-0
fail-compaction check (instead of removing it), but I really wouldn't like to
insert the order-0 one and also keep the current one.

> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
