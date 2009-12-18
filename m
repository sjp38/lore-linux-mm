Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5F74D6B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 13:34:41 -0500 (EST)
Date: Fri, 18 Dec 2009 12:33:36 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00 of 28] Transparent Hugepage support #2
In-Reply-To: <20091218140530.GE29790@random.random>
Message-ID: <alpine.DEB.2.00.0912181229580.26947@router.home>
References: <patchbomb.1261076403@v2.random> <alpine.DEB.2.00.0912171352330.4640@router.home> <4B2A8D83.30305@redhat.com> <alpine.DEB.2.00.0912171402550.4640@router.home> <20091218140530.GE29790@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 18 Dec 2009, Andrea Arcangeli wrote:

> On Thu, Dec 17, 2009 at 02:09:47PM -0600, Christoph Lameter wrote:
> > Can we do this step by step? This splitting thing and its
> > associated overhead causes me concerns.
>
> The split_huge_page* functionality whole point is exactly to do things
> step by step. Removing it would mean doing it all at once.

The split huge page thing involved introducing new refcounting and locking
features into the VM. Not a first step thing. And certainly difficult to
verify if it is correct.

> This is like the big kernel lock when SMP initially was
> introduced. Surely kernel would have been a little faster if the big
> kernel lock was never introduced but over time the split_huge_page can
> be removed just like the big kernel lock has been removed. Then the
> PG_compound_lock can go away too.

That is a pretty strange comparison. Split huge page is like introducing
the split pte lock after removing the bkl. You first want to solve the
simpler issues (anon huge) and then see if there is a way to avoid
introducing new locking methods.

> scalable. In the future mmu notifier users that calls gup will stop
> using FOLL_GET and in turn they will stop calling put_page, so
> eliminating any need to take the PG_compound_lock in all KVM fast paths.

Maybe do that first then and never introduce the lock in the first place?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
