Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 50C446B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 12:35:02 -0400 (EDT)
Date: Wed, 28 Oct 2009 17:34:58 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Transparent Hugepage support
Message-ID: <20091028163458.GT7744@basil.fritz.box>
References: <20091026185130.GC4868@random.random> <87ljiwk8el.fsf@basil.nowhere.org> <20091027193007.GA6043@random.random> <20091028042805.GJ7744@basil.fritz.box> <20091028120050.GD9640@random.random> <20091028141803.GQ7744@basil.fritz.box> <20091028154827.GF9640@random.random> <20091028160352.GS7744@basil.fritz.box> <20091028162206.GG9640@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091028162206.GG9640@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 28, 2009 at 05:22:06PM +0100, Andrea Arcangeli wrote:
> I want to keep it as transparent as possible and to defer adding user
> visible interfaces (with the exception of MADV_HUGEPAGE equivalent to
> MADV_MERGEABLE for the scan daemon) initially. Even MADV_HUGEPAGE
> might not be necessary, even the disable/enable global flag may not be
> necessary but that is the absolute minimum tuning that seems
> useful and so there's not much risk to obsolete it.

I think you need some user visible interfaces to cleanly handle existing
reservations on a process base at least, otherwise you'll completely break 
their semantics.

sysctls that change existing semantics greatly are usually a bad idea
because what should the user do if they have existing applications
that rely on old semantics, but still want the new functionality?

> > e.g. a per process flag + prctl wouldn't seem to be particularly complicated.
> 
> You realize we can add those _interfaces_ later _after_ adding
> pud_trans_huge. I don't even want to add pud_trans_huge right

If you rely on splitting then it all won't work
for 1GB anyways and might need to be redone on the design level.
Code that's not complete is ok, but code that is known to need a 
redesign from the start is not that great.

Also completely ignoring sane reservation semantics in advance also
doesn't seem to be a particularly good way. Some way to control
this fine grained should be there at least.

> > I don't think there's much (anything?) in 1GB support that's absolutely
> > useless for 2M. e.g. a flexible reservation policy is certainly not.
> 
> I don't see KVM ever using this reservation hint, glibc neither. So

It would be set by the administrator.

> all, we should better focus on ensuring the MADV_HUGEPAGE fits 1G
> collapse_huge_page collapsing later (yeah, assuming 1G pages becomes
> available and that you can hang all apps using that data for as long
> as copy_page(1g)).

Can always schedule and check for signals during the copy.

> > When the performance improvement is visible enough people will
> > feel the need to reboot and the practical effect will be that
> > Linux requires reboots for full performance.
> 
> So you think the collapse_huge_page daemon will not be enough? How
> can't it be enough? If it's not enough it means the defrag logic isn't

I don't know how well it will hold up in practice. Only data can tell.

The problem I have is that the current "split on demand" approach 
can fragment even prereserved pages.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
