Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 297116B007E
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 16:16:02 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hb4so104850805pac.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 13:16:02 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id wl8si2457517pab.33.2016.04.14.13.16.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 13:16:01 -0700 (PDT)
Received: by mail-pa0-x22e.google.com with SMTP id zm5so47926440pac.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 13:16:01 -0700 (PDT)
Date: Thu, 14 Apr 2016 13:15:51 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mmotm woes, mainly compaction
In-Reply-To: <20160412121020.GC10771@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1604141114290.1086@eggly.anvils>
References: <alpine.LSU.2.11.1604120005350.1832@eggly.anvils> <20160412121020.GC10771@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 12 Apr 2016, Michal Hocko wrote:
> On Tue 12-04-16 00:18:00, Hugh Dickins wrote:
> > Michal, I'm sorry to say that I now find that I misinformed you.
> > 
> > You'll remember when we were chasing the order=2 OOMs on two of my
> > machines at the end of March (in private mail).  And you sent me a
> > mail containing two patches, the second "Another thing to try ...
> > so this on top" doing a *migrate_mode++.
> > 
> > I answered you definitively that the first patch worked,
> > so "I haven't tried adding the one below at all".
> > 
> > Not true, I'm afraid.  Although I had split the *migrate_mode++ one
> > off into a separate patch that I did not apply, I found looking back
> > today (when trying to work out why order=2 OOMs were still a problem
> > on mmotm 2016-04-06) that I never deleted that part from the end of
> > the first patch; so in fact what I'd been testing had included the
> > second; and now I find that _it_ was the effective solution.
> > 
> > Which is particularly sad because I think we were both a bit
> > uneasy about the *migrate_mode++ one: partly the style of it
> > incrementing the enum; but more seriously that it advances all the
> > way to MIGRATE_SYNC, when the first went only to MIGRATE_SYNC_LIGHT.
> 
> Yeah, I was thinking about this some more and I have dropped
> MIGRATE_SYNC patch because this is just too dangerous. It gets all the
> way to to writeout() and this is a great stack overflow hazard.

That's a very good point about MIGRATE_SYNC, which I never thought of.
Worried me for a moment, since I do use MIGRATE_SYNC from a reclaim
context in huge tmpfs (its shrinker): but in fact that one's not a
problem, because the only pages it's trying to migrate are its own,
and shmem migrates PageDirty without writeout(); whereas compaction
has to deal with pages from assorted unknown filesystems, including
the writeout() ones.

> But I
> guess we do not need this writeout and wait_on_page_writeback (done from
> __unmap_and_move) would be sufficient. I was already thinking about
> splitting MIGRATE_SYNC into two states one allowing the wait on events
> and the other to allow the writeout.

Might eventually turn out to be necessary, but not for my immediate
issue: see below.

> 
> > But without it, I am still stuck with the order=2 OOMs.
> > 
> > And worse: after establishing that that fixes the order=2 OOMs for
> > me on 4.6-rc2-mm1, I thought I'd better check that the three you
> > posted today (the 1/2 classzone_idx one, the 2/2 prevent looping
> > forever, and the "ction-abstract-compaction-feedback-to-helpers-fix";
> > but I'm too far behind to consider or try the RFC thp backoff one)
> > (a) did not surprisingly fix it on their own, and (b) worked well
> > with the *migrate_mode++ one added in.
> 
> I am not really sure what you have been testing here. The hugetlb load
> or the same make on tmpfs? I would be really surprised if any of the
> above pathces made any difference for the make workload. 

Merely the make on tmpfs.  Optimizing hugepage loads is something else,
that I'm just not going to worry about, until your end has settled down:
hence why I asked Andrew to back out my 30/31 and 31/31, to get out of
your way.  Just the recognition of THP allocations is a tricky matter,
which gets even more confusing when chasing a moving target.

>  
> > (a) as you'd expect, they did not help on their own; and (b) they
> > worked fine together on the G5 (until it hit the powerpc swapping
> > sigsegv, which I think the powerpc guys are hoping is a figment of
> > my imagination); but (b) they did not work fine together on the
> > laptop, that combination now gives it order=1 OOMs.  Despair.
> 
> Something is definitelly wrong here.

Indeed!  And you'll kick yourself when you read on :)

> I have already seen that compaction
> is sometimes giving surprising results. I have seen Vlastimil has posted
> some fixes so maybe this would be a side effect. I also hope to come up
> with some reasonable set of trace points to tell us more but let's see
> whether the order-2 issue can be solved first.
> 
> This is still with the ugly enum++ but let's close eyes and think about
> something nicer...
> 
> Thanks!
> ---
> diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
> index ebf3d89a3919..e1947d7af63f 100644
> --- a/include/linux/migrate_mode.h
> +++ b/include/linux/migrate_mode.h
> @@ -6,11 +6,14 @@
>   *	on most operations but not ->writepage as the potential stall time
>   *	is too significant
>   * MIGRATE_SYNC will block when migrating pages
> + * MIGRATE_SYNC_WRITEOUT will trigger the IO when migrating pages. Make sure
> + * 	to not use this flag from deep stacks.
>   */
>  enum migrate_mode {
>  	MIGRATE_ASYNC,
>  	MIGRATE_SYNC_LIGHT,
>  	MIGRATE_SYNC,
> +	MIGRATE_SYNC_WRITEOUT,
>  };

To tell the truth, I didn't even try applying your patch, because I knew
it was going to clash with my MIGRATE_SHMEM_RECOVERy one, and I didn't
want to spend time thinking about what the resultant tests ought to be
(!= this or == that or < the other or what?).

(And your patch seemed unnecessarily extensive, changing the meaning of
MIGRATE_SYNC, then adding a new mode beyond it to do what MIGRATE_SYNC
used to do.)

Since I wasn't worried about latency in the experiment, just order=2
OOMs, I instead tried the much simpler patch...

> @@ -938,7 +938,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>  		 * the retry loop is too short and in the sync-light case,
>  		 * the overhead of stalling is too much
>  		 */
> -		if (mode != MIGRATE_SYNC) {
> +		if (mode < MIGRATE_SYNC) {
>  			rc = -EBUSY;
>  			goto out_unlock;
>  		}

... saying "if (mode == MIGRATE_ASYNC) {" there, so that
MIGRATE_SYNC_LIGHT would proceed to wait_on_page_writeback() when force.

And that patch did not help at all, on either machine: so although
pages under writeback had been my suspicion, and motivation for your
patch, it just wasn't the issue.

> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3030,8 +3030,8 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
>  	 * failure could be caused by weak migration mode.
>  	 */
>  	if (compaction_failed(compact_result)) {
> -		if (*migrate_mode == MIGRATE_ASYNC) {
> -			*migrate_mode = MIGRATE_SYNC_LIGHT;
> +		if (*migrate_mode < MIGRATE_SYNC) {
> +			*migrate_mode++;
>  			return true;
>  		}
>  		return false;

Thanks so much for your followup mail, pointing out that it should say
(*migrate_mode)++.  I never noticed that.  So the set of patches I had
been testing before was doing something quite random, I don't want to
think about exactly what it was doing.  Yet proved useful...

... because the thing that was really wrong (and I spent far too long
studying compaction.c before noticing in page_alloc.c) was this:

	/*
	 * It can become very expensive to allocate transparent hugepages at
	 * fault, so use asynchronous memory compaction for THP unless it is
	 * khugepaged trying to collapse.
	 */
	if (!is_thp_gfp_mask(gfp_mask) || (current->flags & PF_KTHREAD))
		migration_mode = MIGRATE_SYNC_LIGHT;

Yes, but advancing migration_mode before should_compact_retry() checks
whether it was MIGRATE_ASYNC, so eliminating the retry when MIGRATE_ASYNC
compaction_failed().  And the bogus *migrate_mode++ code had appeared to
work by interposing an additional state for a retry.

So all I had to do to get OOM-free results, on both machines, was to
remove those lines quoted above.  Now, no doubt it's wrong (for THP)
to remove them completely, but I don't want to second-guess you on
where to do the equivalent check: over to you for that.

I'm over-optimistic when I say OOM-free: on the G5 yes; but I did
see an order=2 OOM after an hour on the laptop one time, and much
sooner when I applied your further three patches (classzone_idx etc),
again on the laptop, on one occasion but not another.  Something not
quite right, but much easier to live with than before, and will need
a separate tedious investigation if it persists.

Earlier on, when all my suspicions were in compaction.c, I did make a
couple of probable fixes there, though neither helped out of my OOMs:

At present MIGRATE_SYNC_LIGHT is allowing __isolate_lru_page() to
isolate a PageWriteback page, which __unmap_and_move() then rejects
with -EBUSY: of course the writeback might complete in between, but
that's not what we usually expect, so probably better not to isolate it.

And where compact_zone() sets whole_zone, I tried a BUG_ON if
compact_scanners_met() already, and hit that as a real possibility
(only when compactors competing perhaps): without the BUG_ON, it
would proceed to compact_finished() COMPACT_COMPLETE without doing
any work at all - and the new should_compact_retry() code is placing
more faith in that compact_result than perhaps it deserves.  No need
to BUG_ON then, just be stricter about setting whole_zone.

(I do worry about the skip hints: once in MIGRATE_SYNC_LIGHT mode,
compaction seemed good at finding pages to migrate, but not so good
at then finding enough free pages to migrate them into.  Perhaps
there were none, but it left me suspicious.)

Vlastimil, thanks so much for picking up my bits and pieces a couple
of days ago: I think I'm going to impose upon you again with the below,
if that's not too irritating.

Signed-off-by: Hugh Dickins <hughd@google.com>

--- 4.6-rc2-mm1/mm/compaction.c	2016-04-11 11:35:08.536604712 -0700
+++ linux/mm/compaction.c	2016-04-13 23:17:03.671959715 -0700
@@ -1190,7 +1190,7 @@ static isolate_migrate_t isolate_migrate
 	struct page *page;
 	const isolate_mode_t isolate_mode =
 		(sysctl_compact_unevictable_allowed ? ISOLATE_UNEVICTABLE : 0) |
-		(cc->mode == MIGRATE_ASYNC ? ISOLATE_ASYNC_MIGRATE : 0);
+		(cc->mode != MIGRATE_SYNC ? ISOLATE_ASYNC_MIGRATE : 0);
 
 	/*
 	 * Start at where we last stopped, or beginning of the zone as
@@ -1459,8 +1459,8 @@ static enum compact_result compact_zone(
 		zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
 	}
 
-	if (cc->migrate_pfn == start_pfn)
-		cc->whole_zone = true;
+	cc->whole_zone = cc->migrate_pfn == start_pfn &&
+			cc->free_pfn == pageblock_start_pfn(end_pfn - 1);
 
 	cc->last_migrated_pfn = 0;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
