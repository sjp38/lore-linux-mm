Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9ED6D6B0038
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 15:32:29 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id q7so5993808ioi.3
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 12:32:29 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i78sor1102951ioa.24.2017.09.20.12.32.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 12:32:28 -0700 (PDT)
Subject: Re: [PATCH 0/6] More graceful flusher thread memory reclaim wakeup
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
 <20170920192909.GA27517@quad.stoffel.home>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <8a91a54e-e224-ad79-faac-3f8fe654246a@kernel.dk>
Date: Wed, 20 Sep 2017 13:32:25 -0600
MIME-Version: 1.0
In-Reply-To: <20170920192909.GA27517@quad.stoffel.home>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stoffel <john@quad.stoffel.home>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, clm@fb.com, jack@suse.cz

On 09/20/2017 01:29 PM, John Stoffel wrote:
> On Tue, Sep 19, 2017 at 01:53:01PM -0600, Jens Axboe wrote:
>> We've had some issues with writeback in presence of memory reclaim
>> at Facebook, and this patch set attempts to fix it up. The real
>> functional change is the last patch in the series, the first 5 are
>> prep and cleanup patches.
>>
>> The basic idea is that we have callers that call
>> wakeup_flusher_threads() with nr_pages == 0. This means 'writeback
>> everything'. For memory reclaim situations, we can end up queuing
>> a TON of these kinds of writeback units. This can cause softlockups
>> and further memory issues, since we allocate huge amounts of
>> struct wb_writeback_work to handle this writeback. Handle this
>> situation more gracefully.
> 
> This looks nice, but do you have any numbers to show how this improves
> things?  I read the patches, but I'm not strong enough to comment on
> them at all.  But I am interested in how this improves writeback under
> pressure, if at all.

Writeback should be about the same, it's mostly about preventing
softlockups and excessive memory usage, under conditions where we are
actively trying to reclaim/clean memory. It was bad enough to cause
softlockups for writeback work processing, while the pending writeback
work units grew to insane lengths.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
