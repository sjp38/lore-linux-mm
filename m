Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9212E6B02DC
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 19:11:52 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id b9so4446872wra.3
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 16:11:52 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id z9si308836edk.423.2017.09.20.16.11.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Sep 2017 16:11:51 -0700 (PDT)
Date: Wed, 20 Sep 2017 19:11:46 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/6] More graceful flusher thread memory reclaim wakeup
Message-ID: <20170920230910.GA18540@cmpxchg.org>
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
 <20170920192909.GA27517@quad.stoffel.home>
 <8a91a54e-e224-ad79-faac-3f8fe654246a@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8a91a54e-e224-ad79-faac-3f8fe654246a@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: John Stoffel <john@stoffel.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, clm@fb.com, jack@suse.cz

[ Fixed up CC list. John, you're sending email with
  From: John Stoffel <john@quad.stoffel.home> ]

On Wed, Sep 20, 2017 at 01:32:25PM -0600, Jens Axboe wrote:
> On 09/20/2017 01:29 PM, John Stoffel wrote:
> > On Tue, Sep 19, 2017 at 01:53:01PM -0600, Jens Axboe wrote:
> >> We've had some issues with writeback in presence of memory reclaim
> >> at Facebook, and this patch set attempts to fix it up. The real
> >> functional change is the last patch in the series, the first 5 are
> >> prep and cleanup patches.
> >>
> >> The basic idea is that we have callers that call
> >> wakeup_flusher_threads() with nr_pages == 0. This means 'writeback
> >> everything'. For memory reclaim situations, we can end up queuing
> >> a TON of these kinds of writeback units. This can cause softlockups
> >> and further memory issues, since we allocate huge amounts of
> >> struct wb_writeback_work to handle this writeback. Handle this
> >> situation more gracefully.
> > 
> > This looks nice, but do you have any numbers to show how this improves
> > things?  I read the patches, but I'm not strong enough to comment on
> > them at all.  But I am interested in how this improves writeback under
> > pressure, if at all.
> 
> Writeback should be about the same, it's mostly about preventing
> softlockups and excessive memory usage, under conditions where we are
> actively trying to reclaim/clean memory. It was bad enough to cause
> softlockups for writeback work processing, while the pending writeback
> work units grew to insane lengths.

In numbers, we have seen situations where we had 600 million writeback
work items queued up from reclaim under pressure. That's 35G worth of
work descriptors, and the machine was struggling to remain responsive
due to a lack of memory.

Once writeback against all outstanding dirty pages has been requested,
there really isn't a need to queue even a second work item; the job is
already being performed. We can queue the next one when it completes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
