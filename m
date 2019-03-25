Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 355CDC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:40:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E44002087C
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:40:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E44002087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 563586B0006; Mon, 25 Mar 2019 10:40:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E97B6B000A; Mon, 25 Mar 2019 10:40:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 388A36B000C; Mon, 25 Mar 2019 10:40:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0D6546B0006
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 10:40:17 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id 35so10300950qty.12
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 07:40:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pWcLW/bNcbSzZsR0N5LB1nlWz2nt3SFlayKquuhRY14=;
        b=fqu4kQVHJPvnl6i6aa6q3P2q2mRGRVUfdjCmYP2bg1BU1h+Bz0BGbiQnmTUyXNMuir
         2QKjyDO2feEVdRafFFwNOAywtzMuj42pnMU+Y/TR6AWBQXLIiVkr20vlfYby9IBASsWE
         KixeeBhICwNwYTJS2o9/ZYYvQ2cAPowgpF6xa2qv+QUJu+pWCK7B8QQWNIwB1/q5MAAs
         1YFEsSsJNo9OqtWKuPTrhhmEIDnUXeWMaVkDswmbtlk0QMdIs8e8GBp+1QpAxqHFLy0a
         bi07lYCXuorBLhLBtAVAzsG9nRdHWtyE3FVhmwORqCoKvAkZJnMNl7JkcI7d3wYkSrv/
         /5rw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWJt3iRKAtqGpHbTcdths35+Zpx7/dBhZv7lB7yWYVA5EnUWIAE
	XuO4/6YWJSzXE9FZR9PkLKP0CuOfwvtNziHf/dBT16K43GzLH7H0tG1YWsXyYpGgkxv69BPCQIO
	dXywFZk9CCD1oH37Dbxo/a69tYiVAE28WUhzGPu7hh0SdjTmktZLBwq5gq3FBEgd/0w==
X-Received: by 2002:a0c:b15c:: with SMTP id r28mr8177990qvc.122.1553524816793;
        Mon, 25 Mar 2019 07:40:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqws1UwuD3D8U55ZmP2S0fOF0ngILZnAwya47CZMNvIJ7e4vJ1e8I5U2bqZUIzng1f8VBIzx
X-Received: by 2002:a0c:b15c:: with SMTP id r28mr8177939qvc.122.1553524816067;
        Mon, 25 Mar 2019 07:40:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553524816; cv=none;
        d=google.com; s=arc-20160816;
        b=hDMbGq3rxDgi0oMMxYjzEa/tfIct094P1qEIzbn4jTfitc5tyKAFEoIUpLA5uTRKCJ
         QN9FZQKFmoH3zO08S//yFVmiLeTN9vMyMZrx27cD6b8oo6iLvelX2jSciMNOA74BT3kK
         Zf2ZkQ8n/HnhMOtpbUybFjEOkhfi5rQ5K3fMym8Z6198AXPnALxXTqiMcgD/PAZXexkZ
         shx3WaVSiueK1fpZhL8Wx1i2uC8QhzkCtGRitLcQ7so4wwL/YNaxoPuE2nq4ExqQ0pBb
         JGOja/fz0772x2atxrCoIlP93nB40aAhIXrGpRt+RA1GWf+OdM9lOOsE7o1075rA6sON
         oZLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=pWcLW/bNcbSzZsR0N5LB1nlWz2nt3SFlayKquuhRY14=;
        b=hUiC6TPeSU/wg34oHgGuekrV61+NmY89y5hjPL0bM25+gm5/Z3fUesMy9Yzf/45asH
         oICMi1vERRJOFOJV/qlFipXhRDM/bQdK52yvD55BWI52TlN2kMD6Qo5fPOpsisdGt85y
         PbdAiLmwI5Rk8rXW9Fq/2GfXT4nUrPpOaOQYmXjMdvC38My0xk9d/KFJdVtLJpLyNmJd
         wchEqx/yTn2CapeCvWLI0zfy2YR3gjlq7v/Y58ABQCH8+/Jphk4OZ//DSx78TMtwYQvb
         w8g6FXJNWMrEK0K5/DRjdygQCfgGaIsPzfFd/0P7LnX4WZvFksUAAPPipoM8+FpNPqfB
         875g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d16si2741478qto.126.2019.03.25.07.40.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 07:40:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5683946289;
	Mon, 25 Mar 2019 14:40:15 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9254F1001DC8;
	Mon, 25 Mar 2019 14:40:14 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v2 01/11] mm/hmm: select mmu notifier when selecting HMM
Date: Mon, 25 Mar 2019 10:40:01 -0400
Message-Id: <20190325144011.10560-2-jglisse@redhat.com>
In-Reply-To: <20190325144011.10560-1-jglisse@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Mon, 25 Mar 2019 14:40:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

To avoid random config build issue, select mmu notifier when HMM is
selected. In any cases when HMM get selected it will be by users that
will also wants the mmu notifier.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Acked-by: Balbir Singh <bsingharora@gmail.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 mm/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 25c71eb8a7db..0d2944278d80 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -694,6 +694,7 @@ config DEV_PAGEMAP_OPS
 
 config HMM
 	bool
+	select MMU_NOTIFIER
 	select MIGRATE_VMA_HELPER
 
 config HMM_MIRROR
-- 
2.17.2

