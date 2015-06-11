Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7FB3D6B006C
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 21:15:23 -0400 (EDT)
Received: by qgf75 with SMTP id 75so21582996qgf.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 18:15:23 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id b132si717912qka.45.2015.06.10.18.15.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 18:15:21 -0700 (PDT)
Date: Wed, 10 Jun 2015 18:15:08 -0700
From: Mark Hairgrove <mhairgrove@nvidia.com>
Subject: Re: [PATCH 05/36] HMM: introduce heterogeneous memory management
 v3.
In-Reply-To: <20150610154237.GA13465@gmail.com>
Message-ID: <alpine.DEB.2.00.1506101757580.8383@mdh-linux64-2.nvidia.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com> <1432236705-4209-6-git-send-email-j.glisse@gmail.com> <alpine.DEB.2.00.1506081222270.27796@mdh-linux64-2.nvidia.com> <20150608211740.GA5241@gmail.com> <alpine.DEB.2.00.1506081841490.1802@mdh-linux64-2.nvidia.com>
 <20150609155601.GA3101@gmail.com> <alpine.DEB.2.00.1506091939490.21359@mdh-linux64-2.nvidia.com> <20150610154237.GA13465@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, "joro@8bytes.org" <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>



On Wed, 10 Jun 2015, Jerome Glisse wrote:

> [...]
> 
> Like said, just ignore current code it is utterly broken in so many way
> when it comes to lifetime. I screw that part badly when reworking the
> patchset, i was focusing on other part.
> 
> I fixed that in my tree, i am waiting for more review on other part as
> anyway the lifetime thing is easy to rework/fix.
> 
> http://cgit.freedesktop.org/~glisse/linux/log/?h=hmm
> 

Ok, I'm working through the other patches so I'll check the updates out 
once I've made it through. My primary interest in this discussion is 
making sure we know the plan for mirror and device lifetimes.


> > So to confirm, on all file operations from user space the driver is 
> > expected to check that current->mm matches the mm associated with the 
> > struct file's hmm_mirror?
> 
> Well you might have a valid usecase for that, just be aware that
> anything your driver do with the hmm_mirror will actually impact
> the mm of the parent. Which i assume is not what you want.
> 
> I would actualy thought that what you want is having a way to find
> hmm_mirror using both device file & mm as a key. Otherwise you can
> not really use HMM with process that like to fork themself. Which
> is a valid usecase to me. For instance process start using HMM
> through your driver, decide to fork itself and to also use HMM
> through your driver inside its child.

Agreed, that sounds reasonable, and the use case is valid. I was digging 
into this to make sure we don't prevent that.


> > 
> > On file->release the driver still ought to call hmm_mirror_unregister 
> > regardless of whether the mms match, otherwise we'll never tear down the 
> > mirror. That means we're not saved from the race condition because 
> > hmm_mirror_unregister can happen in one thread while hmm_notifier_release 
> > might be happening in another thread.
> 
> Again there is no race the mirror list is the synchronization point and
> it is protected by a lock. So either hmm_mirror_unregister() wins or the
> other thread hmm_notifier_release()

Yes, I agree. That's not the race I'm worried about. I'm worried about a 
race on the device lifetime, but in order to hit that one first 
hmm_notifier_release must take the lock and remove the mirror from the 
list before hmm_mirror_unregister does it. That's why I brought it up.


> 
> You unregister as soon as you want, it is up to your driver to do it,
> i do not enforce anything. The only thing i enforce is that you can
> not unregister the hmm device driver before all mirror are unregistered
> and free.
> 
> So yes for device driver you want to unregister when device file is
> close (which happens when the process exit).

Sounds good.


> 
> There is no race here, the mirror struct will only be freed once as again
> the list is a synchronization point. Whoever remove the mirror from the
> list is responsible to drop the list reference.
> 
> In the fixed code the only thing that will happen twice is the ->release()
> callback. Even that can be work around to garanty it is call only once.
> 
> Anyway i do not see anyrace here.
> 

The mirror lifetime is fine. The problem I see is with the device lifetime 
on a multi-core system. Imagine this sequence:

- On CPU1 the mm associated with the mirror is going down
- On CPU2 the driver unregisters the mirror then the device

When this happens, the last device mutex_unlock on CPU1 is the only thing 
preventing the free of the device in CPU2. That doesn't work, as described 
in this thread: https://lkml.org/lkml/2013/12/2/997

Here's the full sequence again with mutex_unlock split apart. Hopefully 
this shows the device_unregister problem more clearly:

CPU1 (mm release)                   CPU2 (driver)
----------------------              ----------------------
hmm_notifier_release
  down_write(&hmm->rwsem);
  hlist_del_init(&mirror->mlist);
  up_write(&hmm->rwsem);

  // CPU1 thread is preempted or 
  // something
                                    hmm_mirror_unregister
                                      hmm_mirror_kill
                                        down_write(&hmm->rwsem);
                                        // mirror removed by CPU1 already
                                        // so hlist_unhashed returns 1
                                        up_write(&hmm->rwsem);

                                      hmm_mirror_unref(&mirror);
                                      // Mirror ref now 1

                                      // CPU2 thread is preempted or
                                      // something
// CPU1 thread is scheduled

hmm_mirror_unref(&mirror);
  // Mirror ref now 0, cleanup
  hmm_mirror_destroy(&mirror)
    mutex_lock(&device->mutex);
    list_del_init(&mirror->dlist);
    device->ops->release(mirror);
      kfree(mirror);
                                      // CPU2 thread is scheduled, now
                                      // both CPU1 and CPU2 are running

                                    hmm_device_unregister
                                      mutex_lock(&device->mutex);
                                        mutex_optimistic_spin()
    mutex_unlock(&device->mutex);
      [...]
      __mutex_unlock_common_slowpath
        // CPU2 releases lock
        atomic_set(&lock->count, 1);
                                          // Spinning CPU2 acquires now-
                                          // free lock
                                      // mutex_lock returns
                                      // Device list empty
                                      mutex_unlock(&device->mutex);
                                      return 0;
                                    kfree(hmm_device);
        // CPU1 still accessing 
        // hmm_device->mutex in 
        //__mutex_unlock_common_slowpath

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
