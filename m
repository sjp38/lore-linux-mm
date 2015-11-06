Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 02F8882F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 05:34:46 -0500 (EST)
Received: by wimw2 with SMTP id w2so27484622wim.1
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 02:34:45 -0800 (PST)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id m129si52292wmb.70.2015.11.06.02.34.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Nov 2015 02:34:45 -0800 (PST)
Received: by wmll128 with SMTP id l128so36990575wml.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 02:34:44 -0800 (PST)
Date: Fri, 6 Nov 2015 12:34:43 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2] mm: hwpoison: adjust for new thp refcounting
Message-ID: <20151106103442.GB6463@node.shutemov.name>
References: <20151106064743.GA30023@hori1.linux.bs1.fc.nec.co.jp>
 <1446796992-15798-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1446796992-15798-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Wanpeng Li <wanpeng.li@hotmail.com>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Nov 06, 2015 at 05:03:12PM +0900, Naoya Horiguchi wrote:
> Some mm-related BUG_ON()s could trigger from hwpoison code due to recent
> changes in thp refcounting rule. This patch fixes them up.
> 
> In the new refcounting, we no longer use tail->_mapcount to keep tail's
> refcount, and thereby we can simplify get/put_hwpoison_page().
> 
> And another change is that tail's refcount is not transferred to the raw
> page during thp split (more precisely, in new rule we don't take refcount
> on tail page any more.) So when we need thp split, we have to transfer the
> refcount properly to the 4kB soft-offlined page before migration.
> 
> thp split code goes into core code only when precheck (total_mapcount(head)
> == page_count(head) - 1) passes to avoid useless split, where we assume that
> one refcount is held by the caller of thp split and the others are taken
> via mapping. To meet this assumption, this patch moves thp split part in
> soft_offline_page() after get_any_page().
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
> ChangeLog v1->v2:
> - leave put_hwpoison_page() as a macro
> 
> - based on mmotm-2015-10-21-14-41 + Kirill's "[PATCH 0/4] Bugfixes for THP
>   refcounting" series.
> ---
>  include/linux/mm.h  |    1 +
>  mm/memory-failure.c |   75 +++++++++++++++------------------------------------
>  2 files changed, 23 insertions(+), 53 deletions(-)
> 
> diff --git mmotm-2015-10-21-14-41/include/linux/mm.h mmotm-2015-10-21-14-41_patched/include/linux/mm.h
> index a36f9fa..51e3ffe 100644
> --- mmotm-2015-10-21-14-41/include/linux/mm.h
> +++ mmotm-2015-10-21-14-41_patched/include/linux/mm.h
> @@ -2173,6 +2173,7 @@ extern int memory_failure(unsigned long pfn, int trapno, int flags);
>  extern void memory_failure_queue(unsigned long pfn, int trapno, int flags);
>  extern int unpoison_memory(unsigned long pfn);
>  extern int get_hwpoison_page(struct page *page);
> +#define put_hwpoison_page(page)	put_page(page)
>  extern void put_hwpoison_page(struct page *page);

This line should be removed.

Otherwise looks good to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
