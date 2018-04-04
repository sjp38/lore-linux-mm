Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 74FF56B000A
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 18:20:44 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f4-v6so9850121plm.12
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 15:20:44 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o33-v6si4005656plb.369.2018.04.04.15.20.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 15:20:43 -0700 (PDT)
Date: Wed, 4 Apr 2018 15:20:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] z3fold: fix memory leak
Message-Id: <20180404152039.aadbe5bbed5bc91da8c5fa99@linux-foundation.org>
In-Reply-To: <1522803111-29209-1-git-send-email-wangxidong_97@163.com>
References: <1522803111-29209-1-git-send-email-wangxidong_97@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xidong Wang <wangxidong_97@163.com>
Cc: Vitaly Wool <vitalywool@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed,  4 Apr 2018 08:51:51 +0800 Xidong Wang <wangxidong_97@163.com> wrote:

> In function z3fold_create_pool(), the memory allocated by
> __alloc_percpu() is not released on the error path that pool->compact_wq
> , which holds the return value of create_singlethread_workqueue(), is NULL.
> This will result in a memory leak bug.
>
> ...
>
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -490,6 +490,7 @@ static struct z3fold_pool *z3fold_create_pool(const char *name, gfp_t gfp,
>  out_wq:
>  	destroy_workqueue(pool->compact_wq);
>  out:
> +	free_percpu(pool->unbuddied);
>  	kfree(pool);
>  	return NULL;
>  }

That isn't right.  If the initial kzallc fails we'll goto out with
pool==NULL.

Please check:

--- a/mm/z3fold.c~z3fold-fix-memory-leak-fix
+++ a/mm/z3fold.c
@@ -479,7 +479,7 @@ static struct z3fold_pool *z3fold_create
 	pool->name = name;
 	pool->compact_wq = create_singlethread_workqueue(pool->name);
 	if (!pool->compact_wq)
-		goto out;
+		goto out_unbuddied;
 	pool->release_wq = create_singlethread_workqueue(pool->name);
 	if (!pool->release_wq)
 		goto out_wq;
@@ -489,9 +489,10 @@ static struct z3fold_pool *z3fold_create
 
 out_wq:
 	destroy_workqueue(pool->compact_wq);
-out:
+out_unbuddied:
 	free_percpu(pool->unbuddied);
 	kfree(pool);
+out:
 	return NULL;
 }
 
_
