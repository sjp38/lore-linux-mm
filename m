Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0F9806B000A
	for <linux-mm@kvack.org>; Sat, 24 Feb 2018 22:38:18 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id a6so6398420pff.6
        for <linux-mm@kvack.org>; Sat, 24 Feb 2018 19:38:18 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t6si2838141pgs.315.2018.02.24.19.38.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 24 Feb 2018 19:38:17 -0800 (PST)
Date: Sat, 24 Feb 2018 19:38:08 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 3/7] struct page: add field for vm_struct
Message-ID: <20180225033808.GB15796@bombadil.infradead.org>
References: <20180223144807.1180-1-igor.stoppa@huawei.com>
 <20180223144807.1180-4-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180223144807.1180-4-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: david@fromorbit.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Fri, Feb 23, 2018 at 04:48:03PM +0200, Igor Stoppa wrote:
> @@ -1769,6 +1771,9 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
>  
>  	kmemleak_vmalloc(area, size, gfp_mask);
>  
> +	for (i = 0; i < area->nr_pages; i++)
> +		area->pages[i]->area = area;
> +
>  	return addr;
>  
>  fail:

IMO, this is the wrong place to initialise the page->area.  It should be
done in __vmalloc_area_node() like so:

                        area->nr_pages = i;
                        goto fail;
                }
+		page->area = area;
                area->pages[i] = page;
                if (gfpflags_allow_blocking(gfp_mask))
                        cond_resched();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
