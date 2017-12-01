Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 780A36B025E
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 10:49:58 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id s10so5317579oth.14
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 07:49:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d37si2257894oic.368.2017.12.01.07.49.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Dec 2017 07:49:57 -0800 (PST)
Date: Fri, 1 Dec 2017 17:49:36 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v18 10/10] virtio-balloon: don't report free pages when
 page poisoning is enabled
Message-ID: <20171201173951-mutt-send-email-mst@kernel.org>
References: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
 <1511963726-34070-11-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511963726-34070-11-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

On Wed, Nov 29, 2017 at 09:55:26PM +0800, Wei Wang wrote:
> The guest free pages should not be discarded by the live migration thread
> when page poisoning is enabled with PAGE_POISONING_NO_SANITY=n, because
> skipping the transfer of such poisoned free pages will trigger false
> positive when new pages are allocated and checked on the destination.
> This patch skips the reporting of free pages in the above case.
> 
> Reported-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> ---
>  drivers/virtio/virtio_balloon.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 035bd3a..6ac4cff 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -652,7 +652,9 @@ static void report_free_page(struct work_struct *work)
>  	/* Start by sending the obtained cmd id to the host with an outbuf */
>  	send_one_desc(vb, vb->free_page_vq, virt_to_phys(&vb->start_cmd_id),
>  		      sizeof(uint32_t), false, true, false);
> -	walk_free_mem_block(vb, 0, &virtio_balloon_send_free_pages);
> +	if (!(page_poisoning_enabled() &&
> +	    !IS_ENABLED(CONFIG_PAGE_POISONING_NO_SANITY)))
> +		walk_free_mem_block(vb, 0, &virtio_balloon_send_free_pages);
>  	/*
>  	 * End by sending the stop id to the host with an outbuf. Use the
>  	 * non-batching mode here to trigger a kick after adding the stop id.

PAGE_POISONING_ZERO is actually OK.

But I really would prefer it that we still send pages to host,
otherwise debugging becomes much harder.

And it does not have to be completely useless, even though
you can not discard them as they would be zero-filled then.

How about a config field telling host what should be there in the free
pages? This way even though host can not discard them, host can send
them out without reading them, still a win.



> -- 
> 2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
