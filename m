Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7FDE16B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 06:57:26 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id g83so165128189oib.0
        for <linux-mm@kvack.org>; Mon, 23 May 2016 03:57:26 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0119.outbound.protection.outlook.com. [157.56.112.119])
        by mx.google.com with ESMTPS id t19si12322250otd.151.2016.05.23.03.57.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 May 2016 03:57:25 -0700 (PDT)
Date: Mon, 23 May 2016 13:57:18 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 7/8] pipe: account to kmemcg
Message-ID: <20160523105718.GC7917@esperanza>
References: <9e5dd7673dc37f198615b717fb1eae9309115134.1463997354.git.vdavydov@virtuozzo.com>
 <201605231850.3CoT8OXo%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <201605231850.3CoT8OXo%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 23, 2016 at 06:39:40PM +0800, kbuild test robot wrote:
...
>    fs/built-in.o: In function `anon_pipe_buf_steal':
> >> pipe.c:(.text+0x5f8d): undefined reference to `memcg_kmem_uncharge'

From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] pipe-account-to-kmemcg-fix


diff --git a/fs/pipe.c b/fs/pipe.c
index 6345f3543788..b3ad0b33f04e 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -144,8 +144,10 @@ static int anon_pipe_buf_steal(struct pipe_inode_info *pipe,
 	struct page *page = buf->page;
 
 	if (page_count(page) == 1) {
-		memcg_kmem_uncharge(page, 0);
-		__ClearPageKmemcg(page);
+		if (memcg_kmem_enabled()) {
+			memcg_kmem_uncharge(page, 0);
+			__ClearPageKmemcg(page);
+		}
 		__SetPageLocked(page);
 		return 0;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
