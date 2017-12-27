Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8869F6B0033
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 05:18:37 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id l99so16529613wrc.18
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 02:18:37 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z12sor18346630edm.42.2017.12.27.02.18.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Dec 2017 02:18:36 -0800 (PST)
Date: Wed, 27 Dec 2017 13:18:34 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v5 03/78] xarray: Add the xa_lock to the radix_tree_root
Message-ID: <20171227101834.qfjsy6eqaojiifsr@node.shutemov.name>
References: <20171215220450.7899-1-willy@infradead.org>
 <20171215220450.7899-4-willy@infradead.org>
 <20171226165440.tv6inwa2fgk3bfy6@node.shutemov.name>
 <20171227034340.GC24828@bombadil.infradead.org>
 <20171227035815.GD24828@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171227035815.GD24828@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

On Tue, Dec 26, 2017 at 07:58:15PM -0800, Matthew Wilcox wrote:
> On Tue, Dec 26, 2017 at 07:43:40PM -0800, Matthew Wilcox wrote:
> >     Also add the xa_lock() and xa_unlock() family of wrappers to make it
> >     easier to use the lock.  If we could rely on -fplan9-extensions in
> >     the compiler, we could avoid all of this syntactic sugar, but that
> >     wasn't added until gcc 4.6.
> 
> Oh, in case anyone's wondering, here's how I'd do it with plan9 extensions:
> 
> struct xarray {
>         spinlock_t;
>         int xa_flags;
>         void *xa_head;
> };
> 
> ...
>         spin_lock_irqsave(&mapping->pages, flags);
>         __delete_from_page_cache(page, NULL);
>         spin_unlock_irqrestore(&mapping->pages, flags);
> ...
> 
> The plan9 extensions permit passing a pointer to a struct which has an
> unnamed element to a function which is expecting a pointer to the type
> of that element.  The compiler does any necessary arithmetic to produce 
> a pointer.  It's exactly as if I had written:
> 
>         spin_lock_irqsave(&mapping->pages.xa_lock, flags);
>         __delete_from_page_cache(page, NULL);
>         spin_unlock_irqrestore(&mapping->pages.xa_lock, flags);
> 
> More details here: https://9p.io/sys/doc/compiler.html

Yeah, that's neat.

Dealing with old compilers is frustrating...

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
