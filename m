Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id AD8956B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 18:27:40 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id y15so12083644wrc.6
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 15:27:40 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i6si11456126wrc.488.2017.12.19.15.27.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 15:27:39 -0800 (PST)
Date: Tue, 19 Dec 2017 15:27:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/zsmalloc: simplify shrinker init/destroy
Message-Id: <20171219152736.55d064945a68d2d2ffc64b15@linux-foundation.org>
In-Reply-To: <15c19718-c08e-e7f6-8af9-9651db1b11cc@gmail.com>
References: <20171219102213.GA435@jagdpanzerIV>
	<1513680552-9798-1-git-send-email-akaraliou.dev@gmail.com>
	<20171219151341.GC15210@dhcp22.suse.cz>
	<20171219152536.GA591@tigerII.localdomain>
	<20171219155815.GC2787@dhcp22.suse.cz>
	<15c19718-c08e-e7f6-8af9-9651db1b11cc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aliaksei Karaliou <akaraliou.dev@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org

On Tue, 19 Dec 2017 20:45:17 +0300 Aliaksei Karaliou <akaraliou.dev@gmail.com> wrote:

> >>> So what will happen if the pool is alive and used without any shrinker?
> >>> How do objects get freed?
> >> we use shrinker for "optional" de-fragmentation of zsmalloc pools. we
> >> don't free any objects from that path. just move them around within their
> >> size classes - to consolidate objects and to, may be, free unused pages
> >> [but we first need to make them "unused"]. it's not a mandatory thing for
> >> zsmalloc, we are just trying to be nice.
> > OK, it smells like an abuse of the API but please add a comment
> > clarifying that.
> >
> > Thanks!
> I can update the existing comment to be like that:
>          /*
>           * Not critical since shrinker is only used to trigger internal
>           * de-fragmentation of the pool which is pretty optional thing.
>           * If registration fails we still can use the pool normally and
>           * user can trigger compaction manually. Thus, ignore return code.
>           */
> 
> Sergey, does this sound well to you ? Or not clear enough, Michal ?

I did this:

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-zsmalloc-simplify-shrinker-init-destroy-fix

update comment (Aliaksei), make zs_register_shrinker() return void

Cc: Aliaksei Karaliou <akaraliou.dev@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/zsmalloc.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff -puN mm/zsmalloc.c~mm-zsmalloc-simplify-shrinker-init-destroy-fix mm/zsmalloc.c
--- a/mm/zsmalloc.c~mm-zsmalloc-simplify-shrinker-init-destroy-fix
+++ a/mm/zsmalloc.c
@@ -2323,14 +2323,14 @@ static void zs_unregister_shrinker(struc
 	unregister_shrinker(&pool->shrinker);
 }
 
-static int zs_register_shrinker(struct zs_pool *pool)
+static void zs_register_shrinker(struct zs_pool *pool)
 {
 	pool->shrinker.scan_objects = zs_shrinker_scan;
 	pool->shrinker.count_objects = zs_shrinker_count;
 	pool->shrinker.batch = 0;
 	pool->shrinker.seeks = DEFAULT_SEEKS;
 
-	return register_shrinker(&pool->shrinker);
+	register_shrinker(&pool->shrinker);
 }
 
 /**
@@ -2419,10 +2419,12 @@ struct zs_pool *zs_create_pool(const cha
 		goto err;
 
 	/*
-	 * Not critical, we still can use the pool
-	 * and user can trigger compaction manually.
+	 * Not critical since shrinker is only used to trigger internal
+	 * defragmentation of the pool which is pretty optional thing.  If
+	 * registration fails we still can use the pool normally and user can
+	 * trigger compaction manually. Thus, ignore return code.
 	 */
-	(void) zs_register_shrinker(pool);
+	zs_register_shrinker(pool);
 
 	return pool;
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
