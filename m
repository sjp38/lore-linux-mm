Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 410058E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 18:17:03 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id q63so11436725pfi.19
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 15:17:03 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v16si20858588pgc.519.2019.01.11.15.17.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 11 Jan 2019 15:17:02 -0800 (PST)
Date: Fri, 11 Jan 2019 15:16:52 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] rbtree: fix the red root
Message-ID: <20190111231652.GN6310@bombadil.infradead.org>
References: <20190111181600.GJ6310@bombadil.infradead.org>
 <20190111205843.25761-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190111205843.25761-1-cai@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, esploit@protonmail.ch, jejb@linux.ibm.com, dgilbert@interlog.com, martin.petersen@oracle.com, joeypabalinas@gmail.com, walken@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 11, 2019 at 03:58:43PM -0500, Qian Cai wrote:
> diff --git a/lib/rbtree_test.c b/lib/rbtree_test.c
> index b7055b2a07d3..afad0213a117 100644
> --- a/lib/rbtree_test.c
> +++ b/lib/rbtree_test.c
> @@ -345,6 +345,17 @@ static int __init rbtree_test_init(void)
>  		check(0);
>  	}
>  
> +	/*
> +	 * a little regression test to catch a bug may be introduced by
> +	 * 6d58452dc06 (rbtree: adjust root color in rb_insert_color() only when
> +	 * necessary)
> +	 */
> +	insert(nodes, &root);
> +	nodes->rb.__rb_parent_color = RB_RED;
> +	insert(nodes + 1, &root);
> +	erase(nodes + 1, &root);
> +	erase(nodes, &root);

That's not a fair test!  You're poking around in the data structure to
create the situation.  This test would have failed before 6d58452dc06 too.
How do we create a tree that has a red parent at root, only using insert()
and erase()?
