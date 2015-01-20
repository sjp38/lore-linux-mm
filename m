Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 471166B0070
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 08:31:48 -0500 (EST)
Received: by mail-la0-f44.google.com with SMTP id s18so980970lam.3
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 05:31:47 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x6si5444690wif.15.2015.01.20.05.31.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 05:31:47 -0800 (PST)
Message-ID: <54BE58C0.2050801@suse.cz>
Date: Tue, 20 Jan 2015 14:31:44 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] mm, compaction: simplify handling restart position
 in free pages scanner
References: <1421661920-4114-1-git-send-email-vbabka@suse.cz> <1421661920-4114-3-git-send-email-vbabka@suse.cz> <54BE57D7.6080501@gmail.com>
In-Reply-To: <54BE57D7.6080501@gmail.com>
Content-Type: text/plain; charset=gbk
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On 01/20/2015 02:27 PM, Zhang Yanfei wrote:
> Hello,
> 
> OU 2015/1/19 18:05, Vlastimil Babka D'uA:
>> @@ -883,6 +883,8 @@ static void isolate_freepages(struct compact_control *cc)
>>  		nr_freepages += isolated;
>>  
>>  		/*
>> +		 * If we isolated enough freepages, or aborted due to async
>> +		 * compaction being contended, terminate the loop.
>>  		 * Remember where the free scanner should restart next time,
>>  		 * which is where isolate_freepages_block() left off.
>>  		 * But if it scanned the whole pageblock, isolate_start_pfn
>> @@ -891,28 +893,30 @@ static void isolate_freepages(struct compact_control *cc)
>>  		 * In that case we will however want to restart at the start
>>  		 * of the previous pageblock.
>>  		 */
>> -		cc->free_pfn = (isolate_start_pfn < block_end_pfn) ?
>> -				isolate_start_pfn :
>> -				block_start_pfn - pageblock_nr_pages;
>> -
>> -		/*
>> -		 * isolate_freepages_block() might have aborted due to async
>> -		 * compaction being contended
>> -		 */
>> -		if (cc->contended)
>> +		if ((nr_freepages > cc->nr_migratepages) || cc->contended) {
> 
> Shouldn't this be nr_freepages >= cc->nr_migratepages?

Ah, of course. Thanks for catching that!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
