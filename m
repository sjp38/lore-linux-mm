Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA234C31E5F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 17:22:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71EB92147A
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 17:22:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="XJUjnADz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71EB92147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22BED8E0005; Wed, 19 Jun 2019 13:22:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B88C8E0001; Wed, 19 Jun 2019 13:22:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 054C38E0005; Wed, 19 Jun 2019 13:22:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id DC2318E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 13:22:23 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id f22so268084ioj.9
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 10:22:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=E3jskMxg6mXOnAk1TRm40OOCGhyEHDf4Luejh67p06E=;
        b=Y7mh1mxsbGmfBd/NbSlXpJeaQx10nokmHQ+7zwYdp0/LsLKtrLz+4Z3EnKkTd/bI0C
         n77mlNmSuSuzZ3e1Scf2GupRnzGwAo2Gx4rVbSswOoMq69cfqLd3WZdllaqulKgEWFf5
         LFvm5S0adL+nRFr45+W/zErSDiVijf1AQ4ZLO+8s9QMEmvnFwpcE/Jw9qWALpihcKNw1
         XAYy8zsO6OummeywuvKBvdlG0EwWjWOd2h72BIP7TACtnBMv21O/E/qnxVkmUTiJztCW
         b04Y8jtit7J/daDaJi4qx9c8P3q6tgz+m+OlJeTKBfJ6AO+zOq0pCrt8Mqss3qX+P2Mn
         vdrg==
X-Gm-Message-State: APjAAAUemXD+lMFSwLXXByACKMdmc9jq+4YiQwNkZt5SLVN8lZMDl4mW
	XNdPQ5TvxGWQ7Q0bhbB8PSeKlYiGbbCUgDqNEyDV18dPxR3Xvx06TubsAkJT6Qph9VwhVcY9LJ3
	I1ASz4vBGiMD9xPqw05fFiPy91NhE+E2mSub/w9e7nzY+kgSkRCYK6MBFoxX+bNsTlQ==
X-Received: by 2002:a6b:f114:: with SMTP id e20mr9846262iog.169.1560964943487;
        Wed, 19 Jun 2019 10:22:23 -0700 (PDT)
X-Received: by 2002:a6b:f114:: with SMTP id e20mr9846220iog.169.1560964942908;
        Wed, 19 Jun 2019 10:22:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560964942; cv=none;
        d=google.com; s=arc-20160816;
        b=dPkZJOSFs/btjciO0ZHeY3l8I85+IUx18zAP8C7a887nBT4QChAQeNiVtQpWu3tpM2
         ipGC7XWw23hiBwcGPUuVHs3jew8Jb+CAAABos69EtlaOhO9hUfC9xlRrbSzKmKT4plVg
         lmLVJuj54RJbg5rXhiblBj+GAj8z4h9ZMnyn8OQq8u/ij/dl/hI3L4fA8kAGZUXGLhhN
         0DaY62uLW3q79YYVBANgbRuYwFOJkmwjJvxu6qx2R+RA6dcserl5XJVWUUEA7LTBtQm/
         x5ZEyHAbZiO9/UrDzEPaD5KIXJvo7W0Ev4awu2VnhcZ3vJjDPfSmRoxyIvYPOYF/2oFp
         q2Pg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=E3jskMxg6mXOnAk1TRm40OOCGhyEHDf4Luejh67p06E=;
        b=HHhUP0aHo0yh5oKGy7I5TGeTc4nbvq2BsRCf1wFbORwiTHDuQsowpX6yFN2Gwu0MEH
         M7tpPlemWqNCEKehAI7y+FIysgYiRZE4kqfKX44/OxKkBtm5JXBKmWXiYC6WNJsu/fCU
         20AfVvftLHYe8x+m/aAaSyLM5PBwIJ42IgTc5ywvwKY11oMZgD0XTpdV4NrEpsHXQ897
         TqnEJvboqxI/1rfGhTTGcg5meeUJIM7+Hqx52HsigpmUxBdOJFrKZWOrxUoxsT2B+ZXZ
         T31rpqdkK9EbqiKI+Ou0nVz+AnTH/fzrljsaLbSlhOnAbKxlQwKenrNHM+/yEARK0+JZ
         nm5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=XJUjnADz;
       spf=pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=zwisler@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i21sor21462597jan.8.2019.06.19.10.22.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 10:22:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=XJUjnADz;
       spf=pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=zwisler@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=E3jskMxg6mXOnAk1TRm40OOCGhyEHDf4Luejh67p06E=;
        b=XJUjnADzObWPEkqAra7JZG2MqVf6jOIl2xtoUl1SDnE0wuok4jfWhzqw1sqdOy1MdG
         ukIsu9ZRYZ7Odf66ee9EScvXI8+ziKIaEoU1vAYC/d16vXG5k7/dNvwAB5MjWlb1v9J5
         LJYYWKu+nb0iK/BWTUe5n9zeCPnxh/3JNBMQ4=
X-Google-Smtp-Source: APXvYqzUJ4kHlMB8oH2as8CG6GkE5UrM7Ov3FQ1gEUbkCnWiEbXHPUBrf42GwGzGyQpr2zjdPsDhvg==
X-Received: by 2002:a02:cd82:: with SMTP id l2mr11507623jap.96.1560964942675;
        Wed, 19 Jun 2019 10:22:22 -0700 (PDT)
Received: from localhost ([2620:15c:183:200:855f:8919:84a7:4794])
        by smtp.gmail.com with ESMTPSA id y17sm17889989ioa.40.2019.06.19.10.22.21
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 10:22:22 -0700 (PDT)
From: Ross Zwisler <zwisler@chromium.org>
X-Google-Original-From: Ross Zwisler <zwisler@google.com>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <zwisler@google.com>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Jan Kara <jack@suse.com>,
	linux-ext4@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Fletcher Woodruff <fletcherw@google.com>,
	Justin TerAvest <teravest@google.com>
Subject: [PATCH 1/3] mm: add filemap_fdatawait_range_keep_errors()
Date: Wed, 19 Jun 2019 11:21:54 -0600
Message-Id: <20190619172156.105508-2-zwisler@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
In-Reply-To: <20190619172156.105508-1-zwisler@google.com>
References: <20190619172156.105508-1-zwisler@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In the spirit of filemap_fdatawait_range() and
filemap_fdatawait_keep_errors(), introduce
filemap_fdatawait_range_keep_errors() which both takes a range upon
which to wait and does not clear errors from the address space.

Signed-off-by: Ross Zwisler <zwisler@google.com>
---
 include/linux/fs.h |  2 ++
 mm/filemap.c       | 22 ++++++++++++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index f7fdfe93e25d3..79fec8a8413f4 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2712,6 +2712,8 @@ extern int filemap_flush(struct address_space *);
 extern int filemap_fdatawait_keep_errors(struct address_space *mapping);
 extern int filemap_fdatawait_range(struct address_space *, loff_t lstart,
 				   loff_t lend);
+extern int filemap_fdatawait_range_keep_errors(struct address_space *mapping,
+		loff_t start_byte, loff_t end_byte);
 
 static inline int filemap_fdatawait(struct address_space *mapping)
 {
diff --git a/mm/filemap.c b/mm/filemap.c
index df2006ba0cfa5..e87252ca0835a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -553,6 +553,28 @@ int filemap_fdatawait_range(struct address_space *mapping, loff_t start_byte,
 }
 EXPORT_SYMBOL(filemap_fdatawait_range);
 
+/**
+ * filemap_fdatawait_range_keep_errors - wait for writeback to complete
+ * @mapping:		address space structure to wait for
+ * @start_byte:		offset in bytes where the range starts
+ * @end_byte:		offset in bytes where the range ends (inclusive)
+ *
+ * Walk the list of under-writeback pages of the given address space in the
+ * given range and wait for all of them.  Unlike filemap_fdatawait_range(),
+ * this function does not clear error status of the address space.
+ *
+ * Use this function if callers don't handle errors themselves.  Expected
+ * call sites are system-wide / filesystem-wide data flushers: e.g. sync(2),
+ * fsfreeze(8)
+ */
+int filemap_fdatawait_range_keep_errors(struct address_space *mapping,
+		loff_t start_byte, loff_t end_byte)
+{
+	__filemap_fdatawait_range(mapping, start_byte, end_byte);
+	return filemap_check_and_keep_errors(mapping);
+}
+EXPORT_SYMBOL(filemap_fdatawait_range_keep_errors);
+
 /**
  * file_fdatawait_range - wait for writeback to complete
  * @file:		file pointing to address space structure to wait for
-- 
2.22.0.410.gd8fdbe21b5-goog

