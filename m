Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2CF8D6B0032
	for <linux-mm@kvack.org>; Sat, 10 Jan 2015 01:48:48 -0500 (EST)
Received: by mail-qc0-f170.google.com with SMTP id x3so12292865qcv.1
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 22:48:48 -0800 (PST)
Received: from mail-qc0-x229.google.com (mail-qc0-x229.google.com. [2607:f8b0:400d:c01::229])
        by mx.google.com with ESMTPS id h10si15166027qcm.42.2015.01.09.22.48.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 Jan 2015 22:48:47 -0800 (PST)
Received: by mail-qc0-f169.google.com with SMTP id w7so12193819qcr.0
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 22:48:46 -0800 (PST)
Date: Sat, 10 Jan 2015 01:48:32 -0500
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 5/6] HMM: add per mirror page table.
Message-ID: <20150110064831.GA19689@gmail.com>
References: <1420497889-10088-1-git-send-email-j.glisse@gmail.com>
 <1420497889-10088-6-git-send-email-j.glisse@gmail.com>
 <54AE6485.60402@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <54AE6485.60402@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haggai Eran <haggaie@mellanox.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

On Thu, Jan 08, 2015 at 01:05:41PM +0200, Haggai Eran wrote:
> On 06/01/2015 00:44, j.glisse@gmail.com wrote:
> > +	/* fence_wait() - to wait on device driver fence.
> > +	 *
> > +	 * @fence: The device driver fence struct.
> > +	 * Returns: 0 on success,-EIO on error, -EAGAIN to wait again.
> > +	 *
> > +	 * Called when hmm want to wait for all operations associated with a
> > +	 * fence to complete (including device cache flush if the event mandate
> > +	 * it).
> > +	 *
> > +	 * Device driver must free fence and associated resources if it returns
> > +	 * something else thant -EAGAIN. On -EAGAIN the fence must not be free
> > +	 * as hmm will call back again.
> > +	 *
> > +	 * Return error if scheduled operation failed or if need to wait again.
> > +	 * -EIO Some input/output error with the device.
> > +	 * -EAGAIN The fence not yet signaled, hmm reschedule waiting thread.
> > +	 *
> > +	 * All other return value trigger warning and are transformed to -EIO.
> > +	 */
> > +	int (*fence_wait)(struct hmm_fence *fence);
> 
> According to the comment, the device frees the fence struct when the
> fence_wait callback returns zero or -EIO, but the code below calls
> fence_unref after fence_wait on the same fence.

Yes comment is out of date, i wanted to simplify fence before readding
it once needed (by device memory migration).

> 
> > +
> > +	/* fence_ref() - take a reference fence structure.
> > +	 *
> > +	 * @fence: Fence structure hmm is referencing.
> > +	 */
> > +	void (*fence_ref)(struct hmm_fence *fence);
> 
> I don't see fence_ref being called anywhere in the patchset. Is it
> actually needed?

Not right now but the page migration to device memory use it. But i
can remove it now.

I can respin to make comment match code but i would like to know where
i stand on everythings else.

Cheers,
Jerome

> 
> > +static void hmm_device_fence_wait(struct hmm_device *device,
> > +				  struct hmm_fence *fence)
> > +{
> > +	struct hmm_mirror *mirror;
> > +	int r;
> > +
> > +	if (fence == NULL)
> > +		return;
> > +
> > +	list_del_init(&fence->list);
> > +	do {
> > +		r = device->ops->fence_wait(fence);
> > +		if (r == -EAGAIN)
> > +			io_schedule();
> > +	} while (r == -EAGAIN);
> > +
> > +	mirror = fence->mirror;
> > +	device->ops->fence_unref(fence);
> > +	if (r)
> > +		hmm_mirror_release(mirror);
> > +}
> > +
> 
> Regards,
> Haggai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
