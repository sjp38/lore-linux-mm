Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 499F16B025E
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 04:27:18 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id q124so4064024wmg.2
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 01:27:18 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id 186si20556502wmx.129.2017.02.01.01.27.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 01:27:17 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id v77so4462539wmv.0
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 01:27:17 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/3] mm, fs: check for fatal signals in do_generic_file_read
Date: Wed,  1 Feb 2017 10:27:05 +0100
Message-Id: <20170201092706.9966-3-mhocko@kernel.org>
In-Reply-To: <20170201092706.9966-1-mhocko@kernel.org>
References: <20170201092706.9966-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

do_generic_file_read can be told to perform a large request from
userspace. If the system is under OOM and the reading task is the OOM
victim then it has an access to memory reserves and finishing the full
request can lead to the full memory depletion which is dangerous. Make
sure we rather go with a short read and allow the killed task to
terminate.

Cc: stable
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/filemap.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/filemap.c b/mm/filemap.c
index 14bddd0d7fa4..2ba46f410c7c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1797,6 +1797,11 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
 
 		cond_resched();
 find_page:
+		if (fatal_signal_pending(current)) {
+			error = -EINTR;
+			goto out;
+		}
+
 		page = find_get_page(mapping, index);
 		if (!page) {
 			page_cache_sync_readahead(mapping,
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
