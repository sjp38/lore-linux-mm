Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7CE396B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 13:41:42 -0400 (EDT)
Received: by qgt47 with SMTP id 47so124856807qgt.2
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 10:41:42 -0700 (PDT)
Received: from mail-qg0-x22f.google.com (mail-qg0-x22f.google.com. [2607:f8b0:400d:c04::22f])
        by mx.google.com with ESMTPS id l49si15923889qgd.66.2015.10.12.10.41.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 10:41:41 -0700 (PDT)
Received: by qgez77 with SMTP id z77so125531837qge.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 10:41:41 -0700 (PDT)
Date: Mon, 12 Oct 2015 13:41:31 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 1/6] mmput: use notifier chain to call subsystem exit
 handler.
Message-ID: <20151012174130.GA8037@gmail.com>
References: <20140701210620.GL26537@8bytes.org>
 <20140701213208.GC3322@gmail.com>
 <20140703183024.GA3306@gmail.com>
 <20140703231541.GR26537@8bytes.org>
 <019CCE693E457142B37B791721487FD918085329@storexdag01.amd.com>
 <20140707101158.GD1958@8bytes.org>
 <1404729783.31606.1.camel@tlv-gabbay-ws.amd.com>
 <20140708080059.GF1958@8bytes.org>
 <20140708170355.GA2469@gmail.com>
 <1444590209.92154.116.camel@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1444590209.92154.116.camel@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: "joro@8bytes.org" <joro@8bytes.org>, "peterz@infradead.org" <peterz@infradead.org>, "SCheung@nvidia.com" <SCheung@nvidia.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "ldunning@nvidia.com" <ldunning@nvidia.com>, "hpa@zytor.com" <hpa@zytor.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "jakumar@nvidia.com" <jakumar@nvidia.com>, "mgorman@suse.de" <mgorman@suse.de>, "jweiner@redhat.com" <jweiner@redhat.com>, "sgutti@nvidia.com" <sgutti@nvidia.com>, "riel@redhat.com" <riel@redhat.com>, "Bridgman, John" <John.Bridgman@amd.com>, "jhubbard@nvidia.com" <jhubbard@nvidia.com>, "mhairgrove@nvidia.com" <mhairgrove@nvidia.com>, "cabuschardt@nvidia.com" <cabuschardt@nvidia.com>, "dpoole@nvidia.com" <dpoole@nvidia.com>, "Cornwall, Jay" <Jay.Cornwall@amd.com>, "Lewycky, Andrew" <Andrew.Lewycky@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "arvindg@nvidia.com" <arvindg@nvidia.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>


Note that i am no longer actively pushing this patch serie but i believe the
solution it provides to be needed in one form or another. So I still think
discussion on this to be useful so see below for my answer.

On Sun, Oct 11, 2015 at 08:03:29PM +0100, David Woodhouse wrote:
> On Tue, 2014-07-08 at 13:03 -0400, Jerome Glisse wrote:
> > 
> > Now regarding the device side, if we were to cleanup inside the file release
> > callback than we would be broken in front of fork. Imagine the following :
> >   - process A open device file and mirror its address space (hmm or kfd)
> >     through a device file.
> >   - process A forks itself (child is B) while having the device file open.
> >   - process A quits
> > 
> > Now the file release will not be call until child B exit which might infinite.
> > Thus we would be leaking memory. As we already pointed out we can not free the
> > resources from the mmu_notifier >release callback.
> 
> So if your library just registers a pthread_atfork() handler to close
> the file descriptor in the child, that problem goes away? Like any
> other "if we continue to hold file descriptors open when we should
> close them, resources don't get freed" problem?


I was just pointing out existing device driver usage pattern where user
space open device file and do ioctl on it without necessarily caring
about the mm struct.

New usecase where device actually run thread against a specific process
mm is different and require proper synchronization as file lifetime is
different from process lifetime in many case when fork is involve.

> 
> Perhaps we could even handled that automatically in the kernel, with
> something like an O_CLOFORK flag on the file descriptor. Although
> that's a little horrid.
> 
> You've argued that the amdkfd code is special and not just a device
> driver. I'm not going to contradict you there, but now we *are* going
> to see device drivers doing this kind of thing. And we definitely
> *don't* want to be calling back into device driver code from the
> mmu_notifier's .release() function.

Well that's the current solution, call back into device driver from the
mmu_notifer release() call back. Since changes to mmu_notifier this is
a workable solution (thanks to mmu_notifier_unregister_no_release()).

> 
> I think amdkfd absolutely is *not* a useful precedent for normal device
> drivers, and we *don't* want to follow this model in the general case.
> 
> As we try to put together a generic API for device access to processes'
> address space, I definitely think we want to stick with the model that
> we take a reference on the mm, and we *keep* it until the device driver
> unbinds from the mm (because its file descriptor is closed, or
> whatever).

Well i think when a process is kill (for whatever reasons) we do want to
also kill all device threads at the same time. For instance we do not want
to have zombie GPU threads that can keep running indefinitly. This is why
use mmu_notifier.release() callback is kind of right place as it will be
call once all threads using a given mm are killed.

The exit_mm() or do_exit() are also places from where we could a callback
to let device know that it must kill all thread related to a given mm.

>
> Perhaps you can keep a back door into the AMD IOMMU code to continue to
> do what you're doing, or perhaps the explicit management of off-cpu
> tasks that is being posited will give you a sane cleanup path that
> *doesn't* involve the IOMMU's mmu_notifier calling back to you. But
> either way, I *really* don't want this to be the way it works for
> device drivers.

So at kernel summit we are supposedly gonna have a discussion about device
thread and scheduling and i think device thread lifetime belongs to that
discussion too. My opinion is that device threads must be kill when a
process quits.


> > One hacky way to do it would be to schedule some delayed job from 
> > >release callback but then again we would have no way to properly 
> > synchronize ourself with other mm destruction code ie the delayed job 
> > could run concurently with other mm destruction code and interfer
> > badly.
> 
> With the RCU-based free of the struct containing the notifier, your
> 'schedule some delayed job' is basically what we have now, isn't it?
> 
> I note that you also have your *own* notifier which does other things,
> and has to cope with being called before or after the IOMMU's notifier.
> 
> Seriously, we don't want device drivers having to do this. We really
> need to keep it simple.

So right now in HMM what happens is that device driver get a callback as
a result of mmu_notifier.release() and can call the unregister functions
and device driver must then schedule through whatever means a call to the
unregister function (can be a workqueue or other a kernel thread).

Basicly i am hidding the issue inside the device driver until we can agree
on a common proper way to do this.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
