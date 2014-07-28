Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id F347B6B0036
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 10:49:26 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id m5so7947168qaj.35
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 07:49:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m9si32515629qge.84.2014.07.28.07.49.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jul 2014 07:49:26 -0700 (PDT)
Date: Mon, 28 Jul 2014 10:48:55 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/2] APEI, GHES: Cleanup unnecessary function for
 lock-less list
Message-ID: <20140728144855.GC27391@nhori.redhat.com>
References: <1406530260-26078-1-git-send-email-gong.chen@linux.intel.com>
 <1406530260-26078-2-git-send-email-gong.chen@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1406530260-26078-2-git-send-email-gong.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Chen, Gong" <gong.chen@linux.intel.com>
Cc: tony.luck@intel.com, bp@alien8.de, linux-acpi@vger.kernel.org, linux-mm@kvack.org

On Mon, Jul 28, 2014 at 02:50:59AM -0400, Chen, Gong wrote:
> We have provided a reverse function for lock-less list so delete
> uncessary codes.
> 
> Signed-off-by: Chen, Gong <gong.chen@linux.intel.com>
> Acked-by: Borislav Petkov <bp@suse.de>

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  drivers/acpi/apei/ghes.c | 18 ++----------------
>  1 file changed, 2 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
> index dab7cb7..1f9fba9 100644
> --- a/drivers/acpi/apei/ghes.c
> +++ b/drivers/acpi/apei/ghes.c
> @@ -734,20 +734,6 @@ static int ghes_notify_sci(struct notifier_block *this,
>  	return ret;
>  }
>  
> -static struct llist_node *llist_nodes_reverse(struct llist_node *llnode)
> -{
> -	struct llist_node *next, *tail = NULL;
> -
> -	while (llnode) {
> -		next = llnode->next;
> -		llnode->next = tail;
> -		tail = llnode;
> -		llnode = next;
> -	}
> -
> -	return tail;
> -}
> -
>  static void ghes_proc_in_irq(struct irq_work *irq_work)
>  {
>  	struct llist_node *llnode, *next;
> @@ -761,7 +747,7 @@ static void ghes_proc_in_irq(struct irq_work *irq_work)
>  	 * Because the time order of estatus in list is reversed,
>  	 * revert it back to proper order.
>  	 */
> -	llnode = llist_nodes_reverse(llnode);
> +	llnode = llist_reverse_order(llnode);
>  	while (llnode) {
>  		next = llnode->next;
>  		estatus_node = llist_entry(llnode, struct ghes_estatus_node,
> @@ -794,7 +780,7 @@ static void ghes_print_queued_estatus(void)
>  	 * Because the time order of estatus in list is reversed,
>  	 * revert it back to proper order.
>  	 */
> -	llnode = llist_nodes_reverse(llnode);
> +	llnode = llist_reverse_order(llnode);
>  	while (llnode) {
>  		estatus_node = llist_entry(llnode, struct ghes_estatus_node,
>  					   llnode);
> -- 
> 2.0.0.rc2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
