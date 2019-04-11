Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67977C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:09:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1631E20850
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:09:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1631E20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F1216B0275; Thu, 11 Apr 2019 17:09:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3502D6B0276; Thu, 11 Apr 2019 17:09:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F3536B0277; Thu, 11 Apr 2019 17:09:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E76F66B0275
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 17:09:11 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id 54so6851405qtn.15
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:09:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pOHrPGofh06pHg03iJfHjp0gBDMwrqOeVJMCGyWT4ew=;
        b=H5uh1VVneThd4iw/scayMZqASK2kXVqLbjzcyhrJqY+8Xwg9Em/GoeDEIlDZHNwl+1
         YAwdicleauXL4XvKT/hfk9EkVLUo6Fr5oVjS4pAWUiJlOzoKF70IbQFCE79JEpicRKkK
         Y6BEcmEUlJSInjG4KnnCa2/EhTCV0jzOoFK+HvWR+iKgSb1CkuuyARTtSNQGGzkODwdH
         QyflXvAYUjL8E0ywqHfLjefPMSDpBkoW0g2pJR2/FJKYu24GR67OOw3ZaKlAVa5TstiI
         P7+4lwCWiqHz1hu3N3Z6/3fdTxw/V/YzCEOo0vYKItzn279YiEO6Sqs8HJh4ZmSK/D8Y
         G+1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX8x5TTW4VyVxC8fEApbxGAgGbfZbxHRoF9ZQYh4PDGVSlr919o
	UUza/kKUbj0xbmw1Ij/GjnmS0+y88MS4msKXc7THD+FPw4SMdespvPaw9kkcCWcg8zXuNDYDyut
	qgmA7hNzuqO0gIU/u3VCOIGDf0+ZcMOhIM8XUa+hOyVkXl+cFUf/rEH1FNwICLNZVxA==
X-Received: by 2002:ac8:2acc:: with SMTP id c12mr41564587qta.108.1555016951671;
        Thu, 11 Apr 2019 14:09:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3JVgSfbPhDTpqOPZhJGGWDjJtPrUaYffAxEEdTDZF2m2rsI+pCMFx9NY2zYuy54EEkPA6
X-Received: by 2002:ac8:2acc:: with SMTP id c12mr41564496qta.108.1555016950441;
        Thu, 11 Apr 2019 14:09:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555016950; cv=none;
        d=google.com; s=arc-20160816;
        b=PiMp1Edq3aixLo6FwlYxao84hhuhPnTHY62nCwRrdDWz8FF1vHUXji+3oevJev5lOh
         SPL5WiZaPoZ9bm9MvGA3AfDXoepCQkxEg5wp7wgKgJrAmh0DvJQgAiwUo55NwDJREcQO
         6IoGuKGpmS7vjq8lyshKvDd6w06zEMddSiupPaQP3i/WiptS9GJhf5SIl1ip2S5Z7Hnz
         RtAQUp3iXqcWIUviqeLzGRLSj+o6AfvxcDNYngCyWsANgDXhQH2MMoiBmjiC4viCb+9z
         AVMeo4Zl02HjtGxPReAZ+YazwJRHYKNzTpOBaRNP8XrEgJ/sK1tBS9OgqIUpqncRBUQZ
         Ppmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=pOHrPGofh06pHg03iJfHjp0gBDMwrqOeVJMCGyWT4ew=;
        b=y/yOXt/MsAj1/XXshKzveh19pLMWbstx+4bHGIlFgEQllPpicxsSdQQrdwUzkl8fty
         2yW6Bi3fKSRB66a4tc8tddkOsoG8u/UnrcH2U36CqqaADsfe5G3KpwscwCYE/kWSAdt4
         nnVj3gSPDB0nQyiRT9sp4+MlgraXWq9OossxlpYEDEl1ofgXZlShoCairW233Rl0dapA
         oxN8M+azMwgi5TFXNah5EjdWiZif+IrrASUX9ymMGVXbQnxNVyneV0HkbEaq9TEgjTEi
         GpjWpvLCRyRhuPhnRi8e1ISG/DJCZfjzaIdM0iAW3Z8Af53avwx+CQJRGxL3AlEAGmbs
         jhEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m40si13200134qtf.215.2019.04.11.14.09.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 14:09:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8B72723E6C5;
	Thu, 11 Apr 2019 21:09:09 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E84B35C220;
	Thu, 11 Apr 2019 21:09:07 +0000 (UTC)
From: jglisse@redhat.com
To: linux-kernel@vger.kernel.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org,
	linux-mm@kvack.org,
	John Hubbard <jhubbard@nvidia.com>,
	Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <axboe@kernel.dk>,
	Ming Lei <ming.lei@redhat.com>,
	Dave Chinner <david@fromorbit.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	=?UTF-8?q?Ernesto=20A=20=2E=20Fern=C3=A1ndez?= <ernesto.mnd.fernandez@gmail.com>,
	Jeff Moyer <jmoyer@redhat.com>
Subject: [PATCH v1 12/15] fs/direct-io: keep track of wether a page is coming from GUP or not
Date: Thu, 11 Apr 2019 17:08:31 -0400
Message-Id: <20190411210834.4105-13-jglisse@redhat.com>
In-Reply-To: <20190411210834.4105-1-jglisse@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 11 Apr 2019 21:09:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

We want to keep track of how we got a reference on page when doing DIO,
ie wether the page was reference through GUP (get_user_page*) or not.
For that this patch rework the way page reference is taken and handed
over between DIO code and BIO. Instead of taking a reference for page
that have been successfuly added to a BIO we just steal the reference
we have when we lookup the page (either through GUP or for ZERO_PAGE).

So this patch keep track of wether the reference has been stolen by the
BIO or not. This avoids a bunch of get_page()/put_page() so this limit
the number of atomic operations.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-block@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Johannes Thumshirn <jthumshirn@suse.de>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Ming Lei <ming.lei@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Ernesto A. Fernández <ernesto.mnd.fernandez@gmail.com>
Cc: Jeff Moyer <jmoyer@redhat.com>
---
 fs/direct-io.c | 82 ++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 60 insertions(+), 22 deletions(-)

diff --git a/fs/direct-io.c b/fs/direct-io.c
index b8b5d8e31aeb..ef9fc7703a78 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -100,6 +100,7 @@ struct dio_submit {
 	unsigned cur_page_len;		/* Nr of bytes at cur_page_offset */
 	sector_t cur_page_block;	/* Where it starts */
 	loff_t cur_page_fs_offset;	/* Offset in file */
+	bool cur_page_from_gup;		/* Current page is coming from GUP */
 
 	struct iov_iter *iter;
 	/*
@@ -148,6 +149,8 @@ struct dio {
 		struct page *pages[DIO_PAGES];	/* page buffer */
 		struct work_struct complete_work;/* deferred AIO completion */
 	};
+
+	bool gup;			/* pages are coming from GUP */
 } ____cacheline_aligned_in_smp;
 
 static struct kmem_cache *dio_cache __read_mostly;
@@ -167,6 +170,7 @@ static inline int dio_refill_pages(struct dio *dio, struct dio_submit *sdio)
 {
 	ssize_t ret;
 
+	dio->gup = iov_iter_get_pages_use_gup(sdio->iter);
 	ret = iov_iter_get_pages(sdio->iter, dio->pages, LONG_MAX, DIO_PAGES,
 				&sdio->from);
 
@@ -181,6 +185,7 @@ static inline int dio_refill_pages(struct dio *dio, struct dio_submit *sdio)
 			dio->page_errors = ret;
 		get_page(page);
 		dio->pages[0] = page;
+		dio->gup = false;
 		sdio->head = 0;
 		sdio->tail = 1;
 		sdio->from = 0;
@@ -490,8 +495,12 @@ static inline void dio_bio_submit(struct dio *dio, struct dio_submit *sdio)
  */
 static inline void dio_cleanup(struct dio *dio, struct dio_submit *sdio)
 {
-	while (sdio->head < sdio->tail)
-		put_page(dio->pages[sdio->head++]);
+	while (sdio->head < sdio->tail) {
+		if (dio->gup)
+			put_user_page(dio->pages[sdio->head++]);
+		else
+			put_page(dio->pages[sdio->head++]);
+	}
 }
 
 /*
@@ -760,15 +769,19 @@ static inline int dio_bio_add_page(struct dio_submit *sdio)
 {
 	int ret;
 
-	ret = bio_add_page(sdio->bio, sdio->cur_page,
-			sdio->cur_page_len, sdio->cur_page_offset, false);
+	/*
+	 * The bio is stealing the page reference and that is fine we can add a
+	 * page only once ie when dio_send_cur_page() is call and each call to
+	 * dio_send_cur_page() clear the cur_page (on success).
+	 */
+	ret = bio_add_page(sdio->bio, sdio->cur_page, sdio->cur_page_len,
+			 sdio->cur_page_offset, sdio->cur_page_from_gup);
 	if (ret == sdio->cur_page_len) {
 		/*
 		 * Decrement count only, if we are done with this page
 		 */
 		if ((sdio->cur_page_len + sdio->cur_page_offset) == PAGE_SIZE)
 			sdio->pages_in_io--;
-		get_page(sdio->cur_page);
 		sdio->final_block_in_bio = sdio->cur_page_block +
 			(sdio->cur_page_len >> sdio->blkbits);
 		ret = 0;
@@ -828,9 +841,14 @@ static inline int dio_send_cur_page(struct dio *dio, struct dio_submit *sdio,
 		ret = dio_new_bio(dio, sdio, sdio->cur_page_block, map_bh);
 		if (ret == 0) {
 			ret = dio_bio_add_page(sdio);
+			if (!ret)
+				/* Clear the current page. */
+				sdio->cur_page = NULL;
 			BUG_ON(ret != 0);
 		}
-	}
+	} else
+		/* Clear the current page. */
+		sdio->cur_page = NULL;
 out:
 	return ret;
 }
@@ -855,7 +873,7 @@ static inline int dio_send_cur_page(struct dio *dio, struct dio_submit *sdio,
 static inline int
 submit_page_section(struct dio *dio, struct dio_submit *sdio, struct page *page,
 		    unsigned offset, unsigned len, sector_t blocknr,
-		    struct buffer_head *map_bh)
+		    struct buffer_head *map_bh, bool gup)
 {
 	int ret = 0;
 
@@ -882,14 +900,13 @@ submit_page_section(struct dio *dio, struct dio_submit *sdio, struct page *page,
 	 */
 	if (sdio->cur_page) {
 		ret = dio_send_cur_page(dio, sdio, map_bh);
-		put_page(sdio->cur_page);
-		sdio->cur_page = NULL;
 		if (ret)
 			return ret;
 	}
 
-	get_page(page);		/* It is in dio */
+	/* Steal page reference and GUP flag */
 	sdio->cur_page = page;
+	sdio->cur_page_from_gup = gup;
 	sdio->cur_page_offset = offset;
 	sdio->cur_page_len = len;
 	sdio->cur_page_block = blocknr;
@@ -903,8 +920,6 @@ submit_page_section(struct dio *dio, struct dio_submit *sdio, struct page *page,
 		ret = dio_send_cur_page(dio, sdio, map_bh);
 		if (sdio->bio)
 			dio_bio_submit(dio, sdio);
-		put_page(sdio->cur_page);
-		sdio->cur_page = NULL;
 	}
 	return ret;
 }
@@ -946,13 +961,29 @@ static inline void dio_zero_block(struct dio *dio, struct dio_submit *sdio,
 	this_chunk_bytes = this_chunk_blocks << sdio->blkbits;
 
 	page = ZERO_PAGE(0);
+	get_page(page);
 	if (submit_page_section(dio, sdio, page, 0, this_chunk_bytes,
-				sdio->next_block_for_io, map_bh))
+				sdio->next_block_for_io, map_bh, false)) {
+		put_page(page);
 		return;
+	}
 
 	sdio->next_block_for_io += this_chunk_blocks;
 }
 
+static inline void dio_put_page(const struct dio *dio, bool stolen,
+				struct page *page)
+{
+	/* If page reference was stolen then nothing to do. */
+	if (stolen)
+		return;
+
+	if (dio->gup)
+		put_user_page(page);
+	else
+		put_page(page);
+}
+
 /*
  * Walk the user pages, and the file, mapping blocks to disk and generating
  * a sequence of (page,offset,len,block) mappings.  These mappings are injected
@@ -977,6 +1008,7 @@ static int do_direct_IO(struct dio *dio, struct dio_submit *sdio,
 	int ret = 0;
 
 	while (sdio->block_in_file < sdio->final_block_in_request) {
+		bool stolen = false;
 		struct page *page;
 		size_t from, to;
 
@@ -1003,7 +1035,7 @@ static int do_direct_IO(struct dio *dio, struct dio_submit *sdio,
 
 				ret = get_more_blocks(dio, sdio, map_bh);
 				if (ret) {
-					put_page(page);
+					dio_put_page(dio, stolen, page);
 					goto out;
 				}
 				if (!buffer_mapped(map_bh))
@@ -1048,7 +1080,7 @@ static int do_direct_IO(struct dio *dio, struct dio_submit *sdio,
 
 				/* AKPM: eargh, -ENOTBLK is a hack */
 				if (dio->op == REQ_OP_WRITE) {
-					put_page(page);
+					dio_put_page(dio, stolen, page);
 					return -ENOTBLK;
 				}
 
@@ -1061,7 +1093,7 @@ static int do_direct_IO(struct dio *dio, struct dio_submit *sdio,
 				if (sdio->block_in_file >=
 						i_size_aligned >> blkbits) {
 					/* We hit eof */
-					put_page(page);
+					dio_put_page(dio, stolen, page);
 					goto out;
 				}
 				zero_user(page, from, 1 << blkbits);
@@ -1099,11 +1131,13 @@ static int do_direct_IO(struct dio *dio, struct dio_submit *sdio,
 						  from,
 						  this_chunk_bytes,
 						  sdio->next_block_for_io,
-						  map_bh);
+						  map_bh, dio->gup);
 			if (ret) {
-				put_page(page);
+				dio_put_page(dio, stolen, page);
 				goto out;
-			}
+			} else
+				/* The page reference has been  stolen ... */
+				stolen = true;
 			sdio->next_block_for_io += this_chunk_blocks;
 
 			sdio->block_in_file += this_chunk_blocks;
@@ -1117,7 +1151,7 @@ static int do_direct_IO(struct dio *dio, struct dio_submit *sdio,
 		}
 
 		/* Drop the ref which was taken in get_user_pages() */
-		put_page(page);
+		dio_put_page(dio, stolen, page);
 	}
 out:
 	return ret;
@@ -1356,8 +1390,12 @@ do_blockdev_direct_IO(struct kiocb *iocb, struct inode *inode,
 		ret2 = dio_send_cur_page(dio, &sdio, &map_bh);
 		if (retval == 0)
 			retval = ret2;
-		put_page(sdio.cur_page);
-		sdio.cur_page = NULL;
+		else {
+			if (sdio.cur_page_from_gup)
+				put_user_page(sdio.cur_page);
+			else
+				put_page(sdio.cur_page);
+		}
 	}
 	if (sdio.bio)
 		dio_bio_submit(dio, &sdio);
-- 
2.20.1

