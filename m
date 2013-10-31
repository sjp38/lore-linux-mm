Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 99A0D6B0035
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 01:00:54 -0400 (EDT)
Received: by mail-ie0-f177.google.com with SMTP id e14so3923464iej.8
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 22:00:54 -0700 (PDT)
Received: from psmtp.com ([74.125.245.180])
        by mx.google.com with SMTP id nv6si1551558icc.80.2013.10.30.22.00.51
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 22:00:52 -0700 (PDT)
Received: by mail-qc0-f180.google.com with SMTP id e9so1368995qcy.25
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 22:00:50 -0700 (PDT)
Message-ID: <5271E3F8.80108@gmail.com>
Date: Thu, 31 Oct 2013 01:00:40 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: __rmqueue_fallback() should respect pageblock type
References: <1383193489-27331-1-git-send-email-kosaki.motohiro@gmail.com> <20131030213537.f346d751.akpm@linux-foundation.org>
In-Reply-To: <20131030213537.f346d751.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>

(10/31/13 12:35 AM), Andrew Morton wrote:
> On Thu, 31 Oct 2013 00:24:49 -0400 kosaki.motohiro@gmail.com wrote:
>
>> When __rmqueue_fallback() don't find out a free block with the same size
>> of required, it splits a larger page and puts back rest peiece of the page
>> to free list.
>>
>> But it has one serious mistake. When putting back, __rmqueue_fallback()
>> always use start_migratetype if type is not CMA. However, __rmqueue_fallback()
>> is only called when all of start_migratetype queue are empty. That said,
>> __rmqueue_fallback always put back memory to wrong queue except
>> try_to_steal_freepages() changed pageblock type (i.e. requested size is
>> smaller than half of page block). Finally, antifragmentation framework
>> increase fragmenation instead of decrease.
>>
>> Mel's original anti fragmentation do the right thing. But commit 47118af076
>> (mm: mmzone: MIGRATE_CMA migration type added) broke it.
>>
>> This patch restores sane and old behavior.
>
> What are the user-visible runtime effects of this change?

Memory fragmentation may increase compaction rate. (And then system get unnecessary
slow down)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
