Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 98B596B003B
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 06:11:27 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id gi9so9576477lab.0
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 03:11:26 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id kx4si2282044lac.8.2014.09.03.03.11.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Sep 2014 03:11:26 -0700 (PDT)
Subject: [PATCH 2/2] fuse: fuse_get_user_pages(): do not pack more data than
 requested
From: Maxim Patlasov <MPatlasov@parallels.com>
Date: Wed, 03 Sep 2014 14:11:21 +0400
Message-ID: <20140903101109.23218.60234.stgit@localhost.localdomain>
In-Reply-To: <20140903100826.23218.95122.stgit@localhost.localdomain>
References: <20140903100826.23218.95122.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk
Cc: miklos@szeredi.hu, fuse-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, werner.baumann@onlinehome.de

The patch fixes a bug introduced by commit c9c37e2e6378 ("fuse: switch to
iov_iter_get_pages()"):

The third argument of fuse_get_user_pages() "nbytesp" refers to the number of
bytes a caller asked to pack into fuse request. This value may be lesser
than capacity of fuse request or iov_iter. So fuse_get_user_pages() must
ensure that *nbytesp won't grow. Before that commit, it was ensured by:

>		ret = get_user_pages_fast(user_addr, npages, !write,
>					  &req->pages[req->num_pages]);
>		...
>		npages = ret;
>		frag_size = min_t(size_t, frag_size,
>				  (npages << PAGE_SHIFT) - offset);

Now, when helper iov_iter_get_pages() performs all hard work of extracting
pages from iov_iter, it can be done by passing properly calculated "maxsize"
to the helper.

Reported-by: Werner Baumann <werner.baumann@onlinehome.de>
Signed-off-by: Maxim Patlasov <mpatlasov@parallels.com>
---
 fs/fuse/file.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 40ac262..1d2bb70 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1303,10 +1303,15 @@ static int fuse_get_user_pages(struct fuse_req *req, struct iov_iter *ii,
 	while (nbytes < *nbytesp && req->num_pages < req->max_pages) {
 		unsigned npages;
 		size_t start;
+		ssize_t ret;
 		unsigned n = req->max_pages - req->num_pages;
-		ssize_t ret = iov_iter_get_pages(ii,
-					&req->pages[req->num_pages],
-					n * PAGE_SIZE, &start);
+		size_t frag_size = fuse_get_frag_size(ii, *nbytesp - nbytes);
+
+		frag_size = min_t(size_t, frag_size, n << PAGE_SHIFT);
+
+		ret = iov_iter_get_pages(ii,
+				&req->pages[req->num_pages],
+				frag_size, &start);
 		if (ret < 0)
 			return ret;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
