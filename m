Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 86BFB83292
	for <linux-mm@kvack.org>; Tue, 23 May 2017 17:57:07 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e131so179986963pfh.7
        for <linux-mm@kvack.org>; Tue, 23 May 2017 14:57:07 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n4si22384608pfk.396.2017.05.23.14.57.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 14:57:06 -0700 (PDT)
Date: Tue, 23 May 2017 14:57:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: make kswapd try harder to keep active pages in
 cache
Message-Id: <20170523145704.afa4ad145af572275e310148@linux-foundation.org>
In-Reply-To: <1495549403-3719-1-git-send-email-jbacik@fb.com>
References: <1495549403-3719-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: kernel-team@fb.com, riel@redhat.com, hannes@cmpxchg.org, linux-mm@kvack.org

On Tue, 23 May 2017 10:23:23 -0400 Josef Bacik <josef@toxicpanda.com> wrote:

> When testing a slab heavy workload I noticed that we often would barely
> reclaim anything at all from slab when kswapd started doing reclaim.
> This is because we use the ratio of nr_scanned / nr_lru to determine how
> much of slab we should reclaim.  But in a slab only/mostly workload we
> will not have much page cache to reclaim, and thus our ratio will be
> really low and not at all related to where the memory on the system is.
> Instead we want to use a ratio of the reclaimable slab to the actual
> reclaimable space on the system.  That way if we are slab heavy we work
> harder to reclaim slab.
> 
> The other part of this that hurts is when we are running close to full
> memory with our working set.  If we start putting a lot of reclaimable
> slab pressure on the system (think find /, or some other silliness), we
> will happily evict the active pages over the slab cache.  This is kind
> of backwards as we want to do all that we can to keep the active working
> set in memory, and instead evict these short lived objects.  The same
> thing occurs when say you do a yum update of a few packages while your
> working set takes up most of RAM, you end up with inactive lists being
> relatively small and so we reclaim active pages even though we could
> reclaim these short lived inactive pages.
> 
> My approach here is twofold.  First, keep track of the difference in
> inactive and slab pages since the last time kswapd ran.  In the first
> run this will just be the overall counts of inactive and slab, but for
> each subsequent run we'll have a good idea of where the memory pressure
> is coming from.  Then we use this information to put pressure on either
> the inactive lists or the slab caches, depending on where the pressure
> is coming from.
>
> ...
>

hm, that's a pretty big change.  I took it, but it will require quite
some reviewing and testing to get further, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
