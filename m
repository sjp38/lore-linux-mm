Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id AC68A6B0055
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 15:41:10 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so1361482pdj.29
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 12:41:10 -0700 (PDT)
From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: Re: [PATCH 05/26] omap3isp: Make isp_video_buffer_prepare_user() use get_user_pages_fast()
Date: Wed, 02 Oct 2013 21:41:10 +0200
Message-ID: <11048370.rLWI050cLv@avalon>
In-Reply-To: <1380724087-13927-6-git-send-email-jack@suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz> <1380724087-13927-6-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-media@vger.kernel.org

Hi Jan,

Thank you for the patch.

On Wednesday 02 October 2013 16:27:46 Jan Kara wrote:
> CC: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
> CC: linux-media@vger.kernel.org
> Signed-off-by: Jan Kara <jack@suse.cz>

Acked-by: Laurent Pinchart <laurent.pinchart@ideasonboard.com>

Could you briefly explain where you're headed with this ? The V4L2 subsystem 
has suffered for quite a long time from potentiel AB-BA deadlocks, due the 
drivers taking the mmap_sem semaphore while holding the V4L2 buffers queue 
lock in the code path below, and taking them in reverse order in the mmap() 
path (as the mm core takes the mmap_sem semaphore before calling the mmap() 
operation). We've solved that by releasing the V4L2 buffers queue lock before 
taking the mmap_sem lock below and taking it back after releasing the mmap_sem 
lock. Having an explicit indication that the mmap_sem lock was taken helped 
keeping the problem in mind. I'm not against hiding it in 
get_user_pages_fast(), but I'd like to know what the next step is. Maybe it 
would also be worth it adding a /* get_user_pages_fast() takes the mmap_sem */ 
comment before the call ?

> ---
>  drivers/media/platform/omap3isp/ispqueue.c | 10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/media/platform/omap3isp/ispqueue.c
> b/drivers/media/platform/omap3isp/ispqueue.c index
> e15f01342058..bed380395e6c 100644
> --- a/drivers/media/platform/omap3isp/ispqueue.c
> +++ b/drivers/media/platform/omap3isp/ispqueue.c
> @@ -331,13 +331,9 @@ static int isp_video_buffer_prepare_user(struct
> isp_video_buffer *buf) if (buf->pages == NULL)
>  		return -ENOMEM;
> 
> -	down_read(&current->mm->mmap_sem);
> -	ret = get_user_pages(current, current->mm, data & PAGE_MASK,
> -			     buf->npages,
> -			     buf->vbuf.type == V4L2_BUF_TYPE_VIDEO_CAPTURE, 0,
> -			     buf->pages, NULL);
> -	up_read(&current->mm->mmap_sem);
> -
> +	ret = get_user_pages_fast(data & PAGE_MASK, buf->npages,
> +				  buf->vbuf.type == V4L2_BUF_TYPE_VIDEO_CAPTURE,
> +				  buf->pages);
>  	if (ret != buf->npages) {
>  		buf->npages = ret < 0 ? 0 : ret;
>  		isp_video_buffer_cleanup(buf);
-- 
Regards,

Laurent Pinchart

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
