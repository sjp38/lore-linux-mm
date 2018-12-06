Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 098C66B7C22
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 15:46:46 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id r16so990284pgr.15
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 12:46:45 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w22si1035173plp.301.2018.12.06.12.46.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 12:46:44 -0800 (PST)
Date: Thu, 6 Dec 2018 14:46:43 -0600
From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: [PATCH] PCI/P2PDMA: Match interface changes to
 devm_memremap_pages()
Message-ID: <20181206204643.GC247703@google.com>
References: <20181130225911.2900-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181130225911.2900-1-logang@deltatee.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-pci@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>

On Fri, Nov 30, 2018 at 03:59:11PM -0700, Logan Gunthorpe wrote:
> "mm-hmm-mark-hmm_devmem_add-add_resource-export_symbol_gpl.patch" in the
> mm tree breaks p2pdma. The patch was written and reviewed before p2pdma
> was merged so the necessary changes were not done to the call site in
> that code.
> 
> Without this patch, all drivers will fail to register P2P resources
> because devm_memremap_pages() will return -EINVAL due to the 'kill'
> member of the pagemap structure not yet being set.
> 
> Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Bjorn Helgaas <bhelgaas@google.com>

Applied with Dan's reviewed-by to pci/peer-to-peer for v4.21, thanks!

If the mm patch you mention gets merged for v4.20, let me know and I can
promote this to for-linus so v4.20 doesn't end up broken.

> ---
> 
> Ideally this patch should be squashed with the one mentioned above to
> avoid a bisect regression point.
> 
> drivers/pci/p2pdma.c | 10 ++--------
>  1 file changed, 2 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/pci/p2pdma.c b/drivers/pci/p2pdma.c
> index ae3c5b25dcc7..a2eb25271c96 100644
> --- a/drivers/pci/p2pdma.c
> +++ b/drivers/pci/p2pdma.c
> @@ -82,10 +82,8 @@ static void pci_p2pdma_percpu_release(struct percpu_ref *ref)
>  	complete_all(&p2p->devmap_ref_done);
>  }
> 
> -static void pci_p2pdma_percpu_kill(void *data)
> +static void pci_p2pdma_percpu_kill(struct percpu_ref *ref)
>  {
> -	struct percpu_ref *ref = data;
> -
>  	/*
>  	 * pci_p2pdma_add_resource() may be called multiple times
>  	 * by a driver and may register the percpu_kill devm action multiple
> @@ -198,6 +196,7 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
>  	pgmap->type = MEMORY_DEVICE_PCI_P2PDMA;
>  	pgmap->pci_p2pdma_bus_offset = pci_bus_address(pdev, bar) -
>  		pci_resource_start(pdev, bar);
> +	pgmap->kill = pci_p2pdma_percpu_kill;
> 
>  	addr = devm_memremap_pages(&pdev->dev, pgmap);
>  	if (IS_ERR(addr)) {
> @@ -211,11 +210,6 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
>  	if (error)
>  		goto pgmap_free;
> 
> -	error = devm_add_action_or_reset(&pdev->dev, pci_p2pdma_percpu_kill,
> -					  &pdev->p2pdma->devmap_ref);
> -	if (error)
> -		goto pgmap_free;
> -
>  	pci_info(pdev, "added peer-to-peer DMA memory %pR\n",
>  		 &pgmap->res);
> 
> --
> 2.19.0
