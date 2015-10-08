Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2D9146B0253
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 03:24:29 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so14984531wic.0
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 00:24:28 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id gn10si51276704wjc.141.2015.10.08.00.24.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Oct 2015 00:24:28 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so11909754wic.1
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 00:24:27 -0700 (PDT)
Date: Thu, 8 Oct 2015 10:24:25 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/3] page: add new flags "PG_movable" and add interfaces
 to control these pages
Message-ID: <20151008072425.GA884@node>
References: <1444286152-30175-1-git-send-email-zhuhui@xiaomi.com>
 <1444286152-30175-2-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1444286152-30175-2-git-send-email-zhuhui@xiaomi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Dave Hansen <dave.hansen@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jennifer Herbert <jennifer.herbert@citrix.com>, Hugh Dickins <hughd@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, "Steven Rostedt (Red Hat)" <rostedt@goodmis.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <wanpeng.li@hotmail.com>, Geert Uytterhoeven <geert+renesas@glider.be>, Greg Thelen <gthelen@google.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, teawater@gmail.com

On Thu, Oct 08, 2015 at 02:35:50PM +0800, Hui Zhu wrote:
> This patch add PG_movable to mark a page as movable.
> And when system call migrate function, it will call the interfaces isolate,
> put and migrate to control it.
> 
> There is a patch for page migrate interface in LKML.  But for zsmalloc,
> it is too deep inside the file system.  So I add another one.
> 
> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
> ---
>  include/linux/mm_types.h   |  6 ++++++
>  include/linux/page-flags.h |  3 +++
>  mm/compaction.c            |  6 ++++++
>  mm/debug.c                 |  1 +
>  mm/migrate.c               | 17 +++++++++++++----
>  mm/vmscan.c                |  2 +-
>  6 files changed, 30 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 3d6baa7..132afb0 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -12,6 +12,7 @@
>  #include <linux/cpumask.h>
>  #include <linux/uprobes.h>
>  #include <linux/page-flags-layout.h>
> +#include <linux/migrate_mode.h>
>  #include <asm/page.h>
>  #include <asm/mmu.h>
>  
> @@ -196,6 +197,11 @@ struct page {
>  #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
>  	int _last_cpupid;
>  #endif
> +
> +	int (*isolate)(struct page *page);
> +	void (*put)(struct page *page);
> +	int (*migrate)(struct page *page, struct page *newpage, int force,
> +		       enum migrate_mode mode);
>  }

That's no-go. We are not going to add three pointers to struct page. It
would cost ~0.5% of system memory.

NAK.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
