Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B27CC2806DC
	for <linux-mm@kvack.org>; Fri, 19 May 2017 09:05:45 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h76so13314974pfh.15
        for <linux-mm@kvack.org>; Fri, 19 May 2017 06:05:45 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o82si8318559pfi.82.2017.05.19.06.05.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 06:05:44 -0700 (PDT)
Date: Fri, 19 May 2017 06:05:41 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] ib/core: not to set page dirty bit if it's already set.
Message-ID: <20170519130541.GA8017@infradead.org>
References: <20170518233353.14370-1-qing.huang@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170518233353.14370-1-qing.huang@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qing Huang <qing.huang@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org, dledford@redhat.com, sean.hefty@intel.com, artemyko@mellanox.com, linux-mm@kvack.org

On Thu, May 18, 2017 at 04:33:53PM -0700, Qing Huang wrote:
> This change will optimize kernel memory deregistration operations.
> __ib_umem_release() used to call set_page_dirty_lock() against every
> writable page in its memory region. Its purpose is to keep data
> synced between CPU and DMA device when swapping happens after mem
> deregistration ops. Now we choose not to set page dirty bit if it's
> already set by kernel prior to calling __ib_umem_release(). This
> reduces memory deregistration time by half or even more when we ran
> application simulation test program.

As far as I can tell this code doesn't even need set_page_dirty_lock
and could just use set_page_dirty

> 
> Signed-off-by: Qing Huang <qing.huang@oracle.com>
> ---
>  drivers/infiniband/core/umem.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
> index 3dbf811..21e60b1 100644
> --- a/drivers/infiniband/core/umem.c
> +++ b/drivers/infiniband/core/umem.c
> @@ -58,7 +58,7 @@ static void __ib_umem_release(struct ib_device *dev, struct ib_umem *umem, int d
>  	for_each_sg(umem->sg_head.sgl, sg, umem->npages, i) {
>  
>  		page = sg_page(sg);
> -		if (umem->writable && dirty)
> +		if (!PageDirty(page) && umem->writable && dirty)
>  			set_page_dirty_lock(page);
>  		put_page(page);
>  	}
> -- 
> 2.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
---end quoted text---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
