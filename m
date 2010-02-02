Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 921446B0098
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 15:25:46 -0500 (EST)
Date: Tue, 2 Feb 2010 21:24:50 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 32 of 32] khugepaged
Message-ID: <20100202202450.GR4135@random.random>
References: <patchbomb.1264969631@v2.random>
 <51b543fab38b1290f176.1264969663@v2.random>
 <alpine.DEB.2.00.1002011551560.2384@router.home>
 <20100201225624.GB4135@random.random>
 <alpine.DEB.2.00.1002021347520.19529@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002021347520.19529@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 02, 2010 at 01:52:11PM -0600, Christoph Lameter wrote:
> On Mon, 1 Feb 2010, Andrea Arcangeli wrote:
> 
> > KSM also works exactly the same as khugepaged and migration but we
> > solved it without migration pte and apparently nobody wants to deal
> > with that special migration pte logic. So before worrying about
> > khugepaged out of the tree, you should actively go fix ksm that works
> > exactly the same and it's in mainline. Until you don't fix ksm I think
> > I should be allowed to keep khugepaged simple and lightweight without
> > being forced to migration pte.
> 
> You are being "forced"? What language... You do not want to reuse the ksm

How would you say it? I think if ksm was forced to the migration pte
like it was discussed when ksm was first submitted, I would definitely
be forced to use it here too in order to get it merged. Do you disagree?

> code or the page migration code?

I prefer not to reuse the migration pte. I prefer to stick to the ksm
method. My rationale is pretty simple, migration pte requires an
additional logic in the pagefault code, while this doesn't and so it
has less dependencies and it looks simpler and more self contained to
me and it is enough for khugepaged as it is enough for ksm.

> Please consider consolidating the code for the multiple ways that we do
> these complex moves of physical memory without changing the physical one.
> 
> The code needs to be understandable and easy to maintain after all.

Again, I recommend to consolidate the code between ksm.c and migrate.c
yourself in mainline upsteam, then I'll be sure to share it in
khugepaged. I think it'll make it worse and more complicated and this
is all different enough that there's not enough to share, but then if
you find a way and your patch has more - lines than + lines, I'll be
happy to remove lines from huge_memory.c. I just don't have an obvious
point where to start removing code from the two files given the enough
difference in the logic and how the comparison (in ksm case) and
copies from regular to hugepage (in khugepaged case) are nested post
pte freezing (ksm) or pmd_huge freezing (khugepaged). I think what
you're asking is over-engineering but again I welcome you to do it
yourself and prove you actually save lines, I don't see it myself. I
think if it was it so obvious as you pretend it to be, Hugh would have
cleaned it up considering it was an issue mentioned already.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
