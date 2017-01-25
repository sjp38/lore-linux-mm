Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 41AAF6B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 06:48:00 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c85so36564586wmi.6
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 03:48:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n189si21214215wmn.97.2017.01.25.03.47.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 03:47:58 -0800 (PST)
Date: Wed, 25 Jan 2017 12:47:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] HWPOISON: soft offlining for non-lru movable page
Message-ID: <20170125114753.GJ32377@dhcp22.suse.cz>
References: <1485183010-9276-1-git-send-email-ysxie@foxmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1485183010-9276-1-git-send-email-ysxie@foxmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ysxie@foxmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, guohanjun@huawei.com, qiuxishi@huawei.com

On Mon 23-01-17 22:50:10, ysxie@foxmail.com wrote:
> From: Yisheng Xie <xieyisheng1@huawei.com>
> 
> This patch is to extends soft offlining framework to support
> non-lru page, which already support migration after
> commit bda807d44454 ("mm: migrate: support non-lru movable page
> migration")
> 
> When memory corrected errors occur on a non-lru movable page,
> we can choose to stop using it by migrating data onto another
> page and disable the original (maybe half-broken) one.
> 
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Suggested-by: Minchan Kim <minchan@kernel.org>
> Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This doesn't compile with CONFIG_MIGRATION=n

mm/memory-failure.c: In function '__soft_offline_page':
mm/memory-failure.c:1656:3: error: implicit declaration of function 'isolate_movable_page' [-Werror=implicit-function-declaration]
   ret = !isolate_movable_page(page, ISOLATE_UNEVICTABLE);
   ^
cc1: some warnings being treated as errors

I guess the following should handle the problem
---
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index ae8d475a9385..1da7a1f99fc7 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -57,6 +57,11 @@ static inline int migrate_pages(struct list_head *l, new_page_t new,
 		int reason)
 	{ return -ENOSYS; }
 
+static inline bool isolate_movable_page(struct page *page, isolate_mode_t mode)
+{
+	return -EBUSY;
+}
+
 static inline int migrate_prep(void) { return -ENOSYS; }
 static inline int migrate_prep_local(void) { return -ENOSYS; }
 
At least it compiles fine now. I have to look at the patch yet.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
