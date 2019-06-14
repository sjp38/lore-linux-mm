Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B85F5C31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 10:01:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8978021773
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 10:01:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8978021773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F9BD6B000D; Fri, 14 Jun 2019 06:01:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18D856B0266; Fri, 14 Jun 2019 06:01:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 049CE6B000E; Fri, 14 Jun 2019 06:01:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id D41AA6B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:01:54 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id d62so1567166qke.21
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 03:01:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CgJcDDtOoRdyVXX+iicAe9GvZqRRuW9//gwRK0vdIho=;
        b=K/1bfhVf5+BFD5O0/PBFoOWvxyIf0zaa8iQVNU1VD3e5ApRrXLGVSVWDwOivEEyakO
         kMYN3dr9umjsEzJ1Hbw7BPcM5XFawKP8S2eDc+s444z9e6dQ/lrSsO/Ke0jSDjDXVIXB
         c1/CwzhsUD86rSxZp2wiV1MmjkCosaOHlOg0ZLpJx3i3IibJXjJ3BFLMQWyquAUJaeYC
         RxTDPoApr9L/eppTyEa/eLF8q9KWWm6xZ+yQPWm/Ohgy1x3KaeKp9V6JZ00Qse7se8rK
         kjmI8Z1S8lrMfCnQGViZCtAcnfgms3pQ4jTT20oNalHYPm8zCIDb0aeh78rUhChLxbfN
         Kp4g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWC8/dHbZZMd4YAPPN0h2mgDhAKEmKKiKTMV8LqzKI++nZ77MCs
	66Vpk+icArpZA3Gp+wBkEQeKDRhVcxPFl2zMGTfzVRYs1KbvcpOghfPpexYQhpcz2AgVbqbHPBY
	5Ya9+3Gm8qlZlQcg73X/BqkLHXQQE/sMhoH1Kd6XOwmWjp+n/+EcqY5DOfkRjG2Bxng==
X-Received: by 2002:a0c:d40d:: with SMTP id t13mr7467051qvh.175.1560506514614;
        Fri, 14 Jun 2019 03:01:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwSNszPF9q9Zz6qGqfUlctBXIvdUGYAlNJ0Z3NoMyxdzGEeAny4oxykKLI+iHrT5aWHshES
X-Received: by 2002:a0c:d40d:: with SMTP id t13mr7466967qvh.175.1560506513545;
        Fri, 14 Jun 2019 03:01:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560506513; cv=none;
        d=google.com; s=arc-20160816;
        b=l4j2Bj2neEvhyL4p/J9ZTAZf/iUb91fUWCePPoO4WQSCCfgG62TYTwu9RATRoLE5+Z
         QIEtpEmrDiv2072ZjfF2cRiswpyq+BnuLU1Gqtihz+iwYNuuz56jDzzwaFdXMo4Au2r9
         cLOkvlxqA5xbOzq6Uj0RNBLR/r02l2feBQSikOo135BK9R/muuc9aT7TDOE32on+LWk5
         4J2PGZrRGbYxxieARc6XXTFvBne6NhlWrJekx6S9b2jhnEKzpqfo93VqHJpH83GOiJXK
         tClNYxEydzE4zeNGP7Ux2XpOvexPrgPgEk86lds9uyIsq5HG5LIAre7IEIarpl3yaJ7J
         5ftw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=CgJcDDtOoRdyVXX+iicAe9GvZqRRuW9//gwRK0vdIho=;
        b=tqEX5hZlcGoasbattxKueeskZwQfQ3YiVNOsmDP/uv4S0s0C3D7xsIAFLudvNhx7qp
         s+YAzn20PidHpT5NjEqPqfka2i6ok6UlUWPo1JISNJM2lMUQZCuxjd26pXu429a80y4M
         Veiy9oolT/K8ilxnzKpIQbygXkGniDQ9JaNM7FNNuCgH5Bn/MZzpPPVibh2rnZSQyupk
         IHmVNy7Q0A4pWCorzLUwLNe7HvKYRgtyy6S4q6TvJil9jcIDu+/MuWpFgQJ8RYAk3rJm
         QrAju/53i6hyahHU2/EVxRPG/Tq35jLIOlp8O2LokJZJWvK8vsvf+LO/K6YuVh7bqJl/
         nu5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q1si1489835qkd.157.2019.06.14.03.01.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 03:01:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 264D581F07;
	Fri, 14 Jun 2019 10:01:50 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-252.ams2.redhat.com [10.36.116.252])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 05D8D5DD7A;
	Fri, 14 Jun 2019 10:01:47 +0000 (UTC)
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
Subject: [PATCH v1 3/6] mm: Make register_mem_sect_under_node() static
Date: Fri, 14 Jun 2019 12:01:11 +0200
Message-Id: <20190614100114.311-4-david@redhat.com>
In-Reply-To: <20190614100114.311-1-david@redhat.com>
References: <20190614100114.311-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Fri, 14 Jun 2019 10:01:50 +0000 (UTC)
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

