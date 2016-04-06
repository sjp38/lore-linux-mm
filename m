Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7470E6B02AF
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 20:55:52 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id bx7so5117580pad.3
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 17:55:52 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id ur6si504062pac.226.2016.04.05.17.55.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 17:55:51 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id 184so21668531pff.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 17:55:51 -0700 (PDT)
Date: Tue, 5 Apr 2016 17:55:39 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 09/11] mm, compaction: Abstract compaction feedback to
 helpers
In-Reply-To: <20160405165826.012236e79db7f396fda546a8@linux-foundation.org>
Message-ID: <alpine.LSU.2.11.1604051727150.7348@eggly.anvils>
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org> <1459855533-4600-10-git-send-email-mhocko@kernel.org> <20160405165826.012236e79db7f396fda546a8@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>

On Tue, 5 Apr 2016, Andrew Morton wrote:
> On Tue,  5 Apr 2016 13:25:31 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> > -	if (is_thp_gfp_mask(gfp_mask)) {
> > -		/*
> > -		 * If compaction is deferred for high-order allocations, it is
> > -		 * because sync compaction recently failed. If this is the case
> > -		 * and the caller requested a THP allocation, we do not want
> > -		 * to heavily disrupt the system, so we fail the allocation
> > -		 * instead of entering direct reclaim.
> > -		 */
> > -		if (compact_result == COMPACT_DEFERRED)
> > -			goto nopage;
> > -
> > -		/*
> > -		 * Compaction is contended so rather back off than cause
> > -		 * excessive stalls.
> > -		 */
> > -		if(compact_result == COMPACT_CONTENDED)
> > -			goto nopage;
> > -	}
> > +	/*
> > +	 * Checks for THP-specific high-order allocations and back off
> > +	 * if the the compaction backed off
> > +	 */
> > +	if (is_thp_gfp_mask(gfp_mask) && compaction_withdrawn(compact_result))
> > +		goto nopage;
> 
> This change smashed into Hugh's "huge tmpfs: shmem_huge_gfpmask and
> shmem_recovery_gfpmask".
> 
> I ended up doing this:
> 
> 	/* Checks for THP-specific high-order allocations */
> 	if (!is_thp_allocation(gfp_mask, order))
> 		migration_mode = MIGRATE_SYNC_LIGHT;
> 
> 	/*
> 	 * Checks for THP-specific high-order allocations and back off
> 	 * if the the compaction backed off
> 	 */
> 	if (is_thp_allocation(gfp_mask) && compaction_withdrawn(compact_result))
> 		goto nopage;

You'll already have found that is_thp_allocation() needs the order too.
But then you had to drop a hunk out of his 10/11 also to fit with mine.

What you've done may be just right, but I haven't had time to digest
Michal's changes yet (and not yet seen what happens to the PF_KTHREAD
distinction), so I think it will probably end up better if you take
his exactly as he tested and posted them, and drop my 30/31 and 31/31
for now - I can resubmit them (or maybe drop 30 altogether) after I've
pondered and tested a little on top of Michal's.

Huge tmpfs got along fine for many months without 30/31 and 31/31: 30
is just for experimentation, and 31 to reduce the compaction stalls we
saw under some loads.  Maybe I'll find that Michal's rework has changed
the balance there anyway, and something else or nothing at all needed.

(The gfp_mask stuff was very confusing, and it's painful for me, how
~__GFP_KSWAPD_RECLAIM gets used as a secret password to say "THP" and
how to angle compaction - or maybe it's all more straightforward now.)

Many thanks for giving us both this quick exposure!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
