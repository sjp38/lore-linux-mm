Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f173.google.com (mail-vc0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7DCC58299E
	for <linux-mm@kvack.org>; Tue,  6 May 2014 11:18:36 -0400 (EDT)
Received: by mail-vc0-f173.google.com with SMTP id il7so916921vcb.4
        for <linux-mm@kvack.org>; Tue, 06 May 2014 08:18:36 -0700 (PDT)
Received: from mail-vc0-x236.google.com (mail-vc0-x236.google.com [2607:f8b0:400c:c03::236])
        by mx.google.com with ESMTPS id uq6si2386952vcb.0.2014.05.06.08.18.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 08:18:34 -0700 (PDT)
Received: by mail-vc0-f182.google.com with SMTP id la4so1151888vcb.13
        for <linux-mm@kvack.org>; Tue, 06 May 2014 08:18:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140506150014.GA6731@gmail.com>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
	<20140506102925.GD11096@twins.programming.kicks-ass.net>
	<CA+55aFzt47Jpp-KK-ocLGgzYt_w-vheqFLfaGZOUSjwVrgGUtw@mail.gmail.com>
	<20140506150014.GA6731@gmail.com>
Date: Tue, 6 May 2014 08:18:34 -0700
Message-ID: <CA+55aFwM-g01tCZ1NknwvMeSMpwyKyTm6hysN-GmrZ_APtk7UA@mail.gmail.com>
Subject: Re: [RFC] Heterogeneous memory management (mirror process address
 space on a device mmu).
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, "Sander, Ben" <ben.sander@amd.com>, "Stoner, Greg" <Greg.Stoner@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>, Davidlohr Bueso <davidlohr@hp.com>

On Tue, May 6, 2014 at 8:00 AM, Jerome Glisse <j.glisse@gmail.com> wrote:
>
> So question becomes how to implement process address space mirroring
> without pinning memory and track cpu page table update knowing that
> device page table update is unbound can not be atomic from cpu point
> of view.

Perhaps as a fake TLB and interacting with the TLB shootdown? And
making sure that everything is atomic?

Some of these devices are going to actually *share* the real page
tables. Not "cache" them. Actually use the page tables directly.
That's where all these on-die APU things are going, where the device
really ends up being something much more like ASMP (asymmetric
multi-processing) than a traditional external device.

So we *will* have to extend our notion of TLB shootdown to have not
just a mask of possible active CPU's, but possible active devices. No
question about that.

But doing this with sleeping in some stupid VM notifier is completely
out of the question, because it *CANNOT EVEN WORK* for that eventual
real goal of sharing the physical page tables where the device can do
things like atomic dirty/accessed bit settings etc. It can only work
for crappy sh*t that does the half-way thing. It's completely racy wrt
the actual page table updates. That kind of page table sharing needs
true atomicity for exactly the same reason we need it for our current
SMP. So it needs to have all the same page table locking rules etc.
Not that shitty notifier callback.

As I said, the VM notifiers were misdesigned to begin with. They are
an abomination. We're not going to extend on that and make it worse.
We are *certainly* not going to make them blocking and screwing our
core VM that way. And that's doubly and triply true when it cannot
work for the generic case _anyway_.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
