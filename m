Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C2FCC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 18:32:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1384620665
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 18:32:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1384620665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53E038E0001; Thu, 20 Jun 2019 14:32:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E99F6B0007; Thu, 20 Jun 2019 14:32:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D9D48E0002; Thu, 20 Jun 2019 14:32:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA168E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 14:32:16 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id e39so4796971qte.8
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 11:32:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CgJcDDtOoRdyVXX+iicAe9GvZqRRuW9//gwRK0vdIho=;
        b=gfoXD074oqntlGsUqQLw/XjV/Fgy6SuYFhWXDd8wAbB2JFt4EixJyPLC2pUwJhndyz
         qodUS35n/HynBzwTqpYgp+UHbbPJZRZlM9fmfVtLSZm1LxQzKSW4d0W7FF8/oZxziCWd
         M8ME/uuDxfqVLTuamosrGIOFO0G9E3LgLpLz/lDZ/lG8SBcOwUD+GvX2PpLlCeHMMTkA
         /uAxrYHmLVZ767rGmJPV3h9nIWxGCOx95pVeOp8cO2QZ4mujhGrWEiPO/erUWABHnYG8
         634kprjP+fVTop4iN78glzP7zPdl4/CHJHpxBpBi9x+6tPymzNk/nQ9fpQLBULPEvFSQ
         14TA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWxlrbJtDlrJaUzgYdEC+d6ypHhF1cy/tQcvAqp3rqTTBYf8H6H
	+WOipvrdnbz/GDTanndyYjdso+QWDKF58P3QkJkgF+5BCgzmq4ory2bjlkehnmg1jkSWB9CVElm
	58IskLOgPulSg/JSNyz56F63b1Jt/6L0PIzcQhFTFXWOcfr63/O6sg5ENkrgI5LtMpA==
X-Received: by 2002:a0c:876e:: with SMTP id 43mr7875471qvi.61.1561055535818;
        Thu, 20 Jun 2019 11:32:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfqIBQxi5Z2IySHgJawDOW41ftQEvnw69oPQE2s5FAD3GBtSNhBC3Y/V7HJdwy53Vx8e4I
X-Received: by 2002:a0c:876e:: with SMTP id 43mr7875385qvi.61.1561055534843;
        Thu, 20 Jun 2019 11:32:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561055534; cv=none;
        d=google.com; s=arc-20160816;
        b=IQXfAv00GUr0VlYn0/6UAXCWyP9v6KT5JSh8sEHaXKLQuhb0S8yA71Q5MPf870fQPL
         UOWksavuVZTHw2RGCEHsOQPadYpPkTelbkaoY0aJjdwFu+nSAYqSssiKr0Z/pxvA21G7
         GLM7BS7mwJo4Dp2zPapTtO1ZlSVxJzYhSe+Ou4kPvJ+3gAVBB7BQYSGvxMUl/LmFmwEy
         NckdDIidqu/1rlhlln2pv6zf6diNjBHlKajpjIbFPRAgNURCIxzq3GlfUdn/jflqNj3k
         l36IU5tq3ceH37STBVph3GG3dxXwP3//jREhTIxY8uYLo7MDjfZq/EdGBepKTGZM9xVV
         ZCQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=CgJcDDtOoRdyVXX+iicAe9GvZqRRuW9//gwRK0vdIho=;
        b=GCX2DpkBCwfu6b51l3o0e7roudZJKaXrn8AWFV0RNZZ/fBVm/tNTwKtgKn8IojbqR+
         FkInE74nOJBQsU4nAOBJZwrm/FJ5of3X50+SWO9Q6hF5Z/g09oVXWYu/N3DBygqEVJCa
         /7YtYqDd+PRxzPgkedOpSnsGZczx740QaBtAvcoCiGhBHpZBfeobUe6/BqioazQp636t
         6BIF6bjUcObqLoKuUmD9zgdfwOPX6e93MWrhdHr9UiiKHrJcVhRW1mksIcbL4xpXfReS
         IdkXQB7h021ElAGsD5ASUQvAV/f4DoJ+xC+c8SMh6gFvLGh0t6L5t86uIt+sP+B7/UA/
         4ZVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a190si94909qke.379.2019.06.20.11.32.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 11:32:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1785475726;
	Thu, 20 Jun 2019 18:32:14 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-71.ams2.redhat.com [10.36.116.71])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E49CA19C5B;
	Thu, 20 Jun 2019 18:32:11 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Dan Williams <dan.j.williams@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linuxppc-dev@lists.ozlabs.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Keith Busch <keith.busch@intel.com>,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v3 3/6] mm: Make register_mem_sect_under_node() static
Date: Thu, 20 Jun 2019 20:31:36 +0200
Message-Id: <20190620183139.4352-4-david@redhat.com>
In-Reply-To: <20190620183139.4352-1-david@redhat.com>
References: <20190620183139.4352-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Thu, 20 Jun 2019 18:32:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It is only used internally.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Keith Busch <keith.busch@intel.com>
Cc: Oscar Salvador <osalvador@suse.de>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/node.c  | 3 ++-
 include/linux/node.h | 7 -------
 2 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 9be88fd05147..e6364e3e3e31 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -752,7 +752,8 @@ static int __ref get_nid_for_pfn(unsigned long pfn)
 }
 
 /* register memory section under specified node if it spans that node */
-int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
+static int register_mem_sect_under_node(struct memory_block *mem_blk,
+					 void *arg)
 {
 	int ret, nid = *(int *)arg;
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
diff --git a/include/linux/node.h b/include/linux/node.h
index 548c226966a2..4866f32a02d8 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -137,8 +137,6 @@ static inline int register_one_node(int nid)
 extern void unregister_one_node(int nid);
 extern int register_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
-extern int register_mem_sect_under_node(struct memory_block *mem_blk,
-						void *arg);
 extern void unregister_memory_block_under_nodes(struct memory_block *mem_blk);
 
 extern int register_memory_node_under_compute_node(unsigned int mem_nid,
@@ -170,11 +168,6 @@ static inline int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
 {
 	return 0;
 }
-static inline int register_mem_sect_under_node(struct memory_block *mem_blk,
-							void *arg)
-{
-	return 0;
-}
 static inline void unregister_memory_block_under_nodes(struct memory_block *mem_blk)
 {
 }
-- 
2.21.0

