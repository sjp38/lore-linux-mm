Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7795B6B0256
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 15:36:31 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so16458348pab.0
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 12:36:31 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id yt3si20011924pab.87.2015.12.01.12.36.30
        for <linux-mm@kvack.org>;
        Tue, 01 Dec 2015 12:36:30 -0800 (PST)
Date: Tue, 01 Dec 2015 15:36:28 -0500 (EST)
Message-Id: <20151201.153628.148150792813486828.davem@davemloft.net>
Subject: Re: [PATCH] Improve Atheros ethernet driver not to do order 4
 GFP_ATOMIC allocation
From: David Miller <davem@davemloft.net>
In-Reply-To: <1448906303.24696.133.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151127082010.GA2500@dhcp22.suse.cz>
	<20151128145113.GB4135@amd>
	<1448906303.24696.133.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: eric.dumazet@gmail.com
Cc: pavel@ucw.cz, mhocko@kernel.org, akpm@osdl.org, linux-kernel@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org, rjw@rjwysocki.net, linux-mm@kvack.org, nic-devel@qualcomm.com, ronangeles@gmail.com, ebiederm@xmission.com

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 30 Nov 2015 09:58:23 -0800

> On Sat, 2015-11-28 at 15:51 +0100, Pavel Machek wrote:
>> atl1c driver is doing order-4 allocation with GFP_ATOMIC
>> priority. That often breaks  networking after resume. Switch to
>> GFP_KERNEL. Still not ideal, but should be significantly better.
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
>> +		dev_err(&pdev->dev, "could not get memmory for DMA buffer\n");
>>  		goto err_nomem;
>>  	}
>>  	memset(ring_header->desc, 0, ring_header->size);
>> 
> 
> It seems there is a missed opportunity to get rid of the memset() here,
> by adding __GFP_ZERO to the dma_alloc_coherent() GFP_KERNEL mask,
> or simply using dma_zalloc_coherent()

Also, the Subject line needs to be adjusted.  The proper format for
the Subject line is:

	[PATCH $TREE] $subsystem: $description.

Where "$TREE" is either 'net' or 'net-next', $subsystem is the lowercase
name of the driver (here 'atl1c') and then a colon, and then a space, and
then the single-line description.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
