Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 901436B01F2
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 05:28:33 -0400 (EDT)
Date: Thu, 19 Aug 2010 17:28:28 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/9] HWPOISON, hugetlb: move PG_HWPoison bit check
Message-ID: <20100819092828.GA20863@localhost>
References: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1281432464-14833-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20100818001842.GC6928@localhost>
 <20100819075543.GA4125@spritzera.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100819075543.GA4125@spritzera.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 19, 2010 at 03:55:43PM +0800, Naoya Horiguchi wrote:
> On Wed, Aug 18, 2010 at 08:18:42AM +0800, Wu Fengguang wrote:
> > On Tue, Aug 10, 2010 at 05:27:36PM +0800, Naoya Horiguchi wrote:
> > > In order to handle metadatum correctly, we should check whether the hugepage
> > > we are going to access is HWPOISONed *before* incrementing mapcount,
> > > adding the hugepage into pagecache or constructing anon_vma.
> > > This patch also adds retry code when there is a race between
> > > alloc_huge_page() and memory failure.
> > 
> > This duplicates the PageHWPoison() test into 3 places without really
> > address any problem. For example, there are still _unavoidable_ races
> > between PageHWPoison() and add_to_page_cache().
> > 
> > What's the problem you are trying to resolve here? If there are
> > data structure corruption, we may need to do it in some other ways.
> 
> The problem I tried to resolve in this patch is the corruption of
> data structures when memory failure occurs between alloc_huge_page()
> and lock_page().
> The corruption occurs because page fault can fail with metadata changes
> remained (such as refcount, mapcount, etc.) 
> Since the PageHWPoison() check is for avoiding hwpoisoned page remained
> in pagecache mapping to the process, it should be done in
> "found in pagecache" branch, not in the common path.
> This patch moves the check to "found in pagecache" branch.

That's good stuff to put in the changelog.

> In addition to that, I added 2 PageHWPoison checks in "new allocation" branches
> to enhance the possiblity to recover from memory failures on pages under allocation.
> But it's a different point from the original one, so I drop these retry checks.

So you'll remove the first two chunks and retain the 3rd chunk?
That makes it a small bug-fix patch suitable for 2.6.36 and I'll
happily ACK it :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
