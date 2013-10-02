Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id D86266B003D
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 16:18:43 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id g10so1440898pdj.16
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 13:18:43 -0700 (PDT)
Date: Wed, 2 Oct 2013 22:18:38 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 05/26] omap3isp: Make isp_video_buffer_prepare_user() use
 get_user_pages_fast()
Message-ID: <20131002201838.GE16998@quack.suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
 <1380724087-13927-6-git-send-email-jack@suse.cz>
 <11048370.rLWI050cLv@avalon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <11048370.rLWI050cLv@avalon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-media@vger.kernel.org

On Wed 02-10-13 21:41:10, Laurent Pinchart wrote:
> Hi Jan,
> 
> Thank you for the patch.
> 
> On Wednesday 02 October 2013 16:27:46 Jan Kara wrote:
> > CC: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
> > CC: linux-media@vger.kernel.org
> > Signed-off-by: Jan Kara <jack@suse.cz>
> 
> Acked-by: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
  Thanks!
> 
> Could you briefly explain where you're headed with this ?
  My motivation is that currently filesystems have to workaround locking
problems with ->page_mkwrite() (the write page fault handler) being called
with mmap_sem held. The plan is to provide ability to ->page_mkwrite()
handler to drop mmap_sem. And that needs an audit of all get_user_pages()
callers to verify they won't be broken by this locking change. So I've
started with making this audit simpler.

> The V4L2 subsystem has suffered for quite a long time from potentiel
> AB-BA deadlocks, due the drivers taking the mmap_sem semaphore while
> holding the V4L2 buffers queue lock in the code path below, and taking
> them in reverse order in the mmap() path (as the mm core takes the
> mmap_sem semaphore before calling the mmap() operation).
  Yeah, I've read about this in some comment in V4L2. Also there are some
places (drivers/media/platform/omap/omap_vout.c and
drivers/media/v4l2-core/) which acquire mmap_sem pretty early to avoid lock
inversion with the queue lock. These are actually causing me quite some
headache :)

> We've solved that by releasing the V4L2 buffers queue lock before 
> taking the mmap_sem lock below and taking it back after releasing the mmap_sem 
> lock. Having an explicit indication that the mmap_sem lock was taken helped 
> keeping the problem in mind. I'm not against hiding it in 
> get_user_pages_fast(), but I'd like to know what the next step is. Maybe it 
> would also be worth it adding a /* get_user_pages_fast() takes the mmap_sem */ 
> comment before the call ?
  OK, I can add the comment. Thanks for review.

								Honza

> > ---
> >  drivers/media/platform/omap3isp/ispqueue.c | 10 +++-------
> >  1 file changed, 3 insertions(+), 7 deletions(-)
> > 
> > diff --git a/drivers/media/platform/omap3isp/ispqueue.c
> > b/drivers/media/platform/omap3isp/ispqueue.c index
> > e15f01342058..bed380395e6c 100644
> > --- a/drivers/media/platform/omap3isp/ispqueue.c
> > +++ b/drivers/media/platform/omap3isp/ispqueue.c
> > @@ -331,13 +331,9 @@ static int isp_video_buffer_prepare_user(struct
> > isp_video_buffer *buf) if (buf->pages == NULL)
> >  		return -ENOMEM;
> > 
> > -	down_read(&current->mm->mmap_sem);
> > -	ret = get_user_pages(current, current->mm, data & PAGE_MASK,
> > -			     buf->npages,
> > -			     buf->vbuf.type == V4L2_BUF_TYPE_VIDEO_CAPTURE, 0,
> > -			     buf->pages, NULL);
> > -	up_read(&current->mm->mmap_sem);
> > -
> > +	ret = get_user_pages_fast(data & PAGE_MASK, buf->npages,
> > +				  buf->vbuf.type == V4L2_BUF_TYPE_VIDEO_CAPTURE,
> > +				  buf->pages);
> >  	if (ret != buf->npages) {
> >  		buf->npages = ret < 0 ? 0 : ret;
> >  		isp_video_buffer_cleanup(buf);
> -- 
> Regards,
> 
> Laurent Pinchart
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
