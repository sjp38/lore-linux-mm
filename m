Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9AD5E2808AC
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 03:53:21 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id 72so76966578uaf.7
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 00:53:21 -0800 (PST)
Received: from mail-ua0-x231.google.com (mail-ua0-x231.google.com. [2607:f8b0:400c:c08::231])
        by mx.google.com with ESMTPS id f16si2668740uaa.233.2017.03.09.00.53.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 00:53:20 -0800 (PST)
Received: by mail-ua0-x231.google.com with SMTP id q7so58095246uaf.2
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 00:53:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170308151141.2ccdd5cb9e82a56cd25562cc@linux-foundation.org>
References: <20170308151532.5070-1-dvyukov@google.com> <20170308151141.2ccdd5cb9e82a56cd25562cc@linux-foundation.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 9 Mar 2017 09:52:59 +0100
Message-ID: <CACT4Y+awf24iyh_nvn14bZzd95PK021Ohpr6FAkugNnhzkfHKA@mail.gmail.com>
Subject: Re: [PATCH] kasan: fix races in quarantine_remove_cache()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kasan-dev <kasan-dev@googlegroups.com>, Greg Thelen <gthelen@google.com>

On Thu, Mar 9, 2017 at 12:11 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed,  8 Mar 2017 16:15:32 +0100 Dmitry Vyukov <dvyukov@google.com> wrote:
>
>> quarantine_remove_cache() frees all pending objects that belong to the
>> cache, before we destroy the cache itself. However there are currently
>> two possibilities how it can fail to do so.
>>
>> First, another thread can hold some of the objects from the cache in
>> temp list in quarantine_put(). quarantine_put() has a windows of enabled
>> interrupts, and on_each_cpu() in quarantine_remove_cache() can finish
>> right in that window. These objects will be later freed into the
>> destroyed cache.
>>
>> Then, quarantine_reduce() has the same problem. It grabs a batch of
>> objects from the global quarantine, then unlocks quarantine_lock and
>> then frees the batch. quarantine_remove_cache() can finish while some
>> objects from the cache are still in the local to_free list in
>> quarantine_reduce().
>>
>> Fix the race with quarantine_put() by disabling interrupts for the
>> whole duration of quarantine_put(). In combination with on_each_cpu()
>> in quarantine_remove_cache() it ensures that quarantine_remove_cache()
>> either sees the objects in the per-cpu list or in the global list.
>>
>> Fix the race with quarantine_reduce() by protecting quarantine_reduce()
>> with srcu critical section and then doing synchronize_srcu() at the end
>> of quarantine_remove_cache().
>>
>> ...
>>
>> I suspect that these races are the root cause of some GPFs that
>> I episodically hit. Previously I did not have any explanation for them.
>
> The changelog doesn't convey a sense of how serious this bug is, so I'm
> not in a good position to decide whether this fix should be backported.
> The patch looks fairly intrusive so I tentatively decided that it
> needn't be backported.  Perhaps that was wrong.
>
> Please be more careful in describing the end-user visible impact of
> bugs when fixing them.

Will try to do better next time. Thanks for the feedback.

I am not sure myself about backporting. The back is quite hard to
trigger, I've seen it few times during our massive continuous testing
(however, it could be cause of some other episodic stray crashes as it
leads to memory corruption...). If it is triggered, the consequences
are very bad -- almost definite bad memory corruption. The fix is non
trivial and has chances of introducing new bugs. I am also not sure
how actively people use KASAN on older releases.

Can we flag it for backporting later if/when we see real need?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
