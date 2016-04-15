Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9E6AD6B0253
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 04:42:48 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id q8so63196802lfe.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 01:42:48 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id 140si38962122wmb.5.2016.04.15.01.42.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 01:42:46 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id l6so4138007wml.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 01:42:46 -0700 (PDT)
Date: Fri, 15 Apr 2016 10:42:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mmotm woes, mainly compaction
Message-ID: <20160415084244.GC32377@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1604120005350.1832@eggly.anvils>
 <20160412121020.GC10771@dhcp22.suse.cz>
 <alpine.LSU.2.11.1604141114290.1086@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1604141114290.1086@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 14-04-16 13:15:51, Hugh Dickins wrote:
> On Tue, 12 Apr 2016, Michal Hocko wrote:
[...]
> > @@ -938,7 +938,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
> >  		 * the retry loop is too short and in the sync-light case,
> >  		 * the overhead of stalling is too much
> >  		 */
> > -		if (mode != MIGRATE_SYNC) {
> > +		if (mode < MIGRATE_SYNC) {
> >  			rc = -EBUSY;
> >  			goto out_unlock;
> >  		}
> 
> ... saying "if (mode == MIGRATE_ASYNC) {" there, so that
> MIGRATE_SYNC_LIGHT would proceed to wait_on_page_writeback() when force.
> 
> And that patch did not help at all, on either machine: so although
> pages under writeback had been my suspicion, and motivation for your
> patch, it just wasn't the issue.

OK, So it was not the writeback which blocked the compaction. This is
good to know. But I guess we want to wait for writeback longterm. I kind
of like the MIGRATE_SYNC vs. MIGRATE_SYNC_WRITEOUT split. I will think
again whether to add it to the series or not some more.

> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3030,8 +3030,8 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
> >  	 * failure could be caused by weak migration mode.
> >  	 */
> >  	if (compaction_failed(compact_result)) {
> > -		if (*migrate_mode == MIGRATE_ASYNC) {
> > -			*migrate_mode = MIGRATE_SYNC_LIGHT;
> > +		if (*migrate_mode < MIGRATE_SYNC) {
> > +			*migrate_mode++;
> >  			return true;
> >  		}
> >  		return false;
> 
> Thanks so much for your followup mail, pointing out that it should say
> (*migrate_mode)++.  I never noticed that.  So the set of patches I had
> been testing before was doing something quite random, I don't want to
> think about exactly what it was doing.  Yet proved useful...
> 
> ... because the thing that was really wrong (and I spent far too long
> studying compaction.c before noticing in page_alloc.c) was this:
> 
> 	/*
> 	 * It can become very expensive to allocate transparent hugepages at
> 	 * fault, so use asynchronous memory compaction for THP unless it is
> 	 * khugepaged trying to collapse.
> 	 */
> 	if (!is_thp_gfp_mask(gfp_mask) || (current->flags & PF_KTHREAD))
> 		migration_mode = MIGRATE_SYNC_LIGHT;
> 
> Yes, but advancing migration_mode before should_compact_retry() checks
> whether it was MIGRATE_ASYNC, so eliminating the retry when MIGRATE_ASYNC
> compaction_failed().  And the bogus *migrate_mode++ code had appeared to
> work by interposing an additional state for a retry.

Ouch. My http://lkml.kernel.org/r/1459855533-4600-11-git-send-email-mhocko@kernel.org
has moved the code down after noretry: label for this very reason.
Andrew has asked about this because it has caused the conflict when
applying both your and mine patch series but the end results contains
both the original code and my moved migrate_mode update for the noretry
path. I have even checked my patch when posted to mm-commit ML but
failed to notice that the to-be-removed-hunk is still there!

That would mean that there is no change to be done in my original patch,
just to apply it properly in mmotm tree. I will ask Andrew to drop the
whole series from the mmotm tree and will repost the whole series again
sometimes next week. I have done some changes in the patch ordering
which should make it easier to merge in smaller parts because the core
part of the change should sit longer in the mmomt before it gets merged.

> So all I had to do to get OOM-free results, on both machines, was to
> remove those lines quoted above.  Now, no doubt it's wrong (for THP)
> to remove them completely, but I don't want to second-guess you on
> where to do the equivalent check: over to you for that.

As I have tried to explain
http://lkml.kernel.org/r/20160406092841.GE24272@dhcp22.suse.cz moving
the check down for thp is OK.
 
> I'm over-optimistic when I say OOM-free: on the G5 yes; but I did
> see an order=2 OOM after an hour on the laptop one time, and much
> sooner when I applied your further three patches (classzone_idx etc),

well, classzone_idx patch is fixing a long term bug where we actually
never triggered OOM for order != 0. So it might be possible that a
previously existing issue was just papered over.

> again on the laptop, on one occasion but not another.  Something not
> quite right, but much easier to live with than before, and will need
> a separate tedious investigation if it persists.

I really hope I will have some tracepoints ready soon which would help
to pinpoint what is going on there.

> Earlier on, when all my suspicions were in compaction.c, I did make a
> couple of probable fixes there, though neither helped out of my OOMs:
> 
> At present MIGRATE_SYNC_LIGHT is allowing __isolate_lru_page() to
> isolate a PageWriteback page, which __unmap_and_move() then rejects
> with -EBUSY: of course the writeback might complete in between, but
> that's not what we usually expect, so probably better not to isolate it.

Those two definitely should be in sync.

> And where compact_zone() sets whole_zone, I tried a BUG_ON if
> compact_scanners_met() already, and hit that as a real possibility
> (only when compactors competing perhaps): without the BUG_ON, it
> would proceed to compact_finished() COMPACT_COMPLETE without doing
> any work at all - and the new should_compact_retry() code is placing
> more faith in that compact_result than perhaps it deserves.  No need
> to BUG_ON then, just be stricter about setting whole_zone.

Interesting, I will have to check this closer.

Thanks again!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
