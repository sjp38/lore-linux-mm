Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id EF0FA6B0069
	for <linux-mm@kvack.org>; Wed, 30 May 2012 16:02:01 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so145061qcs.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 13:02:01 -0700 (PDT)
Date: Wed, 30 May 2012 16:01:51 -0400
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: Re: [PATCH 04/35] autonuma: define _PAGE_NUMA_PTE and _PAGE_NUMA_PMD
Message-ID: <20120530200150.GA30148@localhost.localdomain>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
 <1337965359-29725-5-git-send-email-aarcange@redhat.com>
 <20120530182247.GA28341@localhost.localdomain>
 <20120530183406.GH21339@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120530183406.GH21339@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Wed, May 30, 2012 at 08:34:06PM +0200, Andrea Arcangeli wrote:
> Hi Konrad,
> 
> On Wed, May 30, 2012 at 02:22:49PM -0400, Konrad Rzeszutek Wilk wrote:
> > Thank you for loking at this from the xen side. The interesting thing
> > is that I believe the _PAGE_PAT (or _PAGE_PSE) is actually used on
> > Xen on PTEs. It is used to mark the pages WC. <sigh>
> 
> Oops, I'm using _PAGE_PSE too on the pte, but only when it's unmapped.
> 
> static inline int pte_numa(pte_t pte)
> {
> 	return (pte_flags(pte) &
> 		(_PAGE_NUMA_PTE|_PAGE_PRESENT)) == _PAGE_NUMA_PTE;
> }
> 
> And _PAGE_UNUSED2 (_PAGE_IOMAP) is used for the pmd but _PAGE_IOMAP by
> Xen should only be set on ptes.
<nods>
> 
> The only way to use _PAGE_PSE safe on the pte is if the pte is
> non-present, is this what Xen is also doing? (in turn colliding with
> pte_numa)

The only time the _PAGE_PSE (_PAGE_PAT) is set is when
_PAGE_PCD | _PAGE_PWT are set. It is this ugly transformation
of doing:

 if (pat_enabled && _PAGE_PWT | _PAGE_PCD)
	pte = ~(_PAGE_PWT | _PAGE_PCD) | _PAGE_PAT;

and then writting the pte with the 7th bit set instead of the
2nd and 3rd to mark it as WC. There is a corresponding reverse too
(to read the pte - so the pte_val calls) - so if _PAGE_PAT is
detected it will remove the _PAGE_PAT and return the PTE as
if it had _PAGE_PWT | _PAGE_PCD.

So that little bit of code will need some tweaking - as it does
that even if _PAGE_PRESENT is not set. Meaning it would
transform your _PAGE_PAT to _PAGE_PWT | _PAGE_PCD. Gah!


> 
> Now if I shrink the size of the page_autonuma to one entry per pmd
> (instead of per pte) I may as well drop pte_numa entirely and only
> leave pmd_numa. At the moment it's possible to switch between the two
> models at runtime with sysctl (if one wants to do a more expensive
> granular tracking). I'm still uncertain on the best way to shrink
> the page_autonuma size we'll see.

OK. I can whip up a patch to deal with the 'Gah!' case easily if needed.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
