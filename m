Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id BDCCA6B0255
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 12:32:53 -0500 (EST)
Received: by pfnn128 with SMTP id n128so11601276pfn.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 09:32:53 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id ny6si13102421pab.215.2015.12.03.09.32.52
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 09:32:53 -0800 (PST)
Date: Thu, 03 Dec 2015 12:32:49 -0500 (EST)
Message-Id: <20151203.123249.2158644928982094593.davem@davemloft.net>
Subject: Re: [PATCH net] atl1c: Improve driver not to do order 4 GFP_ATOMIC
 allocation
From: David Miller <davem@davemloft.net>
In-Reply-To: <1449163048.25029.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151128145113.GB4135@amd>
	<20151203155905.GA31974@amd>
	<1449163048.25029.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: eric.dumazet@gmail.com
Cc: pavel@ucw.cz, mhocko@kernel.org, akpm@osdl.org, linux-kernel@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org, rjw@rjwysocki.net, linux-mm@kvack.org, nic-devel@qualcomm.com, ronangeles@gmail.com, ebiederm@xmission.com

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Dec 2015 09:17:28 -0800

> On Thu, 2015-12-03 at 16:59 +0100, Pavel Machek wrote:
>> atl1c driver is doing order-4 allocation with GFP_ATOMIC
>> priority. That often breaks  networking after resume. Switch to
>> GFP_KERNEL. Still not ideal, but should be significantly better.
>> 
>> atl1c_setup_ring_resources() is called from .open() function, and
>> already uses GFP_KERNEL, so this change is safe.
>>     
>> Signed-off-by: Pavel Machek <pavel@ucw.cz>
>> 
>> diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
>> index 2795d6d..afb71e0 100644
>> --- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
>> +++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
>> @@ -1016,10 +1016,10 @@ static int atl1c_setup_ring_resources(struct atl1c_adapter *adapter)
>>  		sizeof(struct atl1c_recv_ret_status) * rx_desc_count +
>>  		8 * 4;
>>  
>> -	ring_header->desc = pci_alloc_consistent(pdev, ring_header->size,
>> -				&ring_header->dma);
>> +	ring_header->desc = dma_alloc_coherent(&pdev->dev, ring_header->size,
>> +					       &ring_header->dma, GFP_KERNEL);
>>  	if (unlikely(!ring_header->desc)) {
>> -		dev_err(&pdev->dev, "pci_alloc_consistend failed\n");
>> +		dev_err(&pdev->dev, "could not get memory for DMA buffer\n");
>>  		goto err_nomem;
>>  	}
>>  	memset(ring_header->desc, 0, ring_header->size);
>> 
>> 
> 
> So this memset() will really require a different patch to get removed ?
> 
> Sigh, not sure why I review patches.

Agreed, please use dma_zalloc_coherent() and kill that memset().

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
