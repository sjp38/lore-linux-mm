Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id DB7118E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 17:09:00 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id e88-v6so393956qtb.1
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 14:09:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l9-v6sor61037qtk.30.2018.09.26.14.08.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Sep 2018 14:08:59 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [RFC][PATCH 0/9][V2] drop the mmap_sem when doing IO in the fault path
Date: Wed, 26 Sep 2018 17:08:47 -0400
Message-Id: <20180926210856.7895-1-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-team@fb.com, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, tj@kernel.org, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, riel@redhat.com, linux-mm@kvack.org, linux-btrfs@vger.kernel.org

v1->v2:
- reworked so it only affects x86, since its the only arch I can build and test.
- fixed the fact that do_page_mkwrite wasn't actually sending ALLOW_RETRY down
  to ->page_mkwrite.
- fixed error handling in do_page_mkwrite/callers to explicitly catch
  VM_FAULT_RETRY.
- fixed btrfs to set ->cached_page properly.

This time I've verified that the ->page_mkwrite retry path is actually getting
used (apparently I only verified the read side last time).  xfstests is still
running but it passed the couple of mmap tests I ran directly.  Again this is an
RFC, I'm still doing a bunch of testing, but I'd appreciate comments on the
overall strategy.

-- Original message --

Now that we have proper isolation in place with cgroups2 we have started going
through and fixing the various priority inversions.  Most are all gone now, but
this one is sort of weird since it's not necessarily a priority inversion that
happens within the kernel, but rather because of something userspace does.

We have giant applications that we want to protect, and parts of these giant
applications do things like watch the system state to determine how healthy the
box is for load balancing and such.  This involves running 'ps' or other such
utilities.  These utilities will often walk /proc/<pid>/whatever, and these
files can sometimes need to down_read(&task->mmap_sem).  Not usually a big deal,
but we noticed when we are stress testing that sometimes our protected
application has latency spikes trying to get the mmap_sem for tasks that are in
lower priority cgroups.

This is because any down_write() on a semaphore essentially turns it into a
mutex, so even if we currently have it held for reading, any new readers will
not be allowed on to keep from starving the writer.  This is fine, except a
lower priority task could be stuck doing IO because it has been throttled to the
point that its IO is taking much longer than normal.  But because a higher
priority group depends on this completing it is now stuck behind lower priority
work.

In order to avoid this particular priority inversion we want to use the existing
retry mechanism to stop from holding the mmap_sem at all if we are going to do
IO.  This already exists in the read case sort of, but needed to be extended for
more than just grabbing the page lock.  With io.latency we throttle at
submit_bio() time, so the readahead stuff can block and even page_cache_read can
block, so all these paths need to have the mmap_sem dropped.

The other big thing is ->page_mkwrite.  btrfs is particularly shitty here
because we have to reserve space for the dirty page, which can be a very
expensive operation.  We use the same retry method as the read path, and simply
cache the page and verify the page is still setup properly the next pass through
->page_mkwrite().

I've tested these patches with xfstests and there are no regressions.  Let me
know what you think.  Thanks,

Josef
