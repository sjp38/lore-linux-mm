Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id F203E6B0033
	for <linux-mm@kvack.org>; Thu, 28 Dec 2017 19:00:19 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id m39so22666436plg.19
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 16:00:19 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id m61si27394607plb.136.2017.12.28.16.00.17
        for <linux-mm@kvack.org>;
        Thu, 28 Dec 2017 16:00:18 -0800 (PST)
Date: Fri, 29 Dec 2017 09:00:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Hang with v4.15-rc trying to swap back in
Message-ID: <20171229000016.GA11452@bbox>
References: <1514398340.3986.10.camel@HansenPartnership.com>
 <1514407817.4169.4.camel@HansenPartnership.com>
 <20171227232650.GA9702@bbox>
 <1514417689.3083.1.camel@HansenPartnership.com>
 <20171227235643.GA10532@bbox>
 <1514482907.3040.15.camel@HansenPartnership.com>
 <1514487640.3040.21.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1514487640.3040.21.camel@HansenPartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Thorsten Leemhuis <regressions@leemhuis.info>

On Thu, Dec 28, 2017 at 11:00:40AM -0800, James Bottomley wrote:
> On Thu, 2017-12-28 at 09:41 -0800, James Bottomley wrote:
> > I'd guess that since they're both in io_schedule, the problem is that
> > the io_scheduler is taking far too long servicing the requests due to
> > some priority issue you've introduced.
> 
> OK, so after some analysis, that turned out to be incorrect.  The
> problem seems to be that we're exiting do_swap_page() with locked pages
> that have been read in from swap.
> 
> Your changelogs are entirely unclear on why you changed the swapcache
> setting logic in this patch:
> 
> commit 0bcac06f27d7528591c27ac2b093ccd71c5d0168
> Author: Minchan Kim <minchan@kernel.org>
> Date:   Wed Nov 15 17:33:07 2017 -0800
> 
>     mm, swap: skip swapcache for swapin of synchronous device
> 
> But I think you're using swapcache == NULL as a signal the page came
> from a synchronous device.  In which case the bug is that you've

Exactly. Because the patchset aims for skipping swap cache for synchronous
device and some logics of do_swap_page has has assumed the page is on
swap cache.

> forgotten we may already have picked up a page in
> swap_readahead_detect() which you're wrongly keeping swapcache == NULL
> for and the fix is this (it works on my system, although I'm still
> getting an unaccountable shutdown delay).

SIGH. I missed that.

> 
> I still think we should revert this series, because this may not be the
> only bug lurking in the code, so it should go through a lot more
> rigorous testing than it has.

I have no problem. It's not urgent.

Andrew, this is reverting patch based on 4.15-rc5. And I need to send
another revert patch against on mmotm because it would have conflict due to
vma-based readahead restructuring patch. I will send soon.

Thanks.
