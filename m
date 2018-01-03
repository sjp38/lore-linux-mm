Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5C5656B039F
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 16:06:22 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id a74so1273180pfg.20
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 13:06:22 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id u14si1100493pgo.179.2018.01.03.13.06.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Jan 2018 13:06:21 -0800 (PST)
Date: Wed, 3 Jan 2018 13:06:16 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC] Heuristic for inode/dentry fragmentation prevention
Message-ID: <20180103210616.GB3228@bombadil.infradead.org>
References: <alpine.DEB.2.20.1801031332230.10522@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1801031332230.10522@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Dave Chinner <dchinner@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, Jan 03, 2018 at 01:39:27PM -0600, Christopher Lameter wrote:
> +++ linux/fs/dcache.c
> @@ -1074,7 +1074,8 @@ static enum lru_status dentry_lru_isolat
>  		return LRU_REMOVED;
>  	}
> 
> -	if (dentry->d_flags & DCACHE_REFERENCED) {
> +	if (dentry->d_flags & DCACHE_REFERENCED &&
> +	   kobjects_left_in_slab_page(dentry) > 1) {
>  		dentry->d_flags &= ~DCACHE_REFERENCED;
>  		spin_unlock(&dentry->d_lock);
> 

Maybe also update this comment:

        /*
         * Referenced dentries are still in use. If they have active
         * counts, just remove them from the LRU. Otherwise give them
-        * another pass through the LRU.
+	 * another pass through the LRU unless they are the only
+	 * object on their slab page.
         */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
