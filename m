Message-ID: <47E3EFEB.8060506@intel.com>
Date: Fri, 21 Mar 2008 10:27:07 -0700
From: "Kok, Auke" <auke-jan.h.kok@intel.com>
MIME-Version: 1.0
Subject: Re: [12/14] vcompound: Avoid vmalloc in e1000 driver
References: <20080321061703.921169367@sgi.com> <20080321061727.013005177@sgi.com>
In-Reply-To: <20080321061727.013005177@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Switch all the uses of vmalloc in the e1000 driver to virtual compounds.
> This will result in the use of regular memory for the ring buffers etc
> avoiding page tables,

hey, cool patch for sure!

I'll see if I can transpose this to e1000e and all the other drivers I maintain
which use vmalloc as well.

This one goes on my queue and I'll merge through Jeff.

Thanks Christoph!

Auke



> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  drivers/net/e1000/e1000_main.c |   23 +++++++++++------------
>  drivers/net/e1000e/netdev.c    |   12 ++++++------
>  2 files changed, 17 insertions(+), 18 deletions(-)
> 
> Index: linux-2.6.25-rc5-mm1/drivers/net/e1000e/netdev.c
> ===================================================================
> --- linux-2.6.25-rc5-mm1.orig/drivers/net/e1000e/netdev.c	2008-03-20 21:52:45.962733927 -0700
> +++ linux-2.6.25-rc5-mm1/drivers/net/e1000e/netdev.c	2008-03-20 21:57:27.212078371 -0700
> @@ -1083,7 +1083,7 @@ int e1000e_setup_tx_resources(struct e10
>  	int err = -ENOMEM, size;
>  
>  	size = sizeof(struct e1000_buffer) * tx_ring->count;
> -	tx_ring->buffer_info = vmalloc(size);
> +	tx_ring->buffer_info = __alloc_vcompound(GFP_KERNEL, get_order(size));
>  	if (!tx_ring->buffer_info)
>  		goto err;
>  	memset(tx_ring->buffer_info, 0, size);
> @@ -1102,7 +1102,7 @@ int e1000e_setup_tx_resources(struct e10
>  
>  	return 0;
>  err:
> -	vfree(tx_ring->buffer_info);
> +	__free_vcompound(tx_ring->buffer_info);
>  	ndev_err(adapter->netdev,
>  	"Unable to allocate memory for the transmit descriptor ring\n");
>  	return err;
> @@ -1121,7 +1121,7 @@ int e1000e_setup_rx_resources(struct e10
>  	int i, size, desc_len, err = -ENOMEM;
>  
>  	size = sizeof(struct e1000_buffer) * rx_ring->count;
> -	rx_ring->buffer_info = vmalloc(size);
> +	rx_ring->buffer_info = __alloc_vcompound(GFP_KERNEL, get_order(size));
>  	if (!rx_ring->buffer_info)
>  		goto err;
>  	memset(rx_ring->buffer_info, 0, size);
> @@ -1157,7 +1157,7 @@ err_pages:
>  		kfree(buffer_info->ps_pages);
>  	}
>  err:
> -	vfree(rx_ring->buffer_info);
> +	__free_vcompound(rx_ring->buffer_info);
>  	ndev_err(adapter->netdev,
>  	"Unable to allocate memory for the transmit descriptor ring\n");
>  	return err;
> @@ -1204,7 +1204,7 @@ void e1000e_free_tx_resources(struct e10
>  
>  	e1000_clean_tx_ring(adapter);
>  
> -	vfree(tx_ring->buffer_info);
> +	__free_vcompound(tx_ring->buffer_info);
>  	tx_ring->buffer_info = NULL;
>  
>  	dma_free_coherent(&pdev->dev, tx_ring->size, tx_ring->desc,
> @@ -1231,7 +1231,7 @@ void e1000e_free_rx_resources(struct e10
>  		kfree(rx_ring->buffer_info[i].ps_pages);
>  	}
>  
> -	vfree(rx_ring->buffer_info);
> +	__free_vcompound(rx_ring->buffer_info);
>  	rx_ring->buffer_info = NULL;
>  
>  	dma_free_coherent(&pdev->dev, rx_ring->size, rx_ring->desc,
> Index: linux-2.6.25-rc5-mm1/drivers/net/e1000/e1000_main.c
> ===================================================================
> --- linux-2.6.25-rc5-mm1.orig/drivers/net/e1000/e1000_main.c	2008-03-20 22:06:14.462252441 -0700
> +++ linux-2.6.25-rc5-mm1/drivers/net/e1000/e1000_main.c	2008-03-20 22:08:46.582009872 -0700
> @@ -1609,14 +1609,13 @@ e1000_setup_tx_resources(struct e1000_ad
>  	int size;
>  
>  	size = sizeof(struct e1000_buffer) * txdr->count;
> -	txdr->buffer_info = vmalloc(size);
> +	txdr->buffer_info = __alloc_vcompound(GFP_KERNEL | __GFP_ZERO,
> +							get_order(size));
>  	if (!txdr->buffer_info) {
>  		DPRINTK(PROBE, ERR,
>  		"Unable to allocate memory for the transmit descriptor ring\n");
>  		return -ENOMEM;
>  	}
> -	memset(txdr->buffer_info, 0, size);
> -
>  	/* round up to nearest 4K */
>  
>  	txdr->size = txdr->count * sizeof(struct e1000_tx_desc);
> @@ -1625,7 +1624,7 @@ e1000_setup_tx_resources(struct e1000_ad
>  	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
>  	if (!txdr->desc) {
>  setup_tx_desc_die:
> -		vfree(txdr->buffer_info);
> +		__free_vcompound(txdr->buffer_info);
>  		DPRINTK(PROBE, ERR,
>  		"Unable to allocate memory for the transmit descriptor ring\n");
>  		return -ENOMEM;
> @@ -1653,7 +1652,7 @@ setup_tx_desc_die:
>  			DPRINTK(PROBE, ERR,
>  				"Unable to allocate aligned memory "
>  				"for the transmit descriptor ring\n");
> -			vfree(txdr->buffer_info);
> +			__free_vcompound(txdr->buffer_info);
>  			return -ENOMEM;
>  		} else {
>  			/* Free old allocation, new allocation was successful */
> @@ -1826,7 +1825,7 @@ e1000_setup_rx_resources(struct e1000_ad
>  	int size, desc_len;
>  
>  	size = sizeof(struct e1000_buffer) * rxdr->count;
> -	rxdr->buffer_info = vmalloc(size);
> +	rxdr->buffer_info = __alloc_vcompound(GFP_KERNEL, size);
>  	if (!rxdr->buffer_info) {
>  		DPRINTK(PROBE, ERR,
>  		"Unable to allocate memory for the receive descriptor ring\n");
> @@ -1837,7 +1836,7 @@ e1000_setup_rx_resources(struct e1000_ad
>  	rxdr->ps_page = kcalloc(rxdr->count, sizeof(struct e1000_ps_page),
>  	                        GFP_KERNEL);
>  	if (!rxdr->ps_page) {
> -		vfree(rxdr->buffer_info);
> +		__free_vcompound(rxdr->buffer_info);
>  		DPRINTK(PROBE, ERR,
>  		"Unable to allocate memory for the receive descriptor ring\n");
>  		return -ENOMEM;
> @@ -1847,7 +1846,7 @@ e1000_setup_rx_resources(struct e1000_ad
>  	                            sizeof(struct e1000_ps_page_dma),
>  	                            GFP_KERNEL);
>  	if (!rxdr->ps_page_dma) {
> -		vfree(rxdr->buffer_info);
> +		__free_vcompound(rxdr->buffer_info);
>  		kfree(rxdr->ps_page);
>  		DPRINTK(PROBE, ERR,
>  		"Unable to allocate memory for the receive descriptor ring\n");
> @@ -1870,7 +1869,7 @@ e1000_setup_rx_resources(struct e1000_ad
>  		DPRINTK(PROBE, ERR,
>  		"Unable to allocate memory for the receive descriptor ring\n");
>  setup_rx_desc_die:
> -		vfree(rxdr->buffer_info);
> +		__free_vcompound(rxdr->buffer_info);
>  		kfree(rxdr->ps_page);
>  		kfree(rxdr->ps_page_dma);
>  		return -ENOMEM;
> @@ -2175,7 +2174,7 @@ e1000_free_tx_resources(struct e1000_ada
>  
>  	e1000_clean_tx_ring(adapter, tx_ring);
>  
> -	vfree(tx_ring->buffer_info);
> +	__free_vcompound(tx_ring->buffer_info);
>  	tx_ring->buffer_info = NULL;
>  
>  	pci_free_consistent(pdev, tx_ring->size, tx_ring->desc, tx_ring->dma);
> @@ -2283,9 +2282,9 @@ e1000_free_rx_resources(struct e1000_ada
>  
>  	e1000_clean_rx_ring(adapter, rx_ring);
>  
> -	vfree(rx_ring->buffer_info);
> +	__free_vcompound(rx_ring->buffer_info);
>  	rx_ring->buffer_info = NULL;
> -	kfree(rx_ring->ps_page);
> +	__free_vcompound(rx_ring->ps_page);
>  	rx_ring->ps_page = NULL;
>  	kfree(rx_ring->ps_page_dma);
>  	rx_ring->ps_page_dma = NULL;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
