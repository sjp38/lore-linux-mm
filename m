Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id C83BA6B010F
	for <linux-mm@kvack.org>; Thu,  8 May 2014 13:56:35 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id q107so3237988qgd.29
        for <linux-mm@kvack.org>; Thu, 08 May 2014 10:56:35 -0700 (PDT)
Received: from mail-qg0-x236.google.com (mail-qg0-x236.google.com [2607:f8b0:400d:c04::236])
        by mx.google.com with ESMTPS id l59si867837qga.108.2014.05.08.10.56.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 May 2014 10:56:35 -0700 (PDT)
Received: by mail-qg0-f54.google.com with SMTP id q108so3119046qgd.41
        for <linux-mm@kvack.org>; Thu, 08 May 2014 10:56:35 -0700 (PDT)
Date: Thu, 8 May 2014 13:56:26 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC] Heterogeneous memory management (mirror process address
 space on a device mmu).
Message-ID: <20140508175624.GA3121@gmail.com>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
 <20140506102925.GD11096@twins.programming.kicks-ass.net>
 <1399429987.2581.25.camel@buesod1.americas.hpqcorp.net>
 <536BB508.2020704@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <536BB508.2020704@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sagi grimberg <sagig@mellanox.com>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, "Sander, Ben" <ben.sander@amd.com>, "Stoner, Greg" <Greg.Stoner@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, May 08, 2014 at 07:47:04PM +0300, sagi grimberg wrote:
> On 5/7/2014 5:33 AM, Davidlohr Bueso wrote:
> >On Tue, 2014-05-06 at 12:29 +0200, Peter Zijlstra wrote:
> >>So you forgot to CC Linus, Linus has expressed some dislike for
> >>preemptible mmu_notifiers in the recent past:
> >>
> >>   https://lkml.org/lkml/2013/9/30/385
> >I'm glad this came up again.
> >
> >So I've been running benchmarks (mostly aim7, which nicely exercises our
> >locks) comparing my recent v4 for rwsem optimistic spinning against
> >previous implementation ideas for the anon-vma lock, mostly:
> >
> >- rwsem (currently)
> >- rwlock_t
> >- qrwlock_t
> >- rwsem+optspin
> >
> >Of course, *any* change provides significant improvement in throughput
> >for several workloads, by avoiding to block -- there are more
> >performance numbers in the different patches. This is fairly obvious.
> >
> >What is perhaps not so obvious is that rwsem+optimistic spinning beats
> >all others, including the improved qrwlock from Waiman and Peter. This
> >is mostly because of the idea of cancelable MCS, which was mimic'ed from
> >mutexes. The delta in most cases is around +10-15%, which is non
> >trivial.
> 
> These are great news David!
> 
> >I mention this because from a performance PoV, we'll stop caring so much
> >about the type of lock we require in the notifier related code. So while
> >this is not conclusive, I'm not as opposed to keeping the locks blocking
> >as I once was. Now this might still imply things like poor design
> >choices, but that's neither here nor there.
> 
> So is the rwsem+opt strategy the way to go Given it keeps everyone happy?
> We will be more than satisfied with it as it will allow us to
> guarantee device
> MMU update.
> 
> >/me sees Sagi smiling ;)
> 
> :)

So i started doing thing with tlb flush but i must say things looks ugly.
I need a new page flag (goodbye 32bits platform) and i need my own lru and
page reclaimation for any page in use by a device, i need to hook up inside
try_to_unmap or migrate (but i will do the former). I am trying to be smart
by trying to schedule a worker on another cpu before before sending the ipi
so that while the ipi is in progress hopefully another cpu might schedule
the invalidation on the GPU and the wait after ipi for the gpu will be quick.

So all in all this is looking ugly and it does not change the fact that i
sleep (well need to be able to sleep). It just move the sleeping to another
part.

Maybe i should stress that with the mmu_notifier version it only sleep for
process that are using the GPU those process are using userspace API like
OpenCL which are not playing well with fork, ie read do not use fork if
you are using such API.

So for my case if a process has mm->hmm set to something that would mean
that there is a GPU using that address space and that it is unlikely to
go under the massive workload that people try to optimize the anon_vma
lock for.

My point is that with rwsem+optspin it could try spinning if mm->hmm
was NULL and make the massive fork workload go fast, or it could sleep
directly if mm->hmm is set.

This way my addition are not damaging anyone workload, only the workload
that would use hmm would likely have lock contention on fork but those
workload should not fork in the first place and if they do they should
pay a price.

I will finish up the tlb hackish version of hmm so people can judge how
ugly it is (in my view) and send it here as soon as i can.

But i think it's clear that with rwsem+optspin we can make all workload
happy and fast.

Cheers,
Jerome Glisse

> 
> Sagi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
