Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 898B4C41514
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:08:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 588DA217F4
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:08:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 588DA217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F383D6B0005; Tue,  6 Aug 2019 04:08:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE8906B0008; Tue,  6 Aug 2019 04:08:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB0AD6B000A; Tue,  6 Aug 2019 04:08:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id BA1846B0005
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 04:08:32 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id l9so77970398qtu.12
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 01:08:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=U+gUm+QDpVvbOCHGsRktkVvtBBUcta0H2JMJrhhjCWw=;
        b=htKueqySnr4v6bT+5e6VsynTMtuqqkwUU3JIA7X5vcKjo3xqt2iBBiSCvLH82BE1w2
         NXQSOXCwlRzFfmeUt0/817xjy7Hxmhleuu876gBldyze1HpBSOFYQ5tfcfg+FPg7yKtO
         XhkJAAfcDITClPcyC1a9gW7XK09pUNR6szubXPvZxWppSuO6u0wRqtKts75yoMM8qr+R
         Zh6ZYzmDelg3u3kcPZ4yBwJhbZ1XLKFYQPnnczzcSR5cLinfNhGUT5jq1bOsgT0rW113
         VJfuRmNT+hnE7kSZZ3Q4bx68RIBM+pjhXDKwm3S9L3vrHmMnDIlxRJil58EVQO5ud8C/
         hKfQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX9Wl7OFo+oh8NADcbYjkTBgxriNj3WavQKYYiMKeZZh4By5mb6
	xSLBzc8VSPi/YKtYCI0ykDVRhkY7aVqbBFGvW64RVQ9q8013hUZtG7pdg4BE/xWdemolwQ85F5n
	eFl36X6lg5XsOZ+aSCid/yUKVRfpO99hXW7rw9PJFou7lMNRHmB/LZVSDk9zeVbr2wg==
X-Received: by 2002:a37:dc1:: with SMTP id 184mr2087527qkn.10.1565078912535;
        Tue, 06 Aug 2019 01:08:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvWAfvN8d8lQ7rUh+QCp0WLSEofEif1k+LkhNt9RcrPCCIIykm1Y4ACCk/y5z6cZHLGWpt
X-Received: by 2002:a37:dc1:: with SMTP id 184mr2087503qkn.10.1565078911999;
        Tue, 06 Aug 2019 01:08:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565078911; cv=none;
        d=google.com; s=arc-20160816;
        b=L5XM5p63Pl1q2X3c2KniU5RTIJjUpb7ipIUj/FqrAMyVju8COLdMhcrPqcRnViY36X
         A0H615BqbGUKumv2ZzVn7pcozcKBX0bwt8c93pPsDEHax+ZxmZtwb25R36MOfSmURmvj
         nH1m8O5VX1tTJce/txxCJl8fWiYC9FsGDCtv7m352Rm6DIoj23fERkYej1if4p1eIGYR
         dwk9RMYVv+XK7r2b31WIMtOfHm9vBt+YQnkjyM772rkZfEVEJyDHC2JdEBVzXLuFRI1n
         vb7KbmPYbNfzV0QjjXztVXiDt7eGTx83PTTlH1XbYV4QO9qvkdCQubDqI2D5dh4d5Ikj
         lJeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=U+gUm+QDpVvbOCHGsRktkVvtBBUcta0H2JMJrhhjCWw=;
        b=DsNrzv4gkTMVRTdkHlPh16LDcVHBomebjPQ2mADksTIE6YAaBeqPcAtUMrQEZDd87E
         dhfTNkz7IPUBFLKK5HoZ4a3y4Z0USGe7zjh4PJd3PpUVcz4WTPm41FhDhq1vBnjRKly0
         j/ntOpDPfQM5HuY1KFXiFknCYxVEkpk6eZtzNVY1eBctcrzvD17swEIYYxTySmawqWa4
         b2/Ep1XRoQdH3uwVg2nEF+av2pJJxUbVHbLzRRXwYMcwRSdU9+rOIfxzLt5ex56ZKnno
         +JEPlYeCT2lPFVfFL4Hq9bG3TDBfuUaVgmuPJqENTXyhK1U7mjHzMk1BhDMKHhsxmGPw
         WHsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j4si51224856qtb.288.2019.08.06.01.08.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 01:08:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 351893CA18;
	Tue,  6 Aug 2019 08:08:31 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-71.ams2.redhat.com [10.36.117.71])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4A1F65D704;
	Tue,  6 Aug 2019 08:08:27 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v1] drivers/base/memory.c: Fixup documentation of removable/phys_index/block_size_bytes
Date: Tue,  6 Aug 2019 10:08:26 +0200
Message-Id: <20190806080826.5963-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 06 Aug 2019 08:08:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Let's rephrase to memory block terminology and add some further
clarifications.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <osalvador@suse.de>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/memory.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index cb80f2bdd7de..790b3bcd63a6 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -116,10 +116,8 @@ static unsigned long get_memory_block_size(void)
 }
 
 /*
- * use this as the physical section index that this memsection
- * uses.
+ * Show the first physical section index (number) of this memory block.
  */
-
 static ssize_t phys_index_show(struct device *dev,
 			       struct device_attribute *attr, char *buf)
 {
@@ -131,7 +129,10 @@ static ssize_t phys_index_show(struct device *dev,
 }
 
 /*
- * Show whether the section of memory is likely to be hot-removable
+ * Show whether the memory block is likely to be offlineable (or is already
+ * offline). Once offline, the memory block could be removed. The return
+ * value does, however, not indicate that there is a way to remove the
+ * memory block.
  */
 static ssize_t removable_show(struct device *dev, struct device_attribute *attr,
 			      char *buf)
@@ -455,7 +456,7 @@ static DEVICE_ATTR_RO(phys_device);
 static DEVICE_ATTR_RO(removable);
 
 /*
- * Block size attribute stuff
+ * Show the memory block size (shared by all memory blocks).
  */
 static ssize_t block_size_bytes_show(struct device *dev,
 				     struct device_attribute *attr, char *buf)
-- 
2.21.0

