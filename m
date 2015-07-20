Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 647C69003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 16:26:20 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so71838412wib.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 13:26:20 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bb10si20958578wib.69.2015.07.21.13.26.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Jul 2015 13:26:18 -0700 (PDT)
Date: Mon, 20 Jul 2015 10:03:35 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 9/9] drm/exynos: Convert g2d_userptr_get_dma_addr() to
 use get_vaddr_frames()
Message-ID: <20150720080335.GB3131@quack.suse.cz>
References: <1436799351-21975-1-git-send-email-jack@suse.com>
 <1436799351-21975-10-git-send-email-jack@suse.com>
 <55A8D700.9080203@xs4all.nl>
 <55A8D903.2080102@samsung.com>
 <55A8D96F.5000704@xs4all.nl>
 <55A9C484.2090707@samsung.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="6TrnltStXW4iwmi0"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <55A9C484.2090707@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Inki Dae <inki.dae@samsung.com>
Cc: Hans Verkuil <hverkuil@xs4all.nl>, Jan Kara <jack@suse.com>, linux-media@vger.kernel.org, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, linux-samsung-soc@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Marek Szyprowski <m.szyprowski@samsung.com>


--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Sat 18-07-15 12:14:12, Inki Dae wrote:
> On 2015e?? 07i?? 17i? 1/4  19:31, Hans Verkuil wrote:
> > On 07/17/2015 12:29 PM, Inki Dae wrote:
> >> On 2015e?? 07i?? 17i? 1/4  19:20, Hans Verkuil wrote:
> >>> On 07/13/2015 04:55 PM, Jan Kara wrote:
> >>>> From: Jan Kara <jack@suse.cz>
> >>>>
> >>>> Convert g2d_userptr_get_dma_addr() to pin pages using get_vaddr_frames().
> >>>> This removes the knowledge about vmas and mmap_sem locking from exynos
> >>>> driver. Also it fixes a problem that the function has been mapping user
> >>>> provided address without holding mmap_sem.
> >>>
> >>> I'd like to see an Ack from one of the exynos drm driver maintainers before
> >>> I merge this.
> >>>
> >>> Inki, Marek?
> >>
> >> I already gave Ack but it seems that Jan missed it while updating.
> >>
> >> Anyway,
> >> Acked-by: Inki Dae <inki.dae@samsung.com>
> > 
> > Thanks!
> 
> Oops, sorry. This patch would incur a build warning. Below is my comment.
> 
> >>>> @@ -456,65 +455,38 @@ static dma_addr_t *g2d_userptr_get_dma_addr(struct drm_device *drm_dev,
> >>>>  		return ERR_PTR(-ENOMEM);
> >>>>  
> >>>>  	atomic_set(&g2d_userptr->refcount, 1);
> >>>> +	g2d_userptr->size = size;
> >>>>  
> >>>>  	start = userptr & PAGE_MASK;
> >>>>  	offset = userptr & ~PAGE_MASK;
> >>>>  	end = PAGE_ALIGN(userptr + size);
> >>>>  	npages = (end - start) >> PAGE_SHIFT;
> >>>> -	g2d_userptr->npages = npages;
> >>>> -
> >>>> -	pages = drm_calloc_large(npages, sizeof(struct page *));
> >>>> -	if (!pages) {
> >>>> -		DRM_ERROR("failed to allocate pages.\n");
> >>>> -		ret = -ENOMEM;
> >>>> +	g2d_userptr->vec = frame_vector_create(npages);
> >>>> +	if (!g2d_userptr->vec)
> 
> You would need ret = -EFAULT here. And below is a patch posted already,
> 	http://www.spinics.net/lists/dri-devel/msg85321.html

The error should IMHO be -ENOMEM because frame_vector_create() fails only
if we fail to allocate the structure. Attached is the updated version of
the patch. Hans, can you please pick this one?
 
> ps. please, ignore the codes related to build error in the patch.
> 
> With the change, Acked-by: Inki Dae <inki.dae@samsung.com>

Thanks and sorry for making so many stupid mistakes in the Exynos driver.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--6TrnltStXW4iwmi0
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0009-drm-exynos-Convert-g2d_userptr_get_dma_addr-to-use-g.patch"


--6TrnltStXW4iwmi0--
