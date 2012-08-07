Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id CCDCE6B004D
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 12:03:47 -0400 (EDT)
Date: Tue, 7 Aug 2012 17:03:37 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] mm: hugetlb: flush dcache before returning zeroed huge
 page to userspace
Message-ID: <20120807160337.GC16877@mudshark.cambridge.arm.com>
References: <1341412376-6272-1-git-send-email-will.deacon@arm.com>
 <20120709122523.GC4627@tiehlicka.suse.cz>
 <20120709141324.GK7315@mudshark.cambridge.arm.com>
 <alpine.LSU.2.00.1207091622470.2261@eggly.anvils>
 <20120710094513.GB9108@mudshark.cambridge.arm.com>
 <20120710104234.GI9108@mudshark.cambridge.arm.com>
 <20120711174802.GG13498@mudshark.cambridge.arm.com>
 <20120712111659.GF21013@tiehlicka.suse.cz>
 <20120712112645.GG2816@mudshark.cambridge.arm.com>
 <20120712115708.GG21013@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120712115708.GG21013@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, Russell King <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

<resurrecting this thread>

On Thu, Jul 12, 2012 at 12:57:08PM +0100, Michal Hocko wrote:
> On Thu 12-07-12 12:26:45, Will Deacon wrote:
> > Well, the comment in linux/page-flags.h does state that:
> > 
> >  * PG_arch_1 is an architecture specific page state bit.  The generic code
> >  * guarantees that this bit is cleared for a page when it first is entered into
> >  * the page cache.
> > 
> > so it's not completely clear cut that the architecture should be responsible
> > for clearing this bit when allocating pages from the hugepage pool.
> 
> I think the wording is quite clear. It guarantees it gets cleared not
> clears it. So it is up to an arch specific functions called from the
> generic code to do that.

If we have to do this in arch-specific functions then:

	1. Where should we do it?
	2. Why don't we also do this for normal (non-huge) pages?

I looked at what happens for non-huge pages and the page flags are
cleared by *generic* code in free_pages_check:


  /*
   * Flags checked when a page is prepped for return by the page allocator.
   * Pages being prepped should not have any flags set.  It they are set,
   * there has been a kernel bug or struct page corruption.
   */
  #define PAGE_FLAGS_CHECK_AT_PREP	((1 << NR_PAGEFLAGS) - 1)

  static inline int free_pages_check(struct page *page)
  {
  	[...]
  	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
  		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
  	return 0;
  }


Which guarantees to the arch-code that any new pages coming back from the
allocator will have PG_arch_1 clear. Why can't we just do something similar
for the hugepage pool?

Sorry to nag, but the discrepancy seems both unnecessary and unsolvable
at the arch level with the current hooks.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
