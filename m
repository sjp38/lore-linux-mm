Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3DF396B711C
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 17:49:36 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id l9so13539046plt.7
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 14:49:36 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f90si19717368plb.362.2018.12.04.14.49.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 14:49:35 -0800 (PST)
Date: Tue, 4 Dec 2018 14:49:31 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/4][V4] drop the mmap_sem when doing IO in the fault
 path
Message-Id: <20181204144931.03566f7e21615e3c2c1b18e8@linux-foundation.org>
In-Reply-To: <20181130195812.19536-1-josef@toxicpanda.com>
References: <20181130195812.19536-1-josef@toxicpanda.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, jack@suse.cz

On Fri, 30 Nov 2018 14:58:08 -0500 Josef Bacik <josef@toxicpanda.com> wrote:

> Now that we have proper isolation in place with cgroups2 we have started going
> through and fixing the various priority inversions.  Most are all gone now, but
> this one is sort of weird since it's not necessarily a priority inversion that
> happens within the kernel, but rather because of something userspace does.
> 
> We have giant applications that we want to protect, and parts of these giant
> applications do things like watch the system state to determine how healthy the
> box is for load balancing and such.  This involves running 'ps' or other such
> utilities.  These utilities will often walk /proc/<pid>/whatever, and these
> files can sometimes need to down_read(&task->mmap_sem).  Not usually a big deal,
> but we noticed when we are stress testing that sometimes our protected
> application has latency spikes trying to get the mmap_sem for tasks that are in
> lower priority cgroups.
> 
> This is because any down_write() on a semaphore essentially turns it into a
> mutex, so even if we currently have it held for reading, any new readers will
> not be allowed on to keep from starving the writer.  This is fine, except a
> lower priority task could be stuck doing IO because it has been throttled to the
> point that its IO is taking much longer than normal.  But because a higher
> priority group depends on this completing it is now stuck behind lower priority
> work.
> 
> In order to avoid this particular priority inversion we want to use the existing
> retry mechanism to stop from holding the mmap_sem at all if we are going to do
> IO.  This already exists in the read case sort of, but needed to be extended for
> more than just grabbing the page lock.  With io.latency we throttle at
> submit_bio() time, so the readahead stuff can block and even page_cache_read can
> block, so all these paths need to have the mmap_sem dropped.
> 
> The other big thing is ->page_mkwrite.  btrfs is particularly shitty here
> because we have to reserve space for the dirty page, which can be a very
> expensive operation.  We use the same retry method as the read path, and simply
> cache the page and verify the page is still setup properly the next pass through
> ->page_mkwrite().

Seems reasonable.  I have a few minorish changeloggish comments.

We're at v4 and no acks have been gathered?
