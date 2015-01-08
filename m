Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id BC8C46B0073
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 03:46:30 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id ex7so1743919wid.0
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 00:46:30 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hz2si10467329wjb.173.2015.01.08.00.46.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Jan 2015 00:46:29 -0800 (PST)
Message-ID: <54AE43E3.60209@suse.cz>
Date: Thu, 08 Jan 2015 09:46:27 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm/compaction: enhance trace output to know more
 about compaction internals
References: <1417593127-6819-1-git-send-email-iamjoonsoo.kim@lge.com> <54ABA563.1040103@suse.cz> <20150108081835.GC25453@js1304-P5Q-DELUXE>
In-Reply-To: <20150108081835.GC25453@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/08/2015 09:18 AM, Joonsoo Kim wrote:
> On Tue, Jan 06, 2015 at 10:05:39AM +0100, Vlastimil Babka wrote:
>> On 12/03/2014 08:52 AM, Joonsoo Kim wrote:
>> > It'd be useful to know where the both scanner is start. And, it also be
>> > useful to know current range where compaction work. It will help to find
>> > odd behaviour or problem on compaction.
>> 
>> Overall it looks good, just two questions:
>> 1) Why change the pfn output to hexadecimal with different printf layout and
>> change the variable names and? Is it that better to warrant people having to
>> potentially modify their scripts parsing the old output?
> 
> Deciaml output has really bad readability since we manage all pages by order
> of 2 which is well represented by hexadecimal. With hex output, we can
> easily notice whether we move out from one pageblock to another one.

OK. I don't have any strong objection, maybe Mel should comment on this as the
author of most of the tracepoints? But if it happens, I think converting the old
tracepoints to new hexadecimal format should be a separate patch from adding the
new ones.

>> 2) Would it be useful to also print in the mm_compaction_isolate_template based
>> tracepoints, pfn of where the particular scanner left off a block prematurely?
>> It doesn't always match start_pfn + nr_scanned.
> 
> With start_pfn and end_pfn, detailed analysis is possible. We can know pageblock
> where we actually scan and isolate and how much pages we try in that
> pageblock and can guess why it doesn't become freepage with pageblock
> order roughly.
> 
> nr_scanned is just different metric. end_pfn don't need to match with
> start_pfn + nr_scanned.

Well that's part of my point. end_pfn is the end of the pageblock. nr_scanned
might be lower than end_pfn - start_pfn, because we terminate in the middle of
the pageblock. But it might be also lower, because we e.g. skip higher-order
free pages. So we don't recognize where we terminated early.

> Thanks.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
