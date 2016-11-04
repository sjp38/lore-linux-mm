Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 936116B031E
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 10:50:43 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id rf5so39670194pab.3
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 07:50:43 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id d1si5015595pav.104.2016.11.04.07.50.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 07:50:42 -0700 (PDT)
Date: Fri, 4 Nov 2016 07:50:40 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH v3 1/2] Add support for eXclusive Page Frame
 Ownership (XPFO)
Message-ID: <20161104145040.GA24930@infradead.org>
References: <20160914071901.8127-1-juerg.haefliger@hpe.com>
 <20161104144534.14790-1-juerg.haefliger@hpe.com>
 <20161104144534.14790-2-juerg.haefliger@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161104144534.14790-2-juerg.haefliger@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juerg Haefliger <juerg.haefliger@hpe.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-x86_64@vger.kernel.org, vpk@cs.columbia.edu, Tejun Heo <tj@kernel.org>, linux-ide@vger.kernel.org

The libata parts here really need to be split out and the proper list
and maintainer need to be Cc'ed.

> diff --git a/drivers/ata/libata-sff.c b/drivers/ata/libata-sff.c
> index 051b6158d1b7..58af734be25d 100644
> --- a/drivers/ata/libata-sff.c
> +++ b/drivers/ata/libata-sff.c
> @@ -715,7 +715,7 @@ static void ata_pio_sector(struct ata_queued_cmd *qc)
>  
>  	DPRINTK("data %s\n", qc->tf.flags & ATA_TFLAG_WRITE ? "write" : "read");
>  
> -	if (PageHighMem(page)) {
> +	if (PageHighMem(page) || xpfo_page_is_unmapped(page)) {
>  		unsigned long flags;
>  
>  		/* FIXME: use a bounce buffer */
> @@ -860,7 +860,7 @@ static int __atapi_pio_bytes(struct ata_queued_cmd *qc, unsigned int bytes)
>  
>  	DPRINTK("data %s\n", qc->tf.flags & ATA_TFLAG_WRITE ? "write" : "read");
>  
> -	if (PageHighMem(page)) {
> +	if (PageHighMem(page) || xpfo_page_is_unmapped(page)) {
>  		unsigned long flags;
>  
>  		/* FIXME: use bounce buffer */
> diff --git a/include/linux/highmem.h b/include/linux/highmem.h

This is just piling one nasty hack on top of another.  libata should
just use the highmem case unconditionally, as it is the correct thing
to do for all cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
