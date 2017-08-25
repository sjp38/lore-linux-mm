Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E5AEF6810C8
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 16:47:17 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p8so1254452wrf.2
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 13:47:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l197si2038128wma.196.2017.08.25.13.47.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 13:47:16 -0700 (PDT)
Date: Fri, 25 Aug 2017 13:47:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm,page_alloc: Don't call __node_reclaim() with
 oom_lock held.
Message-Id: <20170825134714.844d9fb169e5b1883c3dd6eb@linux-foundation.org>
In-Reply-To: <1503577106-9196-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1503577106-9196-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

On Thu, 24 Aug 2017 21:18:25 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:

> We are doing last second memory allocation attempt before calling
> out_of_memory(). But since slab shrinker functions might indirectly
> wait for other thread's __GFP_DIRECT_RECLAIM && !__GFP_NORETRY memory
> allocations via sleeping locks, calling slab shrinker functions from
> node_reclaim() from get_page_from_freelist() with oom_lock held has
> possibility of deadlock. Therefore, make sure that last second memory
> allocation attempt does not call slab shrinker functions.

I wonder if there's any way we could gert lockdep to detect this sort
of thing.

Has the deadlock been observed in testing?  Do we think this fix
should be backported into -stable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
