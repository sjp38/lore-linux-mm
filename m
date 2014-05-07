Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id D6AF46B0035
	for <linux-mm@kvack.org>; Tue,  6 May 2014 22:33:17 -0400 (EDT)
Received: by mail-ob0-f178.google.com with SMTP id va2so430026obc.23
        for <linux-mm@kvack.org>; Tue, 06 May 2014 19:33:17 -0700 (PDT)
Received: from g5t1625.atlanta.hp.com (g5t1625.atlanta.hp.com. [15.192.137.8])
        by mx.google.com with ESMTPS id gu8si9719742obc.139.2014.05.06.19.33.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 06 May 2014 19:33:16 -0700 (PDT)
Message-ID: <1399429987.2581.25.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [RFC] Heterogeneous memory management (mirror process address
 space on a device mmu).
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 06 May 2014 19:33:07 -0700
In-Reply-To: <20140506102925.GD11096@twins.programming.kicks-ass.net>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
	 <20140506102925.GD11096@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: j.glisse@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, "Sander,
 Ben" <ben.sander@amd.com>, "Stoner, Greg" <Greg.Stoner@amd.com>, "Bridgman,
 John" <John.Bridgman@amd.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, 2014-05-06 at 12:29 +0200, Peter Zijlstra wrote:
> So you forgot to CC Linus, Linus has expressed some dislike for
> preemptible mmu_notifiers in the recent past:
> 
>   https://lkml.org/lkml/2013/9/30/385

I'm glad this came up again.

So I've been running benchmarks (mostly aim7, which nicely exercises our
locks) comparing my recent v4 for rwsem optimistic spinning against
previous implementation ideas for the anon-vma lock, mostly:

- rwsem (currently)
- rwlock_t
- qrwlock_t
- rwsem+optspin

Of course, *any* change provides significant improvement in throughput
for several workloads, by avoiding to block -- there are more
performance numbers in the different patches. This is fairly obvious.

What is perhaps not so obvious is that rwsem+optimistic spinning beats
all others, including the improved qrwlock from Waiman and Peter. This
is mostly because of the idea of cancelable MCS, which was mimic'ed from
mutexes. The delta in most cases is around +10-15%, which is non
trivial.

I mention this because from a performance PoV, we'll stop caring so much
about the type of lock we require in the notifier related code. So while
this is not conclusive, I'm not as opposed to keeping the locks blocking
as I once was. Now this might still imply things like poor design
choices, but that's neither here nor there.

/me sees Sagi smiling ;)

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
