Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id BFE706B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 13:46:07 -0400 (EDT)
Received: by mail-pf0-f171.google.com with SMTP id n1so37987616pfn.2
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 10:46:07 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 13si5919029pft.59.2016.04.06.10.46.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 10:46:07 -0700 (PDT)
Date: Wed, 6 Apr 2016 10:46:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 09/11] mm, compaction: Abstract compaction feedback to
 helpers
Message-Id: <20160406104605.e6254b153f2ab5a26fd556e5@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.11.1604051727150.7348@eggly.anvils>
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
	<1459855533-4600-10-git-send-email-mhocko@kernel.org>
	<20160405165826.012236e79db7f396fda546a8@linux-foundation.org>
	<alpine.LSU.2.11.1604051727150.7348@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, 5 Apr 2016 17:55:39 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:

> > I ended up doing this:
> > 
> > 	/* Checks for THP-specific high-order allocations */
> > 	if (!is_thp_allocation(gfp_mask, order))
> > 		migration_mode = MIGRATE_SYNC_LIGHT;
> > 
> > 	/*
> > 	 * Checks for THP-specific high-order allocations and back off
> > 	 * if the the compaction backed off
> > 	 */
> > 	if (is_thp_allocation(gfp_mask) && compaction_withdrawn(compact_result))
> > 		goto nopage;
> 
> You'll already have found that is_thp_allocation() needs the order too.
> But then you had to drop a hunk out of his 10/11 also to fit with mine.
> 
> What you've done may be just right, but I haven't had time to digest
> Michal's changes yet (and not yet seen what happens to the PF_KTHREAD
> distinction), so I think it will probably end up better if you take
> his exactly as he tested and posted them, and drop my 30/31 and 31/31
> for now - I can resubmit them (or maybe drop 30 altogether) after I've
> pondered and tested a little on top of Michal's.
> 
> Huge tmpfs got along fine for many months without 30/31 and 31/31: 30
> is just for experimentation, and 31 to reduce the compaction stalls we
> saw under some loads.  Maybe I'll find that Michal's rework has changed
> the balance there anyway, and something else or nothing at all needed.
> 
> (The gfp_mask stuff was very confusing, and it's painful for me, how
> ~__GFP_KSWAPD_RECLAIM gets used as a secret password to say "THP" and
> how to angle compaction - or maybe it's all more straightforward now.)

OK, thanks.  I dropped
huge-tmpfs-shmem_huge_gfpmask-and-shmem_recovery_gfpmask.patch and
huge-tmpfs-no-kswapd-by-default-on-sync-allocations.patch and restored
Michal's patches.

> Many thanks for giving us both this quick exposure!

I'll push all this into -next later today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
