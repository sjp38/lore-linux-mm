Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2F03A6B0035
	for <linux-mm@kvack.org>; Tue,  6 May 2014 16:30:11 -0400 (EDT)
Received: by mail-qa0-f42.google.com with SMTP id j5so19602qaq.15
        for <linux-mm@kvack.org>; Tue, 06 May 2014 13:30:10 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id v9si5727126qar.105.2014.05.06.13.30.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 May 2014 13:30:10 -0700 (PDT)
Date: Tue, 6 May 2014 22:30:06 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 17/17] mm: filemap: Avoid unnecessary barries and
 waitqueue lookup in unlock_page fastpath
Message-ID: <20140506203006.GF1429@laptop.programming.kicks-ass.net>
References: <1398933888-4940-1-git-send-email-mgorman@suse.de>
 <1398933888-4940-18-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1398933888-4940-18-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu, May 01, 2014 at 09:44:48AM +0100, Mel Gorman wrote:
> +/*
> + * If PageWaiters was found to be set at unlock time, __wake_page_waiters
> + * should be called to actually perform the wakeup of waiters.
> + */
> +static inline void __wake_page_waiters(struct page *page)
> +{
> +	ClearPageWaiters(page);

-ENOCOMMENT

barriers should always come with a comment that explain the memory
ordering and reference the pairing barrier.

Also, FWIW, there's a mass rename queued for .16 that'll make this:

  smp_mb__after_atomic();

but for now it will also still provide the old names with a __deprecated
tag on, so no real harm.

> +	smp_mb__after_clear_bit();
> +	wake_up_page(page, PG_locked);
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
