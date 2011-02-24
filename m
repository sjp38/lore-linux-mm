Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 50D118D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 04:57:57 -0500 (EST)
Date: Thu, 24 Feb 2011 09:57:27 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: too big min_free_kbytes
Message-ID: <20110224095727.GQ15652@csn.ul.ie>
References: <20110126174236.GV18984@csn.ul.ie> <20110127134057.GA32039@csn.ul.ie> <20110127152755.GB30919@random.random> <20110203025808.GJ5843@random.random> <20110214022524.GA18198@sli10-conroe.sh.intel.com> <20110222142559.GD15652@csn.ul.ie> <1298438954.19589.7.camel@sli10-conroe> <20110223144509.GG31195@random.random> <1298534927.19589.41.camel@sli10-conroe> <20110224095208.GP15652@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110224095208.GP15652@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>, Rik van Riel <riel@redhat.com>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>

On Thu, Feb 24, 2011 at 09:52:09AM +0000, Mel Gorman wrote:
> On Thu, Feb 24, 2011 at 04:08:47PM +0800, Shaohua Li wrote:
> > On Wed, 2011-02-23 at 22:45 +0800, Andrea Arcangeli wrote:
> > > On Wed, Feb 23, 2011 at 01:29:14PM +0800, Shaohua Li wrote:
> > > > Fixing it will let more people enable THP by default. but anyway we will
> > > > disable it now if the issue can't be fixed.
> > > 
> > > Did you try what happens with transparent_hugepage=madvise? If that
> > > doesn't fix it, it's min_free_kbytes issue.
> > with madvise, the min_free_kbytes is still high (same as the 'always'
> > case).
> 
> This high min_free_kbytes is expected and is not considered a bug as it's
> related to transparent hugepages being able to allocate huge pages for a
> long period of time. Essentially, it's a cost of using hugepages.
> 

I should be clearer here. madvise|always sets a high min_free_kbytes by
this check

        if (ret > 0 &&
            (test_bit(TRANSPARENT_HUGEPAGE_FLAG,
                      &transparent_hugepage_flags) ||
             test_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
                      &transparent_hugepage_flags)))
                set_recommended_min_free_kbytes();

so I'd expect the new higher value for min_free_kbytes once THP was ever
expected to be used.

If this new value was still considered a bug, removing the call to
set_recommended_min_free_kbytes() would always use the lower value that
was used in older kernels. This would "fix" the bug but transparent hugepage
users would not get the pages they expected the longer the system was running.
This would be harder for ordinary users to catch.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
