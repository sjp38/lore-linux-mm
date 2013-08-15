Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 7E2146B0068
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 02:24:03 -0400 (EDT)
Date: Thu, 15 Aug 2013 02:23:40 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1376547820-91ccjgp3-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130814164052.2ccdd5bdf7ab56deeba88e68@linux-foundation.org>
References: <1376025702-14818-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130814164052.2ccdd5bdf7ab56deeba88e68@linux-foundation.org>
Subject: Re: [PATCH v5 0/9] extend hugepage migration
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, Aug 14, 2013 at 04:40:52PM -0700, Andrew Morton wrote:
> On Fri,  9 Aug 2013 01:21:33 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > Here is the 5th version of hugepage migration patchset.
> > Changes in this version are as follows:
> >  - removed putback_active_hugepages() as a cleanup (1/9)
> >  - added code to check movability of a given hugepage (8/9)
> >  - set GFP MOVABLE flag depending on the movability of hugepage (9/9).
> > 
> > I feel that 8/9 and 9/9 contain some new things, so need reviews on them.
> > 
> > TODOs: (likely to be done after this work)
> >  - split page table lock for pmd/pud based hugepage (maybe applicable to thp)
> >  - improve alloc_migrate_target (especially in node choice)
> >  - using page walker in check_range
> 
> This is a pretty large and complex patchset.  I skimmed the patches
> (and have one trivial comment) then queued them up for a bit of
> testing.  I've asked Mel if he can find time to review the changes
> (please).
> 
> btw, it would be helpful if this [patch 0/n] had a decent overview of
> the patch series - what are the objectives, how were they achieved,
> what value they have to our users, testing results, etc.

Here is the general description:
---
Currently hugepage migration is available only for soft offlining, but
it's also useful for some other users of page migration (clearly because
users of hugepage can enjoy the benefit of mempolicy and memory hotplug.)
So this patchset tries to extend such users to support hugepage migration.

The target of this patchset is to enable hugepage migration for NUMA
related system calls (migrate_pages(2), move_pages(2), and mbind(2)),
and memory hotplug.
This patchset does not add hugepage migration for memory compaction,
because users of memory compaction mainly expect to construct thp by
arranging raw pages, and there's little or no need to compact hugepages.
CMA, another user of page migration, can have benefit from hugepage
migration, but is not enabled to support it for now (just because of
lack of testing and expertise in CMA.)

Hugepage migration of non pmd-based hugepage (for example 1GB hugepage in
x86_64, or hugepages in architectures like ia64) is not enabled for now
(again, because of lack of testing.)
---

As for how these are achived, I extended the API (migrate_pages()) to
handle hugepage (with patch 1 and 2) and adjusted code of each caller
to check and collect movable hugepages (with patch 3-7). Remaining 2
patches are kind of miscellaneous ones to avoid unexpected behavior.
Patch 8 is about making sure that we only migrate pmd-based hugepages.
And patch 9 is about choosing appropriate zone for hugepage allocation.

My test is mainly functional one, simply kicking hugepage migration via
each entry point and confirm that migration is done correctly. Test code
is available here:
  git://github.com/Naoya-Horiguchi/test_hugepage_migration_extension.git

And I always run libhugetlbfs test when changing hugetlbfs's code.
With this patchset, no regression was found in the test.

> mm-prepare-to-remove-proc-sys-vm-hugepages_treat_as_movable.patch had a
> conflict with
> http://ozlabs.org/~akpm/mmots/broken-out/mm-hugetlb-move-up-the-code-which-check-availability-of-free-huge-page.patch
> which I resolved in the obvious manner.  Please check that from a
> runtime perspective.

As replied to the mm-commits notification ("Subject: + mm-prepare-to-remove-
proc-sys-vm-hugepages_treat_as_movable.patch added to -mm tree",)
I want to replace that patch with another one ("Subject: [PATCH] hugetlb:
make htlb_alloc_mask dependent on migration support").
With the new patch, the conflict with the Joonsoo's patch changes a little
bit (only difference of htlb_alloc_mask and htlb_alloc_mask(h).)
And I confirmed that the conflict had no harm on runtime behavior (passed
my testing.)

---
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 364f745..510b232 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -555,10 +555,6 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 	struct zoneref *z;
 	unsigned int cpuset_mems_cookie;
 
-retry_cpuset:
-	cpuset_mems_cookie = get_mems_allowed();
-	zonelist = huge_zonelist(vma, address,
-					htlb_alloc_mask(h), &mpol, &nodemask);
 	/*
 	 * A child process with MAP_PRIVATE mappings created by their parent
 	 * have no page reserves. This check ensures that reservations are
@@ -572,6 +568,11 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 	if (avoid_reserve && h->free_huge_pages - h->resv_huge_pages == 0)
 		goto err;
 
+retry_cpuset:
+	cpuset_mems_cookie = get_mems_allowed();
+	zonelist = huge_zonelist(vma, address,
+					htlb_alloc_mask(h), &mpol, &nodemask);
+
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						MAX_NR_ZONES - 1, nodemask) {
 		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask(h))) {
@@ -590,7 +591,6 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 	return page;
 
 err:
-	mpol_cond_put(mpol);
 	return NULL;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
