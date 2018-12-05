Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id A173E6B769F
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 17:23:55 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id i12so17902418ita.3
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 14:23:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t187sor9475978iod.103.2018.12.05.14.23.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Dec 2018 14:23:54 -0800 (PST)
Date: Wed, 5 Dec 2018 14:23:40 -0800
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/4] filemap: drop the mmap_sem for all blocking
 operations
Message-ID: <20181205222340.GB13938@cmpxchg.org>
References: <20181130195812.19536-1-josef@toxicpanda.com>
 <20181130195812.19536-4-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181130195812.19536-4-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: kernel-team@fb.com, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, jack@suse.cz

On Fri, Nov 30, 2018 at 02:58:11PM -0500, Josef Bacik wrote:
> Currently we only drop the mmap_sem if there is contention on the page
> lock.  The idea is that we issue readahead and then go to lock the page
> while it is under IO and we want to not hold the mmap_sem during the IO.
> 
> The problem with this is the assumption that the readahead does
> anything.  In the case that the box is under extreme memory or IO
> pressure we may end up not reading anything at all for readahead, which
> means we will end up reading in the page under the mmap_sem.

I'd also add that even if readahead did something, the block request
queues could be contended enough that merely submitting the io could
become IO bound if it has to wait for in-flight requests.

Not really a concern with cgroup IO control, but this has always
somewhat defeated the original purpose of the mmap_sem dropping
(avoiding serializing page faults when there is a writer queued).

> Instead rework filemap fault path to drop the mmap sem at any point that
> we may do IO or block for an extended period of time.  This includes
> while issuing readahead, locking the page, or needing to call ->readpage
> because readahead did not occur.  Then once we have a fully uptodate
> page we can return with VM_FAULT_RETRY and come back again to find our
> nicely in-cache page that was gotten outside of the mmap_sem.
> 
> Signed-off-by: Josef Bacik <josef@toxicpanda.com>

Keeping the fpin throughout the fault handler makes things a lot
simpler than the -EAGAIN and wait_on_page_locked dance from earlier
versions. Nice.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
