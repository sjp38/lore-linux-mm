Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B6F0F6B03AB
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 16:08:15 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id j6so1444489pll.4
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 13:08:15 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 197si1098028pge.234.2018.01.03.13.08.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Jan 2018 13:08:14 -0800 (PST)
Date: Wed, 3 Jan 2018 13:08:12 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: kernel BUG at ./include/linux/mm.h:LINE! (3)
Message-ID: <20180103210812.GC3228@bombadil.infradead.org>
References: <20171228160346.6406d52df0d9afe8cf7a0862@linux-foundation.org>
 <20171229132420.jn2pwabl6pyjo6mk@node.shutemov.name>
 <20180103010238.1e510ac2@lembas.zaitcev.lan>
 <20180103092604.5y4bvh3i644ts3zm@node.shutemov.name>
 <20180103150419.2fefd759@lembas.zaitcev.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180103150419.2fefd759@lembas.zaitcev.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pete Zaitcev <zaitcev@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-usb@vger.kernel.org

On Wed, Jan 03, 2018 at 03:04:19PM -0600, Pete Zaitcev wrote:
> @@ -1231,12 +1233,15 @@ static int mon_bin_vma_fault(struct vm_fault *vmf)
>  	unsigned long offset, chunk_idx;
>  	struct page *pageptr;
>  
> +	mutex_lock(&rp->fetch_lock);
>  	offset = vmf->pgoff << PAGE_SHIFT;
>  	if (offset >= rp->b_size)
> +		mutex_unlock(&rp->fetch_lock);
>  		return VM_FAULT_SIGBUS;
>  	chunk_idx = offset / CHUNK_SIZE;

missing braces ... maybe you'd rather a 'goto sigbus' approach?

>  	pageptr = rp->b_vec[chunk_idx].pg;
>  	get_page(pageptr);
> +	mutex_unlock(&rp->fetch_lock);
>  	vmf->page = pageptr;
>  	return 0;
>  }
> 
> -- Pete
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
