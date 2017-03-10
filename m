Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5E60A28092C
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 16:34:25 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id e5so184104013pgk.1
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 13:34:25 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v5si4075229pgo.315.2017.03.10.13.34.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Mar 2017 13:34:24 -0800 (PST)
Date: Fri, 10 Mar 2017 13:34:19 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: z3fold: suspicious return with spinlock held
Message-ID: <20170310213419.GD16328@bombadil.infradead.org>
References: <1489180932-13918-1-git-send-email-khoroshilov@ispras.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1489180932-13918-1-git-send-email-khoroshilov@ispras.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Cc: Vitaly Wool <vitalywool@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org

On Sat, Mar 11, 2017 at 12:22:12AM +0300, Alexey Khoroshilov wrote:
> Hello!
> 
> z3fold_reclaim_page() contains the only return that may
> leave the function with pool->lock spinlock held.
> 
> 669 	spin_lock(&pool->lock);
> 670 	if (kref_put(&zhdr->refcount, release_z3fold_page)) {
> 671 		atomic64_dec(&pool->pages_nr);
> 672 		return 0;
> 673 	}
> 
> May be we need spin_unlock(&pool->lock); just before return?

I would tend to agree.  sparse warns about this, and also about two
other locking problems ... which I'm not sure are really problems so
much as missing annotations?

mm/z3fold.c:467:35: warning: context imbalance in 'z3fold_alloc' - unexpected unlock
mm/z3fold.c:519:26: warning: context imbalance in 'z3fold_free' - different lock contexts for basic block
mm/z3fold.c:581:12: warning: context imbalance in 'z3fold_reclaim_page' - different lock contexts for basic block

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
