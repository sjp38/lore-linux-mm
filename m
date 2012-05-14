Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id C3D526B00E7
	for <linux-mm@kvack.org>; Mon, 14 May 2012 04:13:33 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (mailout1.samsung.com [203.254.224.24])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M40003X36TLXSJ0@mailout1.samsung.com> for
 linux-mm@kvack.org; Mon, 14 May 2012 17:13:32 +0900 (KST)
Received: from NOINKIDAE02 ([165.213.219.102])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M4000KQJ6UKKL02@mmp1.samsung.com> for linux-mm@kvack.org;
 Mon, 14 May 2012 17:13:32 +0900 (KST)
From: Inki Dae <inki.dae@samsung.com>
References: <1336544259-17222-1-git-send-email-inki.dae@samsung.com>
 <1336976268-14328-1-git-send-email-inki.dae@samsung.com>
 <1336976268-14328-3-git-send-email-inki.dae@samsung.com>
 <CAHGf_=qv45_uuO_JWMXOQp4VymyOxVq76rGXghoNMmDh7mURKQ@mail.gmail.com>
 <003001cd319e$263c9230$72b5b690$%dae@samsung.com> <4FB0AE87.60800@gmail.com>
In-reply-to: <4FB0AE87.60800@gmail.com>
Subject: RE: [PATCH 2/2 v4] drm/exynos: added userptr feature.
Date: Mon, 14 May 2012 17:13:29 +0900
Message-id: <003601cd31a9$71c2d380$55487a80$%dae@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'KOSAKI Motohiro' <kosaki.motohiro@gmail.com>
Cc: linux-mm@kvack.org, airlied@linux.ie, dri-devel@lists.freedesktop.org, j.glisse@gmail.com, minchan@kernel.org, kyungmin.park@samsung.com, sw0312.kim@samsung.com, jy0922.shim@samsung.com

ccing linux-mm

> -----Original Message-----
> From: KOSAKI Motohiro [mailto:kosaki.motohiro@gmail.com]
> Sent: Monday, May 14, 2012 4:05 PM
> To: Inki Dae
> Cc: 'KOSAKI Motohiro'; airlied@linux.ie; dri-devel@lists.freedesktop.org;
> j.glisse@gmail.com; minchan@kernel.org; kyungmin.park@samsung.com;
> sw0312.kim@samsung.com; jy0922.shim@samsung.com
> Subject: Re: [PATCH 2/2 v4] drm/exynos: added userptr feature.
> 
> (5/14/12 2:52 AM), Inki Dae wrote:
> >
> >
> >> -----Original Message-----
> >> From: KOSAKI Motohiro [mailto:kosaki.motohiro@gmail.com]
> >> Sent: Monday, May 14, 2012 3:33 PM
> >> To: Inki Dae
> >> Cc: airlied@linux.ie; dri-devel@lists.freedesktop.org;
> j.glisse@gmail.com;
> >> minchan@kernel.org; kyungmin.park@samsung.com; sw0312.kim@samsung.com;
> >> jy0922.shim@samsung.com
> >> Subject: Re: [PATCH 2/2 v4] drm/exynos: added userptr feature.
> >>
> >>> +       npages = buf->size>>  PAGE_SHIFT;
> >>
> >> Why round down? usually we use round up.
> >>
> >
> > The size was already rounded up by exynos_drm_gem_userptr_ioctl so this
> is
> > just used to get page count.
> 
> got it.
> 
> 
> 
> >>> +       down_read(&current->mm->mmap_sem);
> >>> +
> >>> +       /*
> >>> +        * Basically, all the pages from get_user_pages() can not be
not
> >> only
> >>> +        * migrated by CMA but also swapped out.
> >>> +        *
> >>> +        * The migration issue.
> >>> +        * - Pages reserved by CMA for some device using DMA could be
> >> used by
> >>> +        * kernel and if the device driver wants to use those pages
> >>> +        * while being used by kernel then the pages are copied into
> >>> +        * other ones allocated to migrate them and then finally,
> >>> +        * the device driver can use the pages for itself.
> >>> +        * Thus, migrated, the pages being accessed by DMA could be
> >> changed
> >>> +        * to other so this situation may incur that DMA accesses any
> >> pages
> >>> +        * it doesn't want.
> >>> +        *
> >>> +        * But the use of get_user_pages is safe from such magration
> >> issue
> >>> +        * because all the pages from get_user_pages CAN NOT be not
only
> >>> +        * migrated, but also swapped out.
> >>> +        */
> >>> +       get_npages = get_user_pages(current, current->mm, userptr,
> >>> +                                       npages, write, 1, buf->pages,
> > NULL);
> >>
> >> Why force=1? It is almostly core-dump specific option. Why don't you
> >> return
> >
> > I know that force indicates whether to force write access even  if user
> > mapping is readonly.
> 
> right. and then, usually we don't want to ignore access permission. but
> note,
> I'm only talk about generic thing. I have no knowledge drm area.
> 
> 
> 
> > so we just want to use pages from get_user_pages as
> > read/write permission.
> 
> >> EFAULT when the page has write permission. IOW, Why your Xorg module
> >> don't map memory w/ PROT_WRITE?
> >
> > No, Xorg can map memory w/ PROT_WRITE. Couldn't the Xorg map w/
> PROT_WRITE
> > if force = 1? plz, let me know if there is my missing point.
> 
> I meant, if Xorg always use PROT_WRITE, you don't need force=1.
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
