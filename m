Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9CB816B0031
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 01:50:04 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id ma3so19565869pbc.12
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 22:50:04 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id fu1si57341157pbc.344.2014.01.06.22.50.02
        for <linux-mm@kvack.org>;
        Mon, 06 Jan 2014 22:50:03 -0800 (PST)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is no local memory
References: <20140107132100.5b5ad198@kryten>
Date: Mon, 06 Jan 2014 22:49:53 -0800
In-Reply-To: <20140107132100.5b5ad198@kryten> (Anton Blanchard's message of
	"Tue, 7 Jan 2014 13:21:00 +1100")
Message-ID: <871u0k5lri.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Blanchard <anton@samba.org>
Cc: benh@kernel.crashing.org, paulus@samba.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, nacc@linux.vnet.ibm.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

Anton Blanchard <anton@samba.org> writes:
>
> Thoughts? It seems like we could hit a similar situation if a machine
> is balanced but we run out of memory on a single node.

Yes I agree, but your patch doesn't seem to attempt to handle this?

-Andi
>
> Index: b/mm/slub.c
> ===================================================================
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2278,10 +2278,17 @@ redo:
>  
>  	if (unlikely(!node_match(page, node))) {
>  		stat(s, ALLOC_NODE_MISMATCH);
> -		deactivate_slab(s, page, c->freelist);
> -		c->page = NULL;
> -		c->freelist = NULL;
> -		goto new_slab;
> +
> +		/*
> +		 * If the node contains no memory there is no point in trying
> +		 * to allocate a new node local slab
> +		 */
> +		if (node_spanned_pages(node)) {
> +			deactivate_slab(s, page, c->freelist);
> +			c->page = NULL;
> +			c->freelist = NULL;
> +			goto new_slab;
> +		}
>  	}
>  
>  	/*
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
