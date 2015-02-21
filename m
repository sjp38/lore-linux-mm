Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0EF6B6B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 21:37:58 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id x12so16218093wgg.11
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 18:37:57 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id s20si5776024wiv.35.2015.02.20.18.37.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Feb 2015 18:37:56 -0800 (PST)
Date: Sat, 21 Feb 2015 02:37:55 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] fs: avoid locking sb_lock in grab_super_passive()
Message-ID: <20150221023754.GT29656@ZenIV.linux.org.uk>
References: <20150219171934.20458.30175.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150219171934.20458.30175.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Thu, Feb 19, 2015 at 08:19:35PM +0300, Konstantin Khlebnikov wrote:
> I've noticed significant locking contention in memory reclaimer around
> sb_lock inside grab_super_passive(). Grab_super_passive() is called from
> two places: in icache/dcache shrinkers (function super_cache_scan) and
> from writeback (function __writeback_inodes_wb). Both are required for
> progress in memory reclaimer.
> 
> Also this lock isn't irq-safe. And I've seen suspicious livelock under
> serious memory pressure where reclaimer was called from interrupt which
> have happened right in place where sb_lock is held in normal context,
> so all other cpus were stuck on that lock too.

Excuse me, but this part is BS - its call is immediately preceded by
        if (!(sc->gfp_mask & __GFP_FS))
                return SHRINK_STOP;
and if we *ever* hit GFP_FS allocation from interrupt, we are really
screwed.  If nothing else, both prune_dcache_sb() and prune_icache_sb()
can wait for all kinds of IO; you really don't want that called in an
interrupt context.  The same goes for writeback_sb_inodes(), while we
are at it.

If you ever see that in an interrupt context, you have a very bad problem
on hands.

Said that, not bothering with sb_lock (and ->s_count) in those two callers
makes sense.  Applied, with name changed to trylock_super().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
