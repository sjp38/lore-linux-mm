Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D77466B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 12:22:16 -0400 (EDT)
Date: Wed, 28 Oct 2009 17:22:06 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: RFC: Transparent Hugepage support
Message-ID: <20091028162206.GG9640@random.random>
References: <20091026185130.GC4868@random.random>
 <87ljiwk8el.fsf@basil.nowhere.org>
 <20091027193007.GA6043@random.random>
 <20091028042805.GJ7744@basil.fritz.box>
 <20091028120050.GD9640@random.random>
 <20091028141803.GQ7744@basil.fritz.box>
 <20091028154827.GF9640@random.random>
 <20091028160352.GS7744@basil.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091028160352.GS7744@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 28, 2009 at 05:03:52PM +0100, Andi Kleen wrote:
> It's still a big step between just needing reservation and also
> hacking the application to use new interfaces.

The word "transparent" is all about "no need of hacking the
application" because "there is no new interface".

I want to keep it as transparent as possible and to defer adding user
visible interfaces (with the exception of MADV_HUGEPAGE equivalent to
MADV_MERGEABLE for the scan daemon) initially. Even MADV_HUGEPAGE
might not be necessary, even the disable/enable global flag may not be
necessary but that is the absolute minimum tuning that seems
useful and so there's not much risk to obsolete it.

> doesn't fully initially. That is why I objected earlier -- the design
> doesn't seem to support them.

I think it supports them once you solve the reservation, your hinting
and you add pud_trans_huge.

> A global sysctl seems like a quite clumpsy way to do that. I hope
> it would be possible to do better even with relatively simple code.

btw, the sysctl has to be moved to sysfs. The same sysfs directory
will also control the background collapse_huge_page daemon.

> e.g. a per process flag + prctl wouldn't seem to be particularly complicated.

You realize we can add those _interfaces_ later _after_ adding
pud_trans_huge. I don't even want to add pud_trans_huge right
now. Adding them now would force us to be sure to get the interface
right. I don't even want to think about it.

Let's defer any not strictly necessary visible user interface for
_later_. Anything 1G pages need can be deferred later.

> If there's a per process "use pre-reservation" policy that logic
> could well be shared for 2MB and 1GB.

We don't want having to reserve. Yes we could reserve but we don't
want to. We want to tell the kernel which regions have to be scanned
to recreate 2M pages with the madvise, but that's about it.

Nothing prevents us to add an interface to reserve later, which
obviously will be mandatory for 1G pages to ever be allocated. It's
not something we need to solve now I think.

> I don't think there's much (anything?) in 1GB support that's absolutely
> useless for 2M. e.g. a flexible reservation policy is certainly not.

I don't see KVM ever using this reservation hint, glibc neither. So
yes, you may have a corner case, but for the actual users of
transparent hugepages it seems entirely useless to me for the long
run. I may be wrong but because this is a new interface, and
transparent hugepages is all about _not_ having to modify the app at
all, we should better focus on ensuring the MADV_HUGEPAGE fits 1G
collapse_huge_page collapsing later (yeah, assuming 1G pages becomes
available and that you can hang all apps using that data for as long
as copy_page(1g)).

The whole point of ignoring 1G pages is that, we know adding
pud_trans_huge later is no problem, and that it'll require userland
changes that we want to defer as it's an orthogonal problem, even if
it might remotely help some corner case using transparent hugepages.

> When the performance improvement is visible enough people will
> feel the need to reboot and the practical effect will be that
> Linux requires reboots for full performance.

So you think the collapse_huge_page daemon will not be enough? How
can't it be enough? If it's not enough it means the defrag logic isn't
smart enough simply. So there's no way anything we do in this patch
can make a difference to avoid or not avoid reboot. In short your
worry of "need of rebooting" has nothing to do with the code we're
discussing but with the ability of the VM to generate hugepages. The
collapse_huge_page daemon will do the necessary things if those are
made available without need of reboot. yes defrag is another thing to
solve but it can be addressed separately and in parallel with this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
