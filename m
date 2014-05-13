Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4471E6B0035
	for <linux-mm@kvack.org>; Tue, 13 May 2014 04:50:31 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id c13so149647eek.34
        for <linux-mm@kvack.org>; Tue, 13 May 2014 01:50:30 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i47si5408779eev.21.2014.05.13.01.50.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 01:50:30 -0700 (PDT)
Message-ID: <5371DCD2.8030602@suse.cz>
Date: Tue, 13 May 2014 10:50:26 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, compaction: properly signal and act upon lock and
 need_sched() contention
References: <20140508051747.GA9161@js1304-P5Q-DELUXE> <1399904111-23520-1-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1405121326080.961@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1405121326080.961@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On 05/12/2014 10:28 PM, David Rientjes wrote:
> On Mon, 12 May 2014, Vlastimil Babka wrote:
>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 83ca6f9..b34ab7c 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -222,6 +222,27 @@ static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
>>   	return true;
>>   }
>>
>> +/*
>> + * Similar to compact_checklock_irqsave() (see its comment) for places where
>> + * a zone lock is not concerned.
>> + *
>> + * Returns false when compaction should abort.
>> + */
>
> I think we should have some sufficient commentary in the code that
> describes why we do this.

Well I can of course mostly duplicate the comment of 
compact_checklock_irqsave() instead of referring to it, if you think 
that's better.

>> +static inline bool compact_check_resched(struct compact_control *cc)
>> +{
>
> I'm not sure that compact_check_resched() is the appropriate name.  Sure,
> it specifies what the current implementation is, but what it's really
> actually doing is determining when compaction should abort prematurely.
>
> Something like compact_should_abort()?

I tried to be somewhat analogous to the name of 
compact_checklock_irqsave(). compact_should_abort() doesn't indicate 
that there might be a resched().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
