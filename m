Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 288C16B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 12:03:57 -0400 (EDT)
Date: Wed, 28 Oct 2009 17:03:52 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Transparent Hugepage support
Message-ID: <20091028160352.GS7744@basil.fritz.box>
References: <20091026185130.GC4868@random.random> <87ljiwk8el.fsf@basil.nowhere.org> <20091027193007.GA6043@random.random> <20091028042805.GJ7744@basil.fritz.box> <20091028120050.GD9640@random.random> <20091028141803.GQ7744@basil.fritz.box> <20091028154827.GF9640@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091028154827.GF9640@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 28, 2009 at 04:48:27PM +0100, Andrea Arcangeli wrote:
> > Even without automatic allocation and the need to prereseve
> > having the same application interface for 1GB pages is still useful.
> > Otherwise people who want to use the 1GB pages have to do the
> > special hacks again.
> 
> They will have to do the special hacks for reservation... No many
> other hacks after that if they accept if they reserve it becomes not
> swappable. Then it depends how you want to give permissions to use the
> reserved areas. It's all a reservation logic that you need in order to
> use 1G pages with this.

It's still a big step between just needing reservation and also
hacking the application to use new interfaces.

> > LD_PRELOAD, but integrating it in the kernel is much saner.
> > 
> > So even if there are some restrictions it would be good to not
> > ignore the 1GB pages completely.
> 
> I think we should ignore them in the first round of patches, knowing
> this model can fit them later if we just add a reservation logic and
> all pud_trans_huge. I don't think we need to provide this immediately

The design at least should not preclude them, even if the code
doesn't fully initially. That is why I objected earlier -- the design
doesn't seem to support them.

> This is what the sysctl is about. You can turn it off the
> transparency, and then the kernel will keep mapping hugepages only
> inside madvise(MADV_HUGEPAGE). There is no need of reserving anything
> here.

A global sysctl seems like a quite clumpsy way to do that. I hope
it would be possible to do better even with relatively simple code.

e.g. a per process flag + prctl wouldn't seem to be particularly complicated.

> 
> > So some policy here would be likely needed anyways and the same
> > could be used for the 1GB pages.
> 
> 1GB pages can't use the same logic but again I don't think we will be
> doing any additional work, if we address 2M pages now transparent, and
> we lave the reservation required for 1G pages for later.

If there's a per process "use pre-reservation" policy that logic
could well be shared for 2MB and 1GB.

> What I mean with ignore, is not to add a requirement for merging that
> 1G pages are also supported or we've to add even more logics that are
> absolutely useless for 2M pages.

I don't think there's much (anything?) in 1GB support that's absolutely
useless for 2M. e.g. a flexible reservation policy is certainly not.

> 
> > I'm still uneasy about this, it's a very clear "glass jaw"
> > that might well cause serious problems in practice. Anything that requires
> > regular reboots is bad.
> 
> Here nothing requires reboot. If you get 2M pages good, otherwise

When the performance improvement is visible enough people will
feel the need to reboot and the practical effect will be that
Linux requires reboots for full performance.

We already have this to some extent with the kernel direct mapping
breakup over time, but this would make it much worse.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
