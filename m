Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3AB036B0038
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 01:20:47 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r6so13931136pfj.14
        for <linux-mm@kvack.org>; Sat, 21 Oct 2017 22:20:47 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s17si3347953pfg.209.2017.10.21.22.20.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 21 Oct 2017 22:20:45 -0700 (PDT)
Subject: Re: [PATCH v1 1/3] virtio-balloon: replace the coarse-grained balloon_lock
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1508500466-21165-1-git-send-email-wei.w.wang@intel.com>
	<1508500466-21165-2-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1508500466-21165-2-git-send-email-wei.w.wang@intel.com>
Message-Id: <201710221420.FHG17654.OOMFQSFJVFHLtO@I-love.SAKURA.ne.jp>
Date: Sun, 22 Oct 2017 14:20:34 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com, mst@redhat.com
Cc: mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org

Wei Wang wrote:
> The balloon_lock was used to synchronize the access demand to elements
> of struct virtio_balloon and its queue operations (please see commit
> e22504296d). This prevents the concurrent run of the leak_balloon and
> fill_balloon functions, thereby resulting in a deadlock issue on OOM:
> 
> fill_balloon: take balloon_lock and wait for OOM to get some memory;
> oom_notify: release some inflated memory via leak_balloon();
> leak_balloon: wait for balloon_lock to be released by fill_balloon.
> 
> This patch breaks the lock into two fine-grained inflate_lock and
> deflate_lock, and eliminates the unnecessary use of the shared data
> (i.e. vb->pnfs, vb->num_pfns). This enables leak_balloon and
> fill_balloon to run concurrently and solves the deadlock issue.
> 

> @@ -162,20 +160,20 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  			msleep(200);
>  			break;
>  		}
> -		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> -		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
> +		set_page_pfns(vb, pfns + num_pfns, page);
>  		if (!virtio_has_feature(vb->vdev,
>  					VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
>  			adjust_managed_page_count(page, -1);
>  	}
>  
> -	num_allocated_pages = vb->num_pfns;
> +	mutex_lock(&vb->inflate_lock);
>  	/* Did we get any? */
> -	if (vb->num_pfns != 0)
> -		tell_host(vb, vb->inflate_vq);
> -	mutex_unlock(&vb->balloon_lock);
> +	if (num_pfns != 0)
> +		tell_host(vb, vb->inflate_vq, pfns, num_pfns);
> +	mutex_unlock(&vb->inflate_lock);
> +	atomic64_add(num_pfns, &vb->num_pages);

Isn't this addition too late? If leak_balloon() is called due to
out_of_memory(), it will fail to find up to dated vb->num_pages value.

>  
> -	return num_allocated_pages;
> +	return num_pfns;
>  }
>  
>  static void release_pages_balloon(struct virtio_balloon *vb,
> @@ -194,38 +192,39 @@ static void release_pages_balloon(struct virtio_balloon *vb,
>  
>  static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
>  {
> -	unsigned num_freed_pages;
>  	struct page *page;
>  	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
>  	LIST_HEAD(pages);
> +	unsigned int num_pfns;
> +	__virtio32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];

This array consumes 1024 bytes of kernel stack, doesn't it?
leak_balloon() might be called from out_of_memory() where kernel stack
is already largely consumed before entering __alloc_pages_nodemask().
For reducing possibility of stack overflow, since out_of_memory() is
serialized by oom_lock, I suggest using static (maybe kmalloc()ed as
vb->oom_pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX]) buffer when called from
out_of_memory().

>  
>  	/* We can only do one array worth at a time. */
> -	num = min(num, ARRAY_SIZE(vb->pfns));
> +	num = min_t(size_t, num, VIRTIO_BALLOON_ARRAY_PFNS_MAX);
>  
> -	mutex_lock(&vb->balloon_lock);
>  	/* We can't release more pages than taken */
> -	num = min(num, (size_t)vb->num_pages);
> -	for (vb->num_pfns = 0; vb->num_pfns < num;
> -	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
> +	num = min_t(size_t, num, atomic64_read(&vb->num_pages));
> +	for (num_pfns = 0; num_pfns < num;
> +	     num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
>  		page = balloon_page_dequeue(vb_dev_info);

If balloon_page_dequeue() can be concurrently called by both host's request
and guest's OOM event, is (!dequeued_page) test in balloon_page_dequeue() safe?
Is such concurrency needed?

>  		if (!page)
>  			break;
> -		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> +		set_page_pfns(vb, pfns + num_pfns, page);
>  		list_add(&page->lru, &pages);
> -		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
>  	}
>  
> -	num_freed_pages = vb->num_pfns;
>  	/*
>  	 * Note that if
>  	 * virtio_has_feature(vdev, VIRTIO_BALLOON_F_MUST_TELL_HOST);
>  	 * is true, we *have* to do it in this order
>  	 */
> -	if (vb->num_pfns != 0)
> -		tell_host(vb, vb->deflate_vq);
> +	mutex_lock(&vb->deflate_lock);
> +	if (num_pfns != 0)
> +		tell_host(vb, vb->deflate_vq, pfns, num_pfns);
> +	mutex_unlock(&vb->deflate_lock);
>  	release_pages_balloon(vb, &pages);
> -	mutex_unlock(&vb->balloon_lock);
> -	return num_freed_pages;
> +	atomic64_sub(num_pfns, &vb->num_pages);

Isn't this subtraction too late?

> +
> +	return num_pfns;
>  }
>  
>  static inline void update_stat(struct virtio_balloon *vb, int idx,

> @@ -465,6 +464,7 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
>  	struct virtio_balloon *vb = container_of(vb_dev_info,
>  			struct virtio_balloon, vb_dev_info);
>  	unsigned long flags;
> +	__virtio32 pfns[VIRTIO_BALLOON_PAGES_PER_PAGE];

If this is called from memory allocation path, maybe kmalloc()ed buffer is safer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
