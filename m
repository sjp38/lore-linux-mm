Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id CEDB228000A
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 15:22:04 -0500 (EST)
Received: by mail-yk0-f177.google.com with SMTP id 142so4395476ykq.22
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 12:22:04 -0800 (PST)
Received: from mail-yh0-x22c.google.com (mail-yh0-x22c.google.com. [2607:f8b0:4002:c01::22c])
        by mx.google.com with ESMTPS id o8si19996664yhd.67.2014.11.10.12.22.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Nov 2014 12:22:03 -0800 (PST)
Received: by mail-yh0-f44.google.com with SMTP id b6so3978048yha.31
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 12:22:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1415644096-3513-4-git-send-email-j.glisse@gmail.com>
References: <1415644096-3513-1-git-send-email-j.glisse@gmail.com>
	<1415644096-3513-4-git-send-email-j.glisse@gmail.com>
Date: Mon, 10 Nov 2014 12:22:03 -0800
Message-ID: <CA+55aFwHd4QYopHvd=H6hxoQeqDV3HT6=436LGU-FRb5A0p7Vg@mail.gmail.com>
Subject: Re: [PATCH 3/5] lib: lockless generic and arch independent page table
 (gpt) v2.
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Joerg Roedel <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

Ok, so things are somewhat calm, and I'm trying to take time off to
see what's going on. And I'm not happy.

On Mon, Nov 10, 2014 at 10:28 AM,  <j.glisse@gmail.com> wrote:
>
> Page table is a common structure format most notably use by cpu mmu. The
> arch depend page table code has strong tie to the architecture which makes
> it unsuitable to be use by other non arch specific code.

Please don't call this thing a "generic page table".

It is no such thing. The *real* page tables are page tables. This is
some kind of "mapping lookup", and has nothing to do with page tables
as far as I can see. Why do you call it a page table?

Also, why isn't this just using our *existing* generic mapping
functionality, which already uses a radix tree, and has a lot of
lockless models? We already *have* something like that, and it's
called a "struct address_space".

And if you *just* want the tree, why don't you use "struct radix_tree_root".

And if it's generic, why do you have that odd insane conditional
locking going on?

In other words, looking at this, I just go "this is re-implementing
existing models, and uses naming that is actively misleading".

I think it's actively horrible, in other words. The fact that you have
one ACK on it already makes me go "Hmm". Is there some actual reason
why this would be called a page table, when even your explanation very
much clarifies that it is explicitly written to *not* be an actual
page table.

I also find it absolutely disgusting how you use USE_SPLIT_PTE_PTLOCKS
for this, which seems to make absolutely zero sense. So you're sharing
the config with the *real* page tables for no reason I can see.

I'm also looking at the "locking". It's insane. It's wrong, and
doesn't have any serialization. Using the bit operations for locking
is not correct. We've gotten over that years ago.

Rik, the fact that you acked this just makes all your other ack's be
suspect. Did you do it just because it was from Red Hat, or do you do
it because you like seeing Acked-by's with your name?

Anyway, this gets a NAK from me. Maybe I'm missing something, but I
think naming is supremely important, and I really don't see the point
of this. At a minimum, it needs a *hell* of a lot more explanations
for all it does. And quite frankly, I don't think that will be
sufficient, since the whole "bitops for locking" looks downright
buggy, and it's not at all clear why you want this in the first place
as opposed to just using gang lookups on the radix trees that we
already have, and that is well-tested and known to scale fine.

So really, it boils down to: why is this any better than radix trees
that are well-named, tested, and work?

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
