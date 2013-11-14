Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 88D276B0044
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 10:57:06 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id lj1so2280330pab.27
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 07:57:06 -0800 (PST)
Received: from psmtp.com ([74.125.245.175])
        by mx.google.com with SMTP id gl1si28396231pac.111.2013.11.14.07.57.04
        for <linux-mm@kvack.org>;
        Thu, 14 Nov 2013 07:57:05 -0800 (PST)
Message-ID: <5284F2B0.1080708@redhat.com>
Date: Thu, 14 Nov 2013 10:56:32 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 0/8] mm: thrash detection-based file cache sizing v5
References: <1381441622-26215-1-git-send-email-hannes@cmpxchg.org> <5264F353.1080603@suse.cz>
In-Reply-To: <5264F353.1080603@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 10/21/2013 05:26 AM, Vlastimil Babka wrote:
> On 10/10/2013 11:46 PM, Johannes Weiner wrote:
>> Hi everyone,
>>
>> here is an update to the cache sizing patches for 3.13.
>>
>> 	Changes in this revision
>>
>> o Drop frequency synchronization between refaulted and demoted pages
>>    and just straight up activate refaulting pages whose access
>>    frequency indicates they could stay in memory.  This was suggested
>>    by Rik van Riel a looong time ago but misinterpretation of test
>>    results during early stages of development took me a while to
>>    overcome.  It's still the same overall concept, but a little simpler
>>    and with even faster cache adaptation.  Yay!
>
> Oh, I liked the previous approach with direct competition between the
> refaulted and demoted page :) Doesn't the new approach favor the
> refaulted page too much? No wonder it leads to faster cache adaptation,
> but could it also cause degradations for workloads that don't benefit
> from it? Were there any tests for performance regressions on workloads
> that were not the target of the patchset?

This is a good question, and one that is probably
best settled through experimentation.

Even with the first scheme (fault refaulted page to
the inactive list), those pages only need 2 accesses
to be promoted to the active list.

That is because a refault tends to immediately be
followed by an access (after all, the attempted
access causes the page to get loaded back into memory).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
