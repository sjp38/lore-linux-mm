Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 928486B006C
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 13:38:43 -0500 (EST)
Received: by mail-da0-f49.google.com with SMTP id v40so2203649dad.22
        for <linux-mm@kvack.org>; Fri, 21 Dec 2012 10:38:42 -0800 (PST)
Date: Fri, 21 Dec 2012 10:38:45 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: migrate_misplaced_transhuge_page: no page_count check?
In-Reply-To: <20121220164923.GB13367@suse.de>
Message-ID: <alpine.LNX.2.00.1212211030540.1893@eggly.anvils>
References: <alpine.LNX.2.00.1212192011320.25992@eggly.anvils> <20121220164923.GB13367@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>

On Thu, 20 Dec 2012, Mel Gorman wrote:
> On Wed, Dec 19, 2012 at 08:52:37PM -0800, Hugh Dickins wrote:
> > Mel, Ingo,
> > 
> > I want to raise again a question I raised (in offline mail with Mel)
> > a couple of weeks ago.
> > 
> 
> It's a good question and thanks for kicking me on this again because I
> had not followed up properly.
> 
> > I see only a page_mapcount check in migrate_misplaced_transhuge_page,
> > and don't understand how migration can be safe against the possibility
> > of an earlier call to get_user_pages or get_user_pages_fast (intended
> > to pin a part of the THP) without a page_count check.
> > 
> 
> It would be hard to trigger bugs in relation to it but it's not fundamentally
> safe either and just happens to work due to limitations of THP as much as
> anything else. Adding Andrea to cc in case I'm lacking imagination. IMO,
> the GUP would need to be relatively long-lived to trigger a bug so the
> realistic candidate is direct IO.  it. It would look something like;
> 
> 1. pin for direct IO
> 2. PTE scanner run, mark pte_numa
> 3. Incur a fault on a remote node, migrate the page
> 4. direct IO completes on old page and is lost
> 
> Steps 1 and 2 can happen in either order. I am reasonably sure specjbb,
> autonumabench and friends are not exercising such paths so I would not
> have encountered it.
> 
> The end result would look like a read or write corruption to the application
> but I also expect that applications that are accessing pages under direct
> IO are already buggy and it'd be hard to tell the difference.  It's a
> completely different situation than what khugepaged has to deal with.
> The migration concerns for base pages are also much more involvedi.
> 
> > (I'm also still somewhat worried about unidentified attempts to
> > pin the page concurrently; but since I don't have an example to give,
> > and concurrent get_user_pages or get_user_pages_fast wouldn't get past
> > the pmd_numa, let's not worry too much about my unidentified anxiety ;)
> > 
> 
> You are right to be worried.
> 
> > migrate_page_move_mapping and migrate_huge_page_move_mapping check
> > page_count, but migrate_misplaced_transhuge_page doesn't use those.
> > __collapse_huge_page_isolate and khugepaged_scan_pmd (over in
> > huge_memory.c) take commented care to check page_count lest GUP.
> > 
> > I can see that page_count might often be raised by concurrent faults
> > on the same pmd_numa, waiting on the lock_page in do_huge_pmd_numa_page.
> > That's unfortunate, and maybe you can find a clever way to discount
> > those.  But safety must come first: don't we need to check page_count?
> > 
> 
> We do and I'm not super-worried about the concurrent faults as a brief
> check indicated that only 2% of migration attempts failed due to parallel
> faults elevating the count when running autonumabench. The impact is that
> the migration is delayed until the next PTE scan which is bad, but not
> bad enough to delay the obvious safety fix first. How about this?
> 
> ---8<---
> mm: migrate: Check page_count of THP before migrating
> 
> Hugh Dickins poined out that migrate_misplaced_transhuge_page() does not
> check page_count before migrating like base page migration and khugepage. He
> could not see why this was safe and he is right.
> 
> It happens to work for the most part. The page_mapcount() check ensures that
> only a single address space is using this page and as THPs are typically
> private it should not be possible for another address space to fault it in
> parallel. If the address space has one associated task then it's difficult to
> have both a GUP pin and be referencing the page at the same time. If there
> are multiple tasks then a buggy scenario requires that another thread be
> accessing the page while the direct IO is in flight. This is dodgy behaviour
> as there is a possibility of corruption with or without THP migration. It
> would be difficult to identify the corruption as being a migration bug.
> 
> While we happen to be ok for THP migration versus GUP it is shoddy to
> depend on such "safety" so this patch checks the page count similar to
> anonymous pages. Note that this does not mean that the page_mapcount()
> check can go away. If we were to remove the page_mapcount() check then
> the THP would have to be unmapped from all referencing PTEs, replaced with
> migration PTEs and restored properly afterwards.
> 
> Reported-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Thanks very much for responding so quickly on this, Mel.  It pains
me that I cannot yet say acked-by, because I need to spend more time
checking it, and cannot do so today.

I like where you've placed the check, that's just right.  But I'm
worried that perhaps there's a putback_lru_page missing, and wonder
if it's missing even without this additional patch.  It would not
be immediately obvious if it's missing, the pages wouldn't leak,
but more and more would become unreclaimable until freed.

Hugh

> ---
>  mm/migrate.c |    8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 3b676b0..7636b90 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1679,7 +1679,13 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  	page_xchg_last_nid(new_page, page_last_nid(page));
>  
>  	isolated = numamigrate_isolate_page(pgdat, page);
> -	if (!isolated) {
> +
> +	/*
> +	 * Failing to isolate or a GUP pin prevents migration. The expected
> +	 * page count is 2. 1 for anonymous pages without a mapping and 1
> +	 * for the callers pin
> +	 */
> +	if (!isolated || page_count(page) != 2) {
>  		count_vm_events(PGMIGRATE_FAIL, HPAGE_PMD_NR);
>  		put_page(new_page);
>  		goto out_keep_locked;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
