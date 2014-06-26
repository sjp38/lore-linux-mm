Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 905476B00A2
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 15:51:17 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id hi2so1699661wib.13
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 12:51:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id cm4si6672879wib.21.2014.06.26.12.51.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jun 2014 12:51:15 -0700 (PDT)
Date: Thu, 26 Jun 2014 15:50:36 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] hwpoison: Fix race with changing page during offlining
Message-ID: <20140626195036.GA5311@nhori.redhat.com>
References: <1403806972-14267-1-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403806972-14267-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, tony.luck@intel.com, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, dave.hansen@linux.intel.com

Thank you for testing/reporting.

On Thu, Jun 26, 2014 at 11:22:52AM -0700, Andi Kleen wrote:
> From: Andi Kleen <ak@linux.intel.com>
> 
> While running the mcelog test suite on 3.14 I hit the following VM_BUG_ON:
> 
> soft_offline: 0x56d4: unknown non LRU page type 3ffff800008000

This line comes from error path in get_any_page(), I guess this function was
called for a thp (due to the race between thp collapse and soft offlining.)
But in this case soft offlining is not tried, so there's no harm from this.

> page:ffffea000015b400 count:3 mapcount:2097169 mapping:          (null) index:0xffff8800056d7000
> page flags: 0x3ffff800004081(locked|slab|head)
> ------------[ cut here ]------------
> kernel BUG at mm/rmap.c:1495!

This seems to be caused by calling try_to_unmap() for a slab page, which
was called from hwpoison_user_mappings().

> 
> I think what happened is that a LRU page turned into a slab page in parallel
> with offlining. memory_failure initially tests for this case, but doesn't
> retest later after the page has been locked.
> 
> This patch fixes this race. It also check for the case that the page
> changed compound pages.
> 
> Unfortunately since it's a race I wasn't able to reproduce later,
> so the specific case is not tested.
> 
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: dave.hansen@linux.intel.com
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> ---
>  mm/memory-failure.c | 16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 90002ea..e277726a 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1143,6 +1143,22 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>  	lock_page(hpage);
>  
>  	/*
> +	 * The page could have turned into a non LRU page or
> +	 * changed compound pages during the locking.
> +	 * If this happens just bail out.
> +	 */
> +	if (compound_head(p) != hpage) {
> +		action_result(pfn, "different compound page after locking", IGNORED);
> +		res = -EBUSY;
> +		goto out;
> +	}

This is a useful check.

> +	if (!PageLRU(hpage)) {
> +		action_result(pfn, "non LRU after locking", IGNORED);
> +		res = -EBUSY;
> +		goto out;
> +	}

I think this makes sense in v3.14, but maybe redundant if the patch "hwpoison:
fix the handling path of the victimized page frame that belong to non-LRU"
from Chen Yucong is merged into mainline (now it's in linux-mmotm).

And I think that the problem you report is caused by another part of hwpoison
code, because we have PageSlab check at the beginning of hwpoison_user_mappings(),
so if LRU page truned into slab page just before locking the page, we never
reach try_to_unmap().
I think this was caused by the code around lock migration after thp split
in hwpoison_user_mappings(), which was introduced in commit 54b9dd14d09f
("mm/memory-failure.c: shift page lock from head page to tail page after thp split").
I guess the tail page (raw error page) was freed and turned into Slab page
just after thp split and before locking the error page.
So possible solution is to do page status check again after thp split.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
