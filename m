Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DFC756B0071
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 10:40:18 -0500 (EST)
Subject: Re: [patch 2/6] hugetlb: Fix section mismatches
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20100113004938.715904356@suse.com>
References: <20100113004855.550486769@suse.com>
	 <20100113004938.715904356@suse.com>
Content-Type: text/plain
Date: Wed, 13 Jan 2010 10:40:12 -0500
Message-Id: <1263397212.11942.97.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jeff Mahoney <jeffm@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-01-12 at 19:48 -0500, Jeff Mahoney wrote:
> plain text document attachment (patches.rpmify)
> hugetlb_register_node calls hugetlb_sysfs_add_hstate, which is marked with
>  __init. Since hugetlb_register_node is only called by
>  hugetlb_register_all_nodes, which in turn is only called by hugetlb_init,
>  it's safe to mark both of them as __init.

Actually, hugetlb_register_node() also called, via a function pointer
that hugetlb registers with the sysfs node driver, when a node is hot
plugged.  So, I think the correct approach is to remove the '__init'
from hugetlb_sysfs_add_hstate() as this is also used at runtime.  I
missed this in the original submittal.

Regards,
Lee Schermerhorn

> 
> Signed-off-by: Jeff Mahoney <jeffm@suse.com>
> ---
>  mm/hugetlb.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1630,7 +1630,7 @@ void hugetlb_unregister_node(struct node
>   * hugetlb module exit:  unregister hstate attributes from node sysdevs
>   * that have them.
>   */
> -static void hugetlb_unregister_all_nodes(void)
> +static void __init hugetlb_unregister_all_nodes(void)
>  {
>  	int nid;
>  
> @@ -1650,7 +1650,7 @@ static void hugetlb_unregister_all_nodes
>   * Register hstate attributes for a single node sysdev.
>   * No-op if attributes already registered.
>   */
> -void hugetlb_register_node(struct node *node)
> +void __init hugetlb_register_node(struct node *node)
>  {
>  	struct hstate *h;
>  	struct node_hstate *nhs = &node_hstates[node->sysdev.id];
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
