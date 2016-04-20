Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id C94D16B028A
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 19:56:36 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id f83so113817565iod.1
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 16:56:36 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id cs2si310365igb.34.2016.04.20.16.56.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 16:56:36 -0700 (PDT)
Date: Thu, 21 Apr 2016 09:56:33 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH mmotm 5/5] huge tmpfs: add shmem_pmd_fault()
Message-ID: <20160421095633.3969f31d@canb.auug.org.au>
In-Reply-To: <alpine.LSU.2.11.1604161638230.1907@eggly.anvils>
References: <alpine.LSU.2.11.1604161621310.1907@eggly.anvils>
	<alpine.LSU.2.11.1604161638230.1907@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, kernel test robot <xiaolong.ye@intel.com>, Xiong Zhou <jencce.kernel@gmail.com>, Matthew Wilcox <willy@linux.intel.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Hugh,

On Sat, 16 Apr 2016 16:41:33 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
>
> The pmd_fault() method gives the filesystem an opportunity to place
> a trans huge pmd entry at *pmd, before any pagetable is exposed (and
> an opportunity to split it on COW fault): now use it for huge tmpfs.
> 
> This patch is a little raw: with more time before LSF/MM, I would
> probably want to dress it up better - the shmem_mapping() calls look
> a bit ugly; it's odd to want FAULT_FLAG_MAY_HUGE and VM_FAULT_HUGE just
> for a private conversation between shmem_fault() and shmem_pmd_fault();
> and there might be a better distribution of work between those two, but
> prising apart that series of huge tests is not to be done in a hurry.
> 
> Good for now, presents the new way, but might be improved later.
> 
> This patch still leaves the huge tmpfs map_team_by_pmd() allocating a
> pagetable while holding page lock, but other filesystems are no longer
> doing so; and we've not yet settled whether huge tmpfs should (like anon
> THP) or should not (like DAX) participate in deposit/withdraw protocol.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
> I've been testing with this applied on top of mmotm plus 1-4/5,
> but I suppose the right place for it is immediately after
> huge-tmpfs-map-shmem-by-huge-page-pmd-or-by-page-team-ptes.patch
> with a view to perhaps merging it into that in the future.
> 
>  mm/huge_memory.c |    4 ++--
>  mm/memory.c      |   13 +++++++++----
>  mm/shmem.c       |   33 +++++++++++++++++++++++++++++++++
>  3 files changed, 44 insertions(+), 6 deletions(-)

I added this to the end of mmotm in linux-next today.

-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
