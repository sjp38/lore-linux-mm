Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5B8434403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 11:42:36 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id o185so50132987pfb.1
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 08:42:36 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id xi3si17679551pab.123.2016.02.04.08.42.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 08:42:35 -0800 (PST)
Date: Thu, 4 Feb 2016 19:42:26 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH v1 1/3] /proc/kpageflags: return KPF_BUDDY for "tail"
 buddy pages
Message-ID: <20160204164226.GA16895@esperanza>
References: <1454569683-17918-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1454569683-17918-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Feb 04, 2016 at 04:08:01PM +0900, Naoya Horiguchi wrote:
> Currently /proc/kpageflags returns nothing for "tail" buddy pages, which
> is inconvenient when grasping how free pages are distributed. This patch
> sets KPF_BUDDY for such pages.

Looks reasonable to me,

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

> 
> With this patch:
> 
>   $ grep MemFree /proc/meminfo ; tools/vm/page-types -b buddy
>   MemFree:         3134992 kB
>                flags      page-count       MB  symbolic-flags                     long-symbolic-flags
>   0x0000000000000400          779272     3044  __________B_______________________________ buddy
>   0x0000000000000c00            4385       17  __________BM______________________________ buddy,mmap
>                total          783657     3061

Why are buddy pages reported as mmapped? That looks weird. Shouldn't we
fix it? Something like this, may be?
--
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] proc: kpageflags: do not report buddy and balloon pages as
 mapped

PageBuddy and PageBalloon are not usual page flags - they are identified
by a special negative (so as not to confuse with mapped pages) value of
page->_mapcount. Since /proc/kpageflags uses page_mapcount helper to
check if a page is mapped, it reports pages of these kinds as being
mapped, which is confusing. Fix that by replacing page_mapcount with
page_mapped.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

diff --git a/fs/proc/page.c b/fs/proc/page.c
index b2855eea5405..332450d87ea4 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -105,7 +105,7 @@ u64 stable_page_flags(struct page *page)
 	 * Note that page->_mapcount is overloaded in SLOB/SLUB/SLQB, so the
 	 * simple test in page_mapcount() is not enough.
 	 */
-	if (!PageSlab(page) && page_mapcount(page))
+	if (!PageSlab(page) && page_mapped(page))
 		u |= 1 << KPF_MMAP;
 	if (PageAnon(page))
 		u |= 1 << KPF_ANON;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
