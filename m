Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 943BEC0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 12:24:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B99A218A5
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 12:24:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WEx9srRw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B99A218A5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7872D6B0005; Wed,  3 Jul 2019 08:24:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 758128E0005; Wed,  3 Jul 2019 08:24:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 61EA18E0003; Wed,  3 Jul 2019 08:24:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2FFFA6B0005
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 08:24:04 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y5so1387473pfb.20
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 05:24:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZFBwbC42pF4/ydEOSJ4y75ZnrJb+ZBbMm/qFm7Ht5k0=;
        b=Lf3zuddofJ9LWPBFplNtTUOY1Qj6lfyUOfPqU+TN2d/d45DVcTnfHI4zkvIcdM0jud
         VcvkOchIgQ3wDW0o3Yw/XyD4BCorwwwIpyp/9tPkHQhHht7UKc/hcs+xEJsUMABauJSW
         xBTD6MO/QfO5TnEYh43zQKqZsnGLZU6rMC4vyPWymFc2HTXyfZuE6oqIAo6w7dP4du88
         NWnFJfEQx2VMaYsjauLIf8fVV4Njj/wLlCkgyZ2aCKrCOeJg013hPWzWeN6B0fOkCfQD
         NTgyoZXEPH3uVLkfKJPIZtRbtVEI9xWw/X+BNCqgxuVb+kCIr9jh86pp4EPEOIQ6Qmck
         k+MQ==
X-Gm-Message-State: APjAAAWM9Wjr9OPMbAaP+sJ1bzUB7DB/OBI1QhmTzREStFHJJl20Iq9o
	jU15ow4unmR+vx7hYkV5rGgK2Aukw+q+28o64sHWHDW2JfH+a0+tX0OVtkCuB1mc6N7Rj9d4yhc
	E2WoZYBFMun8xVhtpEZUAqdTKI1QgVDhxo3Htr3nJ7/0Kp+UMwm6O75axJYyDIkU=
X-Received: by 2002:a63:ee0c:: with SMTP id e12mr13721164pgi.184.1562156643694;
        Wed, 03 Jul 2019 05:24:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxWP5ibyVHw8K2iCN7p8WtTE1CwLvYiBd2ByOFSScnExyAzHrlNWYFEio3hLN3QeFPF4tOM
X-Received: by 2002:a63:ee0c:: with SMTP id e12mr13721082pgi.184.1562156642776;
        Wed, 03 Jul 2019 05:24:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562156642; cv=none;
        d=google.com; s=arc-20160816;
        b=ztjG5NGfm4JjhdniPwBp1zx3llQX53JaEqYYR0yS31bJH9a+bJegE80mwxT8u+jbaN
         9hEyHdj1NehbBaleuvlJ0I3bGq1Tmvb5r7YtBnFSAK/lNxjidEHwSrI60gDDp0WRTTTM
         ujHxF8vdCx2qroYdjSfpkSzi8EcFDDzxo5mctlYxc/+5+hlfAz/qOa0tw9VX6RMtjISj
         eeq3CZW62T3VQtL63xHxub+1IdIkRB64vFfLIKINjbIje4haISyvVe6nZhdyRdrO5vh0
         SJSDr6tPpP9z+48fLIRSt140cGtsBV0FPEdd/LxCC1ae2q2j8uxy4S5Xg6wHAGyuaOvs
         8Dbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ZFBwbC42pF4/ydEOSJ4y75ZnrJb+ZBbMm/qFm7Ht5k0=;
        b=vg8T4RVxf2SBQTPYKkCFTnuwnCKlB6D8oZO6fhhpvyl4wDjyh1sraCgrzspq8kYoBP
         tkD3GwLLj2RtpgCJTIyndYgIQ3WEJfTLKDMlAMbqH4sYcqOmO+SUQcobnJM5sPugOAwG
         WO+ayDXGteeEsH+VNwpuJUDvfcxgddBPJNqASr2sTNwbFvRTRLZOBhCPX97Zt+/5e7B9
         5g/u2edtt54qcJXjBGtnFgvEt+QXETgJUIsFEbuyVwnhJs8N1rfAdQ8GvinbG8XkqSEm
         eDYvU72ITj4a8c0bX3v0K7lqWH+1ZQU724jdxOkWcJZeejmrBTlLI00SbZorRRZYYDFD
         O3xA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WEx9srRw;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y20si2138468plp.335.2019.07.03.05.24.02
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 03 Jul 2019 05:24:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WEx9srRw;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=ZFBwbC42pF4/ydEOSJ4y75ZnrJb+ZBbMm/qFm7Ht5k0=; b=WEx9srRwWmoqUX7+8/383RgnoA
	JkY9g5iVy2AsFb7crvNngMC9nYxMWlUtCqrN52g21njC+8+Tbwyzj1th2SQC/9Vb68MRJaCdOkIt+
	58E/1wkcRfXTf12JbOQH5edlHDRzkPzOdWiPDu6LqX4AkXipzufsMFiDBgbuc5/+yT39EqLsPEiz/
	uLZmWd5DLgCSDafOJKP7V+kfgpBt8Bf/EZp7hk5snHLffR15fGDXOoYe9ucOHehAAACNgS/uVWofT
	BZdjTpWBb0Lf/XIoTSKMXWgP8D7/gzf6fwicrUI8rZ+tRDhawJFWNO649IsRvKQ7DbhoZ8xN0Qk8V
	HnoKguMg==;
Received: from [12.46.110.2] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hieIp-0002Fv-TN; Wed, 03 Jul 2019 12:23:59 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>,
	linux-riscv@lists.infradead.org,
	linux-arch@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Vladimir Murzin <vladimir.murzin@arm.com>
Subject: [PATCH 2/3] mm: provide a print_vma_addr stub for !CONFIG_MMU
Date: Wed,  3 Jul 2019 05:23:58 -0700
Message-Id: <20190703122359.18200-3-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190703122359.18200-1-hch@lst.de>
References: <20190703122359.18200-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Vladimir Murzin <vladimir.murzin@arm.com>
---
 include/linux/mm.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index dd0b5f4e1e45..69843ee0c5f8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2756,7 +2756,13 @@ extern int randomize_va_space;
 #endif
 
 const char * arch_vma_name(struct vm_area_struct *vma);
+#ifdef CONFIG_MMU
 void print_vma_addr(char *prefix, unsigned long rip);
+#else
+static inline void print_vma_addr(char *prefix, unsigned long rip)
+{
+}
+#endif
 
 void *sparse_buffer_alloc(unsigned long size);
 struct page *sparse_mem_map_populate(unsigned long pnum, int nid,
-- 
2.20.1

