Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9C1AC8E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 05:45:38 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id 129so743646wmy.7
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 02:45:38 -0800 (PST)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id v3si1301365wme.192.2018.12.18.02.45.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 02:45:37 -0800 (PST)
Date: Tue, 18 Dec 2018 10:45:13 +0000
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH v4 3/9] drivers/firewire/core-iso.c: Convert to use
 vm_insert_range
Message-ID: <20181218104513.GM26090@n2100.armlinux.org.uk>
References: <20181217202246.GA10500@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181217202246.GA10500@jordon-HP-15-Notebook-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, stefanr@s5r6.in-berlin.de, linux-mm@kvack.org, linux1394-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Tue, Dec 18, 2018 at 01:52:46AM +0530, Souptick Joarder wrote:
> Convert to use vm_insert_range to map range of kernel memory
> to user vma.
> 
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> Reviewed-by: Matthew Wilcox <willy@infradead.org>
> ---
>  drivers/firewire/core-iso.c | 15 ++-------------
>  1 file changed, 2 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/firewire/core-iso.c b/drivers/firewire/core-iso.c
> index 35e784c..7bf28bb 100644
> --- a/drivers/firewire/core-iso.c
> +++ b/drivers/firewire/core-iso.c
> @@ -107,19 +107,8 @@ int fw_iso_buffer_init(struct fw_iso_buffer *buffer, struct fw_card *card,
>  int fw_iso_buffer_map_vma(struct fw_iso_buffer *buffer,
>  			  struct vm_area_struct *vma)
>  {
> -	unsigned long uaddr;
> -	int i, err;
> -
> -	uaddr = vma->vm_start;
> -	for (i = 0; i < buffer->page_count; i++) {
> -		err = vm_insert_page(vma, uaddr, buffer->pages[i]);
> -		if (err)
> -			return err;
> -
> -		uaddr += PAGE_SIZE;
> -	}
> -
> -	return 0;
> +	return vm_insert_range(vma, vma->vm_start, buffer->pages,
> +				buffer->page_count);

This looks functionally equivalent.  Note that if we go with my
proposal to your patch 4, that would cause an issue for this
implementation.

Maybe we need two functions, but that then causes problems with
which function should be used (which makes it easy to get wrong.)

I'm beginning to wonder if the risks of causing regressions and
introducing bugs is actually worth the effort of trying to clean
this up.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up
