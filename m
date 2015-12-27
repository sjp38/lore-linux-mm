Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9240A6B02BC
	for <linux-mm@kvack.org>; Sun, 27 Dec 2015 18:36:17 -0500 (EST)
Received: by mail-qg0-f44.google.com with SMTP id 6so60239069qgy.1
        for <linux-mm@kvack.org>; Sun, 27 Dec 2015 15:36:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z139si62144521qka.98.2015.12.27.15.36.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Dec 2015 15:36:17 -0800 (PST)
Date: Sun, 27 Dec 2015 18:36:11 -0500
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH 1/2] virtio_balloon: fix race by fill and leak
Message-ID: <20151227233610.GB624@t510.redhat.com>
References: <1451259313-26353-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1451259313-26353-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Michael S. Tsirkin" <mst@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Konstantin Khlebnikov <koct9i@gmail.com>, stable@vger.kernel.org

On Mon, Dec 28, 2015 at 08:35:12AM +0900, Minchan Kim wrote:
> During my compaction-related stuff, I encountered a bug
> with ballooning.
> 
> With repeated inflating and deflating cycle, guest memory(
> ie, cat /proc/meminfo | grep MemTotal) is decreased and
> couldn't be recovered.
> 
> The reason is balloon_lock doesn't cover release_pages_balloon
> so struct virtio_balloon fields could be overwritten by race
> of fill_balloon(e,g, vb->*pfns could be critical).
> 
> This patch fixes it in my test.
> 
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  drivers/virtio/virtio_balloon.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 7efc32945810..7d3e5d0e9aa4 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -209,8 +209,8 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
>  	 */
>  	if (vb->num_pfns != 0)
>  		tell_host(vb, vb->deflate_vq);
> -	mutex_unlock(&vb->balloon_lock);
>  	release_pages_balloon(vb);
> +	mutex_unlock(&vb->balloon_lock);
>  	return num_freed_pages;
>  }
>  
> -- 
> 1.9.1
> 
Acked-by: Rafael Aquini <aquini@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
