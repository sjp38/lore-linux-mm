Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id AD1786B005D
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 12:43:31 -0400 (EDT)
Date: Thu, 16 Aug 2012 19:43:56 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 6/7] mm: make clear_huge_page cache clear only around
 the fault address
Message-ID: <20120816164356.GA30106@shutemov.name>
References: <1345130154-9602-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1345130154-9602-7-git-send-email-kirill.shutemov@linux.intel.com>
 <20120816161647.GM11188@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120816161647.GM11188@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Alex Shi <alex.shu@intel.com>, Jan Beulich <jbeulich@novell.com>, Robert Richter <robert.richter@amd.com>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

On Thu, Aug 16, 2012 at 06:16:47PM +0200, Andrea Arcangeli wrote:
> Hi Kirill,
> 
> On Thu, Aug 16, 2012 at 06:15:53PM +0300, Kirill A. Shutemov wrote:
> >  	for (i = 0; i < pages_per_huge_page;
> >  	     i++, p = mem_map_next(p, page, i)) {
> 
> It may be more optimal to avoid a multiplication/shiftleft before the
> add, and to do:
> 
>   	for (i = 0, vaddr = haddr; i < pages_per_huge_page;
>   	     i++, p = mem_map_next(p, page, i), vaddr += PAGE_SIZE) {
> 

Makes sense. I'll update it.

> >  		cond_resched();
> > -		clear_user_highpage(p, addr + i * PAGE_SIZE);
> > +		vaddr = haddr + i*PAGE_SIZE;
> 
> Not sure if gcc can optimize it away because of the external calls.
> 
> > +		if (!ARCH_HAS_USER_NOCACHE || i == target)
> > +			clear_user_highpage(page + i, vaddr);
> > +		else
> > +			clear_user_highpage_nocache(page + i, vaddr);
> >  	}
> 
> 
> My only worry overall is if there can be some workload where this may
> actually slow down userland if the CPU cache is very large and
> userland would access most of the faulted in memory after the first
> fault.
> 
> So I wouldn't mind to add one more check in addition of
> !ARCH_HAS_USER_NOCACHE above to check a runtime sysctl variable. It'll
> waste a cacheline yes but I doubt it's measurable compared to the time
> it takes to do a >=2M hugepage copy.

Hm.. I think with static_key we can avoid cache overhead here. I'll try.
 
> Furthermore it would allow people to benchmark its effect without
> having to rebuild the kernel themself.
> 
> All other patches looks fine to me.

Thanks, for review. Could you take a look at huge zero page patchset? ;)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
