Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id CC7F68E00B9
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 12:38:07 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id l69so9059980ywb.7
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:38:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e16sor2722609ywa.208.2018.12.11.09.38.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 09:38:06 -0800 (PST)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 0/3][V5] drop the mmap_sem when doing IO in the fault path
Date: Tue, 11 Dec 2018 12:37:58 -0500
Message-Id: <20181211173801.29535-1-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, jack@suse.cz

Here's the latest version, slimmed down a bit from my last submission with more
details in the changelogs as requested.

v4->v5:
- dropped the cached_page infrastructure and the addition of the
  handle_mm_fault_cacheable helper as it had no discernable bearing on
  performance in my performance testing.
- reworked the page lock dropping logic in order to be it's own helper, which
  comments describing how to use it.
- added more details to the changelog for the fpin patch.
- added a patch to cleanup the arguments for the readahead functions for mmap as
  per Jan's suggestion.

v3->v4:
- dropped the ->page_mkwrite portion of these patches, we don't actually see
  issues with mkwrite in production, and I kept running into corner cases where
  I missed something important.  I want to wait on that part until I have a real
  reason to do the work so I can have a solid test in place.
- completely reworked how we drop the mmap_sem in filemap_fault and cleaned it
  up a bit.  Once I started actually testing this with our horrifying reproducer
  I saw a bunch of places where we still ended up doing IO under the mmap_sem
  because I had missed a few corner cases.  Fixed this by reworking
  filemap_fault to only return RETRY once it has a completely uptodate page
  ready to be used.
- lots more testing, including production testing.

v2->v3:
- dropped the RFC, ready for a real review.
- fixed a kbuild error for !MMU configs.
- dropped the swapcache patches since Johannes is still working on those parts.

v1->v2:
- reworked so it only affects x86, since its the only arch I can build and test.
- fixed the fact that do_page_mkwrite wasn't actually sending ALLOW_RETRY down
  to ->page_mkwrite.
- fixed error handling in do_page_mkwrite/callers to explicitly catch
  VM_FAULT_RETRY.
- fixed btrfs to set ->cached_page properly.

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
