Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 47D156B0036
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 15:12:03 -0500 (EST)
Received: by mail-ee0-f42.google.com with SMTP id e53so668417eek.1
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 12:12:02 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m44si5779058eeo.226.2013.12.19.12.12.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 12:12:02 -0800 (PST)
Date: Thu, 19 Dec 2013 20:11:58 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: bad page state in 3.13-rc4
Message-ID: <20131219201158.GT11295@suse.de>
References: <20131219040738.GA10316@redhat.com>
 <CA+55aFwweoGs3eGWXFULcqnbRbpDhpj2qrefXB5OpQOiWW8wYA@mail.gmail.com>
 <alpine.DEB.2.10.1312190930190.4238@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1312190930190.4238@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Thu, Dec 19, 2013 at 09:41:50AM -0600, Christoph Lameter wrote:
> On Wed, 18 Dec 2013, Linus Torvalds wrote:
> 
> > Somebody who knows the migration code needs to look at this. ChristophL?
> 
> Its been awhile sorry and there has been a huge amount of work done on top
> of my earlier work. Cannot debug that anymore and I am finding myself in
> the role of the old guy who just complains a lot.

Shake your fist and tell the kids to get off your lawn.

> Some of that
> functionality seems bizarre to me like the on the fly conversion between
> huge pages and regular pages, weird and complex page count handling etc
> etc.
> 
> The last time I looked at the code I was horrified to find that the new
> huge page migration does not use migration ptes to create a cooldown phase
> but directly swaps the pmd. That used to cause huge problems with regular
> pages in the past. But I was told that was all safe. Mel?

THP migration is specific to automatic NUMA balancing and the safety of
how it works is dependant upon how pmds are marked NUMA and how they are
cleared and migrated.

Dave, was this a NUMA machine? If yes, was CONFIG_NUMA_BALANCING set? If
yes, was NUMA_BALANCING_DEFAULT_ENABLED set or was numa_balancing=enable
specified on the kernel command line? I'm skeptical that this is related to
THP migration largely because the initial stack trace was in the compaction
path which does not deal with THP migration.

If this is recent, then an outside possibility is that this is related to
pmd-level split locks and mm->page_table_lock was protecting us from some
split THP vs migration race or possibly a gup page for aio vs migration
race we were previously unaware of (e.g. aio taking a reference on a page
that migration has frozen the references on, bug would be a case where
get_page instead of get_page_unless_zero was used) . Dave, when this this
bug start triggering? If it's due to a recent change in trinity, can you
check if 3.12 is also affected? If not, can you check if the bug started
happening somewhere around these commits?

ea1e7ed33708c7a760419ff9ded0a6cb90586a50 mm: create a separate slab for page->ptl allocation
539edb5846c740d78a8b6c2e43a99ca4323df68f mm: properly separate the bloated ptl from the regular case
49076ec2ccaf68610aa03d96bced9a6694b93ca1 mm: dynamically allocate page->ptl if it cannot be embedded to struct page
e009bb30c8df8a52a9622b616b67436b6a03a0cd mm: implement split page table lock for PMD level
c4088ebdca64c9a2e34a38177d2249805ede1f4b mm: convert the rest to new page table lock api
cb900f41215447433cbc456d1c4294e858a84d7c mm, hugetlb: convert hugetlbfs to use split pmd lock
c389a250ab4cfa4a3775d9f2c45271618af6d5b2 mm, thp: do not access mm->pmd_huge_pte directly
117b0791ac42f2ec447bc864e70ad622b5604059 mm, thp: move ptl taking inside page_check_address_pmd()
bf929152e9f6c49b66fad4ebf08cc95b02ce48f5 mm, thp: change pmd_trans_huge_lock() to return taken lock
e1f56c89b040134add93f686931cc266541d239a mm: convert mm->nr_ptes to atomic_long_t
e9bb18c7b95d4dcf8c7f0e14f920ca6f03109e75 mm: avoid increase sizeof(struct page) due to split page table lock
b77d88d493b8fc7a4c2dadd3bb86d1dee2f53a56 mm: drop actor argument of do_generic_file_read()

A few bad state bugs have shown up on linux-mm recently but my impression
was that they were related to rmap_walk changes currently in next. The
initial log indicated that this was 3.13-rc4 but is it really 3.13-rc4 or
are there any -next patches applied?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
