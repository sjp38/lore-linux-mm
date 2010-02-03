Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B0BCC6B0078
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 11:32:01 -0500 (EST)
Date: Wed, 3 Feb 2010 17:30:42 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 32 of 32] khugepaged
Message-ID: <20100203163042.GA5959@random.random>
References: <patchbomb.1264969631@v2.random>
 <51b543fab38b1290f176.1264969663@v2.random>
 <alpine.DEB.2.00.1002011551560.2384@router.home>
 <20100201225624.GB4135@random.random>
 <alpine.DEB.2.00.1002021347520.19529@router.home>
 <20100202202450.GR4135@random.random>
 <alpine.DEB.2.00.1002031010170.6590@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002031010170.6590@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 03, 2010 at 10:13:12AM -0600, Christoph Lameter wrote:
> On Tue, 2 Feb 2010, Andrea Arcangeli wrote:
> 
> > How would you say it? I think if ksm was forced to the migration pte
> > like it was discussed when ksm was first submitted, I would definitely
> > be forced to use it here too in order to get it merged. Do you disagree?
> 
> How about at least consolidating the code with ksm pieces?

It's much easier and realistic to consolidate ksm with migrate (which
isn't even done yet) than to consolidate any of the two with
khugepaged (both things you're asked and magically you don't care
about consolidation of ksm and migrate despite it's stuff already in
mainline).

ksm at least runs ptep_clear_flush_notify and works with ptes, so it
is more similar to what migrate does. khugepaged to be a lot faster
and execute a single IPI instead a flood of 512 per pmd, uses
pmdp_clear_flush_notify... it never calls ptep_clear_flush_notify
and ksm will never be able to call pmdp_clear_flush_notify (well of
course until we add transhuge support to ksm too, at which point not
even ksm will merge with migration code).

So unless you create a migration pmd in addition to the migration pte
I'd be shooting khugepaged with 511 unnecessary IPIs by consolidating
it at this point. Or at the very least first you have to make migrate
capable of migrating natively transhuge pages with a migration
pmd.

But again at this point all you can hope to consolidate is ksm with
migrate, khugepaged is the most different in having the serialiation
point in the pmd and not in the pte.

> I am asking for simplification and that you do the cleanup work that comes
> with introcing new functionality in the kernel.

If I thought it was possible or more robust to consolidate I think I
wouldn't be opposing it, I just don't think this is cleanup work but
gratuitous complexity added to ksm and khugepaged. And unless I add
even more functionality (migration pmd and native handling of hugepage
migration in pmd instead of a 3 liner) there's no way to merge
khugepaged with migrate, so I think if one wants to start removing
lines of code, it should start with ksm/migrate consolidation, that at
least won't require adding more functionality (i.e. more lines and
more complexity) not just to migrate but all over the page faults that
could run on a not present (migrate) pmd.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
