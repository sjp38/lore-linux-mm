Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B86848D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 09:27:52 -0500 (EST)
Date: Thu, 24 Feb 2011 15:27:15 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: too big min_free_kbytes
Message-ID: <20110224142715.GE5633@random.random>
References: <20110127134057.GA32039@csn.ul.ie>
 <20110127152755.GB30919@random.random>
 <20110203025808.GJ5843@random.random>
 <20110214022524.GA18198@sli10-conroe.sh.intel.com>
 <20110222142559.GD15652@csn.ul.ie>
 <1298438954.19589.7.camel@sli10-conroe>
 <20110223144509.GG31195@random.random>
 <1298534927.19589.41.camel@sli10-conroe>
 <20110224095208.GP15652@csn.ul.ie>
 <20110224095727.GQ15652@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110224095727.GQ15652@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>, Rik van Riel <riel@redhat.com>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>

On Thu, Feb 24, 2011 at 09:57:27AM +0000, Mel Gorman wrote:
> I should be clearer here. madvise|always sets a high min_free_kbytes by
> this check
> 
>         if (ret > 0 &&
>             (test_bit(TRANSPARENT_HUGEPAGE_FLAG,
>                       &transparent_hugepage_flags) ||
>              test_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
>                       &transparent_hugepage_flags)))
>                 set_recommended_min_free_kbytes();
> 
> so I'd expect the new higher value for min_free_kbytes once THP was ever
> expected to be used.
> 
> If this new value was still considered a bug, removing the call to
> set_recommended_min_free_kbytes() would always use the lower value that
> was used in older kernels. This would "fix" the bug but transparent hugepage
> users would not get the pages they expected the longer the system was running.
> This would be harder for ordinary users to catch.

This is a safe default for TRANSPARENT_HUGEPAGE_FLAG. All servers
will want set_recommended_min_free_kbytes. All we can argue on the
TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG setting if it needs this or not
(maybe we can remove the TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG check
considering madvise is mostly for embedded systems that can't waste a
byte in case THP increases the memory footprint of the program but
they still want to use THP for embedded virt or similar usages that
don't waste any memory at peak load).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
