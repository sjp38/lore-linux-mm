Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 170746B0032
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 06:08:49 -0500 (EST)
Received: by mail-lb0-f170.google.com with SMTP id 10so2238227lbg.1
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 03:08:48 -0800 (PST)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0093.outbound.protection.outlook.com. [157.55.234.93])
        by mx.google.com with ESMTPS id uh4si7458446lbb.15.2015.01.08.03.08.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 08 Jan 2015 03:08:48 -0800 (PST)
Message-ID: <54AE6533.2020302@mellanox.com>
Date: Thu, 8 Jan 2015 13:08:35 +0200
From: Haggai Eran <haggaie@mellanox.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/6] HMM: add per mirror page table.
References: <1420497889-10088-1-git-send-email-j.glisse@gmail.com>
 <1420497889-10088-6-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1420497889-10088-6-git-send-email-j.glisse@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: j.glisse@gmail.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes
 Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van
 Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron
 Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul
 Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

On 06/01/2015 00:44, j.glisse@gmail.com wrote:
> +	/* fence_wait() - to wait on device driver fence.
> +	 *
> +	 * @fence: The device driver fence struct.
> +	 * Returns: 0 on success,-EIO on error, -EAGAIN to wait again.
> +	 *
> +	 * Called when hmm want to wait for all operations associated with a
> +	 * fence to complete (including device cache flush if the event mandate
> +	 * it).
> +	 *
> +	 * Device driver must free fence and associated resources if it returns
> +	 * something else thant -EAGAIN. On -EAGAIN the fence must not be free
> +	 * as hmm will call back again.
> +	 *
> +	 * Return error if scheduled operation failed or if need to wait again.
> +	 * -EIO Some input/output error with the device.
> +	 * -EAGAIN The fence not yet signaled, hmm reschedule waiting thread.
> +	 *
> +	 * All other return value trigger warning and are transformed to -EIO.
> +	 */
> +	int (*fence_wait)(struct hmm_fence *fence);

According to the comment, the device frees the fence struct when the
fence_wait callback returns zero or -EIO, but the code below calls
fence_unref after fence_wait on the same fence.

> +
> +	/* fence_ref() - take a reference fence structure.
> +	 *
> +	 * @fence: Fence structure hmm is referencing.
> +	 */
> +	void (*fence_ref)(struct hmm_fence *fence);

I don't see fence_ref being called anywhere in the patchset. Is it
actually needed?

> +static void hmm_device_fence_wait(struct hmm_device *device,
> +				  struct hmm_fence *fence)
> +{
> +	struct hmm_mirror *mirror;
> +	int r;
> +
> +	if (fence == NULL)
> +		return;
> +
> +	list_del_init(&fence->list);
> +	do {
> +		r = device->ops->fence_wait(fence);
> +		if (r == -EAGAIN)
> +			io_schedule();
> +	} while (r == -EAGAIN);
> +
> +	mirror = fence->mirror;
> +	device->ops->fence_unref(fence);
> +	if (r)
> +		hmm_mirror_release(mirror);
> +}
> +

Regards,
Haggai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
