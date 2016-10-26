Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 50FBA6B0275
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 17:26:59 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id f78so16299853oih.7
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 14:26:59 -0700 (PDT)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id a38si2885334oic.175.2016.10.26.14.26.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 14:26:58 -0700 (PDT)
Received: by mail-oi0-x243.google.com with SMTP id i127so1174576oia.0
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 14:26:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161026203158.GD2699@techsingularity.net>
References: <CAHc6FU4e5sueLi7pfeXnSbuuvnc5PaU3xo5Hnn=SvzmQ+ZOEeg@mail.gmail.com>
 <CALCETrUt+4ojyscJT1AFN5Zt3mKY0rrxcXMBOUUJzzLMWXFXHg@mail.gmail.com>
 <CA+55aFzB2C0aktFZW3GquJF6dhM1904aDPrv4vdQ8=+mWO7jcg@mail.gmail.com>
 <CA+55aFww1iLuuhHw=iYF8xjfjGj8L+3oh33xxUHjnKKnsR-oHg@mail.gmail.com> <20161026203158.GD2699@techsingularity.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 26 Oct 2016 14:26:57 -0700
Message-ID: <CA+55aFy21NqcYTeLVVz4x4kfQ7A+o4HEv7srone6ppKAjCwn7g@mail.gmail.com>
Subject: Re: CONFIG_VMAP_STACK, on-stack struct, and wake_up_bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andy Lutomirski <luto@amacapital.net>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, linux-mm <linux-mm@kvack.org>

On Wed, Oct 26, 2016 at 1:31 PM, Mel Gorman <mgorman@techsingularity.net> wrote:
>
> IO wait activity is not all that matters. We hit the lock/unlock paths
> during a lot of operations like reclaim.

I doubt we do.

Yes, we hit the lock/unlock itself, but do we hit the *contention*?

The current code is nasty, and always ends up touching the wait-queue
regardless of whether it needs to or not, but we have a fix for that.

With that fixed, do we actually get contention on a per-page basis?
Because without contention, we'd never actually look up the wait-queue
at all.

I suspect that without IO, it's really really hard to actually get
that contention, because things like reclaim end up looking at the LRU
queue etc wioth their own locking, so it should look at various
individual pages one at a time, not have multiple queues look at the
same page.

>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index 7f2ae99e5daf..0f088f3a2fed 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -440,33 +440,7 @@ struct zone {
>> +     int initialized;
>>
>>       /* Write-intensive fields used from the page allocator */
>>       ZONE_PADDING(_pad1_)
>
> zone_is_initialized is mostly the domain of hotplug. A potential cleanup
> is to use a page flag and shrink the size of zone slightly. Nothing to
> panic over.

I really did that to make it very obvious that there was no semantic
change. I just set the "initialized" flag in the same place where it
used to initialize the wait_table, so that this:

>>  static inline bool zone_is_initialized(struct zone *zone)
>>  {
>> -     return !!zone->wait_table;
>> +     return zone->initialized;
>>  }

ends up being obviously equivalent.

Admittedly I didn't clear it when the code cleared the wait_table
pointer, because that _seemed_ a non-issue - the zone will remain
initialized until it can't be reached any more, so there didn't seem
to be an actual problem there.

>> +#define WAIT_TABLE_BITS 8
>> +#define WAIT_TABLE_SIZE (1 << WAIT_TABLE_BITS)
>> +static wait_queue_head_t bit_wait_table[WAIT_TABLE_SIZE] __cacheline_aligned;
>> +
>> +wait_queue_head_t *bit_waitqueue(void *word, int bit)
>> +{
>> +     const int shift = BITS_PER_LONG == 32 ? 5 : 6;
>> +     unsigned long val = (unsigned long)word << shift | bit;
>> +
>> +     return bit_wait_table + hash_long(val, WAIT_TABLE_BITS);
>> +}
>> +EXPORT_SYMBOL(bit_waitqueue);
>> +
>
> Minor nit that it's unfortunate this moved to the scheduler core. It
> wouldn't have been a complete disaster to add a page_waitqueue_init() or
> something similar after sched_init.

I considered that, but decided that "minimal patch" was better. Plus,
with that bit_waitqueue() actually also being used for the page
locking queues (which act _kind of_ but not quite, like a bitlock),
the bit_wait_table is actually more core than just the bit-wait code.

In fact, I considered just renaming it to "hashed_wait_queue", because
that's effectively how we use it now, rather than being particularly
specific to the bit-waiting. But again, that would have made the patch
bigger, which I wanted to avoid since this is a post-rc2 thing due to
the gfs2 breakage.

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
