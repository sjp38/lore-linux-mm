Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 53DC36B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 11:56:15 -0400 (EDT)
Received: by qkx62 with SMTP id 62so11642791qkx.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 08:56:15 -0700 (PDT)
Received: from mail-qc0-x235.google.com (mail-qc0-x235.google.com. [2607:f8b0:400d:c01::235])
        by mx.google.com with ESMTPS id l1si5824087qcd.14.2015.06.09.08.56.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 08:56:14 -0700 (PDT)
Received: by qcxw10 with SMTP id w10so8054757qcx.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 08:56:14 -0700 (PDT)
Date: Tue, 9 Jun 2015 11:56:03 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 05/36] HMM: introduce heterogeneous memory management v3.
Message-ID: <20150609155601.GA3101@gmail.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
 <1432236705-4209-6-git-send-email-j.glisse@gmail.com>
 <alpine.DEB.2.00.1506081222270.27796@mdh-linux64-2.nvidia.com>
 <20150608211740.GA5241@gmail.com>
 <alpine.DEB.2.00.1506081841490.1802@mdh-linux64-2.nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.00.1506081841490.1802@mdh-linux64-2.nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, "joro@8bytes.org" <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>

On Mon, Jun 08, 2015 at 06:54:29PM -0700, Mark Hairgrove wrote:
> On Mon, 8 Jun 2015, Jerome Glisse wrote:
> > On Mon, Jun 08, 2015 at 12:40:18PM -0700, Mark Hairgrove wrote:
> > > On Thu, 21 May 2015, j.glisse@gmail.com wrote:
> > > > From: Jerome Glisse <jglisse@redhat.com>
> > > >
> > > > This patch only introduce core HMM functions for registering a new
> > > > mirror and stopping a mirror as well as HMM device registering and
> > > > unregistering.
> > > >
> > > > [...]
> > > >
> > > > +/* struct hmm_device_operations - HMM device operation callback
> > > > + */
> > > > +struct hmm_device_ops {
> > > > +	/* release() - mirror must stop using the address space.
> > > > +	 *
> > > > +	 * @mirror: The mirror that link process address space with the device.
> > > > +	 *
> > > > +	 * When this is call, device driver must kill all device thread using
> > > > +	 * this mirror. Also, this callback is the last thing call by HMM and
> > > > +	 * HMM will not access the mirror struct after this call (ie no more
> > > > +	 * dereference of it so it is safe for the device driver to free it).
> > > > +	 * It is call either from :
> > > > +	 *   - mm dying (all process using this mm exiting).
> > > > +	 *   - hmm_mirror_unregister() (if no other thread holds a reference)
> > > > +	 *   - outcome of some device error reported by any of the device
> > > > +	 *     callback against that mirror.
> > > > +	 */
> > > > +	void (*release)(struct hmm_mirror *mirror);
> > > > +};
> > >
> > > The comment that ->release is called when the mm dies doesn't match the
> > > implementation. ->release is only called when the mirror is destroyed, and
> > > that can only happen after the mirror has been unregistered. This may not
> > > happen until after the mm dies.
> > >
> > > Is the intent for the driver to get the callback when the mm goes down?
> > > That seems beneficial so the driver can kill whatever's happening on the
> > > device. Otherwise the device may continue operating in a dead address
> > > space until the driver's file gets closed and it unregisters the mirror.
> >
> > This was the intent before merging free & release. I guess i need to
> > reinstate the free versus release callback. Sadly the lifetime for HMM
> > is more complex than mmu_notifier as we intend the mirror struct to
> > be embedded into a driver private struct.
> 
> Can you clarify how that's different from mmu_notifiers? Those are also
> embedded into a driver-owned struct.

For HMM you want to be able to kill a mirror from HMM, you might have kernel
thread call inside HMM with a mirror (outside any device file lifetime) ...
The mirror is not only use at register & unregister, there is a lot more thing
you can call using the HMM mirror struct.

So the HMM mirror lifetime as a result is more complex, it can not simply be
free from the mmu_notifier_release callback or randomly. It needs to be
refcounted. The mmu_notifier code assume that the mmu_notifier struct is
embedded inside a struct that has a lifetime properly synchronize with the
mm. For HMM mirror this is not something that sounds like a good idea as there
is too many way to get it wrong.

So idea of HMM mirror is that it can out last the mm lifetime but the HMM
struct can not. So you have hmm_mirror <~> hmm <-> mm and the mirror can be
"unlink" and have different lifetime from the hmm that itself has same life
time as mm.

> Is the goal to allow calling hmm_mirror_unregister from within the "mm is
> dying" HMM callback? I don't know whether that's really necessary as long
> as there's some association between the driver files and the mirrors.

No this is not a goal and i actualy forbid that.

> 
> > > If so, I think there's a race here in the case of mm teardown happening
> > > concurrently with hmm_mirror_unregister.
> > >
> > > [...]
> > >
> > > Do you agree that this sequence can happen, or am I missing something
> > > which prevents it?
> >
> > Can't happen because child have mm->hmm = NULL ie only one hmm per mm
> > and hmm is tie to only one mm. It is the responsability of the device
> > driver to make sure same apply to private reference to the hmm mirror
> > struct ie hmm_mirror should never be tie to a private file struct.
> 
> It's useful for the driver to have some association between files and
> mirrors. If the file is closed prior to process exit we would like to
> unregister the mirror, otherwise it will persist until process teardown.
> The association doesn't have to be 1:1 but having the files ref count the
> mirror or something would be useful.

This is allowed, i might have put strong word here, but you can associate
with a file struct. What you can not do is use the mirror from a different
process ie one with a different mm struct as mirror is linked to a single
mm. So on fork there is no callback to update the private file struct, when
the device file is duplicated (well just refcount inc) against a different
process. This is something you need to be carefull in your driver. Inside
the dummy driver i abuse that to actually test proper behavior of HMM but
it should not be use as an example.

> 
> But even if we assume no association at all between files and mirrors, are
> you sure that prevents the race? The driver may choose to unregister the
> hmm_device at any point once its files are closed. In the case of module
> unload the device unregister can't be prevented. If mm teardown hasn't
> happened yet mirrors may still be active and registered on that
> hmm_device. The driver thus has to first call hmm_mirror_unregister on all
> active mirrors, then call hmm_device_unregister. mm teardown of those
> mirrors may trigger at any point in this sequence, so we're right back to
> that race.

So when device driver unload the first thing it needs to do is kill all of
its context ie all of its HMM mirror (unregister them) by doing so it will
make sure that there can be no more call to any of its functions.

The race with mm teardown does not exist as what matter for mm teardown is
the fact that the mirror is on the struct hmm mirrors list or not. Either
the device driver is first to remove the mirror from the list or it is the
mm teardown but this is lock protected so only one thread can do it.

The issue you pointed is really about decoupling the lifetime of the mirror
context (ie hardware thread that use the mirror) and the lifetime of the
structure that embedded the hmm_mirror struct. The device driver will care
about the second while everything else will only really care about the
first. The second tells you when you know for sure that there will be no
more callback to your device driver code. The first only tells you that
there should be no more activity associated with that mirror but some thread
might still hold a reference on the underlying struct.


Hope this clarify design and motivation behind the hmm_mirror vs hmm struct
lifetime.


Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
