Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id AF1B66B006A
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 18:17:43 -0500 (EST)
Date: Fri, 22 Jan 2010 00:17:14 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 22 of 30] pmd_trans_huge migrate bugcheck
Message-ID: <20100121231714.GJ5598@random.random>
References: <patchbomb.1264054824@v2.random>
 <f5766ea214603fc6a64f.1264054846@v2.random>
 <alpine.DEB.2.00.1001211431300.13130@router.home>
 <20100121230127.GI5598@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100121230127.GI5598@random.random>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 22, 2010 at 12:01:27AM +0100, Andrea Arcangeli wrote:
> @@ -833,6 +834,9 @@ static int do_move_page_to_node_array(st
>  				!migrate_all)
>  			goto put_and_set;
>  
> +		if (unlikely(PageTransHuge(page)))
> +			if (unlikely(split_huge_page(page)))
> +				goto put_and_set;
>  		err = isolate_lru_page(page);
>  		if (!err) {
>  			list_add_tail(&page->lru, &pagelist);

This was too fast of a patch, I've to move this a few lines above so
the mapcount check will work too (also note, pagetranshuge bugs on
tail pages and I like to keep it that way to be more strict on the
other users, so it should be replaced by pagecompound in addition to
moving it a little up). refcounting will adjust automatically and
atomically during the split, simply mapcount will be >0 after the split
on the tailpage and the tail_page->_count will be boosted by the mapcount too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
