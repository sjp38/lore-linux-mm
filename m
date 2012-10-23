Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id C6EB76B0069
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 06:11:33 -0400 (EDT)
Date: Tue, 23 Oct 2012 11:11:25 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v2] mm: thp: Set the accessed flag for old pages on
 access fault.
Message-ID: <20121023101125.GA20210@mudshark.cambridge.arm.com>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121022111843.4406850d.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Miller <davem@davemloft.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "kirill@shutemov.name" <kirill@shutemov.name>, "aarcange@redhat.com" <aarcange@redhat.com>, "cmetcalf@tilera.com" <cmetcalf@tilera.com>, Steve Capper <Steve.Capper@arm.com>

On Mon, Oct 22, 2012 at 07:18:43PM +0100, Andrew Morton wrote:
> On Mon, 22 Oct 2012 11:35:03 +0100
> Will Deacon <will.deacon@arm.com> wrote:
> 
> > On Fri, Oct 19, 2012 at 07:49:55PM +0100, Andrew Morton wrote:
> > > Ho hum.  I'll drop
> > > mm-thp-set-the-accessed-flag-for-old-pages-on-access-fault.patch and
> > > shall assume that you'll sort things out at the appropriate time.
> > 
> > Happy to sort it out once I work out what's going wrong!
> 
> The patch "ARM: mm: Transparent huge page support for LPAE systems" is
> not present in linux-next, so this patch ("mm: thp: Set the accessed
> flag for old pages on access fault") will not compile?

This patch ("mm: thp: Set the accessed flag for old pages on access fault")
doesn't depend on "ARM: mm: Transparent huge page support for LPAE systems"
because currently transparent huge pages cannot be enabled for ARM in
mainline (or linux-next). update_mmu_cache_pmd is only called from
mm/huge_memory.c, which depends on CONFIG_TRANSPARENT_HUGEPAGE=y.

As for the new huge_pmd_set_accessed function... there's a similar situation
for the do_huge_pmd_wp_page function: it's called from mm/memory.c but is
only defined in mm/huge_memory.c. Looks like the compiler optimises those
calls away because pmd_trans_huge and friends constant-fold to 0.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
