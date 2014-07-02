Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 012E06B0035
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 16:42:24 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so12405114pdj.8
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 13:42:24 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id hq3si31172794pad.87.2014.07.02.13.42.17
        for <linux-mm@kvack.org>;
        Wed, 02 Jul 2014 13:42:23 -0700 (PDT)
Date: Wed, 2 Jul 2014 13:42:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 0/3] free reclaimed pages by paging out instantly
Message-Id: <20140702134215.2bf830dcb904c34bd2e2b9e8@linux-foundation.org>
In-Reply-To: <1404260029-11525-1-git-send-email-minchan@kernel.org>
References: <1404260029-11525-1-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On Wed,  2 Jul 2014 09:13:46 +0900 Minchan Kim <minchan@kernel.org> wrote:

> Normally, I/O completed pages for reclaim would be rotated into
> inactive LRU tail without freeing. The why it works is we can't free
> page from atomic context(ie, end_page_writeback) due to vaious locks
> isn't aware of atomic context.
> 
> So for reclaiming the I/O completed pages, we need one more iteration
> of reclaim and it could make unnecessary aging as well as CPU overhead.
> 
> Long time ago, at the first trial, most concern was memcg locking
> but recently, Johnannes tried amazing effort to make memcg lock simple
> and got merged into mmotm so I coded up based on mmotm tree.
> (Kudos to Johannes)
> 
> On 1G, 12 CPU kvm guest, build kernel 5 times and result was
> 
> allocstall
> vanilla: records: 5 avg: 4733.80 std: 913.55(19.30%) max: 6442.00 min: 3719.00
> improve: records: 5 avg: 1514.20 std: 441.69(29.17%) max: 1974.00 min: 863.00

Well yes.  We're now doing unaccounted, impact-a-random-process work in
irq context which was previously being done in process context,
accounted to the process which was allocating the memory.  Some would
call this a regression ;)

> pgrotated
> vanilla: records: 5 avg: 873313.80 std: 40999.20(4.69%) max: 954722.00 min: 845903.00
> improve: records: 5 avg: 28406.40 std: 3296.02(11.60%) max: 34552.00 min: 25047.00

Still a surprisingly high amount of rotation going on.

> Most of field in vmstat are not changed too much but things I can notice
> is allocstall and pgrotated. We could save allocstall(ie, direct relcaim)
> and pgrotated very much.
> 
> Welcome testing, review and any feedback!

Well, it will worsen IRQ latencies and it's all more code for us to
maintain.  I think I'd like to see a better story about the end-user
benefits before proceeding.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
