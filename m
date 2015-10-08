Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3F3296B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 03:23:59 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so11894316wic.1
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 00:23:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c11si9747267wiv.87.2015.10.08.00.23.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Oct 2015 00:23:58 -0700 (PDT)
Subject: Re: [PATCH 1/3] page: add new flags "PG_movable" and add interfaces
 to control these pages
References: <1444286152-30175-1-git-send-email-zhuhui@xiaomi.com>
 <1444286152-30175-2-git-send-email-zhuhui@xiaomi.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56161A06.4060502@suse.cz>
Date: Thu, 8 Oct 2015 09:23:50 +0200
MIME-Version: 1.0
In-Reply-To: <1444286152-30175-2-git-send-email-zhuhui@xiaomi.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Dave Hansen <dave.hansen@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jennifer Herbert <jennifer.herbert@citrix.com>, Hugh Dickins <hughd@google.com>, Vladimir Davydov <vdavydov@parallels.com>, David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, "Steven Rostedt (Red Hat)" <rostedt@goodmis.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <wanpeng.li@hotmail.com>, Geert Uytterhoeven <geert+renesas@glider.be>, Greg Thelen <gthelen@google.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: teawater@gmail.com

On 10/08/2015 08:35 AM, Hui Zhu wrote:
> This patch add PG_movable to mark a page as movable.
> And when system call migrate function, it will call the interfaces isolate,
> put and migrate to control it.
>
> There is a patch for page migrate interface in LKML.  But for zsmalloc,
> it is too deep inside the file system.  So I add another one.
>
> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
> ---
>   include/linux/mm_types.h   |  6 ++++++
>   include/linux/page-flags.h |  3 +++
>   mm/compaction.c            |  6 ++++++
>   mm/debug.c                 |  1 +
>   mm/migrate.c               | 17 +++++++++++++----
>   mm/vmscan.c                |  2 +-
>   6 files changed, 30 insertions(+), 5 deletions(-)
>
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 3d6baa7..132afb0 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -12,6 +12,7 @@
>   #include <linux/cpumask.h>
>   #include <linux/uprobes.h>
>   #include <linux/page-flags-layout.h>
> +#include <linux/migrate_mode.h>
>   #include <asm/page.h>
>   #include <asm/mmu.h>
>
> @@ -196,6 +197,11 @@ struct page {
>   #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
>   	int _last_cpupid;
>   #endif
> +
> +	int (*isolate)(struct page *page);
> +	void (*put)(struct page *page);
> +	int (*migrate)(struct page *page, struct page *newpage, int force,
> +		       enum migrate_mode mode);

Three new function pointers in a struct page? No way! Nowadays it has 
around 64 bytes IIRC and we do quite some crazy stuff to keep it packed.
We can't just like this add extra 24 bytes of overhead per 4096 bytes of 
useful data.

>   }
>   /*
>    * The struct page can be forced to be double word aligned so that atomic ops
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 416509e..d91e98a 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -113,6 +113,7 @@ enum pageflags {
>   	PG_young,
>   	PG_idle,
>   #endif
> +	PG_movable,		/* MOVABLE */

Page flag space is also a rare resource and we shouldn't add new ones if 
it's possible to do otherwise - and it should be in this case.

Since Sergey already responded to the cover letter with links to the 
prior relevant series, I just wanted to point out the biggest reasons 
why this cannot be accepted technically.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
