Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id E83BF6B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 05:45:16 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id n42so5425239ioe.12
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 02:45:16 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y203si3218138itb.91.2017.11.30.02.45.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Nov 2017 02:45:15 -0800 (PST)
Subject: Re: [PATCH v18 10/10] virtio-balloon: don't report free pages when page poisoning is enabled
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
	<1511963726-34070-11-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1511963726-34070-11-git-send-email-wei.w.wang@intel.com>
Message-Id: <201711301945.HJD69236.OSMQtOFHOJLVFF@I-love.SAKURA.ne.jp>
Date: Thu, 30 Nov 2017 19:45:13 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org

Wei Wang wrote:
> @@ -652,7 +652,9 @@ static void report_free_page(struct work_struct *work)
>  	/* Start by sending the obtained cmd id to the host with an outbuf */
>  	send_one_desc(vb, vb->free_page_vq, virt_to_phys(&vb->start_cmd_id),
>  		      sizeof(uint32_t), false, true, false);
> -	walk_free_mem_block(vb, 0, &virtio_balloon_send_free_pages);
> +	if (!(page_poisoning_enabled() &&
> +	    !IS_ENABLED(CONFIG_PAGE_POISONING_NO_SANITY)))

I think that checking IS_ENABLED() before checking page_poisoning_enabled()
would generate better code, for IS_ENABLED() is build-time constant while
page_poisoning_enabled() is a function which the compiler assumes that we
need to call page_poisoning_enabled() even if IS_ENABLED() is known to be 0.

	if (IS_ENABLED(CONFIG_PAGE_POISONING_NO_SANITY) ||
	    !page_poisoning_enabled())

> +		walk_free_mem_block(vb, 0, &virtio_balloon_send_free_pages);
>  	/*
>  	 * End by sending the stop id to the host with an outbuf. Use the
>  	 * non-batching mode here to trigger a kick after adding the stop id.
> -- 
> 2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
