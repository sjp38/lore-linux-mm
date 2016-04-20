Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 93D1E6B0288
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 19:55:59 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id zy2so85766045pac.1
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 16:55:59 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id z75si21545046pfi.48.2016.04.20.16.55.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 16:55:58 -0700 (PDT)
Date: Thu, 21 Apr 2016 09:55:55 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH mmotm 4/5] huge tmpfs: avoid premature exposure of new
 pagetable revert
Message-ID: <20160421095555.6c896fa4@canb.auug.org.au>
In-Reply-To: <alpine.LSU.2.11.1604161633130.1907@eggly.anvils>
References: <alpine.LSU.2.11.1604161621310.1907@eggly.anvils>
	<alpine.LSU.2.11.1604161633130.1907@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, kernel test robot <xiaolong.ye@intel.com>, Xiong Zhou <jencce.kernel@gmail.com>, Matthew Wilcox <willy@linux.intel.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Hugh,

On Sat, 16 Apr 2016 16:38:15 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
>
> This patch reverts all of my 09/31, your
> huge-tmpfs-avoid-premature-exposure-of-new-pagetable.patch
> and also the mm/memory.c changes from the patch after it,
> huge-tmpfs-map-shmem-by-huge-page-pmd-or-by-page-team-ptes.patch
> 
> I've diffed this against the top of the tree, but it may be better to
> throw this and huge-tmpfs-avoid-premature-exposure-of-new-pagetable.patch
> away, and just delete the mm/memory.c part of the patch after it.
> 
> This is in preparation for 5/5, which replaces what was done here.
> Why?  Numerous reasons.  Kirill was concerned that my movement of
> map_pages from before to after fault would show performance regression.
> Robot reported vm-scalability.throughput -5.5% regression, bisected to
> the avoid premature exposure patch.  Andrew was concerned about bloat
> in mm/memory.o.  Google had seen (on an earlier kernel) an OOM deadlock
> from pagetable allocations being done while holding pagecache pagelock.
> 
> I thought I could deal with those later on, but the clincher came from
> Xiong Zhou's report that it had broken binary execution from DAX mount.
> Silly little oversight, but not as easily fixed as first appears, because
> DAX now uses the i_mmap_rwsem to guard an extent from truncation: which
> would be open to deadlock if pagetable allocation goes down to reclaim
> (both are using only the read lock, but in danger of an rwr sandwich).
> 
> I've considered various alternative approaches, and what can be done
> to get both DAX and huge tmpfs working again quickly.  Eventually
> arrived at the obvious: shmem should use the new pmd_fault().
> 
> Reported-by: kernel test robot <xiaolong.ye@intel.com>
> Reported-by: Xiong Zhou <jencce.kernel@gmail.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>  mm/filemap.c |   10 --
>  mm/memory.c  |  225 +++++++++++++++++++++----------------------------
>  2 files changed, 101 insertions(+), 134 deletions(-)

I added this at the end of mmotm in linux-next today.  I will leave
Andrew to sort it out later.

-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
