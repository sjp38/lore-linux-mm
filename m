Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7D3E06B0005
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:28:38 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id p63so31873673wmp.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 07:28:38 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id v71si12840422wmd.18.2016.01.27.07.28.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 07:28:37 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id l65so3987486wmf.3
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 07:28:37 -0800 (PST)
Date: Wed, 27 Jan 2016 16:28:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm/madvise: update comment on sys_madvise()
Message-ID: <20160127152835.GD13956@dhcp22.suse.cz>
References: <1453857865-13650-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453857865-13650-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Jason Baron <jbaron@redhat.com>, Chen Gong <gong.chen@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed 27-01-16 10:24:25, Naoya Horiguchi wrote:
> Some new MADV_* advices are not documented in sys_madvise() comment.
> So let's update it.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Other than few suggestions below
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/madvise.c | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git v4.4-mmotm-2016-01-20-16-10/mm/madvise.c v4.4-mmotm-2016-01-20-16-10_patched/mm/madvise.c
> index 6a77114..c897b15 100644
> --- v4.4-mmotm-2016-01-20-16-10/mm/madvise.c
> +++ v4.4-mmotm-2016-01-20-16-10_patched/mm/madvise.c
> @@ -639,14 +639,26 @@ madvise_behavior_valid(int behavior)
>   *		some pages ahead.
>   *  MADV_DONTNEED - the application is finished with the given range,
>   *		so the kernel can free resources associated with it.
> + *  MADV_FREE - the application marks pages in the given range as lasyfree,

s@lasyfree@lazy free@

> + *		where actual purges are postponed until memory pressure happens.
>   *  MADV_REMOVE - the application wants to free up the given range of
>   *		pages and associated backing store.
>   *  MADV_DONTFORK - omit this area from child's address space when forking:
>   *		typically, to avoid COWing pages pinned by get_user_pages().
>   *  MADV_DOFORK - cancel MADV_DONTFORK: no longer omit this area when forking.
> + *  MADV_HWPOISON - trigger memory error handler as if the given memory range
> + *		were corrupted by unrecoverable hardware memory failure.
> + *  MADV_SOFT_OFFLINE - try to soft-offline the given range of memory.
>   *  MADV_MERGEABLE - the application recommends that KSM try to merge pages in
>   *		this area with pages of identical content from other such areas.
>   *  MADV_UNMERGEABLE- cancel MADV_MERGEABLE: no longer merge pages with others.
> + *  MADV_HUGEPAGE - the application wants to allocate transparent hugepages to
> + *		load the content of the given memory range.

I guess that a slightly different wording would be better:

application wants to back the given range by transparent huge pages in
the future. Existing pages might be coalesced and new pages might be
allocated as THP.

> + *  MADV_NOHUGEPAGE - cancel MADV_HUGEPAGE: no longer allocate transparent
> + *		hugepages.

Mark the given range as not worth being backed by transparent huge pages
so neither existing pages will be coalesced into THP nor new pages will
be allocated as THP.

> + *  MADV_DONTDUMP - the application wants to prevent pages in the given range
> + *		from being included in its core dump.
> + *  MADV_DODUMP - cancel MADV_DONTDUMP: no longer exclude from core dump.
>   *
>   * return values:
>   *  zero    - success
> -- 
> 2.7.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
