Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44D4CC31E5E
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 17:22:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E659E20657
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 17:22:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="gb4iGaYn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E659E20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D46C8E0002; Wed, 19 Jun 2019 13:22:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 584F28E0001; Wed, 19 Jun 2019 13:22:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 473518E0002; Wed, 19 Jun 2019 13:22:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 27C938E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 13:22:22 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id h4so282916iol.5
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 10:22:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=y4I5Ty62o91Pugxcg1FTgTnvgf8oL/T0SugxfMdF360=;
        b=jNS+U8CB1HPf3RfqtkW423rPDoP6VbcHNlKzecVzeWeJ/+BGHdnzstKr6agF2e0OvH
         Yb+5ofVTno/jmid5/jDZxvjxAFnak0NCnL6hrKzspIXL7KDR30CdwJp7oRLyYqjkgIGl
         xyronQjZHTWADz7v8gLf0HvBMmFLV7r8Jf7CtH5bGG0w/HbdOVAjTJa8IVYA0evqaZlP
         YCdA48QVwNibrG5PZ2i0+TYe+BRW16tfG+F9U8ksZ2xomgS0FGn3dVuNFeP9+ewpb5No
         37h+aMA6QPAPBQg6KldgKCPFTmVfgDqFGOVTDfvtJDF/JndplmzlWcBQfxPVwQhHSdUD
         3WyA==
X-Gm-Message-State: APjAAAVIdc/0PYpew3XXhn9vZrwtkilgUzW2Tml+TUtWfFc4bn4+PBZj
	/awhh9nu8nnvBtboLbe5NrXvpG3MNz2999R7pe3IE+bPOb36oWRulG7Sc750IXEiv0dmZqn0QYc
	5eLkA1Fjj+egDaS+fTILBK1IDHtHE+km7sbk2xBDFsWmeWuy06lTh3V/aqKRf4DRmvw==
X-Received: by 2002:a02:a581:: with SMTP id b1mr35353417jam.84.1560964941853;
        Wed, 19 Jun 2019 10:22:21 -0700 (PDT)
X-Received: by 2002:a02:a581:: with SMTP id b1mr35353365jam.84.1560964941213;
        Wed, 19 Jun 2019 10:22:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560964941; cv=none;
        d=google.com; s=arc-20160816;
        b=hWjXe33MTiDJkamoSwjxpg+cOkzNFUAjDPEB/YPn4NbWEZ3S3qOMvfTUb/H5EhCE+J
         Bgl9shhSxMfLqtrGYr97Qm1WaUKmX5MGW7FDDRzX4m+HZYXf5+UUMvBI8gdBKUi5SZXq
         NZ+lXnmwvNVL2x01E9PaFRCvOTOn5kbXQVIBqxYi7BJNz41CVCC6qg1qrtBTeuymjiei
         93LrLvGcfpNpJgXybmUHANPd9aWIy/Rmd6Bxu7S7/2EkUEZPQp4HKbi0UrlzjYnVAd+P
         ej8YZvnXRbrwPaHqAoPAe07dh9jd8VTiNwWzJ6Ziw6/qlIZCZJK/oh5PYkeR+fQewAdo
         Rk2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=y4I5Ty62o91Pugxcg1FTgTnvgf8oL/T0SugxfMdF360=;
        b=VVoXhiVQR8j9YfDFRVFYtefRe7jCkevxeU3ZkZ/1dhBtRl5bUZcxzgbH0bsZPVyFwd
         D659fGEO2+u4lz0M8g/BFkhwwJuhxUmckIqE2nXZ0W5gsyFSm6cJcUk1HA6BGtIB+q/o
         WyMXcu0TXRIku54/cpGrvJ0U28us0zY+xo3/Oc3yIBiVlV9eSLGuaHblrkEQuAkfimKI
         g/0siFgeTb2ItKMLxpPDJoIiMXIYvsXjG6KXWuCAKOM/EGsvtirK8QnZ9mIHjXT85HFl
         YMkmkDhZQPIN2F8oKKaydfGpxOIUrdN9+raJfx6WG2sbihe4H5i7j1pV3SnFFO1wnR96
         ofaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=gb4iGaYn;
       spf=pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=zwisler@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q35sor42681813jac.12.2019.06.19.10.22.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 10:22:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=gb4iGaYn;
       spf=pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=zwisler@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=y4I5Ty62o91Pugxcg1FTgTnvgf8oL/T0SugxfMdF360=;
        b=gb4iGaYnPJYNqGfAxkP3X1NyZrCyL5DKEUxf/+boDKefd2UjG+qdworr0YK1ObtumN
         6uLmt1ytGOjQmAyYXv5eWn2+e/wwvBH4V0YZ02cusIrDbo9JldyQ2tukswmk+W03TQCZ
         3fJ2x8pKx2vhpksYet+kdD7iF28u6Vzn2HBLk=
X-Google-Smtp-Source: APXvYqweh9cE0ZdyorzDcYNOiMgH/757F101nec4Tfciidd/HUUM94okf25BnwroKGtoHIwyBfvbEQ==
X-Received: by 2002:a02:ce37:: with SMTP id v23mr11907871jar.2.1560964940961;
        Wed, 19 Jun 2019 10:22:20 -0700 (PDT)
Received: from localhost ([2620:15c:183:200:855f:8919:84a7:4794])
        by smtp.gmail.com with ESMTPSA id z26sm16377581ioi.85.2019.06.19.10.22.19
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 10:22:20 -0700 (PDT)
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
Subject: [PATCH 0/3] Add dirty range scoping to jbd2
Date: Wed, 19 Jun 2019 11:21:53 -0600
Message-Id: <20190619172156.105508-1-zwisler@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch series fixes the issue I described here:

https://www.spinics.net/lists/linux-block/msg38274.html

Essentially the issue is that journal_finish_inode_data_buffers() operates
on the entire address space of each of the inodes associated with a given
journal entry.  This means that if we have an inode where we are constantly
appending dirty pages we can end up waiting for an indefinite amount of
time in journal_finish_inode_data_buffers().

This series improves this situation in ext4 by scoping each of the inode
dirty ranges associated with a given transaction.  Other users of jbd2
which don't (yet?) take advantage of this scoping (ocfs2) will continue to
have the old behavior.

Ross Zwisler (3):
  mm: add filemap_fdatawait_range_keep_errors()
  jbd2: introduce jbd2_inode dirty range scoping
  ext4: use jbd2_inode dirty range scoping

 fs/ext4/ext4_jbd2.h   | 12 +++++------
 fs/ext4/inode.c       | 13 +++++++++---
 fs/ext4/move_extent.c |  3 ++-
 fs/jbd2/commit.c      | 26 +++++++++++++++++------
 fs/jbd2/journal.c     |  2 ++
 fs/jbd2/transaction.c | 49 ++++++++++++++++++++++++-------------------
 include/linux/fs.h    |  2 ++
 include/linux/jbd2.h  | 22 +++++++++++++++++++
 mm/filemap.c          | 22 +++++++++++++++++++
 9 files changed, 114 insertions(+), 37 deletions(-)

-- 
2.22.0.410.gd8fdbe21b5-goog

