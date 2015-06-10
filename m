Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 02F046B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 23:33:25 -0400 (EDT)
Received: by qcnj1 with SMTP id j1so13161020qcn.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 20:33:24 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id c41si7384939qkh.28.2015.06.09.20.33.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Jun 2015 20:33:24 -0700 (PDT)
Date: Tue, 9 Jun 2015 20:33:12 -0700
From: Mark Hairgrove <mhairgrove@nvidia.com>
Subject: Re: [PATCH 05/36] HMM: introduce heterogeneous memory management
 v3.
In-Reply-To: <20150609155601.GA3101@gmail.com>
Message-ID: <alpine.DEB.2.00.1506091939490.21359@mdh-linux64-2.nvidia.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com> <1432236705-4209-6-git-send-email-j.glisse@gmail.com> <alpine.DEB.2.00.1506081222270.27796@mdh-linux64-2.nvidia.com> <20150608211740.GA5241@gmail.com> <alpine.DEB.2.00.1506081841490.1802@mdh-linux64-2.nvidia.com>
 <20150609155601.GA3101@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="8323329-1789454448-1433907201=:21359"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, "joro@8bytes.org" <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>

--8323329-1789454448-1433907201=:21359
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT



On Tue, 9 Jun 2015, Jerome Glisse wrote:

> On Mon, Jun 08, 2015 at 06:54:29PM -0700, Mark Hairgrove wrote:
> > Can you clarify how that's different from mmu_notifiers? Those are also
> > embedded into a driver-owned struct.
> 
> For HMM you want to be able to kill a mirror from HMM, you might have kernel
> thread call inside HMM with a mirror (outside any device file lifetime) ...
> The mirror is not only use at register & unregister, there is a lot more thing
> you can call using the HMM mirror struct.
> 
> So the HMM mirror lifetime as a result is more complex, it can not simply be
> free from the mmu_notifier_release callback or randomly. It needs to be
> refcounted.

Sure, there are driver -> HMM calls like hmm_mirror_fault that 
mmu_notifiers don't have, but I don't understand why that fundamentally 
makes HMM mirror lifetimes more complex. Decoupling hmm_mirror lifetime 
from mm lifetime adds complexity too.

> The mmu_notifier code assume that the mmu_notifier struct is
> embedded inside a struct that has a lifetime properly synchronize with the
> mm. For HMM mirror this is not something that sounds like a good idea as there
> is too many way to get it wrong.

What kind of synchronization with the mm are you referring to here? 
Clients of mmu_notifiers don't have to do anything as far as I know. 
They're guaranteed that the mm won't go away because each registered 
notifier bumps mm_count.

> So idea of HMM mirror is that it can out last the mm lifetime but the HMM
> struct can not. So you have hmm_mirror <~> hmm <-> mm and the mirror can be
> "unlink" and have different lifetime from the hmm that itself has same life
> time as mm.

Per the earlier discussion hmm_mirror_destroy is missing a call to 
hmm_unref. If that's added back I don't understand how the mirror can 
persist past the hmm struct. The mirror can be unlinked from hmm's list, 
yes, but that doesn't mean that hmm/mm can be torn down. The hmm/mm 
structs will stick around until hmm_destroy since that does the 
mmu_notifier_unregister. hmm_destroy can't be called until the last 
hmm_mirror_destroy.

Doesn't that mean that hmm/mm are guaranteed to be allocated until the 
last hmm_mirror_unregister? That sounds like a good guarantee to make.


> 
> > Is the goal to allow calling hmm_mirror_unregister from within the "mm is
> > dying" HMM callback? I don't know whether that's really necessary as long
> > as there's some association between the driver files and the mirrors.
> 
> No this is not a goal and i actualy forbid that.
> 
> > 
> > > > If so, I think there's a race here in the case of mm teardown happening
> > > > concurrently with hmm_mirror_unregister.
> > > >
> > > > [...]
> > > >
> > > > Do you agree that this sequence can happen, or am I missing something
> > > > which prevents it?
> > >
> > > Can't happen because child have mm->hmm = NULL ie only one hmm per mm
> > > and hmm is tie to only one mm. It is the responsability of the device
> > > driver to make sure same apply to private reference to the hmm mirror
> > > struct ie hmm_mirror should never be tie to a private file struct.
> > 
> > It's useful for the driver to have some association between files and
> > mirrors. If the file is closed prior to process exit we would like to
> > unregister the mirror, otherwise it will persist until process teardown.
> > The association doesn't have to be 1:1 but having the files ref count the
> > mirror or something would be useful.
> 
> This is allowed, i might have put strong word here, but you can associate
> with a file struct. What you can not do is use the mirror from a different
> process ie one with a different mm struct as mirror is linked to a single
> mm. So on fork there is no callback to update the private file struct, when
> the device file is duplicated (well just refcount inc) against a different
> process. This is something you need to be carefull in your driver. Inside
> the dummy driver i abuse that to actually test proper behavior of HMM but
> it should not be use as an example.

So to confirm, on all file operations from user space the driver is 
expected to check that current->mm matches the mm associated with the 
struct file's hmm_mirror?

On file->release the driver still ought to call hmm_mirror_unregister 
regardless of whether the mms match, otherwise we'll never tear down the 
mirror. That means we're not saved from the race condition because 
hmm_mirror_unregister can happen in one thread while hmm_notifier_release 
might be happening in another thread.


> > 
> > But even if we assume no association at all between files and mirrors, are
> > you sure that prevents the race? The driver may choose to unregister the
> > hmm_device at any point once its files are closed. In the case of module
> > unload the device unregister can't be prevented. If mm teardown hasn't
> > happened yet mirrors may still be active and registered on that
> > hmm_device. The driver thus has to first call hmm_mirror_unregister on all
> > active mirrors, then call hmm_device_unregister. mm teardown of those
> > mirrors may trigger at any point in this sequence, so we're right back to
> > that race.
> 
> So when device driver unload the first thing it needs to do is kill all of
> its context ie all of its HMM mirror (unregister them) by doing so it will
> make sure that there can be no more call to any of its functions.

When is the driver expected to call hmm_mirror_unregister? Is it file 
close, module unload, or some other time?

If it's file close, there's no need to unregister anything on module 
unload because the files were all closed already.

If it's module unload, then the mirrors and mms all get leaked until that 
point.

We're exposed to the race in both cases.

> 
> The race with mm teardown does not exist as what matter for mm teardown is
> the fact that the mirror is on the struct hmm mirrors list or not. Either
> the device driver is first to remove the mirror from the list or it is the
> mm teardown but this is lock protected so only one thread can do it.
> 

Agreed, removing the mirror from the list is not a "race" in the classical 
sense. The true race is between hmm_notifier_release's device mutex_unlock 
(process exit) and post-hmm_device_unregister device mutex free (driver 
close/unload). What I meant is that in order to expose that race you first 
need one thread to call hmm_mirror_unregister while another thread is in 
hmm_notifier_release.

Regardless of where hmm_mirror_unregister is called (file close, module 
unload, etc) it can happen concurrently with hmm_notifier_release so we're 
exposed to this race.


> The issue you pointed is really about decoupling the lifetime of the mirror
> context (ie hardware thread that use the mirror) and the lifetime of the
> structure that embedded the hmm_mirror struct. The device driver will care
> about the second while everything else will only really care about the
> first. The second tells you when you know for sure that there will be no
> more callback to your device driver code. The first only tells you that
> there should be no more activity associated with that mirror but some thread
> might still hold a reference on the underlying struct.
> 
> 
> Hope this clarify design and motivation behind the hmm_mirror vs hmm struct
> lifetime.
> 
> 
> Cheers,
> Jerome
> 
--8323329-1789454448-1433907201=:21359--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
