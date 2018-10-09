Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 269BE6B000A
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 18:08:48 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id o18-v6so2390670pgv.14
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 15:08:48 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f9-v6si21294240pgh.325.2018.10.09.15.08.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 15:08:47 -0700 (PDT)
Date: Tue, 9 Oct 2018 15:08:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/4] mm: workingset: add vmstat counter for shadow nodes
Message-Id: <20181009150845.8656eb8ede045ca5f4cc4b21@linux-foundation.org>
In-Reply-To: <20181009184732.762-4-hannes@cmpxchg.org>
References: <20181009184732.762-1-hannes@cmpxchg.org>
	<20181009184732.762-4-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue,  9 Oct 2018 14:47:32 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> --- a/mm/workingset.c
> +++ b/mm/workingset.c
> @@ -378,11 +378,17 @@ void workingset_update_node(struct xa_node *node)
>  	 * as node->private_list is protected by the i_pages lock.
>  	 */
>  	if (node->count && node->count == node->nr_values) {
> -		if (list_empty(&node->private_list))
> +		if (list_empty(&node->private_list)) {
>  			list_lru_add(&shadow_nodes, &node->private_list);
> +			__inc_lruvec_page_state(virt_to_page(node),
> +						WORKINGSET_NODES);
> +		}
>  	} else {
> -		if (!list_empty(&node->private_list))
> +		if (!list_empty(&node->private_list)) {
>  			list_lru_del(&shadow_nodes, &node->private_list);
> +			__dec_lruvec_page_state(virt_to_page(node),
> +						WORKINGSET_NODES);
> +		}
>  	}
>  }

A bit worried that we're depending on the caller's caller to have
disabled interrupts to avoid subtle and rare errors.

Can we do this?

--- a/mm/workingset.c~mm-workingset-add-vmstat-counter-for-shadow-nodes-fix
+++ a/mm/workingset.c
@@ -377,6 +377,8 @@ void workingset_update_node(struct radix
 	 * already where they should be. The list_empty() test is safe
 	 * as node->private_list is protected by the i_pages lock.
 	 */
+	WARN_ON_ONCE(!irqs_disabled());	/* For __inc_lruvec_page_state */
+
 	if (node->count && node->count == node->exceptional) {
 		if (list_empty(&node->private_list)) {
 			list_lru_add(&shadow_nodes, &node->private_list);
_
