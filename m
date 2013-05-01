Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id C8F176B0189
	for <linux-mm@kvack.org>; Wed,  1 May 2013 11:21:18 -0400 (EDT)
Date: Wed, 1 May 2013 11:21:05 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Better active/inactive list balancing
Message-ID: <20130501152105.GB8083@cmpxchg.org>
References: <517B6DF5.70402@gmail.com>
 <517B6E46.30209@gmail.com>
 <20130430163230.GB1229@cmpxchg.org>
 <5180BC79.8080101@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5180BC79.8080101@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mtrr Patt <mtrr.patt@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

Hi Wanpeng Li / Ni zhan Chen / Jaegeuk Hanse / Simon Jeons / Will Huck
/ Ric Mason / Sam Ben / Mtrr Patt!

On Wed, May 01, 2013 at 02:55:53PM +0800, Mtrr Patt wrote:
> Hi Johannes,
> On 05/01/2013 12:32 AM, Johannes Weiner wrote:
> >On Sat, Apr 27, 2013 at 02:20:54PM +0800, Mtrr Patt wrote:
> >>cc linux-mm
> >>
> >>On 04/27/2013 02:19 PM, Mtrr Patt wrote:
> >>>Hi Johannes,
> >>>
> >>>http://lwn.net/Articles/495543/
> >>>
> >>>This link said that "When active pages are considered for
> >>>eviction, they are first moved to the inactive list and unmapped
> >>>from the address space of the process(es) using them. Thus, once a
> >>>page moves to the inactive list, any attempt to reference it will
> >>>generate a page fault; this "soft fault" will cause the page to be
> >>>removed back to the active list."
> >>>
> >>>Why I can't find the codes unmap during page moved from active
> >>>list to inactive list?
> >Most architectures have the hardware track the referenced bit in the
> >page tables, but some don't.  For them, page_referenced_one() will
> >mark the mapping read-only when clearing the referenced/young bit and
> >the page fault handler will set the bit manually.
> 
> Thanks for your response. ;-) So the article is not against more
> common case, isn't it?

It's about the generic/theoretic case I guess, not the optimized
implementation.

> >When mapped pages reach the end of the inactive list and have that bit
> >set, they get activated, see page_check_references().
> 
> It seems that the page should trigger page fault twice and
> page_check_references can active it.

The first one brings it into memory (major fault), the second one sets
the referenced bit (minor fault or set by mmu).  Then it gets
activated.  That is the case for mmap accessed pages.

Buffered IO (read/write syscalls) enters the kernel anyway, so we
activate the pages right then and there with mark_page_accessed().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
