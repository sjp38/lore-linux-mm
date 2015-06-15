Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 01D6C6B0071
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 10:32:27 -0400 (EDT)
Received: by qgal13 with SMTP id l13so5581842qga.3
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 07:32:26 -0700 (PDT)
Received: from mail-qk0-x22c.google.com (mail-qk0-x22c.google.com. [2607:f8b0:400d:c09::22c])
        by mx.google.com with ESMTPS id 53si12910477qgb.16.2015.06.15.07.32.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 07:32:26 -0700 (PDT)
Received: by qkdm188 with SMTP id m188so33354337qkd.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 07:32:25 -0700 (PDT)
Date: Mon, 15 Jun 2015 10:32:16 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 05/36] HMM: introduce heterogeneous memory management v3.
Message-ID: <20150615143215.GA1947@gmail.com>
References: <1432236705-4209-6-git-send-email-j.glisse@gmail.com>
 <alpine.DEB.2.00.1506081222270.27796@mdh-linux64-2.nvidia.com>
 <20150608211740.GA5241@gmail.com>
 <alpine.DEB.2.00.1506081841490.1802@mdh-linux64-2.nvidia.com>
 <20150609155601.GA3101@gmail.com>
 <alpine.DEB.2.00.1506091939490.21359@mdh-linux64-2.nvidia.com>
 <20150610154237.GA13465@gmail.com>
 <alpine.DEB.2.00.1506101757580.8383@mdh-linux64-2.nvidia.com>
 <20150611142313.GA26195@gmail.com>
 <alpine.DEB.2.00.1506111520350.25907@mdh-linux64-2.nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.00.1506111520350.25907@mdh-linux64-2.nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, "joro@8bytes.org" <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>

On Thu, Jun 11, 2015 at 03:26:46PM -0700, Mark Hairgrove wrote:
> On Thu, 11 Jun 2015, Jerome Glisse wrote:
> > On Wed, Jun 10, 2015 at 06:15:08PM -0700, Mark Hairgrove wrote:

[...]
> > Ok i see the race you are afraid of and really it is an unlikely one
> > __mutex_unlock_common_slowpath() take a spinlock right after allowing
> > other to take the mutex, when we are in your scenario there is no
> > contention on that spinlock so it is taken right away and as there
> > is no one in the mutex wait list then it goes directly to unlock the
> > spinlock and return. You can ignore the debug function as if debugging
> > is enabled than the mutex_lock() would need to also take the spinlock
> > and thus you would have proper synchronization btw 2 thread thanks to
> > the mutex.wait_lock.
> > 
> > So basicly while CPU1 is going :
> > spin_lock(mutex.wait_lock)
> > if (!list_empty(mutex.wait_list)) {
> >   // wait_list is empty so branch not taken
> > }
> > spin_unlock(mutex.wait_lock)
> > 
> > CPU2 would have to test the mirror list and mutex_unlock and return
> > before the spin_unlock() of CPU1. This is a tight race, i can add a
> > synchronize_rcu() to device_unregister after the mutex_unlock() so
> > that we also add a grace period before the device is potentialy freed
> > which should make that race completely unlikely.
> > 
> > Moreover for something really bad to happen it would need that the
> > freed memory to be reallocated right away by some other thread. Which
> > really sound unlikely unless CPU1 is the slowest of all :)
> > 
> > Cheers,
> > Jerome
> > 
> 
> But CPU1 could get preempted between the atomic_set and the 
> spin_lock_mutex, and then it doesn't matter whether or not a grace period 
> has elapsed before CPU2 proceeds.
> 
> Making race conditions less likely just makes them harder to pinpoint when 
> they inevitably appear in the wild. I don't think it makes sense to spend 
> any effort in making a race condition less likely, and that thread I 
> referenced (https://lkml.org/lkml/2013/12/2/997) is fairly strong evidence 
> that fixing this race actually matters. So, I think this race condition 
> really needs to be fixed.
> 
> One fix is for hmm_mirror_unregister to wait for hmm_notifier_release 
> completion between hmm_mirror_kill and hmm_mirror_unref. It can do this by 
> calling synchronize_srcu() on the mmu_notifier's srcu. This has the 
> benefit that the driver is guaranteed not to get the "mm is dead" callback 
> after hmm_mirror_unregister returns.
> 
> In fact, are there any callbacks on the mirror that can arrive after 
> hmm_mirror_unregister? If so, how will hmm_device_unregister solve them?
> 
> From a general standpoint, hmm_device_unregister must perform some kind of 
> synchronization to be sure that all mirrors are completely released and 
> done and no new callbacks will trigger. Since that has to be true, can't 
> that synchronization be moved into hmm_mirror_unregister instead?
> 
> If that happens there's no need for a "mirror can be freed" ->release 
> callback at all because the driver is guaranteed that a mirror is done 
> after hmm_mirror_unregister.

Well there is no need or 2 callback (relase|stop , free) just one, the
release|stop that is needed. I kind of went halfway last week on this.
I will probably rework that a little to keep just one call and rely on
driver to call hmm_mirror_unregister()

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
