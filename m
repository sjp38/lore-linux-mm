Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80328C28CC5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 01:45:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 485A820874
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 01:45:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 485A820874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C1B96B0276; Wed,  5 Jun 2019 21:45:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 521336B0277; Wed,  5 Jun 2019 21:45:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 350606B0278; Wed,  5 Jun 2019 21:45:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E5E406B0276
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 21:45:22 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id q6so484869pll.22
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 18:45:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uaTRZLRYkOF6zdKGHzjPlcXa4k/4GB2jeuLkq5t3Y0A=;
        b=Rrc/NLbDW57NON5XbUeHgtGAXAPHC8fMinV3MeWCI25XVikBpIeAchrS3WAGG8NPfu
         JZ6MNwcwAjP5GZvFBlspCGL7FtPIjAy+vcl7s03c7QoMmOKj4tIsLJtWGon5wkLNRWQS
         gujJdzuq+TZrHwnbaLtoaq/A4qisgYWf7kItWCIOePgMW+SREiV333Nd1Vm0sUjMn7MD
         6K206XL8k9SA07s0sUsxuJJXYrCtX9LiVTei++8Tu0QTd3Yvh1V2oNZpBrBMWNzwe6fo
         RLzH40EEa7ClTd9z68TG+O8vL9dbijoqzjbOvBNwFgrF/yIHmFAe/gW3HLfcvecUIZhu
         m8DA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXQG/kqgU7HGhRRPpgM1rNReB8Tfbd+CD46NeP320o6o2UZ1ydv
	SgQ//pjY9UweyXPM4y4Z+wz9iUINHnUZXfYyHfFHVaETfTulIKvei9pkAlJUtLM+OHDvDBMBV7q
	GWPAyZ21k0dchzrpUD3lWs3qf2vh9b3f1AfbrBhjo2eA3KEE4TBe16zHGYLQoit87Vw==
X-Received: by 2002:a62:7552:: with SMTP id q79mr30333153pfc.71.1559785522622;
        Wed, 05 Jun 2019 18:45:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzaG8gDjffgBBcB9JTxp0dG+iNYwRficX0slqinqCiACxwgONcW1yLFPD/1j7j7c75AUgXF
X-Received: by 2002:a62:7552:: with SMTP id q79mr30333115pfc.71.1559785521837;
        Wed, 05 Jun 2019 18:45:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559785521; cv=none;
        d=google.com; s=arc-20160816;
        b=zK0n9+IhN1oiygfPd69BVVmQENfu2TsSKkA6yOZI6fXVLWa0Eq4ApA5iCKKZbZiOkl
         RtJ72+YNDxyHDgaCedPDdacLgr0pohamhmvZ6U3SMI7Rf2ixQYvSoTo5ob/nV4B6UW+e
         pIBHa35V3mGgvWFRJhEGm11FtNta9+ZHA9KHabh8zPouqEQ04zh7bQaGp1byGE3/AI22
         jY1r/FPw7nvSQZoSYerx7tXLXpdMK6m3ugdNn1ZcJsY1a9ChFemmt8EVDXcSO0eeK7Qa
         PirS1PqljBrSHau71DZHfKxh+mpgVO3bCQJZWO23txFzPOF1VGLqlcRzMhH21WB5Gzq5
         M5Iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=uaTRZLRYkOF6zdKGHzjPlcXa4k/4GB2jeuLkq5t3Y0A=;
        b=cNzFPnYC5Dft6uqZ5OrhiLpfKsdzCRP8ZyzXP/FxLM8SQrK2e8xl4IIeLVuYjTqPW7
         nu/Hp/KnoSFeXHEu5nBYmGlb4bVIs3z2vfR80xUPlrv10u9S+fvY2ChOI8tXQ+adSnaD
         70tncTDph+6qvyDp3BIKDhcvGLwrFIx9UhKhJeYGxIERpfaS36q6IkI2IeUITZzcsqRO
         pSTyCGjptjIeAVgoClg9uEF5JDQycwxfEvlCdMW2hUfgARKAyNvUw1tgdlw5v+O51D9P
         Wedo5JHirn9+MGJ1/3tVduQqybD1Rn5dIBNILWdgCRb6MpfJ0J/S7bzFpp/RgCCV3FxE
         vA2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id k18si276921pfk.103.2019.06.05.18.45.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 18:45:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jun 2019 18:45:21 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 05 Jun 2019 18:45:20 -0700
From: ira.weiny@intel.com
To: Dan Williams <dan.j.williams@intel.com>,
	Jan Kara <jack@suse.cz>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>
Cc: Ira Weiny <ira.weiny@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org,
	linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH RFC 07/10] fs/ext4: Fail truncate if pages are GUP pinned
Date: Wed,  5 Jun 2019 18:45:40 -0700
Message-Id: <20190606014544.8339-8-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190606014544.8339-1-ira.weiny@intel.com>
References: <20190606014544.8339-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

If pages are actively gup pinned fail the truncate operation.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 fs/ext4/inode.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 75f543f384e4..1ded83ec08c0 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -4250,6 +4250,9 @@ int ext4_break_layouts(struct inode *inode, loff_t offset, loff_t len)
 		if (!page)
 			return 0;
 
+		if (page_gup_pinned(page))
+			return -ETXTBSY;
+
 		error = ___wait_var_event(&page->_refcount,
 				atomic_read(&page->_refcount) == 1,
 				TASK_INTERRUPTIBLE, 0, 0,
-- 
2.20.1

