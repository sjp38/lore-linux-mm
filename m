Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0B16B013B
	for <linux-mm@kvack.org>; Thu,  8 May 2014 21:42:34 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id rd3so3627325pab.7
        for <linux-mm@kvack.org>; Thu, 08 May 2014 18:42:34 -0700 (PDT)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id yv2si146127pac.23.2014.05.08.18.42.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 08 May 2014 18:42:33 -0700 (PDT)
Message-ID: <1399599734.2497.2.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [RFC] Heterogeneous memory management (mirror process address
 space on a device mmu).
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Thu, 08 May 2014 18:42:14 -0700
In-Reply-To: <20140508175624.GA3121@gmail.com>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
	 <20140506102925.GD11096@twins.programming.kicks-ass.net>
	 <1399429987.2581.25.camel@buesod1.americas.hpqcorp.net>
	 <536BB508.2020704@mellanox.com> <20140508175624.GA3121@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: sagi grimberg <sagig@mellanox.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, "Sander, Ben" <ben.sander@amd.com>, "Stoner,
 Greg" <Greg.Stoner@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, 2014-05-08 at 13:56 -0400, Jerome Glisse wrote:
> On Thu, May 08, 2014 at 07:47:04PM +0300, sagi grimberg wrote:
> > On 5/7/2014 5:33 AM, Davidlohr Bueso wrote:
> > >On Tue, 2014-05-06 at 12:29 +0200, Peter Zijlstra wrote:
> > >>So you forgot to CC Linus, Linus has expressed some dislike for
> > >>preemptible mmu_notifiers in the recent past:
> > >>
> > >>   https://lkml.org/lkml/2013/9/30/385
> > >I'm glad this came up again.
> > >
> > >So I've been running benchmarks (mostly aim7, which nicely exercises our
> > >locks) comparing my recent v4 for rwsem optimistic spinning against
> > >previous implementation ideas for the anon-vma lock, mostly:
> > >
> > >- rwsem (currently)
> > >- rwlock_t
> > >- qrwlock_t
> > >- rwsem+optspin
> > >
> > >Of course, *any* change provides significant improvement in throughput
> > >for several workloads, by avoiding to block -- there are more
> > >performance numbers in the different patches. This is fairly obvious.
> > >
> > >What is perhaps not so obvious is that rwsem+optimistic spinning beats
> > >all others, including the improved qrwlock from Waiman and Peter. This
> > >is mostly because of the idea of cancelable MCS, which was mimic'ed from
> > >mutexes. The delta in most cases is around +10-15%, which is non
> > >trivial.
> > 
> > These are great news David!
> > 
> > >I mention this because from a performance PoV, we'll stop caring so much
> > >about the type of lock we require in the notifier related code. So while
> > >this is not conclusive, I'm not as opposed to keeping the locks blocking
> > >as I once was. Now this might still imply things like poor design
> > >choices, but that's neither here nor there.
> > 
> > So is the rwsem+opt strategy the way to go Given it keeps everyone happy?
> > We will be more than satisfied with it as it will allow us to
> > guarantee device
> > MMU update.
> > 
> > >/me sees Sagi smiling ;)
> > 
> > :)
> 
> So i started doing thing with tlb flush but i must say things looks ugly.
> I need a new page flag (goodbye 32bits platform) and i need my own lru and
> page reclaimation for any page in use by a device, i need to hook up inside
> try_to_unmap or migrate (but i will do the former). I am trying to be smart
> by trying to schedule a worker on another cpu before before sending the ipi
> so that while the ipi is in progress hopefully another cpu might schedule
> the invalidation on the GPU and the wait after ipi for the gpu will be quick.
> 
> So all in all this is looking ugly and it does not change the fact that i
> sleep (well need to be able to sleep). It just move the sleeping to another
> part.
> 
> Maybe i should stress that with the mmu_notifier version it only sleep for
> process that are using the GPU those process are using userspace API like
> OpenCL which are not playing well with fork, ie read do not use fork if
> you are using such API.
> 
> So for my case if a process has mm->hmm set to something that would mean
> that there is a GPU using that address space and that it is unlikely to
> go under the massive workload that people try to optimize the anon_vma
> lock for.
> 
> My point is that with rwsem+optspin it could try spinning if mm->hmm
> was NULL and make the massive fork workload go fast, or it could sleep
> directly if mm->hmm is set.

Sorry? Unless I'm misunderstanding you, we don't do such things. Our
locks are generic and need to work for any circumstance, no special
cases here and there... _specially_ with these kind of things. So no,
rwsem will spin as long as the owner is set, just like any other users.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
