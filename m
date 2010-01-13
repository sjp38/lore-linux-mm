Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BC0386B0071
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 04:28:50 -0500 (EST)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o0D9SjL4009599
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 09:28:46 GMT
Received: from pwj16 (pwj16.prod.google.com [10.241.219.80])
	by kpbe19.cbf.corp.google.com with ESMTP id o0D9S7kB001141
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 01:28:44 -0800
Received: by pwj16 with SMTP id 16so3363105pwj.15
        for <linux-mm@kvack.org>; Wed, 13 Jan 2010 01:28:44 -0800 (PST)
Date: Wed, 13 Jan 2010 01:28:40 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/6] hugetlb: Fix section mismatches
In-Reply-To: <20100113004938.715904356@suse.com>
Message-ID: <alpine.DEB.2.00.1001130127450.469@chino.kir.corp.google.com>
References: <20100113004855.550486769@suse.com> <20100113004938.715904356@suse.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jeff Mahoney <jeffm@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jan 2010, Jeff Mahoney wrote:

>  hugetlb_register_node calls hugetlb_sysfs_add_hstate, which is marked with
>  __init. Since hugetlb_register_node is only called by
>  hugetlb_register_all_nodes, which in turn is only called by hugetlb_init,
>  it's safe to mark both of them as __init.
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

This is wrong, you want to move hugetlb_register_all_nodes() to 
.init.text, not hugetlb_unregister_all_nodes().

> @@ -1650,7 +1650,7 @@ static void hugetlb_unregister_all_nodes
>   * Register hstate attributes for a single node sysdev.
>   * No-op if attributes already registered.
>   */
> -void hugetlb_register_node(struct node *node)
> +void __init hugetlb_register_node(struct node *node)
>  {
>  	struct hstate *h;
>  	struct node_hstate *nhs = &node_hstates[node->sysdev.id];

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
