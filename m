Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 211246B0005
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 01:44:28 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l4so10123378wml.0
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 22:44:28 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id l7si12508434wjj.147.2016.08.04.22.44.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 22:44:26 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id x83so2243225wma.3
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 22:44:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <3ee639d7-2371-c27d-3639-e4b1315d6663@kernel.dk>
References: <147033576532.682609.2277943215598867297.stgit@buzz> <3ee639d7-2371-c27d-3639-e4b1315d6663@kernel.dk>
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Fri, 5 Aug 2016 08:44:25 +0300
Message-ID: <CALYGNiMM-LWAqX2AuH-Su4EykL7fybV9EaW6V_VoGw9HiBXMDg@mail.gmail.com>
Subject: Re: [PATCH RFC] mm, writeback: flush plugged IO in wakeup_flusher_threads()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, linux-raid@vger.kernel.org, Dave Chinner <dchinner@redhat.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@kernel.org>

On Thu, Aug 4, 2016 at 10:21 PM, Jens Axboe <axboe@kernel.dk> wrote:
> On 08/04/2016 12:36 PM, Konstantin Khlebnikov wrote:
>>
>> I've found funny live-lock between raid10 barriers during resync and
>> memory
>> controller hard limits. Inside mpage_readpages() task holds on its plug
>> bio
>> which blocks barrier in raid10. Its memory cgroup have no free memory thus
>> task goes into reclaimer but all reclaimable pages are dirty and cannot be
>> written because raid10 is rebuilding and stuck on barrier.
>>
>> Common flush of such IO in schedule() never happens because machine where
>> that happened has a lot of free cpus and task never goes sleep.
>>
>> Lock is 'live' because changing memory limit or killing tasks which holds
>> that stuck bio unblock whole progress.
>>
>> That was happened in 3.18.x but I see no difference in upstream logic.
>> Theoretically this might happen even without memory cgroup.
>
>
> So the issue is that the caller of wakeup_flusher_threads() ends up never
> going to sleep, hence the plug is never auto-flushed. I didn't quite
> understand your reasoning for why it never sleeps above, but that must be
> the gist of it.

Ah right, simple context switch doesn't flush plug, so count of cpus
is irrelevant.

>
> I don't see anything inherently wrong with the fix.
>
> --
> Jens Axboe
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
