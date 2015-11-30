Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id F16496B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 12:58:25 -0500 (EST)
Received: by pacej9 with SMTP id ej9so191586192pac.2
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 09:58:25 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id v76si5329412pfa.183.2015.11.30.09.58.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 09:58:25 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so191665214pac.3
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 09:58:24 -0800 (PST)
Message-ID: <1448906303.24696.133.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: [PATCH] Improve Atheros ethernet driver not to do order 4
 GFP_ATOMIC allocation
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 30 Nov 2015 09:58:23 -0800
In-Reply-To: <20151128145113.GB4135@amd>
References: <20151126163413.GA3816@amd>
	 <20151127082010.GA2500@dhcp22.suse.cz> <20151128145113.GB4135@amd>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Michal Hocko <mhocko@kernel.org>, davem@davemloft.net, Andrew Morton <akpm@osdl.org>, kernel list <linux-kernel@vger.kernel.org>, jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org, "Rafael
 J. Wysocki" <rjw@rjwysocki.net>, linux-mm@kvack.org, nic-devel@qualcomm.com, ronangeles@gmail.com, ebiederm@xmission.com

On Sat, 2015-11-28 at 15:51 +0100, Pavel Machek wrote:
> atl1c driver is doing order-4 allocation with GFP_ATOMIC
> priority. That often breaks  networking after resume. Switch to
> GFP_KERNEL. Still not ideal, but should be significantly better.
>     
> Signed-off-by: Pavel Machek <pavel@ucw.cz>
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
> +		dev_err(&pdev->dev, "could not get memmory for DMA buffer\n");
>  		goto err_nomem;
>  	}
>  	memset(ring_header->desc, 0, ring_header->size);
> 

It seems there is a missed opportunity to get rid of the memset() here,
by adding __GFP_ZERO to the dma_alloc_coherent() GFP_KERNEL mask,
or simply using dma_zalloc_coherent()





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
