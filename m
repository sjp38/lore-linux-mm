Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0593D6B002C
	for <linux-mm@kvack.org>; Sun, 16 Oct 2011 06:09:06 -0400 (EDT)
Date: Sun, 16 Oct 2011 11:08:21 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 6/9] drivers: add Contiguous Memory Allocator
Message-ID: <20111016100821.GA21648@n2100.arm.linux.org.uk>
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com> <1317909290-29832-7-git-send-email-m.szyprowski@samsung.com> <20111014165730.e98aee8a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111014165730.e98aee8a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

On Fri, Oct 14, 2011 at 04:57:30PM -0700, Andrew Morton wrote:
> On Thu, 06 Oct 2011 15:54:46 +0200
> Marek Szyprowski <m.szyprowski@samsung.com> wrote:
> > +#ifdef phys_to_pfn
> > +/* nothing to do */
> > +#elif defined __phys_to_pfn
> > +#  define phys_to_pfn __phys_to_pfn
> > +#elif defined __va
> > +#  define phys_to_pfn(x) page_to_pfn(virt_to_page(__va(x)))
> > +#else
> > +#  error phys_to_pfn implementation needed
> > +#endif
> 
> Yikes!
> 
> This hackery should not be here, please.  If we need a phys_to_pfn()
> then let's write a proper one which lives in core MM and arch, then get
> it suitably reviewed and integrated and then maintained.

Another question is whether we have any arch where PFN != PHYS >> PAGE_SHIFT?
We've used __phys_to_pfn() to implement that on ARM (with a corresponding
__pfn_to_phys()).  Catalin recently added a cast to __phys_to_pfn() for
LPAE, which I don't think is required:

-#define        __phys_to_pfn(paddr)    ((paddr) >> PAGE_SHIFT)
+#define        __phys_to_pfn(paddr)    ((unsigned long)((paddr) >> PAGE_SHIFT))

since a phys_addr_t >> PAGE_SHIFT will be silently truncated if the passed
in physical address was 64-bit anyway.  (Note: we don't support > 32-bit
PFNs).

So, I'd suggest CMA should just use PFN_DOWN() and be done with it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
