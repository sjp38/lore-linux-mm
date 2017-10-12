Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2FB1C6B0280
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 05:10:01 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id q132so2530189wmd.22
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 02:10:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 91si13194117wrr.179.2017.10.12.02.09.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Oct 2017 02:10:00 -0700 (PDT)
Date: Thu, 12 Oct 2017 10:09:55 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/7 v1] Speed up page cache truncation
Message-ID: <20171012090955.vxsq5rh6ptmk5cp6@suse.de>
References: <20171010151937.26984-1-jack@suse.cz>
 <878tgisyo6.fsf@linux.intel.com>
 <20171011080658.GK3667@quack2.suse.cz>
 <e596a6d7-4858-8fe6-c315-8a285748a31a@intel.com>
 <20171011210613.GQ3667@quack2.suse.cz>
 <20171011212401.GM15067@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171011212401.GM15067@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org

On Thu, Oct 12, 2017 at 08:24:01AM +1100, Dave Chinner wrote:
> On Wed, Oct 11, 2017 at 11:06:13PM +0200, Jan Kara wrote:
> > On Wed 11-10-17 10:34:47, Dave Hansen wrote:
> > > On 10/11/2017 01:06 AM, Jan Kara wrote:
> > > >>> when rebasing our enterprise distro to a newer kernel (from 4.4 to 4.12) we
> > > >>> have noticed a regression in bonnie++ benchmark when deleting files.
> > > >>> Eventually we have tracked this down to a fact that page cache truncation got
> > > >>> slower by about 10%. There were both gains and losses in the above interval of
> > > >>> kernels but we have been able to identify that commit 83929372f629 "filemap:
> > > >>> prepare find and delete operations for huge pages" caused about 10% regression
> > > >>> on its own.
> > > >> It's odd that just checking if some pages are huge should be that
> > > >> expensive, but ok ..
> > > > Yeah, I was surprised as well but profiles were pretty clear on this - part
> > > > of the slowdown was caused by loads of page->_compound_head (PageTail()
> > > > and page_compound() use that) which we previously didn't have to load at
> > > > all, part was in hpage_nr_pages() function and its use.
> > > 
> > > Well, page->_compound_head is part of the same cacheline as the rest of
> > > the page, and the page is surely getting touched during truncation at
> > > _some_ point.  The hpage_nr_pages() might cause the cacheline to get
> > > loaded earlier than before, but I can't imagine that it's that expensive.
> > 
> > Then my intuition matches yours ;) but profiles disagree.
> 
> Do you get the same benefit across different filesystems?
> 

I don't know about Jan's testing but benefit is different on XFS.
Unfortunately, only one machine I was using for testing a follow-on series
covered XFS but still;

bonnie
                                      4.14.0-rc4             4.14.0-rc4
                                         vanilla          janbatch-v1r1
Hmean     SeqCreate del      17164.80 (   0.00%)    18638.45 (   8.59%)
Hmean     RandCreate del     15025.81 (   0.00%)    16485.69 (   9.72%)

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
