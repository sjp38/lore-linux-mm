Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9B7AC10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:46:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F80920835
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:46:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZK2XXyQn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F80920835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20DAB6B0008; Wed, 17 Apr 2019 01:46:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BE246B0266; Wed, 17 Apr 2019 01:46:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0ACF56B0269; Wed, 17 Apr 2019 01:46:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id B351C6B0008
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:46:10 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id f67so1453333wme.3
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 22:46:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=8+vNdus7e6pYg9OnRGbCjVCBd8LPFBxVz8hY7lWMvBo=;
        b=LfX/Rci6xpaSjOzV/NZ4zAw4c7ETNq/yhFkU5Pn0herAR7A+W7zSYzjt+Mqawl/ugu
         QEI+YUO2IbRDpucMBLZbsfc9zQAS9jCGyNzlfPTpZStHMSPNuYtTwzMr9AGadl1KRR2R
         BF9v6X+NQKu5+hrLvZtOFqscOlpAFE5IUCkfW5tOVbwBDqISSmBH0olosAKTcq3xUjSd
         4QzCMMOXKGUGCzZ5T19lIRk7sjpqMEm04HtrCUakDbAoc9wB10TcBx5XNDJrKu+EO2D6
         kHt7/mPNJaER0t+zvIJEDKr6IVFQ8xRAvgvKFQqJlOXPixQNiye9tFwstQmufveQbGBk
         +pIw==
X-Gm-Message-State: APjAAAUgAay7PTr9tYP/Ie/4dk8vwZIXsHaay8RW9b5i1oKP3OedQSw2
	vr2Ba8y62o4Fe8N6KkEEW0LnOrVHgeMmbL3odyK4d3G3hBsjid6d15s+eB87NmdPz72o/1BPFgW
	gHsnT3HFL3FXcfzb06UMYXAf7E+jkygwPrhmyoNuRRrw9Fqmcf9DQTc+sdZ4gSCwVxg==
X-Received: by 2002:a7b:c14c:: with SMTP id z12mr28536398wmi.138.1555479970018;
        Tue, 16 Apr 2019 22:46:10 -0700 (PDT)
X-Received: by 2002:a7b:c14c:: with SMTP id z12mr28536333wmi.138.1555479968768;
        Tue, 16 Apr 2019 22:46:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555479968; cv=none;
        d=google.com; s=arc-20160816;
        b=XUBIMTNUXIanpBeRalM6WBftjyG13hO+iNtw6jRst5N3u3XXoPr911//Hjy5MGwTYj
         WbBx6lJAJneOa06o1DzsVih4rQaG1GCo59kS6supI8kboK3yXad7liTNn0DfDzq2tORC
         Xm9qMypLry7enpJZXFwVA4wFWJJuS4k3nocf9N+IFaXJKpe9Njt8FWmb4jgzcdceSxUE
         LvbGUx5MpBYWL01ydw6Rv9y9C+921x6qJb9LnE5AqgxKW3TLNwAFrWgfvfZQPoh6eIsl
         hjdx+f3XlSwqkE+HKc+i/mN09CLRS5ne4Ebt84uqQGqzP23KD8r+xcJwWJcdvQwKKy6w
         yMLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=8+vNdus7e6pYg9OnRGbCjVCBd8LPFBxVz8hY7lWMvBo=;
        b=f0pLB67LNhEbC/sMEXGz7KAV7br2J6rpqUQT/cLo3wYIbgYFmzQOUQ0lVA8BXsiXW5
         LH/DIAlYsoQqor8tQiyeGMZQxxt208ckaw1k9mQwqMDNA9nxssx2ClFcjFWBVJ8TTfm5
         TePWgWrrf3P+WITI+zN187ZAYpTFVwoLsfzlqOEt/EftDMlC7QqqHFWIChzx1TVAgdQx
         aoEuC5l79cPofa/LL+fyMOaXhY3Q5AqKrkBqFRZd2x3VTVFpwnK6aDVkg66s5F6UUowQ
         CC3tcEn4rjNyfl8m5o9T1jPoUmnr07prtJcZqdld7k3wDWKN8R3ZpDxJN7M1QfFXNDNA
         Tj5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZK2XXyQn;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a2sor38181520wrm.50.2019.04.16.22.46.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 22:46:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZK2XXyQn;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=8+vNdus7e6pYg9OnRGbCjVCBd8LPFBxVz8hY7lWMvBo=;
        b=ZK2XXyQnC09zgSaVvKYVKu1w7cBjOlt6XloEXtkqs4jJCTF3bjLaKw/6B6KbIXPpKm
         pnQ0UNfnp73OWusyBTUv+fxsLeppd4dA+dy3hj7+Y/vY1sXINGGqwgJrTUyP0Aj/XWEb
         uOzemRif+HKdTwGWnIMFOL3RGpTywmP0Rt89KHpsGrGsQSoIZyH2qCjKyCDk6pnTR2x0
         90WYfU1Fw9T0Z5Uk7hgEkGIwiUXh2MqtkP7HiwUeg5mGQScnXCbpXTt4MIT9km1dh9/O
         9qyM5naMA2rsPFITcFs6OoEl5oMEVtLlrWU+6bwZVY9kNPMNVcYchS1MBhdkWOBwN7az
         n2XQ==
X-Google-Smtp-Source: APXvYqx37nPMf4GZe7ysOs7dqeX9FFHTrnAkvjkd+KX9l72hqbBbfjELGzNgC58FLHwouVZN7QBWww==
X-Received: by 2002:adf:e443:: with SMTP id t3mr4041228wrm.257.1555479968232;
        Tue, 16 Apr 2019 22:46:08 -0700 (PDT)
Received: from localhost.localdomain ([5.102.238.208])
        by smtp.gmail.com with ESMTPSA id q24sm1247143wmj.26.2019.04.16.22.46.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 22:46:07 -0700 (PDT)
From: Amir Goldstein <amir73il@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH v4] fs/sync.c: sync_file_range(2) may use WB_SYNC_ALL writeback
Date: Wed, 17 Apr 2019 08:45:59 +0300
Message-Id: <20190417054559.29252-1-amir73il@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190409114922.30095-1-amir73il@gmail.com>
References: <20190409114922.30095-1-amir73il@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Commit 23d0127096cb ("fs/sync.c: make sync_file_range(2) use WB_SYNC_NONE
writeback") claims that sync_file_range(2) syscall was "created for
userspace to be able to issue background writeout and so waiting for
in-flight IO is undesirable there" and changes the writeback (back) to
WB_SYNC_NONE.

This claim is only partially true. It is true for users that use the flag
SYNC_FILE_RANGE_WRITE by itself, as does PostgreSQL, the user that was
the reason for changing to WB_SYNC_NONE writeback.

However, that claim is not true for users that use that flag combination
SYNC_FILE_RANGE_{WAIT_BEFORE|WRITE|_WAIT_AFTER}.
Those users explicitly requested to wait for in-flight IO as well as to
writeback of dirty pages.

Re-brand that flag combination as SYNC_FILE_RANGE_WRITE_AND_WAIT
and use the helper filemap_write_and_wait_range(), that uses WB_SYNC_ALL
writeback, to perform the full range sync request.

Link: http://lkml.kernel.org/r/20190409114922.30095-1-amir73il@gmail.com
Fixes: 23d0127096cb ("fs/sync.c: make sync_file_range(2) use WB_SYNC_NONE")
Signed-off-by: Amir Goldstein <amir73il@gmail.com>
Acked-by: Jan Kara <jack@suse.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
---

Andrew,

V2 of this patch is on your mmtotm queue.
However, I had already sent out V3 with a braino fix and Dave Chinner
just added more review comments which I had addressed in this version.

Thanks,
Amir.

Changes since v3:
- Remove unneeded change to VALID_FLAGS (Dave)
- Call file_fdatawait_range() before writeback (Dave)

Changes since v2:
- Return after filemap_write_and_wait_range()

Changes since v1:
- Remove non-guaranties of the API from commit message
- Added ACK by Jan

 fs/sync.c               | 20 +++++++++++++++-----
 include/uapi/linux/fs.h |  3 +++
 2 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/fs/sync.c b/fs/sync.c
index b54e0541ad89..1836328f1ae8 100644
--- a/fs/sync.c
+++ b/fs/sync.c
@@ -235,9 +235,9 @@ SYSCALL_DEFINE1(fdatasync, unsigned int, fd)
 }
 
 /*
- * sys_sync_file_range() permits finely controlled syncing over a segment of
+ * ksys_sync_file_range() permits finely controlled syncing over a segment of
  * a file in the range offset .. (offset+nbytes-1) inclusive.  If nbytes is
- * zero then sys_sync_file_range() will operate from offset out to EOF.
+ * zero then ksys_sync_file_range() will operate from offset out to EOF.
  *
  * The flag bits are:
  *
@@ -254,7 +254,7 @@ SYSCALL_DEFINE1(fdatasync, unsigned int, fd)
  * Useful combinations of the flag bits are:
  *
  * SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE: ensures that all pages
- * in the range which were dirty on entry to sys_sync_file_range() are placed
+ * in the range which were dirty on entry to ksys_sync_file_range() are placed
  * under writeout.  This is a start-write-for-data-integrity operation.
  *
  * SYNC_FILE_RANGE_WRITE: start writeout of all dirty pages in the range which
@@ -266,10 +266,13 @@ SYSCALL_DEFINE1(fdatasync, unsigned int, fd)
  * earlier SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE operation to wait
  * for that operation to complete and to return the result.
  *
- * SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE|SYNC_FILE_RANGE_WAIT_AFTER:
+ * SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE|SYNC_FILE_RANGE_WAIT_AFTER
+ * (a.k.a. SYNC_FILE_RANGE_WRITE_AND_WAIT):
  * a traditional sync() operation.  This is a write-for-data-integrity operation
  * which will ensure that all pages in the range which were dirty on entry to
- * sys_sync_file_range() are committed to disk.
+ * ksys_sync_file_range() are written to disk.  It should be noted that disk
+ * caches are not flushed by this call, so there are no guarantees here that the
+ * data will be available on disk after a crash.
  *
  *
  * SYNC_FILE_RANGE_WAIT_BEFORE and SYNC_FILE_RANGE_WAIT_AFTER will detect any
@@ -344,6 +347,13 @@ int ksys_sync_file_range(int fd, loff_t offset, loff_t nbytes,
 			goto out_put;
 	}
 
+	if ((flags & SYNC_FILE_RANGE_WRITE_AND_WAIT) ==
+		     SYNC_FILE_RANGE_WRITE_AND_WAIT) {
+		/* Unlike SYNC_FILE_RANGE_WRITE alone, uses WB_SYNC_ALL */
+		ret = filemap_write_and_wait_range(mapping, offset, endbyte);
+		goto out_put;
+	}
+
 	if (flags & SYNC_FILE_RANGE_WRITE) {
 		ret = __filemap_fdatawrite_range(mapping, offset, endbyte,
 						 WB_SYNC_NONE);
diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
index 121e82ce296b..59c71fa8c553 100644
--- a/include/uapi/linux/fs.h
+++ b/include/uapi/linux/fs.h
@@ -320,6 +320,9 @@ struct fscrypt_key {
 #define SYNC_FILE_RANGE_WAIT_BEFORE	1
 #define SYNC_FILE_RANGE_WRITE		2
 #define SYNC_FILE_RANGE_WAIT_AFTER	4
+#define SYNC_FILE_RANGE_WRITE_AND_WAIT	(SYNC_FILE_RANGE_WRITE | \
+					 SYNC_FILE_RANGE_WAIT_BEFORE | \
+					 SYNC_FILE_RANGE_WAIT_AFTER)
 
 /*
  * Flags for preadv2/pwritev2:
-- 
2.17.1

