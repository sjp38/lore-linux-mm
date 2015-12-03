Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 196706B0259
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 11:14:01 -0500 (EST)
Received: by wmec201 with SMTP id c201so34702405wme.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 08:14:00 -0800 (PST)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id o67si3754907wmb.70.2015.12.03.08.13.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 08:14:00 -0800 (PST)
Received: by wmvv187 with SMTP id v187so34963653wmv.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 08:13:59 -0800 (PST)
Date: Thu, 3 Dec 2015 17:13:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH net] atl1c: Improve driver not to do order 4 GFP_ATOMIC
 allocation
Message-ID: <20151203161357.GJ9264@dhcp22.suse.cz>
References: <20151126163413.GA3816@amd>
 <20151127082010.GA2500@dhcp22.suse.cz>
 <20151128145113.GB4135@amd>
 <20151203155905.GA31974@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151203155905.GA31974@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: davem@davemloft.net, Andrew Morton <akpm@osdl.org>, kernel list <linux-kernel@vger.kernel.org>, jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-mm@kvack.org, nic-devel@qualcomm.com, ronangeles@gmail.com, ebiederm@xmission.com

On Thu 03-12-15 16:59:05, Pavel Machek wrote:
> 
> atl1c driver is doing order-4 allocation with GFP_ATOMIC
> priority. That often breaks  networking after resume. Switch to
> GFP_KERNEL. Still not ideal, but should be significantly better.
> 
> atl1c_setup_ring_resources() is called from .open() function, and
> already uses GFP_KERNEL, so this change is safe.

Thanks for updating the changelog

> Signed-off-by: Pavel Machek <pavel@ucw.cz>

Acked-by: Michal Hocko <mhocko@suse.com>

> 
> diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> index 2795d6d..afb71e0 100644
> --- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> +++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> @@ -1016,10 +1016,10 @@ static int atl1c_setup_ring_resources(struct atl1c_adapter *adapter)
>  		sizeof(struct atl1c_recv_ret_status) * rx_desc_count +
>  		8 * 4;
>  
> -	ring_header->desc = pci_alloc_consistent(pdev, ring_header->size,
> -				&ring_header->dma);
> +	ring_header->desc = dma_alloc_coherent(&pdev->dev, ring_header->size,
> +					       &ring_header->dma, GFP_KERNEL);
>  	if (unlikely(!ring_header->desc)) {
> -		dev_err(&pdev->dev, "pci_alloc_consistend failed\n");
> +		dev_err(&pdev->dev, "could not get memory for DMA buffer\n");
>  		goto err_nomem;
>  	}
>  	memset(ring_header->desc, 0, ring_header->size);
> 
> 
> -- 
> (english) http://www.livejournal.com/~pavelmachek
> (cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
