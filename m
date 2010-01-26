Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9BA336B0095
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 17:56:31 -0500 (EST)
Message-ID: <4B5F72FF.9080204@redhat.com>
Date: Tue, 26 Jan 2010 17:55:59 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 30 of 31] transparent hugepage vmstat
References: <patchbomb.1264513915@v2.random> <d75b849a4142269635e1.1264513945@v2.random>
In-Reply-To: <d75b849a4142269635e1.1264513945@v2.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 01/26/2010 08:52 AM, Andrea Arcangeli wrote:
> From: Andrea Arcangeli<aarcange@redhat.com>
>
> Add hugepage stat information to /proc/vmstat and /proc/meminfo.
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>

> @@ -716,7 +721,10 @@ void page_add_new_anon_rmap(struct page
>   	VM_BUG_ON(address<  vma->vm_start || address>= vma->vm_end);
>   	SetPageSwapBacked(page);
>   	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
> -	__inc_zone_page_state(page, NR_ANON_PAGES);
> +	if (!PageTransHuge(page))
> +	    __inc_zone_page_state(page, NR_ANON_PAGES);
> +	else
> +	    __inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);

Does this have the potential to unbalance the pageout code, by
not counting the hugepages at all?  (as opposed to counting a
hugepage as 1 page)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
