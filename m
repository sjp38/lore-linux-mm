Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f51.google.com (mail-lf0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 668066B0038
	for <linux-mm@kvack.org>; Sun, 29 Nov 2015 16:58:05 -0500 (EST)
Received: by lfdl133 with SMTP id l133so174924802lfd.2
        for <linux-mm@kvack.org>; Sun, 29 Nov 2015 13:58:04 -0800 (PST)
Received: from mail-lf0-x22d.google.com (mail-lf0-x22d.google.com. [2a00:1450:4010:c07::22d])
        by mx.google.com with ESMTPS id mr5si18801769lbb.104.2015.11.29.13.58.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Nov 2015 13:58:03 -0800 (PST)
Received: by lfdl133 with SMTP id l133so174924545lfd.2
        for <linux-mm@kvack.org>; Sun, 29 Nov 2015 13:58:03 -0800 (PST)
Subject: Re: [PATCH] Improve Atheros ethernet driver not to do order 4
 GFP_ATOMIC allocation
References: <20151126163413.GA3816@amd> <20151127082010.GA2500@dhcp22.suse.cz>
 <20151128145113.GB4135@amd>
From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Message-ID: <565B74EB.3000005@cogentembedded.com>
Date: Mon, 30 Nov 2015 00:58:03 +0300
MIME-Version: 1.0
In-Reply-To: <20151128145113.GB4135@amd>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>, Michal Hocko <mhocko@kernel.org>, davem@davemloft.net, Andrew Morton <akpm@osdl.org>
Cc: kernel list <linux-kernel@vger.kernel.org>, jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-mm@kvack.org, nic-devel@qualcomm.com, ronangeles@gmail.com, ebiederm@xmission.com

Hello.

On 11/28/2015 5:51 PM, Pavel Machek wrote:

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
>   		sizeof(struct atl1c_recv_ret_status) * rx_desc_count +
>   		8 * 4;
>
> -	ring_header->desc = pci_alloc_consistent(pdev, ring_header->size,
> -				&ring_header->dma);
> +	ring_header->desc = dma_alloc_coherent(&pdev->dev, ring_header->size,
> +					       &ring_header->dma, GFP_KERNEL);
>   	if (unlikely(!ring_header->desc)) {
> -		dev_err(&pdev->dev, "pci_alloc_consistend failed\n");
> +		dev_err(&pdev->dev, "could not get memmory for DMA buffer\n");

     s/memmory/memory/.

[...]

MBR, Sergei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
