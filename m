Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38CC7C76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:44:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED01122BED
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:44:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eJM1DtC5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED01122BED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D02F6B000A; Thu, 25 Jul 2019 14:44:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 981736B000C; Thu, 25 Jul 2019 14:44:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 871D08E0002; Thu, 25 Jul 2019 14:44:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4F6E66B000A
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:44:05 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id w5so31253894pgs.5
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 11:44:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bPDs9aZTbcVy9P5At/6nzEj0xAhZgvBWq0iu1KF/hyM=;
        b=kzWHltFuYqZFlaE7BptoyO1T33OtV7sZp1MhuY1G1WuQIC65wD2RaYvnVmqymqjDtD
         UsJtdOyvWdnHqDcTszGaUtxCekdYfYHUzfMzFGeKBY4jTbuNzsZV43DuBmUJSG87LJeH
         w5wMddeXXaiTSLWo2ZX6km9LrmIZiYtZomdiwl2yFmvZSW5wugrW8/ALlr4J2NRdSG73
         eFycEKINfLSfPCZ/heXMAqUhI2ykXx4ojvZ/7fVW0C4USlfUj+yN2JwC3igwvVgjCB9F
         KSZohmKFjNuySlLp9Pap4/fpKgGoXycHXFykPDnfP00xDOtKr5aKlxKPKy5PeIIDnNTS
         QVww==
X-Gm-Message-State: APjAAAVFTKz5KjcjgUi0PPwFSG6VN+fI/45u+A4BI3Fz2ypSynIUwjQN
	UmQWfR+64NVD71Kh007wzhkotYVilGjUXoRj51bcNrs2eB05muJRMvwbejV799RaAd9V4BGkxy+
	KALdi7BYomejQ6B05YuG7fEHebAUpIyzUbrdIsdVUuqY5UFrNPLJ+JaZPEH9/fC+e7A==
X-Received: by 2002:aa7:818b:: with SMTP id g11mr18280277pfi.122.1564080244983;
        Thu, 25 Jul 2019 11:44:04 -0700 (PDT)
X-Received: by 2002:aa7:818b:: with SMTP id g11mr18280236pfi.122.1564080244224;
        Thu, 25 Jul 2019 11:44:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564080244; cv=none;
        d=google.com; s=arc-20160816;
        b=Pa9VRf0LLWRu2W73/2G4Wj1ntv0UiQ83yBc7gbqZPRoNilQVZXUHeY0zoLzBM2DjtU
         MNERsuDWy1wFHeG12m1ZAunm9x64WiVhreK7D3unq4/qKE+2A5qiPBGFnuncbbbB70wo
         4kCorYjVG+70QXPCkqazZx64bjhWYhpVlsVJu3uUTKfwQKQ1BMTFox5gd3UM04dedKQo
         0MiJBOaW1fjKPzXG0vpKYQjbyEbU41lVZXa0plr11nifGxB9xTqGkS03vhUm2VOwOwl1
         sBOg5Pv9hmvVWEC8Hp75iwtWHKR08EWx0Tt1tqA3JePwSHvq0GQvBNXrGJMpJRZmKJHt
         boxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=bPDs9aZTbcVy9P5At/6nzEj0xAhZgvBWq0iu1KF/hyM=;
        b=aF73GjooVw99eiqZpLLMax4luYGCnjJzx+sNy9fpBQH7QJZymUnvn87V6YKjBTCjUd
         o8L6ysJXlhE/iDQUDNPK04gfNjNqVmRPloiWvJKI+FqE5aiKpfCIPgK2PzqqGZRRDKhD
         yFotwWQIhwKQFl8MKG9d4I6aKVf7VzzgZM3f10My2XbBngOeghe6h/N+QSLVEL7qrrcl
         M9GUmNY9cKmlZZMsahYVoTNsjtHbBT+Y6vWOEoBQSP0jkrCOr8uDA168O6zNomHK1hsk
         H33U23lwtebj2eeyZoIviiu29eIDyrti29qnlzO+VDjFDfoKx/E4C6FXu/R1rZw8aEuY
         S/5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eJM1DtC5;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i2sor7253951pgm.8.2019.07.25.11.44.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 11:44:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eJM1DtC5;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=bPDs9aZTbcVy9P5At/6nzEj0xAhZgvBWq0iu1KF/hyM=;
        b=eJM1DtC5tc7N+x3bUDdfU3a6aCPNIKs5Ea/Z/fUOdrJjaLs5VmctkQkOfWa5ycQmWy
         T5eFh5Pv2d56b42dZkAQcWzM/FzmI6m7UaLTTYpXxUJOE1+rTja/64NwSq+YXHDtkVhj
         UoDfaFAKiw0bjo8MjuKksMwuHF6M1UgGh6b4OyJFpU/RGI7iV6615GCVMwt+fzzREu+q
         F0x/mjJzP3lhCGVKSOcsUzuZMTn3ZbHwy9xR6IjoO9VTr2CUPe9CEu3D+nWk8iwRAWbP
         43C4KdlQ8/ROPCjSjhtS41Jp0XOnZKjzAHMrAVWtaOzkiLvj7kzrci0zbLlYjWwWycJJ
         wfYA==
X-Google-Smtp-Source: APXvYqxBv96pUxmfgMQrftaFG4psDx0UQ6pg+dJPW4c2ZWiusVnPoWSeEsuxPW2mk3fqgO0+1KFlLg==
X-Received: by 2002:a63:4522:: with SMTP id s34mr86869675pga.362.1564080243954;
        Thu, 25 Jul 2019 11:44:03 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:624:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id w3sm43818257pgl.31.2019.07.25.11.43.56
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 11:44:03 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: mgorman@techsingularity.net,
	mhocko@suse.com,
	vbabka@suse.cz,
	cai@lca.pw,
	aryabinin@virtuozzo.com,
	osalvador@suse.de,
	rostedt@goodmis.org,
	mingo@redhat.com,
	pavel.tatashin@microsoft.com,
	rppt@linux.ibm.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH 04/10] mm/page_alloc: remove never used "order" in alloc_contig_range()
Date: Fri, 26 Jul 2019 02:42:47 +0800
Message-Id: <20190725184253.21160-5-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190725184253.21160-1-lpf.vector@gmail.com>
References: <20190725184253.21160-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The "order" will never be used in alloc_contig_range(), and "order"
is a negative number is very strange. So just remove it.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 mm/page_alloc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7d47af09461f..6208ebfac980 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8347,7 +8347,6 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 
 	struct compact_control cc = {
 		.nr_migratepages = 0,
-		.order = -1,
 		.zone = page_zone(pfn_to_page(start)),
 		.mode = MIGRATE_SYNC,
 		.ignore_skip_hint = true,
-- 
2.21.0

