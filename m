Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B775DC31E5B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 17:22:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81B7A2084E
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 17:22:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="WPhIzrHu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81B7A2084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 205798E0007; Wed, 19 Jun 2019 13:22:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DE308E0001; Wed, 19 Jun 2019 13:22:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 080ED8E0007; Wed, 19 Jun 2019 13:22:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id DE5428E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 13:22:26 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id h3so229212iob.20
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 10:22:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PDc3/t6pQgXRlrbpZdKVEwq+X2f/5QLw6zNH6ghEEMo=;
        b=uDyE8YoKnHArASlLYeYHn04RQZj9FKYThXidrt3iBPSid/Oypoi3qUAzO4Ffkot9I/
         QTDMl3kF46AaNyRHeTvsC6oG+uZLuB0d2uwFwfh2YOz/8j133zT21JGy8RuA/V6UPJcT
         BfmoSzMOYojXKWWjzVyQlCHf/OAIkvBnsbVTsnCsntAFDjdngsicV/vt6l26mvGRQds5
         Mf+RNpzSOhLvrsPl2FRNkt3CMsR8qJ6kSVLuAhj4QorOjAt9S3nY3OXVuCzOyjewRJo3
         QvlDwN6jrF8il//6vhW63LfEo24ponsPUOmfyBpas4s6jWvfKyUrHM7gooOVsceFh85y
         96FQ==
X-Gm-Message-State: APjAAAVQAF6e0yxjU1pquNNsbEAyAn9ME/5/dKbnDMufVIKNJrSp/Jf6
	J3qvZZdGfHkTJL9Ks7Z3F2Y2RqavbgaNHBcUITnL/uDEBPNYwWemBg9iUrsQaVasZRp4dW5m/QP
	2P7hKG7hWOZ33apZ5lTIWXzIjIySbq8ppbJ9fwfCzqiGMSpFVJQZdiDAERTSmfg5sJA==
X-Received: by 2002:a6b:6f0e:: with SMTP id k14mr10628225ioc.257.1560964946593;
        Wed, 19 Jun 2019 10:22:26 -0700 (PDT)
X-Received: by 2002:a6b:6f0e:: with SMTP id k14mr10628183ioc.257.1560964946002;
        Wed, 19 Jun 2019 10:22:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560964945; cv=none;
        d=google.com; s=arc-20160816;
        b=S/6WEWblRHU0eYq8u15Z+KMbiElNBrNVSv7RqIyVUpg48zyCNVNqJZYvfNYTkmUI0n
         LBW2CjgpQFP4rTpmXYQYXWxb3uYdCqtuiXXBCLENnzTIkxJ3zntAViqZh++Y8K5jSyJb
         kSINcTCd1DRr8xJs5hQLENbIhKDp4kubKtn5ERcNpTvgZZ4J/TUnF/Vymr3iUs2My9DQ
         bkGQxXGyAyf1/Leo+wXc+u7WUcoDiMi3Yjnn0EK7/m/cuuvWl4KoQoyRTTrrKZS0R2YQ
         HI5YzVWqArX9reOZeTFg13PHVF+ERDvOCUIj2c1cf0vb5YT2kIHZ9XYN9lYrrVcM3C/r
         yluA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=PDc3/t6pQgXRlrbpZdKVEwq+X2f/5QLw6zNH6ghEEMo=;
        b=prHViu3mLc+p5r6k7E4+1o+H/h8i8E7tzP8iMH5QNcjUT0lDMhtNvYzUKYw2YdBzFn
         wzlCidgOpvKi0Vz+eXuM2Ldst3WwXi92CWQ95bvV7qyQwhw9RlxrxNTDvDMA2Ocv1FBz
         tyzac4jtDAHrnhY20gi8UboV8m855by7OPMk56N8hLIlFi6Xt/CD6jZOl/ghLKtwEqYV
         vY9AZbPll+FHUWcoBas4JVX23zmeWhsN5ukYTCuweUmdhcfmJuIeLtC6hvpwQ0WJorgs
         F/KtYanx/TIbC85Apej8lRYIkoOmcjKYQjiBO6tVBDzCVXJC1oCfLU29DEHieV3r/Bss
         rGaw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=WPhIzrHu;
       spf=pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=zwisler@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q9sor14478711iog.65.2019.06.19.10.22.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 10:22:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=WPhIzrHu;
       spf=pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=zwisler@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=PDc3/t6pQgXRlrbpZdKVEwq+X2f/5QLw6zNH6ghEEMo=;
        b=WPhIzrHu8MmV20787TkEtOfYm8/d2xp1ifATc3YV0/Rsg0RGf7SNVNtMk1uBr3yM3O
         ZzONv6mp3+uKgsCWGg7j7qWkPxVOAYs+9VPxean7qbw9ydspDA8iJKMeRoICmmyuPYCL
         Gs68n8T05do8PZDva2U27cwXM3i99K4Y387kg=
X-Google-Smtp-Source: APXvYqyww/nXaKClg6oe4jKe1+QWUCyNtR9Nkjre2Tn+D5wwr4oCZC/khTMy8wbQr3InQ0out2BhWw==
X-Received: by 2002:a6b:cf17:: with SMTP id o23mr3506984ioa.176.1560964945770;
        Wed, 19 Jun 2019 10:22:25 -0700 (PDT)
Received: from localhost ([2620:15c:183:200:855f:8919:84a7:4794])
        by smtp.gmail.com with ESMTPSA id u26sm22681456iol.1.2019.06.19.10.22.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 10:22:25 -0700 (PDT)
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
Subject: [PATCH 3/3] ext4: use jbd2_inode dirty range scoping
Date: Wed, 19 Jun 2019 11:21:56 -0600
Message-Id: <20190619172156.105508-4-zwisler@google.com>
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

Use the newly introduced jbd2_inode dirty range scoping to prevent us
from waiting forever when trying to complete a journal transaction.

Signed-off-by: Ross Zwisler <zwisler@google.com>
---
 fs/ext4/ext4_jbd2.h   | 12 ++++++------
 fs/ext4/inode.c       | 13 ++++++++++---
 fs/ext4/move_extent.c |  3 ++-
 3 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/fs/ext4/ext4_jbd2.h b/fs/ext4/ext4_jbd2.h
index 75a5309f22315..ef8fcf7d0d3b3 100644
--- a/fs/ext4/ext4_jbd2.h
+++ b/fs/ext4/ext4_jbd2.h
@@ -361,20 +361,20 @@ static inline int ext4_journal_force_commit(journal_t *journal)
 }
 
 static inline int ext4_jbd2_inode_add_write(handle_t *handle,
-					    struct inode *inode)
+		struct inode *inode, loff_t start_byte, loff_t length)
 {
 	if (ext4_handle_valid(handle))
-		return jbd2_journal_inode_add_write(handle,
-						    EXT4_I(inode)->jinode);
+		return jbd2_journal_inode_ranged_write(handle,
+				EXT4_I(inode)->jinode, start_byte, length);
 	return 0;
 }
 
 static inline int ext4_jbd2_inode_add_wait(handle_t *handle,
-					   struct inode *inode)
+		struct inode *inode, loff_t start_byte, loff_t length)
 {
 	if (ext4_handle_valid(handle))
-		return jbd2_journal_inode_add_wait(handle,
-						   EXT4_I(inode)->jinode);
+		return jbd2_journal_inode_ranged_wait(handle,
+				EXT4_I(inode)->jinode, start_byte, length);
 	return 0;
 }
 
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index c7f77c6430085..27fec5c594459 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -731,10 +731,16 @@ int ext4_map_blocks(handle_t *handle, struct inode *inode,
 		    !(flags & EXT4_GET_BLOCKS_ZERO) &&
 		    !ext4_is_quota_file(inode) &&
 		    ext4_should_order_data(inode)) {
+			loff_t start_byte =
+				(loff_t)map->m_lblk << inode->i_blkbits;
+			loff_t length = (loff_t)map->m_len << inode->i_blkbits;
+
 			if (flags & EXT4_GET_BLOCKS_IO_SUBMIT)
-				ret = ext4_jbd2_inode_add_wait(handle, inode);
+				ret = ext4_jbd2_inode_add_wait(handle, inode,
+						start_byte, length);
 			else
-				ret = ext4_jbd2_inode_add_write(handle, inode);
+				ret = ext4_jbd2_inode_add_write(handle, inode,
+						start_byte, length);
 			if (ret)
 				return ret;
 		}
@@ -4085,7 +4091,8 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 		err = 0;
 		mark_buffer_dirty(bh);
 		if (ext4_should_order_data(inode))
-			err = ext4_jbd2_inode_add_write(handle, inode);
+			err = ext4_jbd2_inode_add_write(handle, inode, from,
+					length);
 	}
 
 unlock:
diff --git a/fs/ext4/move_extent.c b/fs/ext4/move_extent.c
index 1083a9f3f16a1..c7ded4e2adff5 100644
--- a/fs/ext4/move_extent.c
+++ b/fs/ext4/move_extent.c
@@ -390,7 +390,8 @@ move_extent_per_page(struct file *o_filp, struct inode *donor_inode,
 
 	/* Even in case of data=writeback it is reasonable to pin
 	 * inode to transaction, to prevent unexpected data loss */
-	*err = ext4_jbd2_inode_add_write(handle, orig_inode);
+	*err = ext4_jbd2_inode_add_write(handle, orig_inode,
+			(loff_t)orig_page_offset << PAGE_SHIFT, replaced_size);
 
 unlock_pages:
 	unlock_page(pagep[0]);
-- 
2.22.0.410.gd8fdbe21b5-goog

