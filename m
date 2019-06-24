Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BA50C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:09:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CFFC208C3
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:09:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OktZxb05"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CFFC208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFF166B0003; Mon, 24 Jun 2019 01:09:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AAF928E0002; Mon, 24 Jun 2019 01:09:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C6748E0001; Mon, 24 Jun 2019 01:09:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3846B0003
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:09:51 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id n1so6655634plk.11
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 22:09:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=RVY6qs2x//IRTjLWtMXFvlJbom1+urYYXoetqrm4oak=;
        b=eemOMT2n0ebf/WUlL6q8Gs6B8BB7y4ds99O4XXu2zvbjKlm+vYHdvK5QCDWb0roEfv
         4j0g4HD6U+C4ntsq6Zii/qn4qKCL6iI4Mte9CB5FoQBXwBmJXdfiP9Mr6aR8G9e6lyYc
         npMtJFuSe0sTOLb5iNovsv1bdBy19/9rksyLk/ldsTb0VjVF3sdvr1hD422mDRUwPjyY
         DKAte2AR0Nv603jQ9zzueCKc1C25eClbp0o2CK41h39BnWfW9tgX1cuapLU+Nr90hAhb
         N9hvR4G2npOJyNUCZUHcaPD2BVzxT1zqkyYwfcnFUD278BXPBUSZkuAeHRYFG8pPfGd7
         v2Rw==
X-Gm-Message-State: APjAAAVQuigrL65EvuPHi0peM1ZTNOKMlc3VJMg4m0FLur7hZKI41i3q
	UGr+aY8ie1/riH9ijGI4Pgp/gIxoqVhymNRSm916e77GxHTGIRQwXvATo/fGbcJLRc4FlQ5O/iG
	1/f4BsqtVWs06ExAuVp2b+6XmoeAGRxayC5awX6KBBh3X63xd4M7DxSmr+cpe2tLv8Q==
X-Received: by 2002:a17:902:549:: with SMTP id 67mr86300317plf.86.1561352991016;
        Sun, 23 Jun 2019 22:09:51 -0700 (PDT)
X-Received: by 2002:a17:902:549:: with SMTP id 67mr86300262plf.86.1561352990213;
        Sun, 23 Jun 2019 22:09:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561352990; cv=none;
        d=google.com; s=arc-20160816;
        b=V8v4X5XhKvkzgFSvzghhiUCcLQkRyaBx+zYN3bYW63RbVXKPsfcb4nNSfxfoHMB6g1
         UGTvrlbZN/wD9/zRAHTrioHWJvMQrL2tanSZIoBSRwP3NeslOmH26Hck+0hd3FSQcvkg
         pny6X8UdMJrDEJcY/4IT3dKczNyyGgUJlzI+lICQAbb2tk/0+rGSj0qj0f5hvmyNRIMs
         6lG0IHQ71SyY9ByA2FDIr8/t+0mHdZ/Mtnas0SQwO+4gijufDsJwfolfRndMDNGkipFx
         rlwmK9HqS99HTQ1wrhsj6VrVQADvE9zzv2KqMirdBtjpiAozSwtWIA4A6MG7eB1369cz
         qMZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=RVY6qs2x//IRTjLWtMXFvlJbom1+urYYXoetqrm4oak=;
        b=VtdvmlE1pb86fNUoui/nXy+RngLCJqXa3rXP7Zx6+QDAjuZI+z+XmQPdTSBqUlyaCe
         vl2HDdk7+XOEV+GnhVW3HqCv9hdmeBnlkhv4YnuCwarhqM9gMHfnlO7FfbOBpq/FQvIe
         ttRe9rLXWCPnxUNDiTnJOVzp8WVt8H9Ns7VCSeXcmVUEd74ZB/dVPPS31MsYh0GiWRPl
         5Co2IbZk1+mT6VhD16HGTHRxDpm511HHQ522bO1P9UEF8ECxjln9wnm9iua7gRldaSWx
         eOMDrN+eFhDKxwH/KuvThcMRgP3yZ1LUHN/KCJCtsOuryaeYTSTfiz5x0onB3K5Iilkh
         YTtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OktZxb05;
       spf=pass (google.com: domain of houweitaoo@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=houweitaoo@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j11sor13153852pjn.7.2019.06.23.22.09.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 23 Jun 2019 22:09:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of houweitaoo@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OktZxb05;
       spf=pass (google.com: domain of houweitaoo@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=houweitaoo@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=RVY6qs2x//IRTjLWtMXFvlJbom1+urYYXoetqrm4oak=;
        b=OktZxb05cA7jjdGotH5tWVi83rtdPg2lTEu1k0I13JUX5Cc7oGckdphOhmpETppIb/
         WB/nd70i7joZsf6C/aoyjZglz4U0O2MHKtslPtrOacDf62vt9arL/Xbsjdb1f3l2OFUk
         3bxvKb5zxBiSlia5bPgqP9/KmXTja+33FG2v/pZkgYSjv0U+SWbH/m3AbG2o5D/GLLQB
         oAmRI6J8U8i3xHTTAMItZu79RJGBTeEDMaxcSXJEeiX5AGwjXJY9N3gBuieoajvHr/fX
         R2UaNd/OCfk5AWAyMp77ZYZbYxaJ+tpVQD29b+5JU0/t1nzV6evqaSGn82ke1Agb20RK
         pN/w==
X-Google-Smtp-Source: APXvYqyhniW0jG8SeU16sLDlT8V11Ngp3qjDdLAvp2SYBIu1uSNmdXDBP623duvkPM2tJ6jFh/QtkA==
X-Received: by 2002:a17:90a:2385:: with SMTP id g5mr23132372pje.12.1561352989891;
        Sun, 23 Jun 2019 22:09:49 -0700 (PDT)
Received: from localhost ([43.224.245.181])
        by smtp.gmail.com with ESMTPSA id e63sm17545179pgc.62.2019.06.23.22.09.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jun 2019 22:09:49 -0700 (PDT)
From: Weitao Hou <houweitaoo@gmail.com>
To: akpm@linux-foundation.org,
	urezki@gmail.com,
	rpenyaev@suse.de,
	guro@fb.com,
	rick.p.edgecombe@intel.com,
	rppt@linux.ibm.com,
	aryabinin@virtuozzo.com
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Weitao Hou <houweitaoo@gmail.com>
Subject: [PATCH] mm/vmalloc: fix a compile warning in mm
Date: Mon, 24 Jun 2019 13:09:37 +0800
Message-Id: <20190624050937.6977-1-houweitaoo@gmail.com>
X-Mailer: git-send-email 2.18.0
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

mm/vmalloc.c: In function ‘pcpu_get_vm_areas’:
mm/vmalloc.c:976:4: warning: ‘lva’ may be used uninitialized in
this function [-Wmaybe-uninitialized]
insert_vmap_area_augment(lva, &va->rb_node,

Signed-off-by: Weitao Hou <houweitaoo@gmail.com>
---
 mm/vmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 4c9e150e5ad3..78c5617fdf3f 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -913,7 +913,7 @@ adjust_va_to_fit_type(struct vmap_area *va,
 	unsigned long nva_start_addr, unsigned long size,
 	enum fit_type type)
 {
-	struct vmap_area *lva;
+	struct vmap_area *lva = NULL;
 
 	if (type == FL_FIT_TYPE) {
 		/*
-- 
2.18.0

