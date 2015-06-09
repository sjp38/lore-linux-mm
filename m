Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 096866B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 21:54:41 -0400 (EDT)
Received: by qgfa66 with SMTP id a66so1630962qgf.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 18:54:40 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id m105si4140653qgm.46.2015.06.08.18.54.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 18:54:40 -0700 (PDT)
Date: Mon, 8 Jun 2015 18:54:29 -0700
From: Mark Hairgrove <mhairgrove@nvidia.com>
Subject: Re: [PATCH 05/36] HMM: introduce heterogeneous memory management
 v3.
In-Reply-To: <20150608211740.GA5241@gmail.com>
Message-ID: <alpine.DEB.2.00.1506081841490.1802@mdh-linux64-2.nvidia.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com> <1432236705-4209-6-git-send-email-j.glisse@gmail.com> <alpine.DEB.2.00.1506081222270.27796@mdh-linux64-2.nvidia.com> <20150608211740.GA5241@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="8323329-1917143692-1433814877=:1802"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, "joro@8bytes.org" <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>

--8323329-1917143692-1433814877=:1802
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT



On Mon, 8 Jun 2015, Jerome Glisse wrote:

> On Mon, Jun 08, 2015 at 12:40:18PM -0700, Mark Hairgrove wrote:
> >
> >
> > On Thu, 21 May 2015, j.glisse@gmail.com wrote:
> >
> > > From: Jerome Glisse <jglisse@redhat.com>
> > >
> > > This patch only introduce core HMM functions for registering a new
> > > mirror and stopping a mirror as well as HMM device registering and
> > > unregistering.
> > >
> > > [...]
> > >
> > > +/* struct hmm_device_operations - HMM device operation callback
> > > + */
> > > +struct hmm_device_ops {
> > > +	/* release() - mirror must stop using the address space.
> > > +	 *
> > > +	 * @mirror: The mirror that link process address space with the device.
> > > +	 *
> > > +	 * When this is call, device driver must kill all device thread using
> > > +	 * this mirror. Also, this callback is the last thing call by HMM and
> > > +	 * HMM will not access the mirror struct after this call (ie no more
> > > +	 * dereference of it so it is safe for the device driver to free it).
> > > +	 * It is call either from :
> > > +	 *   - mm dying (all process using this mm exiting).
> > > +	 *   - hmm_mirror_unregister() (if no other thread holds a reference)
> > > +	 *   - outcome of some device error reported by any of the device
> > > +	 *     callback against that mirror.
> > > +	 */
> > > +	void (*release)(struct hmm_mirror *mirror);
> > > +};
> >
> > The comment that ->release is called when the mm dies doesn't match the
> > implementation. ->release is only called when the mirror is destroyed, and
> > that can only happen after the mirror has been unregistered. This may not
> > happen until after the mm dies.
> >
> > Is the intent for the driver to get the callback when the mm goes down?
> > That seems beneficial so the driver can kill whatever's happening on the
> > device. Otherwise the device may continue operating in a dead address
> > space until the driver's file gets closed and it unregisters the mirror.
>
> This was the intent before merging free & release. I guess i need to
> reinstate the free versus release callback. Sadly the lifetime for HMM
> is more complex than mmu_notifier as we intend the mirror struct to
> be embedded into a driver private struct.

Can you clarify how that's different from mmu_notifiers? Those are also
embedded into a driver-owned struct.

Is the goal to allow calling hmm_mirror_unregister from within the "mm is
dying" HMM callback? I don't know whether that's really necessary as long
as there's some association between the driver files and the mirrors.


> > If so, I think there's a race here in the case of mm teardown happening
> > concurrently with hmm_mirror_unregister.
> >
> > [...]
> >
> > Do you agree that this sequence can happen, or am I missing something
> > which prevents it?
>
> Can't happen because child have mm->hmm = NULL ie only one hmm per mm
> and hmm is tie to only one mm. It is the responsability of the device
> driver to make sure same apply to private reference to the hmm mirror
> struct ie hmm_mirror should never be tie to a private file struct.

It's useful for the driver to have some association between files and
mirrors. If the file is closed prior to process exit we would like to
unregister the mirror, otherwise it will persist until process teardown.
The association doesn't have to be 1:1 but having the files ref count the
mirror or something would be useful.

But even if we assume no association at all between files and mirrors, are
you sure that prevents the race? The driver may choose to unregister the
hmm_device at any point once its files are closed. In the case of module
unload the device unregister can't be prevented. If mm teardown hasn't
happened yet mirrors may still be active and registered on that
hmm_device. The driver thus has to first call hmm_mirror_unregister on all
active mirrors, then call hmm_device_unregister. mm teardown of those
mirrors may trigger at any point in this sequence, so we're right back to
that race.
--8323329-1917143692-1433814877=:1802--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
