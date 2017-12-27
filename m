Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3AC8D6B0033
	for <linux-mm@kvack.org>; Tue, 26 Dec 2017 22:58:31 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id m39so19454221plg.19
        for <linux-mm@kvack.org>; Tue, 26 Dec 2017 19:58:31 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q12si24084479pls.475.2017.12.26.19.58.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Dec 2017 19:58:30 -0800 (PST)
Date: Tue, 26 Dec 2017 19:58:15 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v5 03/78] xarray: Add the xa_lock to the radix_tree_root
Message-ID: <20171227035815.GD24828@bombadil.infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
 <20171215220450.7899-4-willy@infradead.org>
 <20171226165440.tv6inwa2fgk3bfy6@node.shutemov.name>
 <20171227034340.GC24828@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171227034340.GC24828@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

On Tue, Dec 26, 2017 at 07:43:40PM -0800, Matthew Wilcox wrote:
>     Also add the xa_lock() and xa_unlock() family of wrappers to make it
>     easier to use the lock.  If we could rely on -fplan9-extensions in
>     the compiler, we could avoid all of this syntactic sugar, but that
>     wasn't added until gcc 4.6.

Oh, in case anyone's wondering, here's how I'd do it with plan9 extensions:

struct xarray {
        spinlock_t;
        int xa_flags;
        void *xa_head;
};

...
        spin_lock_irqsave(&mapping->pages, flags);
        __delete_from_page_cache(page, NULL);
        spin_unlock_irqrestore(&mapping->pages, flags);
...

The plan9 extensions permit passing a pointer to a struct which has an
unnamed element to a function which is expecting a pointer to the type
of that element.  The compiler does any necessary arithmetic to produce 
a pointer.  It's exactly as if I had written:

        spin_lock_irqsave(&mapping->pages.xa_lock, flags);
        __delete_from_page_cache(page, NULL);
        spin_unlock_irqrestore(&mapping->pages.xa_lock, flags);

More details here: https://9p.io/sys/doc/compiler.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
