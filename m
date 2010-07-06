Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9A5566B024D
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 11:55:17 -0400 (EDT)
Date: Tue, 6 Jul 2010 10:54:38 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 5/7] hugetlb: pin oldpage in page migration
In-Reply-To: <1278049646-29769-6-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.00.1007061050320.4938@router.home>
References: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1278049646-29769-6-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2 Jul 2010, Naoya Horiguchi wrote:

> This patch introduces pinning the old page during page migration
> to avoid freeing it before we complete copying.

The old page is already pinned due to the reference count that is taken
when the page is put onto the list of pages to be migrated. See
do_move_pages() f.e.

Huge pages use a different scheme?

> This race condition can happen for privately mapped or anonymous hugepage.

It cannot happen unless you come up with your own scheme of managing pages
to be migrated and bypass migrate_pages(). There you should take the
refcount.

>  	/*
> +	 * It's reasonable to pin the old page until unmapping and copying
> +	 * complete, because when the original page is an anonymous hugepage,
> +	 * it will be freed in try_to_unmap() due to the fact that
> +	 * all references of anonymous hugepage come from mapcount.
> +	 * Although in the other cases no problem comes out without pinning,
> +	 * it looks logically correct to do it.
> +	 */
> +	get_page(page);
> +
> +	/*

Its already pinned. Dont do this. migrate_pages() relies on the caller
having pinned the page already.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
