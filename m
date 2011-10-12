Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2FD546B002D
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 15:01:22 -0400 (EDT)
Received: by qadb17 with SMTP id b17so1170662qad.14
        for <linux-mm@kvack.org>; Wed, 12 Oct 2011 12:01:20 -0700 (PDT)
Date: Wed, 12 Oct 2011 12:01:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Reduce vm_stat cacheline contention in
 __vm_enough_memory
Message-Id: <20111012120118.e948f40a.akpm@linux-foundation.org>
In-Reply-To: <20111012160202.GA18666@sgi.com>
References: <20111012160202.GA18666@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On Wed, 12 Oct 2011 11:02:02 -0500
Dimitri Sivanich <sivanich@sgi.com> wrote:

> Tmpfs I/O throughput testing on UV systems has shown writeback contention
> between multiple writer threads (even when each thread writes to a separate
> tmpfs mount point).
> 
> A large part of this is caused by cacheline contention reading the vm_stat
> array in the __vm_enough_memory check.
> 
> The attached test patch illustrates a possible avenue for improvement in this
> area.  By locally caching the values read from vm_stat (and refreshing the
> values after 2 seconds), I was able to improve tmpfs writeback performance from
> ~300 MB/sec to ~700 MB/sec with 120 threads writing data simultaneously to
> files on separate tmpfs mount points (tested on 3.1.0-rc9).
> 
> Note that this patch is simply to illustrate the gains that can be made here.
> What I'm looking for is some guidance on an acceptable way to accomplish the
> task of reducing contention in this area, either by caching these values in a
> way similar to the attached patch, or by some other mechanism if this is
> unacceptable.

Yes, the global vm_stat[] array is a problem - I'm surprised it's hung
around for this long.  Altering the sysctl_overcommit_memory mode will
hide the problem, but that's no good.

I think we've discussed switching vm_stat[] to a contention-avoiding
counter scheme.  Simply using <percpu_counter.h> would be the simplest
approach.  They'll introduce inaccuracies but hopefully any problems
from that will be minor for the global page counters.

otoh, I think we've been round this loop before and I don't recall why
nothing happened.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
