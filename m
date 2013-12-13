Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id E303D6B0035
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 13:12:14 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id en1so1471012wid.9
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 10:12:14 -0800 (PST)
Date: Fri, 13 Dec 2013 19:12:05 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC PATCH 3/3] Change THP behavior
Message-ID: <20131213181205.GA16534@redhat.com>
References: <cover.1386790423.git.athorlton@sgi.com> <20131212180057.GD134240@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131212180057.GD134240@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Benjamin LaHaise <bcrl@kvack.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, David Rientjes <rientjes@google.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jiang Liu <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Glauber Costa <glommer@parallels.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org

I know almost nothing about thp, unlikely I understand this patch
correctly...

But, afaics, the main idea is that until we have mm->thp_threshold
faults we install the tail pages of temp_hugepage->page as a normal
anonymous page, then we actually add the Head/Tail metadata and add
the necessary huge_pmd/etc.

I simply can't understand how this can work until make_compound_page()
is called. Just for example, what happens after sys_munmap() ? If
nothing else, who will find and free temp_hugepage connected to this
area? Or, what if sys_mremap() moves this vma? find_pmd_mm_freelist()
won't find the right temp_thp after that? Or split_vma, etc.

And make_compound_page() itself looks suspicious,

On 12/12, Alex Thorlton wrote:
>
> +void make_compound_page(struct page *page, unsigned long order)
> +{
> +	int i, max_count = 0, max_mapcount = 0;
> +	int nr_pages = 1 << order;
> +
> +	set_compound_page_dtor(page, free_compound_page);
> +	set_compound_order(page, order);
> +
> +	__SetPageHead(page);
> +
> +	/*
> +	 * we clear all the mappings here, so we have to remember to set
> +	 * them back up!
> +	 */
> +	page->mapping = NULL;
> +
> +	max_count = (int) atomic_read(&page->_count);
> +	max_mapcount = (int) atomic_read(&page->_mapcount);
> +
> +	for (i = 1; i < nr_pages; i++) {
> +		int cur_count, cur_mapcount;
> +		struct page *p = page + i;
> +		p->flags = 0; /* this seems dumb */
> +		__SetPageTail(p);

Just for example, what if put_page(p) or get_page(p) is called after
__SetPageTail() ?

Afaics, this page was already visible to, say, get_user_pages() and
it can have external references.

In fact everything else looks suspicious too but let me repeat that
I do not really understand this code. So please do not count this as
review, but perhaps the changelog should tell more to explain what
this patch actually does and how this all should work?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
