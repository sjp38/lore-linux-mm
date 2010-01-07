Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BEAEC6B006A
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 17:37:12 -0500 (EST)
Date: Thu, 7 Jan 2010 14:36:51 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: + hugetlb-fix-section-mismatch-warning-in-hugetlbc.patch added
 to -mm tree
Message-Id: <20100107143651.2fa73662.randy.dunlap@oracle.com>
In-Reply-To: <201001072218.o07MIPNm020870@imap1.linux-foundation.org>
References: <201001072218.o07MIPNm020870@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, rakib.mullick@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 07 Jan 2010 14:18:25 -0800 akpm@linux-foundation.org wrote:

> 
> The patch titled
>      hugetlb: fix section mismatch warning in hugetlb.c
> has been added to the -mm tree.  Its filename is
>      hugetlb-fix-section-mismatch-warning-in-hugetlbc.patch
> 
> 
> ------------------------------------------------------
> Subject: hugetlb: fix section mismatch warning in hugetlb.c
> From: Rakib Mullick <rakib.mullick@gmail.com>
> 
> Since hugetlb_sysfs_add_hstate()'s caller is __init and it isn't
> referencing from any other function, we can do this.

Hi,

I looked at this section mismatch warning too.
Maybe I'm reading too much into it (so I have cc-ed linux-mm),
but it looks like hugetlbfs supports callbacks for node
hotplug & unplug:

in hugetlb_register_all_nodes():

	/*
	 * Let the node sysdev driver know we're here so it can
	 * [un]register hstate attributes on node hotplug.
	 */
	register_hugetlbfs_with_node(hugetlb_register_node,
				     hugetlb_unregister_node);

If so, then hugetlb_register_node() could be called at any time
(like after system init), and it would then call
hugetlb_sysfs_add_hstate(), which would be bad.

Am I misunderstanding the hotplug callbacks?
or can you explain just a bit better, please?
Thanks.


> Signed-off-by: Rakib Mullick <rakib.mullick@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/hugetlb.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff -puN mm/hugetlb.c~hugetlb-fix-section-mismatch-warning-in-hugetlbc mm/hugetlb.c
> --- a/mm/hugetlb.c~hugetlb-fix-section-mismatch-warning-in-hugetlbc
> +++ a/mm/hugetlb.c
> @@ -1650,7 +1650,7 @@ static void hugetlb_unregister_all_nodes
>   * Register hstate attributes for a single node sysdev.
>   * No-op if attributes already registered.
>   */
> -void hugetlb_register_node(struct node *node)
> +void __init hugetlb_register_node(struct node *node)
>  {
>  	struct hstate *h;
>  	struct node_hstate *nhs = &node_hstates[node->sysdev.id];
> @@ -1683,7 +1683,7 @@ void hugetlb_register_node(struct node *
>   * sysdevs of nodes that have memory.  All on-line nodes should have
>   * registered their associated sysdev by this time.
>   */
> -static void hugetlb_register_all_nodes(void)
> +static void __init hugetlb_register_all_nodes(void)
>  {
>  	int nid;
>  
> @@ -1712,7 +1712,7 @@ static struct hstate *kobj_to_node_hstat
>  
>  static void hugetlb_unregister_all_nodes(void) { }
>  
> -static void hugetlb_register_all_nodes(void) { }
> +static void __init hugetlb_register_all_nodes(void) { }
>  
>  #endif
>  
> _


---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
