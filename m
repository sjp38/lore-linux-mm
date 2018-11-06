Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 26E186B02A9
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 21:42:50 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id r127-v6so14289070itr.4
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 18:42:50 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id c13-v6si476694itc.46.2018.11.05.18.42.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 18:42:49 -0800 (PST)
Date: Mon, 5 Nov 2018 18:42:28 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [RFC PATCH v4 06/13] vfio: parallelize vfio_pin_map_dma
Message-ID: <20181106024228.sxkn3s22mfkf7lcc@ca-dmjordan1.us.oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105165558.11698-7-daniel.m.jordan@oracle.com>
 <20181105145141.6f9937f6@w520.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181105145141.6f9937f6@w520.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Williamson <alex.williamson@redhat.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

On Mon, Nov 05, 2018 at 02:51:41PM -0700, Alex Williamson wrote:
> On Mon,  5 Nov 2018 11:55:51 -0500
> Daniel Jordan <daniel.m.jordan@oracle.com> wrote:
> > +static int vfio_pin_map_dma_chunk(unsigned long start_vaddr,
> > +				  unsigned long end_vaddr,
> > +				  struct vfio_pin_args *args)
> >  {
> > -	dma_addr_t iova = dma->iova;
> > -	unsigned long vaddr = dma->vaddr;
> > -	size_t size = map_size;
> > +	struct vfio_dma *dma = args->dma;
> > +	dma_addr_t iova = dma->iova + (start_vaddr - dma->vaddr);
> > +	unsigned long unmapped_size = end_vaddr - start_vaddr;
> > +	unsigned long pfn, mapped_size = 0;
> >  	long npage;
> > -	unsigned long pfn, limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
> >  	int ret = 0;
> >  
> > -	while (size) {
> > +	while (unmapped_size) {
> >  		/* Pin a contiguous chunk of memory */
> > -		npage = vfio_pin_pages_remote(dma, vaddr + dma->size,
> > -					      size >> PAGE_SHIFT, &pfn, limit);
> > +		npage = vfio_pin_pages_remote(dma, start_vaddr + mapped_size,
> > +					      unmapped_size >> PAGE_SHIFT,
> > +					      &pfn, args->limit, args->mm);
> >  		if (npage <= 0) {
> >  			WARN_ON(!npage);
> >  			ret = (int)npage;
> > @@ -1052,22 +1067,50 @@ static int vfio_pin_map_dma(struct vfio_iommu *iommu, struct vfio_dma *dma,
> >  		}
> >  
> >  		/* Map it! */
> > -		ret = vfio_iommu_map(iommu, iova + dma->size, pfn, npage,
> > -				     dma->prot);
> > +		ret = vfio_iommu_map(args->iommu, iova + mapped_size, pfn,
> > +				     npage, dma->prot);
> >  		if (ret) {
> > -			vfio_unpin_pages_remote(dma, iova + dma->size, pfn,
> > +			vfio_unpin_pages_remote(dma, iova + mapped_size, pfn,
> >  						npage, true);
> >  			break;
> >  		}
> >  
> > -		size -= npage << PAGE_SHIFT;
> > -		dma->size += npage << PAGE_SHIFT;
> > +		unmapped_size -= npage << PAGE_SHIFT;
> > +		mapped_size   += npage << PAGE_SHIFT;
> >  	}
> >  
> > +	return (ret == 0) ? KTASK_RETURN_SUCCESS : ret;
> 
> Overall I'm a big fan of this, but I think there's an undo problem
> here.  Per 03/13, kc_undo_func is only called for successfully
> completed chunks and each kc_thread_func should handle cleanup of any
> intermediate work before failure.  That's not done here afaict.  Should
> we be calling the vfio_pin_map_dma_undo() manually on the completed
> range before returning error?

Yes, we should be, thanks very much for catching this.

At least I documented what I didn't do?  :)

> 
> > +}
> > +
> > +static void vfio_pin_map_dma_undo(unsigned long start_vaddr,
> > +				  unsigned long end_vaddr,
> > +				  struct vfio_pin_args *args)
> > +{
> > +	struct vfio_dma *dma = args->dma;
> > +	dma_addr_t iova = dma->iova + (start_vaddr - dma->vaddr);
> > +	dma_addr_t end  = dma->iova + (end_vaddr   - dma->vaddr);
> > +
> > +	vfio_unmap_unpin(args->iommu, args->dma, iova, end, true);
> > +}
> > +
> > +static int vfio_pin_map_dma(struct vfio_iommu *iommu, struct vfio_dma *dma,
> > +			    size_t map_size)
> > +{
> > +	unsigned long limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
> > +	int ret = 0;
> > +	struct vfio_pin_args args = { iommu, dma, limit, current->mm };
> > +	/* Stay on PMD boundary in case THP is being used. */
> > +	DEFINE_KTASK_CTL(ctl, vfio_pin_map_dma_chunk, &args, PMD_SIZE);
> 
> PMD_SIZE chunks almost seems too convenient, I wonder a) is that really
> enough work per thread, and b) is this really successfully influencing
> THP?  Thanks,

Yes, you're right on both counts.  I'd been using PUD_SIZE for a while in
testing and meant to switch it back to KTASK_MEM_CHUNK (128M) but used PMD_SIZE
by mistake.  PUD_SIZE chunks have made thread finishing times too spread out
in some cases, so 128M seems to be a reasonable compromise.

Thanks for the thorough and quick review.

Daniel
