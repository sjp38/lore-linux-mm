Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9FAEC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 10:35:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A03AA2082C
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 10:35:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A03AA2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D9816B0008; Thu, 20 Jun 2019 06:35:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 763C48E0003; Thu, 20 Jun 2019 06:35:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 603DB8E0002; Thu, 20 Jun 2019 06:35:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3AADB6B0008
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 06:35:51 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id r40so3064040qtk.0
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 03:35:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CgJcDDtOoRdyVXX+iicAe9GvZqRRuW9//gwRK0vdIho=;
        b=ZcnUJW+C/3eu68iHjq6ZYfpQ4E1rjqj9eXaPjIJ63lbLyBQZZebPEjAsgSyGZ5HrWf
         U/fGt4wEF/AciK81S/v+KYV7T3Fr+iCI0gJ4Ymj6blb7EwBMH3ruA5FnQE++PU/DCxc1
         g7PLf9ZLZgo0zZ9zEMZFXgj5TKu2OuLurF7aUZWfiCO5iPPBHx1tkIkZVQ6VB9QyaKE2
         QBYMTI+EqaLsqZC6di45es8a6m1vS/nQiRaMCA2x1zNCG+W2EM9cg4qlaPv6Hlpy+QUU
         1+giSQ/WaDR+GVyAelsUiB+IRWF1wSKWUplBUHd0oPjU5kXVNGH9xVM8MgMV1o98kIyM
         bujQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUV2QgtUZF19uWTOtdxAxFST5uJ/CLET4sqIP9TD/xquY4V61iS
	4ctzvx7WDyXQ0F3MTdX+WiYUZO+jTJwef3mpiImPjGn9WRalubS65qpsyE2zv74ayz7ywCF1sHJ
	3ANVd+f4fSNoZtf3HsxEsxJaP+25owGUlmi6FHOfPaMB13M+dF132sz/kYtgHNEol8A==
X-Received: by 2002:a37:4887:: with SMTP id v129mr24712197qka.17.1561026951002;
        Thu, 20 Jun 2019 03:35:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9rIxWn2pQR9fJuIlvyt3htGTOaQV/hb/F1E0KkAn7kTPqT2m6ige2AuiJEf60Nvkjv+Ef
X-Received: by 2002:a37:4887:: with SMTP id v129mr24712152qka.17.1561026950234;
        Thu, 20 Jun 2019 03:35:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561026950; cv=none;
        d=google.com; s=arc-20160816;
        b=GWJYlVj/lyHgI5EjW3uVMatsOVmF21L44sEERm7BAGfhS5fnqxqZ+CxqWydDlTjNQg
         k/R9aGCOulCr8tzahjRPME0RSCMH4P/davYhiR9sinG8aPDwHHS3mqhg08ECN2pwqB0F
         YRfgr81EKk2HcpQo4hAGflEq1ADEfuCFFA2jmGg7NRmJoNAvAB9GGZI9Qk54RjkImvHc
         Gm14yD8tQaOi/y2cBfdIN4ARbBVDVaqkcaL3dwRZ5Mu+k8mOu6VQEMigqUJnQThcevq6
         6rnkviD4iHcmqdtSBBlF7gkgkB2btYZclm1zwPi2sfEUDQYRxzNACfdqYRo+b/BsV1R+
         XfZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=CgJcDDtOoRdyVXX+iicAe9GvZqRRuW9//gwRK0vdIho=;
        b=lOTzuc9225l0NfSnuIrK01cdC0cln7nojlzdBh+L25cxThry7BWbH5CcXdy4qCk7YI
         Hay+en8OuSNq50G+M/UhNo6X8jY38VMGg3hjnX6bucfMwE/rSGdzENiU9TCfVcoeoYow
         qhhS2f/+e5G8Qzv/TIWzWNUFe3tEYHnYcDjvnNgY+i3MrQq175g8Ds2f+c742oTZbzPl
         p1io75gno73lUKuHjY9TjKGwiTiUDJMC31fQzyCSZIYZJprPxCL4NcWDEPHgwB5EQj/3
         KHhMl6BfEErQki8kJyjJbovB8ourDdXfU7qsb5bIiuCNr+zIo8KcEFRtSgNfjsnCsNmD
         y4uQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u28si13938963qkj.169.2019.06.20.03.35.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 03:35:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7828130C2534;
	Thu, 20 Jun 2019 10:35:49 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-88.ams2.redhat.com [10.36.117.88])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 53CE860600;
	Thu, 20 Jun 2019 10:35:47 +0000 (UTC)
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
Subject: [PATCH v2 3/6] mm: Make register_mem_sect_under_node() static
Date: Thu, 20 Jun 2019 12:35:17 +0200
Message-Id: <20190620103520.23481-4-david@redhat.com>
In-Reply-To: <20190620103520.23481-1-david@redhat.com>
References: <20190620103520.23481-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Thu, 20 Jun 2019 10:35:49 +0000 (UTC)
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

