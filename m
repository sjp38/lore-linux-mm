Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A49E0C76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:22:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76EB8218EA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:22:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76EB8218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 053DD6B0296; Thu, 25 Jul 2019 05:22:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 003DF6B0297; Thu, 25 Jul 2019 05:22:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E35728E0057; Thu, 25 Jul 2019 05:22:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id C30596B0296
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 05:22:13 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id 199so41922569qkj.9
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 02:22:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=tAfcsJ/o8BSdIR7kvDIEFhQqbQgQuionX07qJ9nVKK4=;
        b=TugwhXShAaVsQYjspmw7CtRUfhjffHH2IBYOgb7+MOlIyuI2fXyv60rS+nS6WIGb72
         wdRc3vEokGp9YvtuPd+TOFC/sJILeby460rmkc0q7KL75iQ/AgVormqgItdfbGduTFwU
         GuLHiG2hn41OxFdfnupArhHDSc3ylply37Yo3q8nHk/GD4VmnAY5E2FmFkIRspOZ6xE7
         I2F7k5pRNeC7YpeNP+msLDTsI5Kv1mb/A13cjC8Cy9j1PFnQrCC+r9vAjDEUm7seJwbc
         iePGvc98TDaoK9L4t6BeqlX3tmKj1/+1fW7FzgTpr8ePnIvC+fBrRidb/RCcpJeB94du
         r8hw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVJ2ovTT5DTlVSYDzxuxWJBQOcYRtdiF5LQpxrK5GoGWBo5011w
	jBl3fK+WUQSe/NZhzvNLLCFj8xjTkhht3hsuuuKXyGdDn1kY3okyJ3SGLssrPafAMxKweS/8tPR
	nGIYLdKBRLDbM/p35zGxHRmylzo6egPvSXDMaofA1a+pVUuwPk0gCv/twCvaToXLN1Q==
X-Received: by 2002:ac8:19ac:: with SMTP id u41mr59684677qtj.46.1564046533523;
        Thu, 25 Jul 2019 02:22:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3DpChHA5qsq9IzldIDUOcChureS4HrWGfwakWRLqlKOntzqYvlyBZUHvzd/6FebVLtdvx
X-Received: by 2002:ac8:19ac:: with SMTP id u41mr59684641qtj.46.1564046532660;
        Thu, 25 Jul 2019 02:22:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564046532; cv=none;
        d=google.com; s=arc-20160816;
        b=Q8JDmoeMLB9qWCS6td+Hl6RHGdHga53QA2NUq/e7AZNkPe6xmjaXhWXZrflwmMQ4KL
         cx9oQs7rOtJhdEG2g68ql5Ak9vEpXrqh1Xj038GtUCyzQgzUKDOlzi/GsNzzUC8x4K5p
         /UzM0xtem/P0NCYt8cHJO7q9bXVSga+KJvn2aE1HcuRBGMpbbQoNPtG2zrieCauwSsJU
         nMO7TEooLkCF2TLlZhFUKTakzk88nvzDVMI1OdbC6zwaA1xlBiddsJTnr2+FTMqy76/L
         vrZHSkoLShPPlma3bnhRW8oAaAN3Fg+JRsggbM2l6HNSN4bGPL53R5bwGqANJTVjabaa
         46HQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=tAfcsJ/o8BSdIR7kvDIEFhQqbQgQuionX07qJ9nVKK4=;
        b=gzbqEsw8CQ5dYt2/FpmpM5ae06BsgTecqXW2QpQ4+0mXd8jvyt4KZtimoCeTlb4nab
         /TQuT/4zgReYJAYlFrCHs0recylhRlQeiPKAegRV33lwvCzNrQbRDIY/6z7ClmaH9mMV
         EWQ/POPXyvF7SR0BgrOizIptp4AC/0lBAEvAMJQi5svfsROjuanyX5Fb3qc/Jojv0J6i
         jvhgmuNvKdYvEGGgroHcMAKJqdTvLBmlYJTO95Fym4eHUYpWtNblql/OHg+SXtcm2FnG
         eY59KhUFs2WhS37NwfZsp59bL5IXvWXD5WgSa9piEHAmJiVZ2h6ySYk8eZU8sIZEcZby
         C+MQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n1si26609934qtn.402.2019.07.25.02.22.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 02:22:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C36A230917AF;
	Thu, 25 Jul 2019 09:22:11 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-212.ams2.redhat.com [10.36.117.212])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7D39D5C652;
	Thu, 25 Jul 2019 09:22:07 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: [PATCH RFC] mm/memory_hotplug: Don't take the cpu_hotplug_lock
Date: Thu, 25 Jul 2019 11:22:06 +0200
Message-Id: <20190725092206.23712-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Thu, 25 Jul 2019 09:22:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Commit 9852a7212324 ("mm: drop hotplug lock from lru_add_drain_all()")
states that lru_add_drain_all() "Doesn't need any cpu hotplug locking
because we do rely on per-cpu kworkers being shut down before our
page_alloc_cpu_dead callback is executed on the offlined cpu."

And also "Calling this function with cpu hotplug locks held can actually
lead to obscure indirect dependencies via WQ context.".

Since commit 3f906ba23689 ("mm/memory-hotplug: switch locking to a percpu
rwsem") we do a cpus_read_lock() in mem_hotplug_begin().

I don't see how that lock is still helpful, we already hold the
device_hotplug_lock to protect try_offline_node(), which is AFAIK one
problematic part that can race with CPU hotplug. If it is still
necessary, we should document why.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e7c3b219a305..43b8cd4b96f5 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -86,14 +86,12 @@ __setup("memhp_default_state=", setup_memhp_default_state);
 
 void mem_hotplug_begin(void)
 {
-	cpus_read_lock();
 	percpu_down_write(&mem_hotplug_lock);
 }
 
 void mem_hotplug_done(void)
 {
 	percpu_up_write(&mem_hotplug_lock);
-	cpus_read_unlock();
 }
 
 u64 max_mem_size = U64_MAX;
-- 
2.21.0

