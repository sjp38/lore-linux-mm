Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id DB6356B0038
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 07:26:11 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j83so2460809oif.7
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 04:26:11 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b5si2970910oii.107.2017.11.03.04.26.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Nov 2017 04:26:11 -0700 (PDT)
Subject: Re: [PATCH v17 4/6] virtio-balloon: VIRTIO_BALLOON_F_SG
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1509696786-1597-1-git-send-email-wei.w.wang@intel.com>
	<1509696786-1597-5-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1509696786-1597-5-git-send-email-wei.w.wang@intel.com>
Message-Id: <201711032025.HJC78622.SFFOMLOtFQHVJO@I-love.SAKURA.ne.jp>
Date: Fri, 3 Nov 2017 20:25:32 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

Wei Wang wrote:
> @@ -164,6 +284,8 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  			break;
>  		}
>  
> +		if (use_sg && xb_set_page(vb, page, &pfn_min, &pfn_max) < 0)

Isn't this leaking "page" ?

> +			break;
>  		balloon_page_push(&pages, page);
>  	}
>  



> @@ -184,8 +307,12 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  
>  	num_allocated_pages = vb->num_pfns;
>  	/* Did we get any? */
> -	if (vb->num_pfns != 0)
> -		tell_host(vb, vb->inflate_vq);
> +	if (vb->num_pfns) {
> +		if (use_sg)
> +			tell_host_sgs(vb, vb->inflate_vq, pfn_min, pfn_max);

Please describe why tell_host_sgs() can work without __GFP_DIRECT_RECLAIM allocation,
for tell_host_sgs() is called with vb->balloon_lock mutex held.

> +		else
> +			tell_host(vb, vb->inflate_vq);
> +	}
>  	mutex_unlock(&vb->balloon_lock);
>  
>  	return num_allocated_pages;



> @@ -223,7 +353,13 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
>  		page = balloon_page_dequeue(vb_dev_info);
>  		if (!page)
>  			break;
> -		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> +		if (use_sg) {
> +			if (xb_set_page(vb, page, &pfn_min, &pfn_max) < 0)

Isn't this leaking "page" ?

If this is inside vb->balloon_lock mutex (isn't this?), xb_set_page() must not
use __GFP_DIRECT_RECLAIM allocation, for leak_balloon_sg_oom() will be blocked
on vb->balloon_lock mutex.

> +				break;
> +		} else {
> +			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> +		}
> +
>  		list_add(&page->lru, &pages);
>  		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
