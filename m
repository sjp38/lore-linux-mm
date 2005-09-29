Date: Wed, 28 Sep 2005 23:09:17 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 2/3 htlb-fault] Demand faulting for huge pages
Message-Id: <20050928230917.2be72d69.akpm@osdl.org>
In-Reply-To: <1127939538.26401.36.camel@localhost.localdomain>
References: <1127939141.26401.32.camel@localhost.localdomain>
	<1127939538.26401.36.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Adam Litke <agl@us.ibm.com> wrote:
>
> +static struct page *find_get_huge_page(struct address_space *mapping,
>  +			unsigned long idx)
>  +{
>  +	struct page *page = NULL;
>  +
>  +retry:
>  +	page = find_get_page(mapping, idx);
>  +	if (page)
>  +		goto out;
>  +
>  +	if (hugetlb_get_quota(mapping))
>  +		goto out;
>  +	page = alloc_huge_page();
>  +	if (!page) {
>  +		hugetlb_put_quota(mapping);
>  +		goto out;
>  +	}
>  +
>  +	if (add_to_page_cache(page, mapping, idx, GFP_ATOMIC)) {
>  +		put_page(page);
>  +		hugetlb_put_quota(mapping);
>  +		goto retry;

If add_to_page_cache() fails due to failure in radix_tree_preload(), this
code will lock up.

A lame fix is to check for -ENOMEM and bale.  A better fix would be to use
GFP_KERNEL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
