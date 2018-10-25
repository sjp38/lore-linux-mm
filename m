Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 257CC6B0003
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 02:16:12 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id 186-v6so5024140ybt.9
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 23:16:12 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id c124-v6si4397728ywd.212.2018.10.24.23.16.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 23:16:11 -0700 (PDT)
Date: Thu, 25 Oct 2018 09:15:46 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH] mm/gup_benchmark: prevent integer overflow in ioctl
Message-ID: <20181025061546.hnhkv33diogf2uis@kili.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Keith Busch <keith.busch@intel.com>, "Michael S. Tsirkin" <mst@redhat.com>, Kees Cook <keescook@chromium.org>, YueHaibing <yuehaibing@huawei.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

The concern here is that "gup->size" is a u64 and "nr_pages" is unsigned
long.  On 32 bit systems we could trick the kernel into allocating fewer
pages than expected.

Fixes: 64c349f4ae78 ("mm: add infrastructure for get_user_pages_fast() benchmarking")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 mm/gup_benchmark.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/gup_benchmark.c b/mm/gup_benchmark.c
index debf11388a60..5b42d3d4b60a 100644
--- a/mm/gup_benchmark.c
+++ b/mm/gup_benchmark.c
@@ -27,6 +27,9 @@ static int __gup_benchmark_ioctl(unsigned int cmd,
 	int nr;
 	struct page **pages;
 
+	if (gup->size > ULONG_MAX)
+		return -EINVAL;
+
 	nr_pages = gup->size / PAGE_SIZE;
 	pages = kvcalloc(nr_pages, sizeof(void *), GFP_KERNEL);
 	if (!pages)
-- 
2.11.0
