Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 768C26B0071
	for <linux-mm@kvack.org>; Thu, 14 May 2015 07:40:02 -0400 (EDT)
Received: by wguv19 with SMTP id v19so10196752wgu.1
        for <linux-mm@kvack.org>; Thu, 14 May 2015 04:40:02 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fu7si13784466wib.72.2015.05.14.04.40.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 May 2015 04:40:00 -0700 (PDT)
Date: Thu, 14 May 2015 13:39:53 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 9/9] drm/exynos: Convert g2d_userptr_get_dma_addr() to
 use get_vaddr_frames()
Message-ID: <20150514113953.GA10093@quack.suse.cz>
References: <1431522495-4692-1-git-send-email-jack@suse.cz>
 <1431522495-4692-10-git-send-email-jack@suse.cz>
 <55547E2B.6080307@samsung.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="2oS5YaxWCcQjTEyO"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <55547E2B.6080307@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Inki Dae <inki.dae@samsung.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-samsung-soc@vger.kernel.org, Pawel Osciak <pawel@osciak.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, dri-devel@lists.freedesktop.org, mgorman@suse.de, Marek Szyprowski <m.szyprowski@samsung.com>, linux-media@vger.kernel.org


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Thu 14-05-15 19:51:23, Inki Dae wrote:
> Hi,
> 
> On 2015e?? 05i?? 13i? 1/4  22:08, Jan Kara wrote:
> > Convert g2d_userptr_get_dma_addr() to pin pages using get_vaddr_frames().
> > This removes the knowledge about vmas and mmap_sem locking from exynos
> > driver. Also it fixes a problem that the function has been mapping user
> > provided address without holding mmap_sem.
> > 
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  drivers/gpu/drm/exynos/exynos_drm_g2d.c | 89 ++++++++++--------------------
> >  drivers/gpu/drm/exynos/exynos_drm_gem.c | 97 ---------------------------------
> >  2 files changed, 29 insertions(+), 157 deletions(-)
> > 
> > diff --git a/drivers/gpu/drm/exynos/exynos_drm_g2d.c b/drivers/gpu/drm/exynos/exynos_drm_g2d.c
> > index 81a250830808..265519c0fe2d 100644
> > --- a/drivers/gpu/drm/exynos/exynos_drm_g2d.c
> > +++ b/drivers/gpu/drm/exynos/exynos_drm_g2d.c
> > @@ -190,10 +190,8 @@ struct g2d_cmdlist_userptr {
> >  	dma_addr_t		dma_addr;
> >  	unsigned long		userptr;
> >  	unsigned long		size;
> > -	struct page		**pages;
> > -	unsigned int		npages;
> > +	struct frame_vector	*vec;
> >  	struct sg_table		*sgt;
> > -	struct vm_area_struct	*vma;
> >  	atomic_t		refcount;
> >  	bool			in_pool;
> >  	bool			out_of_list;
> > @@ -363,6 +361,7 @@ static void g2d_userptr_put_dma_addr(struct drm_device *drm_dev,
> >  {
> >  	struct g2d_cmdlist_userptr *g2d_userptr =
> >  					(struct g2d_cmdlist_userptr *)obj;
> > +	struct page **pages;
> >  
> >  	if (!obj)
> >  		return;
> > @@ -382,19 +381,21 @@ out:
> >  	exynos_gem_unmap_sgt_from_dma(drm_dev, g2d_userptr->sgt,
> >  					DMA_BIDIRECTIONAL);
> >  
> > -	exynos_gem_put_pages_to_userptr(g2d_userptr->pages,
> > -					g2d_userptr->npages,
> > -					g2d_userptr->vma);
> > +	pages = frame_vector_pages(g2d_userptr->vec);
> > +	if (!IS_ERR(pages)) {
> > +		int i;
> >  
> > -	exynos_gem_put_vma(g2d_userptr->vma);
> > +		for (i = 0; i < frame_vector_count(g2d_userptr->vec); i++)
> > +			set_page_dirty_lock(pages[i]);
> > +	}
> > +	put_vaddr_frames(g2d_userptr->vec);
> > +	frame_vector_destroy(g2d_userptr->vec);
> >  
> >  	if (!g2d_userptr->out_of_list)
> >  		list_del_init(&g2d_userptr->list);
> >  
> >  	sg_free_table(g2d_userptr->sgt);
> >  	kfree(g2d_userptr->sgt);
> > -
> > -	drm_free_large(g2d_userptr->pages);
> >  	kfree(g2d_userptr);
> >  }
> >  
> > @@ -413,6 +414,7 @@ static dma_addr_t *g2d_userptr_get_dma_addr(struct drm_device *drm_dev,
> >  	struct vm_area_struct *vma;
> >  	unsigned long start, end;
> >  	unsigned int npages, offset;
> > +	struct frame_vector *vec;
> >  	int ret;
> >  
> >  	if (!size) {
> > @@ -456,65 +458,37 @@ static dma_addr_t *g2d_userptr_get_dma_addr(struct drm_device *drm_dev,
> >  		return ERR_PTR(-ENOMEM);
> >  
> >  	atomic_set(&g2d_userptr->refcount, 1);
> > +	g2d_userptr->size = size;
> >  
> >  	start = userptr & PAGE_MASK;
> >  	offset = userptr & ~PAGE_MASK;
> >  	end = PAGE_ALIGN(userptr + size);
> >  	npages = (end - start) >> PAGE_SHIFT;
> > -	g2d_userptr->npages = npages;
> > -
> > -	pages = drm_calloc_large(npages, sizeof(struct page *));
> 
> The declaration to pages isn't needed anymore because you removed it.
> 
> > -	if (!pages) {
> > -		DRM_ERROR("failed to allocate pages.\n");
> > -		ret = -ENOMEM;
> > +	vec = g2d_userptr->vec = frame_vector_create(npages);
> 
> I think you can use g2d_userptr->vec so it seems that vec isn't needed.
> 
> > +	if (!vec)
> >  		goto err_free;
> > -	}
> >  
> > -	down_read(&current->mm->mmap_sem);
> > -	vma = find_vma(current->mm, userptr);
> 
> For vma, ditto.
  Thanks for review! Attached is a new version of the patch.

								Honza

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--2oS5YaxWCcQjTEyO
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-drm-exynos-Convert-g2d_userptr_get_dma_addr-to-use-g.patch"


--2oS5YaxWCcQjTEyO--
