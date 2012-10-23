Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id D091E6B0072
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 17:50:28 -0400 (EDT)
Date: Tue, 23 Oct 2012 14:50:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: thp: Set the accessed flag for old pages on
 access fault.
Message-Id: <20121023145027.40710e7a.akpm@linux-foundation.org>
In-Reply-To: <20121023101125.GA20210@mudshark.cambridge.arm.com>
References: <1349197151-19645-1-git-send-email-will.deacon@arm.com>
	<20121002150104.da57fa94.akpm@linux-foundation.org>
	<20121017130125.GH5973@mudshark.cambridge.arm.com>
	<20121017.112620.1865348978594874782.davem@davemloft.net>
	<20121017155401.GJ5973@mudshark.cambridge.arm.com>
	<20121018150502.3dee7899.akpm@linux-foundation.org>
	<20121019091016.GA4582@mudshark.cambridge.arm.com>
	<20121019114955.3a0c2b66.akpm@linux-foundation.org>
	<20121022103503.GA26619@mudshark.cambridge.arm.com>
	<20121022111843.4406850d.akpm@linux-foundation.org>
	<20121023101125.GA20210@mudshark.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: David Miller <davem@davemloft.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "kirill@shutemov.name" <kirill@shutemov.name>, "aarcange@redhat.com" <aarcange@redhat.com>, "cmetcalf@tilera.com" <cmetcalf@tilera.com>, Steve Capper <Steve.Capper@arm.com>

On Tue, 23 Oct 2012 11:11:25 +0100
Will Deacon <will.deacon@arm.com> wrote:

> On Mon, Oct 22, 2012 at 07:18:43PM +0100, Andrew Morton wrote:
> > On Mon, 22 Oct 2012 11:35:03 +0100
> > Will Deacon <will.deacon@arm.com> wrote:
> > 
> > > On Fri, Oct 19, 2012 at 07:49:55PM +0100, Andrew Morton wrote:
> > > > Ho hum.  I'll drop
> > > > mm-thp-set-the-accessed-flag-for-old-pages-on-access-fault.patch and
> > > > shall assume that you'll sort things out at the appropriate time.
> > > 
> > > Happy to sort it out once I work out what's going wrong!
> > 
> > The patch "ARM: mm: Transparent huge page support for LPAE systems" is
> > not present in linux-next, so this patch ("mm: thp: Set the accessed
> > flag for old pages on access fault") will not compile?
> 
> This patch ("mm: thp: Set the accessed flag for old pages on access fault")
> doesn't depend on "ARM: mm: Transparent huge page support for LPAE systems"
> because currently transparent huge pages cannot be enabled for ARM in
> mainline (or linux-next). update_mmu_cache_pmd is only called from
> mm/huge_memory.c, which depends on CONFIG_TRANSPARENT_HUGEPAGE=y.
> 
> As for the new huge_pmd_set_accessed function... there's a similar situation
> for the do_huge_pmd_wp_page function: it's called from mm/memory.c but is
> only defined in mm/huge_memory.c. Looks like the compiler optimises those
> calls away because pmd_trans_huge and friends constant-fold to 0.

Ah, OK.

"mm: thp: Set the accessed flag for old pages on access fault" clashes
in a non-trivial way with linux-next changes, due to the sched-numa
changes (sigh).  This is a problem for me, because I either need to
significantly alter your patch (so it isn't applicable to mainline) or
I need to stage your patch ahead of linux-next, then fix up linux-next
every day after I've pulled and re-merged it.

I'm unsure what your timing is.  Can you carry "mm: thp: Set the
accessed flag for old pages on access fault" until either the whole
patchset is ready to merge or until the sched-numa situation has been
cleared up?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
