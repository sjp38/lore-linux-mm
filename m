Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 339066B000A
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 23:31:48 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id k12-v6so1832459plt.0
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 20:31:48 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id d1-v6si3372741pld.217.2018.10.23.20.31.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 20:31:46 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -V6 00/21] swap: Swapout/swapin THP in one piece
References: <20181010071924.18767-1-ying.huang@intel.com>
	<20181023122738.a5j2vk554tsx4f6i@ca-dmjordan1.us.oracle.com>
Date: Wed, 24 Oct 2018 11:31:42 +0800
In-Reply-To: <20181023122738.a5j2vk554tsx4f6i@ca-dmjordan1.us.oracle.com>
	(Daniel Jordan's message of "Tue, 23 Oct 2018 05:27:38 -0700")
Message-ID: <87sh0wuijl.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

Hi, Daniel,

Daniel Jordan <daniel.m.jordan@oracle.com> writes:

> On Wed, Oct 10, 2018 at 03:19:03PM +0800, Huang Ying wrote:
>> And for all, Any comment is welcome!
>> 
>> This patchset is based on the 2018-10-3 head of mmotm/master.
>
> There seems to be some infrequent memory corruption with THPs that have been
> swapped out: page contents differ after swapin.

Thanks a lot for testing this!  I know there were big effort behind this
and it definitely will improve the quality of the patchset greatly!

> Reproducer at the bottom.  Part of some tests I'm writing, had to separate it a
> little hack-ily.  Basically it writes the word offset _at_ each word offset in
> a memory blob, tries to push it to swap, and verifies the offset is the same
> after swapin.
>
> I ran with THP enabled=always.  THP swapin_enabled could be always or never, it
> happened with both.  Every time swapping occurred, a single THP-sized chunk in
> the middle of the blob had different offsets.  Example:
>
> ** > word corruption gap
> ** corruption detected 14929920 bytes in (got 15179776, expected 14929920) **
> ** corruption detected 14929928 bytes in (got 15179784, expected 14929928) **
> ** corruption detected 14929936 bytes in (got 15179792, expected 14929936) **
> ...pattern continues...
> ** corruption detected 17027048 bytes in (got 15179752, expected 17027048) **
> ** corruption detected 17027056 bytes in (got 15179760, expected 17027056) **
> ** corruption detected 17027064 bytes in (got 15179768, expected 17027064) **

15179776 < 15179xxx <= 17027064

15179776 % 4096 = 0

And 15179776 = 15179768 + 8

So I guess we have some alignment bug.  Could you try the patches
attached?  It deal with some alignment issue.

> 100.0% of memory was swapped out at mincore time
> 0.00305% of pages were corrupted (first corrupt word 14929920, last corrupt word 17027064)
>
> The problem goes away with THP enabled=never, and I don't see it on 2018-10-3
> mmotm/master with THP enabled=always.
>
> The server had an NVMe swap device and ~760G memory over two nodes, and the
> program was always run like this:  swap-verify -s $((64 * 2**30))
>
> The kernels had one extra patch, Alexander Duyck's
> "dma-direct: Fix return value of dma_direct_supported", which was required to
> get them to build.
>

Thanks again!

Best Regards,
Huang, Ying

---------------------------------->8-----------------------------
