Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5EF348E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 06:06:07 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id w18so15947089qts.8
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 03:06:07 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h13si278132qtb.233.2019.01.11.03.06.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 03:06:06 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V13 16/19] block: always define BIO_MAX_PAGES as 256
Date: Fri, 11 Jan 2019 19:01:24 +0800
Message-Id: <20190111110127.21664-17-ming.lei@redhat.com>
In-Reply-To: <20190111110127.21664-1-ming.lei@redhat.com>
References: <20190111110127.21664-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Ming Lei <ming.lei@redhat.com>

Now multi-page bvec can cover CONFIG_THP_SWAP, so we don't need to
increase BIO_MAX_PAGES for it.

CONFIG_THP_SWAP needs to split one THP into normal pages and adds
them all to one bio. With multipage-bvec, it just takes one bvec to
hold them all.

Reviewed-by: Omar Sandoval <osandov@fb.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index 1ece9f30294b..54ef81f11f83 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -34,15 +34,7 @@
 #define BIO_BUG_ON
 #endif
 
-#ifdef CONFIG_THP_SWAP
-#if HPAGE_PMD_NR > 256
-#define BIO_MAX_PAGES		HPAGE_PMD_NR
-#else
 #define BIO_MAX_PAGES		256
-#endif
-#else
-#define BIO_MAX_PAGES		256
-#endif
 
 #define bio_prio(bio)			(bio)->bi_ioprio
 #define bio_set_prio(bio, prio)		((bio)->bi_ioprio = prio)
-- 
2.9.5
