Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFB46C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 15:18:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 968E620675
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 15:18:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="Vgb6ZSxZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 968E620675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 358848E0003; Thu, 20 Jun 2019 11:18:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3312F8E0001; Thu, 20 Jun 2019 11:18:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 222DE8E0003; Thu, 20 Jun 2019 11:18:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id F11D68E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 11:18:52 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id u25so5621379iol.23
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 08:18:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LbaJcyWYnbCa5ezoro66saapuXs/2zff7F4rgt4jO/0=;
        b=XQXYkkbcz/Sr4PquS6+0ouT9qUplzlO1BnKa3KwkjtP1wQJyLGaoRtfIhLhhmbuB6i
         4WCMCyXv6xJSeFjCYXd+OA1fz3KtkdIA+YNNWzozMSrRZMIvG050y4OH8GWat01KBtkw
         AswTiammMjN5hoZGiCVwVqxX2h3ryuN5wgxwZOHsn7b5FdnI/GigesPY4JQSOxyqHVQK
         noPsgyd2iooL5zyhX43KKVqM+Jq05FAP56YhHnEKxTQE1V7/N82wvVWtbSYUTpTMPBAp
         NhXYH3XENUBeJUeOklxVN1Fvhjkofe96YDBcVZ72qcA8dEdWdGvSvkaoUr17M/+Qxiiz
         BCNQ==
X-Gm-Message-State: APjAAAU0imij2c4eL5zByIM+JIvfrOM4inm5CsQo5sbbQ1API9WaH6XR
	3wmVjY+bI7ecxj3jgN/gH3a9r52vz0ehojzIsfJ5SJ2AKFErfUzozOAxk9ntNYg3esq2Avuz3zF
	lVU0ZgtmB/XH5nZYsD/imI6zrumMPjZewQAe4O/Rr9c/QlXITlgPG5hHf+ykOCB43Qw==
X-Received: by 2002:a5e:a712:: with SMTP id b18mr19413092iod.220.1561043932711;
        Thu, 20 Jun 2019 08:18:52 -0700 (PDT)
X-Received: by 2002:a5e:a712:: with SMTP id b18mr19413046iod.220.1561043932079;
        Thu, 20 Jun 2019 08:18:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561043932; cv=none;
        d=google.com; s=arc-20160816;
        b=M1JLtrGD7CA6BQnP3TQl9I5b1LHlAfw8OcRzqJOrXYl201P4w3QWG0z1iT8+zbGsYI
         MhDqscm+InTPVkkaWUs+bo6jm+LD6Yw/vaojQYBwwx+9qdo9vAawwgY29RBcKEecs+Og
         d5lDvjSPhQTOIhj4pnfwNgziVh+FvSlQjS/tQb4ZAzSRhwxj02B81ezwcMVU7VPpRJek
         YEx47RvOeYE3i2WzfU0ERKUohM9QFeeyctGTVkSWFk1T1lRN4Vvj/+M2+pfFYlCCT0dt
         rRU2zB5WM9fTBlU83aDZhD4h6XdlETfJobz9PVW/cF0Xu0doTkdPAOnpF8gY68v8OSyV
         9IQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=LbaJcyWYnbCa5ezoro66saapuXs/2zff7F4rgt4jO/0=;
        b=Eh5SZDhnjKUV9of6pyFFRJH79qdLy+HARjWmvJVomefMJ0GQAE08HdA1ImX7Y1WGjG
         Uioq2iw96bfeDc25V6Yk6nTPgSYtSk1lzgdTlpbgWEmCuhUtRM8DWS0c2fRGDG1HMYFl
         UG7/x089IlyTRBPpq84tJFeSZeac6gMe38hDZHoY/OtFZ8kq9Q3eLQ/yBiMtmtM9jy8o
         MpVP49sQao6B1/D/1cxm6veM8apgJ5RyyzA2gMtdB+l3e/Otm8h3TNzOazCMHKW4uwfX
         e3SU7Km5mq7owOvbNCivqAbFZOmPj2nzNxA2YfXryiswv9AVsj4B9vewopC08o612/ua
         soNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Vgb6ZSxZ;
       spf=pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=zwisler@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s10sor17203136iol.79.2019.06.20.08.18.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 08:18:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Vgb6ZSxZ;
       spf=pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=zwisler@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=LbaJcyWYnbCa5ezoro66saapuXs/2zff7F4rgt4jO/0=;
        b=Vgb6ZSxZHxs/uF5rGy6wsIsWX1oNvwsVPTCFF0NCmLRH7xlP6b3yhvsiikpiDNYTsl
         fFr9zFv5G8yh1I0ISPt9HhTsz4g31G0pXdVQ66gHrsaLY66H8TVJlwYnY/EZ4IHox7rw
         WGi3kTBfRbg/0MwUa03341kI9jQ6Pm0dIf7m4=
X-Google-Smtp-Source: APXvYqzN4QF7VO7txjKK/zwdz7+tEgOtdahmqqRfrztYneRm16nQeJy7GrQuF3sgTYRsfdJ7IOKEpw==
X-Received: by 2002:a6b:bf01:: with SMTP id p1mr50911675iof.181.1561043931856;
        Thu, 20 Jun 2019 08:18:51 -0700 (PDT)
Received: from localhost ([2620:15c:183:200:855f:8919:84a7:4794])
        by smtp.gmail.com with ESMTPSA id l2sm108135ioh.20.2019.06.20.08.18.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 08:18:51 -0700 (PDT)
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
	Justin TerAvest <teravest@google.com>,
	Jan Kara <jack@suse.cz>,
	stable@vger.kernel.org
Subject: [PATCH v2 1/3] mm: add filemap_fdatawait_range_keep_errors()
Date: Thu, 20 Jun 2019 09:18:37 -0600
Message-Id: <20190620151839.195506-2-zwisler@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
In-Reply-To: <20190620151839.195506-1-zwisler@google.com>
References: <20190620151839.195506-1-zwisler@google.com>
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
Reviewed-by: Jan Kara <jack@suse.cz>
Cc: stable@vger.kernel.org
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

