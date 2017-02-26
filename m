Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id AAECC6B0038
	for <linux-mm@kvack.org>; Sun, 26 Feb 2017 14:40:53 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id o22so31457609wro.6
        for <linux-mm@kvack.org>; Sun, 26 Feb 2017 11:40:53 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id m3si18697075wrm.44.2017.02.26.11.40.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Feb 2017 11:40:51 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id m70so10481360wma.1
        for <linux-mm@kvack.org>; Sun, 26 Feb 2017 11:40:51 -0800 (PST)
Date: Sun, 26 Feb 2017 20:40:48 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH] drm/via: use get_user_pages_unlocked()
Message-ID: <20170226194048.kovnpvvnrg7t53ab@phenom.ffwll.local>
References: <20161101194337.24015-1-lstoakes@gmail.com>
 <CAA5enKai6Gq7gCf6mmuXJwZrds5N8s9JAtNGxy1vAJD1zSmb2Q@mail.gmail.com>
 <CAA5enKbkwP0P1sC4WAMf_SP2QM6-Vg8YMXs_=CkNzav4yTm1ow@mail.gmail.com>
 <CAA5enKYhsACE+LFdjQexEOnOVLAC+soXs4kEtT4fxm2W7MiU=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA5enKYhsACE+LFdjQexEOnOVLAC+soXs4kEtT4fxm2W7MiU=g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Michal Hocko <mhocko@kernel.org>, David Airlie <airlied@linux.ie>, dri-devel@lists.freedesktop.org, Andrew Morton <akpm@linux-foundation.org>

On Mon, Feb 20, 2017 at 06:46:54PM +0000, Lorenzo Stoakes wrote:
> On 6 January 2017 at 07:09, Lorenzo Stoakes <lstoakes@gmail.com> wrote:
> >
> > Adding Andrew, as this may be another less active corner of the corner, thanks!
> 
> Hi all,
> 
> Thought I'd also give this one a gentle nudge now the merge window has
> re-opened, Andrew - are you ok to pick this up? I've checked the patch
> and it still applies, for convenience the raw patch is available at
> https://marc.info/?l=linux-mm&m=147802942832515&q=raw - let me know if
> there's anything else I can do on this or if you'd prefer a re-send.

Somehow your original patch never made it to dri-devel :( The via driver
is entirely unmaintained, but if you resubmit I'll smash it into drm-misc
for 4.12. Merge window is long over already for 4.11, subsystems need to
have their stuff ready _before_ it starts.

Cheers, Daniel
> 
> Best, Lorenzo
> 
> > On 3 January 2017 at 20:23, Lorenzo Stoakes <lstoakes@gmail.com> wrote:
> >> Hi All,
> >>
> >> Just a gentle ping on this one :)
> >>
> >> Cheers, Lorenzo
> >>
> >> On 1 November 2016 at 19:43, Lorenzo Stoakes <lstoakes@gmail.com> wrote:
> >>> Moving from get_user_pages() to get_user_pages_unlocked() simplifies the code
> >>> and takes advantage of VM_FAULT_RETRY functionality when faulting in pages.
> >>>
> >>> Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
> >>> ---
> >>>  drivers/gpu/drm/via/via_dmablit.c | 10 +++-------
> >>>  1 file changed, 3 insertions(+), 7 deletions(-)
> >>>
> >>> diff --git a/drivers/gpu/drm/via/via_dmablit.c b/drivers/gpu/drm/via/via_dmablit.c
> >>> index 1a3ad76..98aae98 100644
> >>> --- a/drivers/gpu/drm/via/via_dmablit.c
> >>> +++ b/drivers/gpu/drm/via/via_dmablit.c
> >>> @@ -238,13 +238,9 @@ via_lock_all_dma_pages(drm_via_sg_info_t *vsg,  drm_via_dmablit_t *xfer)
> >>>         vsg->pages = vzalloc(sizeof(struct page *) * vsg->num_pages);
> >>>         if (NULL == vsg->pages)
> >>>                 return -ENOMEM;
> >>> -       down_read(&current->mm->mmap_sem);
> >>> -       ret = get_user_pages((unsigned long)xfer->mem_addr,
> >>> -                            vsg->num_pages,
> >>> -                            (vsg->direction == DMA_FROM_DEVICE) ? FOLL_WRITE : 0,
> >>> -                            vsg->pages, NULL);
> >>> -
> >>> -       up_read(&current->mm->mmap_sem);
> >>> +       ret = get_user_pages_unlocked((unsigned long)xfer->mem_addr,
> >>> +                       vsg->num_pages, vsg->pages,
> >>> +                       (vsg->direction == DMA_FROM_DEVICE) ? FOLL_WRITE : 0);
> >>>         if (ret != vsg->num_pages) {
> >>>                 if (ret < 0)
> >>>                         return ret;
> >>> --
> >>> 2.10.2
> >>>
> 
> -- 
> Lorenzo Stoakes
> https://ljs.io
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
