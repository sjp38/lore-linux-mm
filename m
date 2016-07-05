Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0985E828E1
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 17:37:39 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a2so146045310lfe.0
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 14:37:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b64si651838wma.31.2016.07.05.14.37.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Jul 2016 14:37:37 -0700 (PDT)
Subject: Re: [patch for-4.7] mm, compaction: prevent VM_BUG_ON when
 terminating freeing scanner
References: <alpine.DEB.2.10.1606291436300.145590@chino.kir.corp.google.com>
 <7ecb4f2d-724f-463f-961f-efba1bdb63d2@suse.cz>
 <alpine.DEB.2.10.1607051357050.110721@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <577C289E.9020403@suse.cz>
Date: Tue, 5 Jul 2016 23:37:34 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1607051357050.110721@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, mgorman@techsingularity.net, minchan@kernel.org, stable@vger.kernel.org

On 07/05/2016 11:01 PM, David Rientjes wrote:
> On Thu, 30 Jun 2016, Vlastimil Babka wrote:
> 
>>>  Note: I really dislike the low watermark check in split_free_page() and
>>>  consider it poor software engineering.  The function should split a free
>>>  page, nothing more.  Terminating memory compaction because of a low
>>>  watermark check when we're simply trying to migrate memory seems like an
>>>  arbitrary heuristic.  There was an objection to removing it in the first
>>>  proposed patch, but I think we should really consider removing that
>>>  check so this is simpler.
>>
>> There's a patch changing it to min watermark (you were CC'd on the series). We
>> could argue whether it belongs to split_free_page() or some wrapper of it, but
>> I don't think removing it completely should be done. If zone is struggling
>> with order-0 pages, a functionality for making higher-order pages shouldn't
>> make it even worse. It's also not that arbitrary, even if we succeeded the
>> migration and created a high-order page, the higher-order allocation would
>> still fail due to watermark checks. Worse, __compact_finished() would keep
>> telling the compaction to continue, creating an even longer lag, which is also
>> against your recent patches.
>>
> 
> I'm suggesting we shouldn't check any zone watermark in split_free_page(): 
> that function should just split the free page.
> 
> I don't find our current watermark checks to determine if compaction is 
> worthwhile to be invalid, but I do think that we should avoid checking or 
> acting on any watermark in isolate_freepages() itself.  We could do more 
> effective checking in __compact_finished() to determine if we should 
> terminate compaction, but the freeing scanner feels like the wrong place 
> to do it -- it's also expensive to check while gathering free pages for 
> memory that we have already successfully isolated as part of the 
> iteration.
> 
> Do you have any objection to this fix for 4.7?

No.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> Joonson and/or Minchan, does this address the issue that you reported?
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
