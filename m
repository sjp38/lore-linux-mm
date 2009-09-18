Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6CD6D6B00F8
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 16:48:47 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id d23so528917fga.8
        for <linux-mm@kvack.org>; Fri, 18 Sep 2009 13:48:52 -0700 (PDT)
Message-ID: <4AB3F227.3030602@gmail.com>
Date: Fri, 18 Sep 2009 22:48:39 +0200
From: Marcin Slusarz <marcin.slusarz@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] virtual block device driver (ramzswap)
References: <1253227412-24342-1-git-send-email-ngupta@vflare.org> <1253227412-24342-4-git-send-email-ngupta@vflare.org>
In-Reply-To: <1253227412-24342-4-git-send-email-ngupta@vflare.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>
List-ID: <linux-mm.kvack.org>

Nitin Gupta wrote:
> (...)
> +
> +static int page_zero_filled(void *ptr)
> +{
> +	u32 pos;
> +	u64 *page;
> +
> +	page = (u64 *)ptr;
> +
> +	for (pos = 0; pos != PAGE_SIZE / sizeof(*page); pos++) {
> +		if (page[pos])
> +			return 0;
> +	}
> +
> +	return 1;
> +}

Wouldn't unsigned long *page be better for both 32-bit and 64-bit machines?

(This function could return bool)

> (...)
> +static void create_device(struct ramzswap *rzs, int device_id)
> +{
> +	mutex_init(&rzs->lock);
> +	INIT_LIST_HEAD(&rzs->backing_swap_extent_list);
> +
> +	rzs->queue = blk_alloc_queue(GFP_KERNEL);
> +	if (!rzs->queue) {
> +		pr_err("Error allocating disk queue for device %d\n",
> +			device_id);
> +		return;
> +	}
> +
> +	blk_queue_make_request(rzs->queue, ramzswap_make_request);
> +	rzs->queue->queuedata = rzs;
> +
> +	 /* gendisk structure */
> +	rzs->disk = alloc_disk(1);
> +	if (!rzs->disk) {
> +		blk_cleanup_queue(rzs->queue);
> +		pr_warning("Error allocating disk structure for device %d\n",
> +			device_id);
> +		return;
> +	}
> +
> +	rzs->disk->major = ramzswap_major;
> +	rzs->disk->first_minor = device_id;
> +	rzs->disk->fops = &ramzswap_devops;
> +	rzs->disk->queue = rzs->queue;
> +	rzs->disk->private_data = rzs;
> +	snprintf(rzs->disk->disk_name, 16, "ramzswap%d", device_id);
> +
> +	/*
> +	 * Actual capacity set using RZSIO_SET_DISKSIZE_KB ioctl
> +	 * or set equal to backing swap device (if provided)
> +	 */
> +	set_capacity(rzs->disk, 0);
> +	add_disk(rzs->disk);
> +
> +	rzs->init_done = 0;
> +
> +	return;
> +}

needless return

Marcin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
