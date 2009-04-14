Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 74DF55F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 10:38:08 -0400 (EDT)
Date: Tue, 14 Apr 2009 16:38:29 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH v3 1/6] mm: Don't unmap gup()ed page
Message-ID: <20090414143829.GG28265@random.random>
References: <20090414151204.C647.A69D9226@jp.fujitsu.com> <20090414151554.C64A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090414151554.C64A.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 14, 2009 at 03:16:52PM +0900, KOSAKI Motohiro wrote:
> +	if (PageSwapCache(page) &&
> +	    page_count(page) != page_mapcount(page) + 2) {
> +		ret = SWAP_FAIL;
> +		goto out_unmap;
> +	}
> +

Besides the race pointed out by Nick, this also would break KVM
swapping with mmu notifier. mmu_notifier_invalidate_page must be
invoked before reading page_count for this to work. However the
invalidate has to be moved below the
mlock/ptep_clear_flush_young_notify, no point to get rid of sptes if
any of the spte or the pte is still young.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
