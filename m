Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id DFCAF6B0006
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 11:57:02 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 14 Mar 2013 01:50:49 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id A2728357804E
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 02:56:58 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2DFutab47644722
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 02:56:55 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2DFuvr3031558
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 02:56:58 +1100
Message-ID: <5140A1C0.8060503@linux.vnet.ibm.com>
Date: Wed, 13 Mar 2013 10:56:48 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: zsmalloc limitations and related topics
References: <0efe9610-1aa5-4aa9-bde9-227acfa969ca@default> <20130313151359.GA3130@linux.vnet.ibm.com> <51409C65.1040207@linux.vnet.ibm.com>
In-Reply-To: <51409C65.1040207@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>, minchan@kernel.org, Nitin Gupta <nitingupta910@gmail.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bob Liu <lliubbo@gmail.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>

On 03/13/2013 10:33 AM, Seth Jennings wrote:
> The periodic writeback that Rob mentions would go something like this
> for zswap:
> 
> ---
>  mm/filemap.c |    3 +--
>  mm/zswap.c   |   63 +++++++++++++++++++++++++++++++++++++++++++++++++++++-----
>  2 files changed, 59 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 83efee7..fe63e95 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -735,12 +735,11 @@ repeat:
>  	if (page && !radix_tree_exception(page)) {
>  		lock_page(page);
>  		/* Has the page been truncated? */
> -		if (unlikely(page->mapping != mapping)) {
> +		if (unlikely(page_mapping(page) != mapping)) {
>  			unlock_page(page);
>  			page_cache_release(page);
>  			goto repeat;
>  		}
> -		VM_BUG_ON(page->index != offset);

A little followup here, previously we were using find_get_page() in
zswap_get_swap_cache_page() and if the page was already in the swap
cache, then we aborted the writeback of that entry.  However, if we do
wish to write the page back, as is the case in periodic writeback, we
must find _and_ lock it which suggests using find_lock_page() instead.

My first attempt to just do a s/find_get_page/find_lock_page/ failed
because, for entries that were already in the swap cache, we would hang
in the repeat loop of find_lock_page() forever because page->mapping of
pages in the swap cache is not set to &swapper_space.

However, there is logic in the page_mapping() function to handle swap
cache entries, hence the change here.

Also page->index != offset for swap cache pages so I just took out the
VM_BUG_ON().

Another solution would be to just set the mapping and index fields of
swap cache pages, if those fields (or fields in the same union) aren't
being used already.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
