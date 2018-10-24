Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2CC7F6B0007
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 13:24:29 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x44-v6so3209779edd.17
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 10:24:29 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id d3-v6si2237195edp.215.2018.10.24.10.24.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 10:24:27 -0700 (PDT)
Date: Wed, 24 Oct 2018 10:24:10 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -V6 00/21] swap: Swapout/swapin THP in one piece
Message-ID: <20181024172410.a3pibijoc2u2awwo@ca-dmjordan1.us.oracle.com>
References: <20181010071924.18767-1-ying.huang@intel.com>
 <20181023122738.a5j2vk554tsx4f6i@ca-dmjordan1.us.oracle.com>
 <87sh0wuijl.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87sh0wuijl.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

On Wed, Oct 24, 2018 at 11:31:42AM +0800, Huang, Ying wrote:
> Hi, Daniel,
> 
> Daniel Jordan <daniel.m.jordan@oracle.com> writes:
> 
> > On Wed, Oct 10, 2018 at 03:19:03PM +0800, Huang Ying wrote:
> >> And for all, Any comment is welcome!
> >> 
> >> This patchset is based on the 2018-10-3 head of mmotm/master.
> >
> > There seems to be some infrequent memory corruption with THPs that have been
> > swapped out: page contents differ after swapin.
> 
> Thanks a lot for testing this!  I know there were big effort behind this
> and it definitely will improve the quality of the patchset greatly!

You're welcome!  Hopefully I'll have more results and tests to share in the
next two weeks.

> 
> > Reproducer at the bottom.  Part of some tests I'm writing, had to separate it a
> > little hack-ily.  Basically it writes the word offset _at_ each word offset in
> > a memory blob, tries to push it to swap, and verifies the offset is the same
> > after swapin.
> >
> > I ran with THP enabled=always.  THP swapin_enabled could be always or never, it
> > happened with both.  Every time swapping occurred, a single THP-sized chunk in
> > the middle of the blob had different offsets.  Example:
> >
> > ** > word corruption gap
> > ** corruption detected 14929920 bytes in (got 15179776, expected 14929920) **
> > ** corruption detected 14929928 bytes in (got 15179784, expected 14929928) **
> > ** corruption detected 14929936 bytes in (got 15179792, expected 14929936) **
> > ...pattern continues...
> > ** corruption detected 17027048 bytes in (got 15179752, expected 17027048) **
> > ** corruption detected 17027056 bytes in (got 15179760, expected 17027056) **
> > ** corruption detected 17027064 bytes in (got 15179768, expected 17027064) **
> 
> 15179776 < 15179xxx <= 17027064
> 
> 15179776 % 4096 = 0
> 
> And 15179776 = 15179768 + 8
> 
> So I guess we have some alignment bug.  Could you try the patches
> attached?  It deal with some alignment issue.

That fixed it.  And removed three lines of code.  Nice :)
