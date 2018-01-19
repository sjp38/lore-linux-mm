Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 608936B0069
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 01:01:44 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f5so828643pgp.18
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 22:01:44 -0800 (PST)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0072.outbound.protection.outlook.com. [104.47.41.72])
        by mx.google.com with ESMTPS id m16si7688648pgc.628.2018.01.18.22.01.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 18 Jan 2018 22:01:43 -0800 (PST)
Subject: Re: [PATCH 3/4] drm/gem: adjust per file OOM badness on handling
 buffers
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
 <1516294072-17841-4-git-send-email-andrey.grodzovsky@amd.com>
From: Chunming Zhou <zhoucm1@amd.com>
Message-ID: <bc332280-b60d-308b-5a52-8131590c06b7@amd.com>
Date: Fri, 19 Jan 2018 14:01:32 +0800
MIME-Version: 1.0
In-Reply-To: <1516294072-17841-4-git-send-email-andrey.grodzovsky@amd.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Grodzovsky <andrey.grodzovsky@amd.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Cc: Christian.Koenig@amd.com



On 2018a1'01ae??19ae?JPY 00:47, Andrey Grodzovsky wrote:
> Large amounts of VRAM are usually not CPU accessible, so they are not mapped
> into the processes address space. But since the device drivers usually support
> swapping buffers from VRAM to system memory we can still run into an out of
> memory situation when userspace starts to allocate to much.
>
> This patch gives the OOM another hint which process is
> holding how many resources.
>
> Signed-off-by: Andrey Grodzovsky <andrey.grodzovsky@amd.com>
> ---
>   drivers/gpu/drm/drm_file.c | 12 ++++++++++++
>   drivers/gpu/drm/drm_gem.c  |  8 ++++++++
>   include/drm/drm_file.h     |  4 ++++
>   3 files changed, 24 insertions(+)
>
> diff --git a/drivers/gpu/drm/drm_file.c b/drivers/gpu/drm/drm_file.c
> index b3c6e99..626cc76 100644
> --- a/drivers/gpu/drm/drm_file.c
> +++ b/drivers/gpu/drm/drm_file.c
> @@ -747,3 +747,15 @@ void drm_send_event(struct drm_device *dev, struct drm_pending_event *e)
>   	spin_unlock_irqrestore(&dev->event_lock, irqflags);
>   }
>   EXPORT_SYMBOL(drm_send_event);
> +
> +long drm_oom_badness(struct file *f)
> +{
> +
> +	struct drm_file *file_priv = f->private_data;
> +
> +	if (file_priv)
> +		return atomic_long_read(&file_priv->f_oom_badness);
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(drm_oom_badness);
> diff --git a/drivers/gpu/drm/drm_gem.c b/drivers/gpu/drm/drm_gem.c
> index 01f8d94..ffbadc8 100644
> --- a/drivers/gpu/drm/drm_gem.c
> +++ b/drivers/gpu/drm/drm_gem.c
> @@ -264,6 +264,9 @@ drm_gem_object_release_handle(int id, void *ptr, void *data)
>   		drm_gem_remove_prime_handles(obj, file_priv);
>   	drm_vma_node_revoke(&obj->vma_node, file_priv);
>   
> +	atomic_long_sub(obj->size >> PAGE_SHIFT,
> +				&file_priv->f_oom_badness);
> +
>   	drm_gem_object_handle_put_unlocked(obj);
>   
>   	return 0;
> @@ -299,6 +302,8 @@ drm_gem_handle_delete(struct drm_file *filp, u32 handle)
>   	idr_remove(&filp->object_idr, handle);
>   	spin_unlock(&filp->table_lock);
>   
> +	atomic_long_sub(obj->size >> PAGE_SHIFT, &filp->f_oom_badness);
> +
>   	return 0;
>   }
>   EXPORT_SYMBOL(drm_gem_handle_delete);
> @@ -417,6 +422,9 @@ drm_gem_handle_create_tail(struct drm_file *file_priv,
>   	}
>   
>   	*handlep = handle;
> +
> +	atomic_long_add(obj->size >> PAGE_SHIFT,
> +				&file_priv->f_oom_badness);
For VRAM case, it should be counted only when vram bo is evicted to 
system memory.
For example, vram total is 8GB, system memory total is 8GB, one 
application allocates 7GB vram and 7GB system memory, which is allowed, 
but if following your idea, then this application will be killed by OOM, 
right?

Regards,
David Zhou
>   	return 0;
>   
>   err_revoke:
> diff --git a/include/drm/drm_file.h b/include/drm/drm_file.h
> index 0e0c868..ac3aa75 100644
> --- a/include/drm/drm_file.h
> +++ b/include/drm/drm_file.h
> @@ -317,6 +317,8 @@ struct drm_file {
>   
>   	/* private: */
>   	unsigned long lock_count; /* DRI1 legacy lock count */
> +
> +	atomic_long_t		f_oom_badness;
>   };
>   
>   /**
> @@ -378,4 +380,6 @@ void drm_event_cancel_free(struct drm_device *dev,
>   void drm_send_event_locked(struct drm_device *dev, struct drm_pending_event *e);
>   void drm_send_event(struct drm_device *dev, struct drm_pending_event *e);
>   
> +long drm_oom_badness(struct file *f);
> +
>   #endif /* _DRM_FILE_H_ */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
