Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B38926B0071
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 16:47:30 -0500 (EST)
Date: Mon, 1 Feb 2010 15:46:47 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 28 of 32] pmd_trans_huge migrate bugcheck
In-Reply-To: <ffe6ba65ebf40dde3c92.1264969659@v2.random>
Message-ID: <alpine.DEB.2.00.1002011542170.2384@router.home>
References: <patchbomb.1264969631@v2.random> <ffe6ba65ebf40dde3c92.1264969659@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Sun, 31 Jan 2010, Andrea Arcangeli wrote:

> diff --git a/mm/migrate.c b/mm/migrate.c
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -819,6 +820,10 @@ static int do_move_page_to_node_array(st
>  		if (PageReserved(page) || PageKsm(page))
>  			goto put_and_set;
>
> +		if (unlikely(PageTransCompound(page)))
> +			if (unlikely(split_huge_page(page)))
> +				goto put_and_set;
> +
>  		pp->page = page;
>  		err = page_to_nid(page);

How does this work? do_move_page_to_node_array takes an array of page
pointers in pp (struct page_to_node).  Lets say one is a compound page.

Now we split this into 512 4k pages? and pp only points to the first of
them?

The rest of the move_pages() logic will only see one 4k page and move it.

The remaining 511 pages are left dangling? With an increased refcount?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
