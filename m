Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C80236B01F0
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 04:19:59 -0400 (EDT)
Date: Tue, 17 Aug 2010 17:18:17 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 0/9] Hugepage migration (v2)
Message-ID: <20100817081817.GA28969@spritzera.linux.bs1.fc.nec.co.jp>
References: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.DEB.2.00.1008110806070.673@router.home>
 <20100812075323.GA6112@spritzera.linux.bs1.fc.nec.co.jp>
 <alpine.DEB.2.00.1008130744550.27542@router.home>
 <20100816091935.GB3388@spritzera.linux.bs1.fc.nec.co.jp>
 <alpine.DEB.2.00.1008160707420.11420@router.home>
 <20100817023719.GC12736@spritzera.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100817023719.GC12736@spritzera.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 17, 2010 at 11:37:19AM +0900, Naoya Horiguchi wrote:
> On Mon, Aug 16, 2010 at 07:19:58AM -0500, Christoph Lameter wrote:
> > On Mon, 16 Aug 2010, Naoya Horiguchi wrote:
> > 
> > > In my understanding, in current code "other processors increasing refcount
> > > during migration" can happen both in non-hugepage direct I/O and in hugepage
> > > direct I/O in the similar way (i.e. get_user_pages_fast() from dio_refill_pages()).
> > > So I think there is no specific problem to hugepage.
> > > Or am I missing your point?
> > 
> > With a single page there is the check of the refcount during migration
> > after all the references have been removed (at that point the page is no
> > longer mapped by any process and direct iO can no longer be
> > initiated without a page fault.
> 
> The same checking mechanism works for hugeapge.

So, my previous comment below was not correct:

>>> This patch only handles migration under direct I/O.
>>> For the opposite (direct I/O under migration) it's not true.
>>> I wrote additional patches (later I'll reply to this email)
>>> for solving locking problem. Could you review them?

The hugepage migration patchset should work fine without the
additional page locking patch.
Please ignore the additional page locking patch-set
and review the hugepage migration patch-set only.
Sorry for confusion.

I explain below why the page lock in direct I/O is not needed to avoid
race with migration. This is true for both hugepage and non-huge page.

Race between page migration and direct I/O is in essense the one between
try_to_unmap() in unmap_and_move() and get_user_pages_fast() in dio_get_page().

When try_to_unmap() is called before get_user_pages_fast(),
all ptes pointing to the page to be migrated are replaced to migration
swap entries, so direct I/O code experiences page fault.
In the page fault, the kernel finds migration swap entry and waits the page lock
(which was held by migration code before try_to_unmap()) to be unlocked
in migration_entry_wait(), so direct I/O blocks until migration completes.

When get_user_pages_fast() is called before try_to_unmap(),
direct I/O code increments refcount on the target page.
Because this refcount is not associated to the mapping,
migration code will find remaining refcounts after try_to_unmap()
unmaps all mappings. Then refcount check decides migration to fail,
so direct I/O is continued safely.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
