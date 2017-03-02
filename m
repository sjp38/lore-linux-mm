Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 595CF6B038A
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:45:53 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y90so9638146wrb.1
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:45:53 -0800 (PST)
Received: from mail-wr0-f195.google.com (mail-wr0-f195.google.com. [209.85.128.195])
        by mx.google.com with ESMTPS id h9si1712444wrc.243.2017.03.02.07.45.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 07:45:52 -0800 (PST)
Received: by mail-wr0-f195.google.com with SMTP id u48so10035224wrc.1
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:45:52 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] xfs: back off from kmem_zalloc_greedy if the task is killed
Date: Thu,  2 Mar 2017 16:45:41 +0100
Message-Id: <20170302154541.16155-2-mhocko@kernel.org>
In-Reply-To: <20170302154541.16155-1-mhocko@kernel.org>
References: <20170302153002.GG3213@bfoster.bfoster>
 <20170302154541.16155-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Brian Foster <bfoster@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Xiong Zhou <xzhou@redhat.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

It doesn't really make much sense to retry vmalloc request if the
current task is killed. We should rather bail out as soon as possible
and let it RIP as soon as possible. The current implementation of
vmalloc will fail anyway.

Suggested-by: Brian Foster <bfoster@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/xfs/kmem.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
index ee95f5c6db45..01c52567a4ff 100644
--- a/fs/xfs/kmem.c
+++ b/fs/xfs/kmem.c
@@ -34,7 +34,7 @@ kmem_zalloc_greedy(size_t *size, size_t minsize, size_t maxsize)
 	size_t		kmsize = maxsize;
 
 	while (!(ptr = vzalloc(kmsize))) {
-		if (kmsize == minsize)
+		if (kmsize == minsize || fatal_signal_pending(current))
 			break;
 		if ((kmsize >>= 1) <= minsize)
 			kmsize = minsize;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
