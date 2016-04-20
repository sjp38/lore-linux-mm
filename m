Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3415F6B0285
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 19:48:14 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 203so37956651pfy.2
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 16:48:14 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id t5si14922680pac.211.2016.04.20.16.48.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 16:48:13 -0700 (PDT)
Date: Thu, 21 Apr 2016 09:48:11 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH mmotm 2/5] huge tmpfs: fix mlocked meminfo track huge
 unhuge mlocks fix
Message-ID: <20160421094811.6552f22b@canb.auug.org.au>
In-Reply-To: <alpine.LSU.2.11.1604161627260.1907@eggly.anvils>
References: <alpine.LSU.2.11.1604161621310.1907@eggly.anvils>
	<alpine.LSU.2.11.1604161627260.1907@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, kbuild test robot <fengguang.wu@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Hugh,

On Sat, 16 Apr 2016 16:29:44 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
>
> Please add this fix after
> huge-tmpfs-fix-mlocked-meminfo-track-huge-unhuge-mlocks.patch
> for later merging into it.  I expect this to fix a build problem found
> by robot on an x86_64 randconfig.  I was not able to reproduce the error,
> but I'm growing to realize that different optimizers behave differently.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>  mm/rmap.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1445,8 +1445,12 @@ static int try_to_unmap_one(struct page
>  	 */
>  	if (!(flags & TTU_IGNORE_MLOCK)) {
>  		if (vma->vm_flags & VM_LOCKED) {
> +			int nr_pages = 1;
> +
> +			if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && !pte)
> +				nr_pages = HPAGE_PMD_NR;
>  			/* Holding pte lock, we do *not* need mmap_sem here */
> -			mlock_vma_pages(page, pte ? 1 : HPAGE_PMD_NR);
> +			mlock_vma_pages(page, nr_pages);
>  			ret = SWAP_MLOCK;
>  			goto out_unmap;
>  		}

Added to linux-next today.

-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
