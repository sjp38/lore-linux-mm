Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4E7316B006C
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 15:40:32 -0400 (EDT)
Received: by qgep100 with SMTP id p100so50798412qge.3
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 12:40:32 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id 67si3412971qgm.49.2015.06.08.12.40.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 12:40:30 -0700 (PDT)
Date: Mon, 8 Jun 2015 12:40:18 -0700
From: Mark Hairgrove <mhairgrove@nvidia.com>
Subject: Re: [PATCH 05/36] HMM: introduce heterogeneous memory management
 v3.
In-Reply-To: <1432236705-4209-6-git-send-email-j.glisse@gmail.com>
Message-ID: <alpine.DEB.2.00.1506081222270.27796@mdh-linux64-2.nvidia.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com> <1432236705-4209-6-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="8323329-1517799086-1433792428=:27796"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "j.glisse@gmail.com" <j.glisse@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, "joro@8bytes.org" <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>

--8323329-1517799086-1433792428=:27796
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT



On Thu, 21 May 2015, j.glisse@gmail.com wrote:

> From: JA(C)rA'me Glisse <jglisse@redhat.com>
>
> This patch only introduce core HMM functions for registering a new
> mirror and stopping a mirror as well as HMM device registering and
> unregistering.
>
> [...]
>
> +/* struct hmm_device_operations - HMM device operation callback
> + */
> +struct hmm_device_ops {
> +	/* release() - mirror must stop using the address space.
> +	 *
> +	 * @mirror: The mirror that link process address space with the device.
> +	 *
> +	 * When this is call, device driver must kill all device thread using
> +	 * this mirror. Also, this callback is the last thing call by HMM and
> +	 * HMM will not access the mirror struct after this call (ie no more
> +	 * dereference of it so it is safe for the device driver to free it).
> +	 * It is call either from :
> +	 *   - mm dying (all process using this mm exiting).
> +	 *   - hmm_mirror_unregister() (if no other thread holds a reference)
> +	 *   - outcome of some device error reported by any of the device
> +	 *     callback against that mirror.
> +	 */
> +	void (*release)(struct hmm_mirror *mirror);
> +};

The comment that ->release is called when the mm dies doesn't match the
implementation. ->release is only called when the mirror is destroyed, and
that can only happen after the mirror has been unregistered. This may not
happen until after the mm dies.

Is the intent for the driver to get the callback when the mm goes down?
That seems beneficial so the driver can kill whatever's happening on the
device. Otherwise the device may continue operating in a dead address
space until the driver's file gets closed and it unregisters the mirror.


> +static void hmm_mirror_destroy(struct kref *kref)
> +{
> +	struct hmm_device *device;
> +	struct hmm_mirror *mirror;
> +	struct hmm *hmm;
> +
> +	mirror = container_of(kref, struct hmm_mirror, kref);
> +	device = mirror->device;
> +	hmm = mirror->hmm;
> +
> +	mutex_lock(&device->mutex);
> +	list_del_init(&mirror->dlist);
> +	device->ops->release(mirror);
> +	mutex_unlock(&device->mutex);
> +}

The hmm variable is unused. It also probably isn't safe to access at this
point.


> +static void hmm_mirror_kill(struct hmm_mirror *mirror)
> +{
> +	down_write(&mirror->hmm->rwsem);
> +	if (!hlist_unhashed(&mirror->mlist)) {
> +		hlist_del_init(&mirror->mlist);
> +		up_write(&mirror->hmm->rwsem);
> +
> +		hmm_mirror_unref(&mirror);
> +	} else
> +		up_write(&mirror->hmm->rwsem);
> +}

Shouldn't this call hmm_unref? hmm_mirror_register calls hmm_ref but
there's no corresponding hmm_unref when the mirror goes away. As a result
the hmm struct gets leaked and thus so does the entire mm since
mmu_notifier_unregister is never called.

It might also be a good idea to set mirror->hmm = NULL here to prevent
accidental use in say hmm_mirror_destroy.


> +/* hmm_device_unregister() - unregister a device with HMM.
> + *
> + * @device: The hmm_device struct.
> + * Returns: 0 on success or -EBUSY otherwise.
> + *
> + * Call when device driver want to unregister itself with HMM. This will check
> + * that there is no any active mirror and returns -EBUSY if so.
> + */
> +int hmm_device_unregister(struct hmm_device *device)
> +{
> +	mutex_lock(&device->mutex);
> +	if (!list_empty(&device->mirrors)) {
> +		mutex_unlock(&device->mutex);
> +		return -EBUSY;
> +	}
> +	mutex_unlock(&device->mutex);
> +	return 0;
> +}

I assume that the intention is for the caller to spin on
hmm_device_unregister until -EBUSY is no longer returned?

If so, I think there's a race here in the case of mm teardown happening
concurrently with hmm_mirror_unregister. This can happen if the parent
process was forked and exits while the child closes the file, or if the
file is passed to another process and closed last there while the original
process exits.

The upshot is that the hmm_device may still be referenced by another
thread even after hmm_device_unregister returns 0.

The below sequence shows how this might happen. Coming into this, the
mirror's ref count is 2:

Thread A (file close)               Thread B (process exit)
----------------------              ----------------------
                                    hmm_notifier_release
                                      down_write(&hmm->rwsem);
hmm_mirror_unregister
  hmm_mirror_kill
    down_write(&hmm->rwsem);
    // Blocked on thread B
                                      hlist_del_init(&mirror->mlist);
                                      up_write(&hmm->rwsem);

                                      // Thread A unblocked
                                      // Thread B is preempted
    // hlist_unhashed returns 1
    up_write(&hmm->rwsem);

  // Mirror ref goes 2 -> 1
  hmm_mirror_unref(&mirror);

  // hmm_mirror_unregister returns

At this point hmm_mirror_unregister has returned to the caller but the
mirror still is in use by thread B. Since all mirrors have been
unregistered, the driver in thread A is now free to call
hmm_device_unregister.

                                      // Thread B is scheduled

                                      // Mirror ref goes 1 -> 0
                                      hmm_mirror_unref(&mirror);
                                        hmm_mirror_destroy(&mirror)
                                          mutex_lock(&device->mutex);
                                          list_del_init(&mirror->dlist);
                                          device->ops->release(mirror);
                                          mutex_unlock(&device->mutex);

hmm_device_unregister
  mutex_lock(&device->mutex);
  // Device list empty
  mutex_unlock(&device->mutex);
  return 0;
// Caller frees device

Do you agree that this sequence can happen, or am I missing something
which prevents it?

If this can happen, the problem is that the only thing preventing thread A
from freeing the device is that thread B has device->mutex locked. That's
bad, because a lock within a structure cannot be used to control freeing
that structure. The mutex_unlock in thread B may internally still access
the mutex memory even after the atomic operation which unlocks the mutex
and unblocks thread A.

This can't be solved by having the driver wait for the ->release mirror
callback before it calls hmm_device_unregister, because the race happens
after that point.

A kref on the device itself might solve this, but the core issue IMO is
that hmm_mirror_unregister doesn't wait for hmm_notifier_release to
complete before returning. It feels like hmm_mirror_unregister wants to do
a synchronize_srcu on the mmu_notifier srcu. Is that possible?

Whatever the resolution, it would be useful for the block comments of
hmm_mirror_unregister and hmm_device_unregister to describe the
expectations on the caller and what the caller is guaranteed as far as
mirror and device lifetimes go.

Thanks,
Mark
--8323329-1517799086-1433792428=:27796--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
