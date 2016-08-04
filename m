Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 94B836B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 15:21:08 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id i64so13480952ith.1
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 12:21:08 -0700 (PDT)
Received: from mail-it0-x22e.google.com (mail-it0-x22e.google.com. [2607:f8b0:4001:c0b::22e])
        by mx.google.com with ESMTPS id e63si4390064ite.96.2016.08.04.12.21.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 12:21:07 -0700 (PDT)
Received: by mail-it0-x22e.google.com with SMTP id x130so4047327ite.1
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 12:21:07 -0700 (PDT)
Subject: Re: [PATCH RFC] mm, writeback: flush plugged IO in
 wakeup_flusher_threads()
References: <147033576532.682609.2277943215598867297.stgit@buzz>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <3ee639d7-2371-c27d-3639-e4b1315d6663@kernel.dk>
Date: Thu, 4 Aug 2016 13:21:05 -0600
MIME-Version: 1.0
In-Reply-To: <147033576532.682609.2277943215598867297.stgit@buzz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, linux-raid@vger.kernel.org, Dave Chinner <dchinner@redhat.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@kernel.org>

On 08/04/2016 12:36 PM, Konstantin Khlebnikov wrote:
> I've found funny live-lock between raid10 barriers during resync and memory
> controller hard limits. Inside mpage_readpages() task holds on its plug bio
> which blocks barrier in raid10. Its memory cgroup have no free memory thus
> task goes into reclaimer but all reclaimable pages are dirty and cannot be
> written because raid10 is rebuilding and stuck on barrier.
>
> Common flush of such IO in schedule() never happens because machine where
> that happened has a lot of free cpus and task never goes sleep.
>
> Lock is 'live' because changing memory limit or killing tasks which holds
> that stuck bio unblock whole progress.
>
> That was happened in 3.18.x but I see no difference in upstream logic.
> Theoretically this might happen even without memory cgroup.

So the issue is that the caller of wakeup_flusher_threads() ends up 
never going to sleep, hence the plug is never auto-flushed. I didn't 
quite understand your reasoning for why it never sleeps above, but that 
must be the gist of it.

I don't see anything inherently wrong with the fix.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
