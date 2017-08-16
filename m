Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DA6CD6B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 00:01:10 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 123so49701960pga.5
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 21:01:10 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 97si6976581plb.954.2017.08.15.21.01.09
        for <linux-mm@kvack.org>;
        Tue, 15 Aug 2017 21:01:09 -0700 (PDT)
Date: Wed, 16 Aug 2017 13:01:08 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3] zsmalloc: zs_page_migrate: schedule free_work if
 zspage is ZS_EMPTY
Message-ID: <20170816040107.GA24294@blaptop>
References: <1502853581-21218-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502853581-21218-1-git-send-email-zhuhui@xiaomi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>
Cc: ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, teawater@gmail.com

On Wed, Aug 16, 2017 at 11:19:41AM +0800, Hui Zhu wrote:
> After commit [1] zs_page_migrate can handle the ZS_EMPTY zspage.
> 
> But I got some false in zs_page_isolate:
> 	if (get_zspage_inuse(zspage) == 0) {
> 		spin_unlock(&class->lock);
> 		return false;
> 	}
> The page of this zspage was migrated in before.
> 
> The reason is commit [1] just handle the "page" but not "newpage"
> then it keep the "newpage" with a empty zspage inside system.
> Root cause is zs_page_isolate remove it from ZS_EMPTY list but not
> call zs_page_putback "schedule_work(&pool->free_work);".  Because
> zs_page_migrate done the job without "schedule_work(&pool->free_work);"
> 
> Make this patch let zs_page_migrate wake up free_work if need.
> 
> [1] zsmalloc-zs_page_migrate-skip-unnecessary-loops-but-not-return-ebusy-if-zspage-is-not-inuse-fix.patch
> 
> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
