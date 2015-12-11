Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id C202F6B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 19:31:57 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so55514736pac.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 16:31:57 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 12si23528872pfb.199.2015.12.10.16.31.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 16:31:56 -0800 (PST)
Date: Thu, 10 Dec 2015 16:31:55 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
Message-Id: <20151210163155.20d983b36bdc7fb7da60db57@linux-foundation.org>
In-Reply-To: <1447181081-30056-2-git-send-email-aarcange@redhat.com>
References: <1447181081-30056-1-git-send-email-aarcange@redhat.com>
	<1447181081-30056-2-git-send-email-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Arjan van de Ven <arjan@linux.intel.com>

On Tue, 10 Nov 2015 19:44:41 +0100 Andrea Arcangeli <aarcange@redhat.com> wrote:

> The STABLE_NODE_DUP_HEAD must be an unique valid pointer never used
> elsewhere in any stable_node->head/node to avoid a clashes with the
> stable_node->node.rb_parent_color pointer, and different from
> &migrate_nodes. So the second field of &migrate_nodes is picked and
> verified as always safe with a BUILD_BUG_ON in case the list_head
> implementation changes in the future.
> 
> ...
>
> +	/*
> +	 * We need the second aligned pointer of the migrate_nodes
> +	 * list_head to stay clear from the rb_parent_color union
> +	 * (aligned and different than any node) and also different
> +	 * from &migrate_nodes. This will verify that future list.h changes
> +	 * don't break STABLE_NODE_DUP_HEAD.
> +	 */
> +	BUILD_BUG_ON(STABLE_NODE_DUP_HEAD <= &migrate_nodes);
> +	BUILD_BUG_ON(STABLE_NODE_DUP_HEAD >= &migrate_nodes + 1);

mm/ksm.c: In function 'remove_node_from_stable_tree':
mm/ksm.c:618: error: call to '__compiletime_assert_618' declared with attribute error: BUILD_BUG_ON failed: STABLE_NODE_DUP_HEAD <= &migrate_nodes
mm/ksm.c:619: error: call to '__compiletime_assert_619' declared with attribute error: BUILD_BUG_ON failed: STABLE_NODE_DUP_HEAD >= &migrate_nodes + 1

That's with gcc-4.4.4.

I don't have time at present to investigate so I'll switch them to
WARN_ON_ONCE for now.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
