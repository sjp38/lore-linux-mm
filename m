Message-ID: <44D8F074.8060001@intel.com>
Date: Tue, 08 Aug 2006 13:13:40 -0700
From: Auke Kok <auke-jan.h.kok@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 4/9] e100 driver conversion
References: <20060808193325.1396.58813.sendpatchset@lappy> <20060808193405.1396.14701.sendpatchset@lappy>
In-Reply-To: <20060808193405.1396.14701.sendpatchset@lappy>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Daniel Phillips <phillips@google.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> Update the driver to make use of the netdev_alloc_skb() API and the
> NETIF_F_MEMALLOC feature.

this should be done in two separate patches. I should take care of the netdev_alloc_skb()
part too for e100 (which I've already queued internally), also since ixgb still needs it.

do you have any plans to visit ixgb for this change too?

Cheers,

Auke


> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Daniel Phillips <phillips@google.com>
> 
> ---
>  drivers/net/e100.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6/drivers/net/e100.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/e100.c
> +++ linux-2.6/drivers/net/e100.c
> @@ -1763,7 +1763,7 @@ static inline void e100_start_receiver(s
>  #define RFD_BUF_LEN (sizeof(struct rfd) + VLAN_ETH_FRAME_LEN)
>  static int e100_rx_alloc_skb(struct nic *nic, struct rx *rx)
>  {
> -	if(!(rx->skb = dev_alloc_skb(RFD_BUF_LEN + NET_IP_ALIGN)))
> +	if(!(rx->skb = netdev_alloc_skb(nic->netdev, RFD_BUF_LEN + NET_IP_ALIGN)))
>  		return -ENOMEM;
>  
>  	/* Align, init, and map the RFD. */
> @@ -2143,7 +2143,7 @@ static int e100_loopback_test(struct nic
>  
>  	e100_start_receiver(nic, NULL);
>  
> -	if(!(skb = dev_alloc_skb(ETH_DATA_LEN))) {
> +	if(!(skb = netdev_alloc_skb(nic->netdev, ETH_DATA_LEN))) {
>  		err = -ENOMEM;
>  		goto err_loopback_none;
>  	}
> @@ -2573,6 +2573,7 @@ static int __devinit e100_probe(struct p
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	netdev->poll_controller = e100_netpoll;
>  #endif
> +	netdev->features |= NETIF_F_MEMALLOC;
>  	strcpy(netdev->name, pci_name(pdev));
>  
>  	nic = netdev_priv(netdev);
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
