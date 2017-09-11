Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0C26E6B029B
	for <linux-mm@kvack.org>; Sun, 10 Sep 2017 21:13:38 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t3so14011955pgt.7
        for <linux-mm@kvack.org>; Sun, 10 Sep 2017 18:13:38 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 201sor1596881pfu.68.2017.09.10.18.13.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 10 Sep 2017 18:13:36 -0700 (PDT)
Date: Sun, 10 Sep 2017 18:13:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/2] mm, compaction: persistently skip hugetlbfs
 pageblocks
In-Reply-To: <74a33b7b-0586-c08a-cb2e-1c3d2872815d@suse.cz>
Message-ID: <alpine.DEB.2.10.1709101812400.85650@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1708151638550.106658@chino.kir.corp.google.com> <alpine.DEB.2.10.1708151639130.106658@chino.kir.corp.google.com> <fa162335-a36d-153a-7b5d-1d9c2d57aebc@suse.cz> <74a33b7b-0586-c08a-cb2e-1c3d2872815d@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, 1 Sep 2017, Vlastimil Babka wrote:

> The pageblock_skip_persistent() function checks for HugeTLB pages of pageblock
> order. When clearing pageblock skip bits for compaction, the bits are not
> cleared for such pageblocks, because they cannot contain base pages suitable
> for migration, nor free pages to use as migration targets.
> 
> This optimization can be simply extended to all compound pages of order equal
> or larger than pageblock order, because migrating such pages (if they support
> it) cannot help sub-pageblock fragmentation. This includes THP's and also
> gigantic HugeTLB pages, which the current implementation doesn't persistently
> skip due to a strict pageblock_order equality check and not recognizing tail
> pages.
> 
> Additionally, this patch removes the pageblock_skip_persistent() calls from
> migration and free scanner, since the generic compound page treatment together
> with update_pageblock_skip() call will also lead to pageblocks starting with a
> large enough compound page being immediately marked for skipping, which then
> becomes persistent.
> 

As mentioned in my other two emails, I'm not sure that persistently 
skipping thp memory is necessary and I disagree that we should not be 
persistently skipping pageblocks when cc->ignore_skip_hint is true.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
