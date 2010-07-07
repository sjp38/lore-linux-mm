Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 305816B006A
	for <linux-mm@kvack.org>; Wed,  7 Jul 2010 02:46:32 -0400 (EDT)
Date: Wed, 7 Jul 2010 15:40:56 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 5/7] hugetlb: pin oldpage in page migration
Message-ID: <20100707064056.GA21962@spritzera.linux.bs1.fc.nec.co.jp>
References: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1278049646-29769-6-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.DEB.2.00.1007061050320.4938@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1007061050320.4938@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi,

Thank you for your reviewing.

On Tue, Jul 06, 2010 at 10:54:38AM -0500, Christoph Lameter wrote:
> On Fri, 2 Jul 2010, Naoya Horiguchi wrote:
> 
> > This patch introduces pinning the old page during page migration
> > to avoid freeing it before we complete copying.
> 
> The old page is already pinned due to the reference count that is taken
> when the page is put onto the list of pages to be migrated. See
> do_move_pages() f.e.

OK.

> Huge pages use a different scheme?

Different scheme is in soft offline, where the target page is not pinned
before migration.  So I should have pinned in soft offline side.
I'll fix it.

> > This race condition can happen for privately mapped or anonymous hugepage.
> 
> It cannot happen unless you come up with your own scheme of managing pages
> to be migrated and bypass migrate_pages(). There you should take the
> refcount.

Yes.

> >  	/*
> > +	 * It's reasonable to pin the old page until unmapping and copying
> > +	 * complete, because when the original page is an anonymous hugepage,
> > +	 * it will be freed in try_to_unmap() due to the fact that
> > +	 * all references of anonymous hugepage come from mapcount.
> > +	 * Although in the other cases no problem comes out without pinning,
> > +	 * it looks logically correct to do it.
> > +	 */
> > +	get_page(page);
> > +
> > +	/*
> 
> Its already pinned. Dont do this. migrate_pages() relies on the caller
> having pinned the page already.

I agree.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
