Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7C6F16B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 23:24:27 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e14so491962pfi.9
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 20:24:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o12-v6si371052plg.463.2018.04.26.20.24.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 26 Apr 2018 20:24:26 -0700 (PDT)
Date: Thu, 26 Apr 2018 20:24:23 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v11 18/63] page cache: Add and replace pages using the
 XArray
Message-ID: <20180427032423.GB14502@bombadil.infradead.org>
References: <20180414141316.7167-1-willy@infradead.org>
 <20180414141316.7167-19-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180414141316.7167-19-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

On Sat, Apr 14, 2018 at 07:12:31AM -0700, Matthew Wilcox wrote:
> -	xa_lock_irq(&mapping->i_pages);
> -	error = page_cache_tree_insert(mapping, page, shadowp);
> -	radix_tree_preload_end();
> -	if (unlikely(error))
> -		goto err_insert;
> +	do {
> +		xas_lock_irq(&xas);
> +		old = xas_create(&xas);
> +		if (xas_error(&xas))
> +			goto unlock;
> +		if (xa_is_value(old)) {
> +			mapping->nrexceptional--;
> +			if (shadowp)
> +				*shadowp = old;
> +		} else if (old) {
> +			xas_set_err(&xas, -EEXIST);
> +			goto unlock;
> +		}
> +
> +		xas_store(&xas, page);
> +		mapping->nrpages++;

At LSFMM, I was unable to explain in the moment why I was doing
xas_create() followed by xas_store(), rather than just calling
xas_store().  Looking at this code on my laptop, it was immediately
obvious to me -- the semantics of attempting to insert a page into the
page cache when there's already one there is to return -EEXIST.

We could also write this function this way:

+		old = xas_load(&xas);
+		if (old && !xa_is_value(old))
+			xas_set_err(&xas, -EEXIST);
+		xas_store(&xas, page);
+		if (xas_error(&xas))
+			goto unlock;
+		if (old) {
+			mapping->nrexceptional--;
+			if (shadowp)
+				*shadowp = old;
+		}
+		mapping->nrpages++;

which I think is slightly clearer.  Or for those allergic to gotos, the
entire function could look like (option 3):

+       do {
+               xas_lock_irq(&xas);
+               old = xas_load(&xas);
+		if (old && !xa_is_value(old))
+                       xas_set_err(&xas, -EEXIST);
+               xas_store(&xas, page);
+
+               if (!xas_error(&xas)) {
+               	if (old) {
+                       	mapping->nrexceptional--;
+                       	if (shadowp)
+                               	*shadowp = old;
+               	}
+               	mapping->nrpages++;
+
+               	/*
+               	 * hugetlb pages do not participate in
+               	 * page cache accounting.
+               	 */
+               	if (!huge)
+                       	__inc_node_page_state(page, NR_FILE_PAGES);
+		}
+               xas_unlock_irq(&xas);
+       } while (xas_nomem(&xas, gfp_mask & ~__GFP_HIGHMEM));
