Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id D77236B0044
	for <linux-mm@kvack.org>; Wed,  9 May 2012 17:25:53 -0400 (EDT)
Date: Wed, 9 May 2012 23:25:44 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] MM: fixup on addition to bootmem data list
Message-ID: <20120509212544.GA20147@cmpxchg.org>
References: <1335498104-31900-1-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1335498104-31900-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org

On Fri, Apr 27, 2012 at 11:41:43AM +0800, Gavin Shan wrote:
> The objects of "struct bootmem_data_t" are being linked together
> to form double-linked list sequentially based on its minimal page
> frame number. Current implementation implicitly supports the
> following cases, which means the inserting point for current bootmem
> data depends on how "list_for_each" works. That makes the code a
> little hard to read. Besides, "list_for_each" and "list_entry" can
> be replaced with "list_for_each_entry".
> 
> 	- The linked list is empty.
> 	- There has no entry in the linked list, whose minimal page
> 	  frame number is bigger than current one.
> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> ---
>  mm/bootmem.c |   16 ++++++++--------
>  1 files changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/bootmem.c b/mm/bootmem.c
> index 0131170..5a04536 100644
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c
> @@ -77,16 +77,16 @@ unsigned long __init bootmem_bootmap_pages(unsigned long pages)
>   */
>  static void __init link_bootmem(bootmem_data_t *bdata)
>  {
> -	struct list_head *iter;
> +	bootmem_data_t *ent;
>  
> -	list_for_each(iter, &bdata_list) {
> -		bootmem_data_t *ent;
> -
> -		ent = list_entry(iter, bootmem_data_t, list);
> -		if (bdata->node_min_pfn < ent->node_min_pfn)
> -			break;
> +	list_for_each_entry(ent, &bdata_list, list) {
> +		if (bdata->node_min_pfn < ent->node_min_pfn) {
> +			list_add_tail(&bdata->list, &ent->list);
> +			return;
> +		}
>  	}
> -	list_add_tail(&bdata->list, iter);
> +
> +	list_add_tail(&bdata->list, &bdata_list);

Yes, this is better, thanks.

Would you care to fix up the patch subject (it's a cleanup, not a fix)
and send it on to Andrew Morton?  You can include

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
