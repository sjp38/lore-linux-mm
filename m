Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 469C16B0007
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 13:18:04 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c22so2582721pfj.2
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 10:18:04 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id p10-v6si286690plo.810.2018.02.08.10.18.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Feb 2018 10:18:03 -0800 (PST)
Date: Thu, 8 Feb 2018 10:18:00 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Regression after commit 19809c2da28a ("mm, vmalloc: use
 __GFP_HIGHMEM implicitly")
Message-ID: <20180208181800.GA9524@bombadil.infradead.org>
References: <627DA40A-D0F6-41C1-BB5A-55830FBC9800@canonical.com>
 <20180208130649.GA15846@bombadil.infradead.org>
 <f8be3fc9-a96d-bf37-4da0-43220014caed@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f8be3fc9-a96d-bf37-4da0-43220014caed@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Kai Heng Feng <kai.heng.feng@canonical.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Feb 08, 2018 at 09:56:42AM -0800, Laura Abbott wrote:
> > +++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
> > @@ -77,7 +77,7 @@ static struct scatterlist *videobuf_vmalloc_to_sg(unsigned char *virt,
> >   		pg = vmalloc_to_page(virt);
> >   		if (NULL == pg)
> >   			goto err;
> > -		BUG_ON(PageHighMem(pg));
> > +		BUG_ON(page_to_pfn(pg) >= (1 << (32 - PAGE_SHIFT)));
> >   		sg_set_page(&sglist[i], pg, PAGE_SIZE, 0);
> >   	}
> >   	return sglist;
> > 
> 
> the vzalloc in this function needs to be switched to vmalloc32 if it
> actually wants to guarantee 32-bit memory.

Whoops, you got confused between the sglist allocation and the allocation
of the pages which will be mapped ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
