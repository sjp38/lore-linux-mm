Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6CA736B0256
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 10:59:27 -0500 (EST)
Received: by wmww144 with SMTP id w144so27200756wmw.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 07:59:27 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id pu5si12114983wjc.50.2015.12.03.07.59.26
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 07:59:26 -0800 (PST)
Date: Thu, 3 Dec 2015 16:59:24 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] Improve Atheros ethernet driver not to do order 4
 GFP_ATOMIC allocation
Message-ID: <20151203155923.GA31751@amd>
References: <20151127082010.GA2500@dhcp22.suse.cz>
 <20151128145113.GB4135@amd>
 <1448906303.24696.133.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151201.153628.148150792813486828.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151201.153628.148150792813486828.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: eric.dumazet@gmail.com, mhocko@kernel.org, akpm@osdl.org, linux-kernel@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org, rjw@rjwysocki.net, linux-mm@kvack.org, nic-devel@qualcomm.com, ronangeles@gmail.com, ebiederm@xmission.com

On Tue 2015-12-01 15:36:28, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 30 Nov 2015 09:58:23 -0800
> 
> > On Sat, 2015-11-28 at 15:51 +0100, Pavel Machek wrote:
> >> atl1c driver is doing order-4 allocation with GFP_ATOMIC
> >> priority. That often breaks  networking after resume. Switch to
> >> GFP_KERNEL. Still not ideal, but should be significantly better.
> >>     
> >> Signed-off-by: Pavel Machek <pavel@ucw.cz>
> >> 
> >> diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> >> index 2795d6d..afb71e0 100644
> >> --- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> >> +++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> >> @@ -1016,10 +1016,10 @@ static int atl1c_setup_ring_resources(struct atl1c_adapter *adapter)
> >>  		sizeof(struct atl1c_recv_ret_status) * rx_desc_count +
> >>  		8 * 4;
> >>  
> >> -	ring_header->desc = pci_alloc_consistent(pdev, ring_header->size,
> >> -				&ring_header->dma);
> >> +	ring_header->desc = dma_alloc_coherent(&pdev->dev, ring_header->size,
> >> +					       &ring_header->dma, GFP_KERNEL);
> >>  	if (unlikely(!ring_header->desc)) {
> >> -		dev_err(&pdev->dev, "pci_alloc_consistend failed\n");
> >> +		dev_err(&pdev->dev, "could not get memmory for DMA buffer\n");
> >>  		goto err_nomem;
> >>  	}
> >>  	memset(ring_header->desc, 0, ring_header->size);
> >> 
> > 
> > It seems there is a missed opportunity to get rid of the memset() here,
> > by adding __GFP_ZERO to the dma_alloc_coherent() GFP_KERNEL mask,
> > or simply using dma_zalloc_coherent()
> 
> Also, the Subject line needs to be adjusted.  The proper format for
> the Subject line is:
> 
> 	[PATCH $TREE] $subsystem: $description.
> 
> Where "$TREE" is either 'net' or 'net-next', $subsystem is the lowercase
> name of the driver (here 'atl1c') and then a colon, and then a space, and
> then the single-line description.

Done, thanks.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
