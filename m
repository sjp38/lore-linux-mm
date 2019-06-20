Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C5AFC48BE3
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 15:18:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC13520675
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 15:18:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="E18fnBvQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC13520675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 554338E0006; Thu, 20 Jun 2019 11:18:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 508778E0005; Thu, 20 Jun 2019 11:18:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37E718E0006; Thu, 20 Jun 2019 11:18:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 190508E0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 11:18:56 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id n4so5741245ioc.0
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 08:18:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8qPSgW/MPmMfMRbYOSrZE2Wb0C0QAL6xUVu8BnMULPU=;
        b=RddU6aWC95odzwH0SUiqSLtG4AsKWQU0UUYQOCyM1cDKbu3fTphEnl0wXVpypPENbG
         GlwDgekEqv63IOiIwGbHogP9zYcBS0nlYL2etZSjSPHAvxxIBPUAC8ssDVLZtbqg6koN
         0MHEUeoo7jxf9qJ0lA8nVKEegXv/6QtqUYIRytGulnLYcrcHJUForv21fY7W+RC3Piht
         mXpnG3GnKhXWo4Rlu7HXw1MgmPQi1oQzj8LKhJcltIcgb2I59jcXTbq4DIqnT8kNfyXk
         gU5BzeNEX+/Y8jvVx7IxX/d8c4Fl+xGP0TdJ7sYlZrtfjTk/lEN9SCV6aQo5miWcPXrQ
         aY6Q==
X-Gm-Message-State: APjAAAXOMD6tihxGH3tamilAoITG7+SdRdrWuzUIc7uknfzCBufrKBJZ
	CwV7AP1XflZvwIVJ+n60CLnIQXvEHFfam5uxxqigRyc9W3n07o/rGb8/3dcInrXh8L3rMcsReA6
	lu6zwuMuVitlrGdN/1JooEO51AKKImsYJFQSN6wDKXEjFfqtniAi7gE/niTAhuKE8dg==
X-Received: by 2002:a02:5502:: with SMTP id e2mr18433963jab.87.1561043935803;
        Thu, 20 Jun 2019 08:18:55 -0700 (PDT)
X-Received: by 2002:a02:5502:: with SMTP id e2mr18433910jab.87.1561043935129;
        Thu, 20 Jun 2019 08:18:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561043935; cv=none;
        d=google.com; s=arc-20160816;
        b=Spo6WgrxhVem3MFCpBsSDI8X8+lcHKMkQWa39kB312gCZ3BgzLpE6iAAmglQGVHLZ+
         hXZ5AA+ktgPR/JE3tzP6LKKLdhHaNItoY5N2Zy9LuBAJf1yXzLJgwOTRNaWykDg7l89j
         Bh9RX/z+6mpjd+1ea8/N7vo8H7aTY9W9hdG1kkOlq221EbsdA0FHxwTIOj2+VdPPU/nD
         kEckwW7PM7zHZMkZuPF5oZ66nzWKzIpL1JZESlYUAGeMGP5SBG/XDk0o0LHGDTKzTKXy
         5U6B5crHz/EyAzhlZSu3uQxpqHW5zBh8mkAtnO7B5SJR58EOSz60S4mLxdqYL7WwhPNd
         CaYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=8qPSgW/MPmMfMRbYOSrZE2Wb0C0QAL6xUVu8BnMULPU=;
        b=BT/kwSpJfPmQOlcjnC0yVY1wUN9fha6FECjH+aJPmF8ZhnxTUbLLNkX4w+lQCMFtE5
         MOTQIWw64cvXuzw+L2jWnjbTPZmywVhAtbupJ6foc+frKLNqKFuMrc86QTNQSa2erCI2
         S387HVzibNAcqxpJHvf69JflljSaSvC/VZoi50Bt9KAekqnhE/JnxKgcH2bk+pm+fIK2
         LAwrk+sstBCV3hlxkurP6xWAGP26xBaz9+5n21dl913ZfgZUPnprHwPPKQQzrn8mrQLS
         raTzJ1VeBHgL9ZbRf1gLIKVzQDJNr9+B2RznBfvxyxpeLRBj5VofrB20ovxyzZ/YpOv/
         N6uw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=E18fnBvQ;
       spf=pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=zwisler@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a24sor17186778iod.40.2019.06.20.08.18.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 08:18:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=E18fnBvQ;
       spf=pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=zwisler@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=8qPSgW/MPmMfMRbYOSrZE2Wb0C0QAL6xUVu8BnMULPU=;
        b=E18fnBvQxeTWGcLPU7yJtnVUsZk1M7260uW49AWUEQwpDTLXW4zaL81bfOBaOIKkJe
         izk337ElLT6ixdEAM82Alqqvi8RTCa5t/m7TIIGM2CTO/X/MhLTAbXsdT4WaLEPQzOwi
         5M/ks9JI6LULaQnx5ORxgNivEqZfrhzLXyxFY=
X-Google-Smtp-Source: APXvYqyKoB4ShJDQDvXm8iMpldDQ7RBFe5iQW/R6q5N6coubvTjfHUDrQI1UrGttuBMzscYMvKWwFg==
X-Received: by 2002:a5d:8794:: with SMTP id f20mr30867938ion.128.1561043934904;
        Thu, 20 Jun 2019 08:18:54 -0700 (PDT)
Received: from localhost ([2620:15c:183:200:855f:8919:84a7:4794])
        by smtp.gmail.com with ESMTPSA id e22sm51531iob.66.2019.06.20.08.18.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 08:18:54 -0700 (PDT)
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
Subject: [PATCH v2 3/3] ext4: use jbd2_inode dirty range scoping
Date: Thu, 20 Jun 2019 09:18:39 -0600
Message-Id: <20190620151839.195506-4-zwisler@google.com>
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

Use the newly introduced jbd2_inode dirty range scoping to prevent us
from waiting forever when trying to complete a journal transaction.

Signed-off-by: Ross Zwisler <zwisler@google.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Cc: stable@vger.kernel.org
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

