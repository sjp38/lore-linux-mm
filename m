Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07D0FC04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:11:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4A5E2084E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:11:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4A5E2084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E73D6B000A; Wed, 15 May 2019 11:11:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1219C6B000C; Wed, 15 May 2019 11:11:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E673B6B000D; Wed, 15 May 2019 11:11:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 869466B000A
	for <linux-mm@kvack.org>; Wed, 15 May 2019 11:11:44 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id h1so450838ljk.22
        for <linux-mm@kvack.org>; Wed, 15 May 2019 08:11:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=/uyr94JnPISQut0hE1li4tFRlu1mk248WXZ6mjsl4Mg=;
        b=QzsivR/jn4resc+vYqFHCMC1GcTsIi6wX3qfJ3YFC2/8PpNbw8cOkc/MURXMHNi5vS
         fcCe/+bE9hNrhAGYlw3nKLSqY/5EAvn5kBeJKz2A2TtXNZRvKAzvyv9pt7cxTjPDvPF8
         ITMZDv7wy6sef8jgwohijxQ4whn52DbW7ATYvCzORrxPWEG3wEY7+tWcgTF7Ys2RmQJU
         71ETHFh9clH6DrER3dUJcldhibTYaDOAG2jEaDJzYiprBQiFDuz2guL8YH73gU0Cj3DY
         qWUZLu5uQcANF0nxZV4BaVtFxFL+hUbN39vykoCfaMEQPnLBMVHGZQS/lTw6CcivPoSD
         xwQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAWeg2T8RjbZiNK4dwNY5D6E8wShoUfDGj7Y5/ZsShvl1T6Kspz3
	2q5RHA+bZ+JvompiQZsBI0a5oDj+mpB3AKjZLt4AIArmTh2WQ9yvpScZwvUfvoYi83cQ5VbydJc
	xTsWp2t5m+OxgilaKIcNCtLzsQMDlpMqZt/plC01yR7wNz/1MkomuZ7kVL0JUK/tGbg==
X-Received: by 2002:a2e:2a03:: with SMTP id q3mr20720085ljq.56.1557933104004;
        Wed, 15 May 2019 08:11:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwEVsH1ATBEstD3g0jmVHaXb8Bzft+Xu09Z9x7izEIeO9eywpUglNQ9FtUr8fXJQl8EWwCD
X-Received: by 2002:a2e:2a03:: with SMTP id q3mr20720015ljq.56.1557933102643;
        Wed, 15 May 2019 08:11:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557933102; cv=none;
        d=google.com; s=arc-20160816;
        b=bUJWHrXuaNzU+dXe0BTvkQW0YC9PQzyURPytzKo6m3tVmq/9kxpvAe/E2kT0G9TNYO
         DJ8u6Dyl2/yCEiBgQr7s2FOfdAYL63UijDb8L5tfDQO9vlJlivU3NQ8OdRAmxVnE6cWl
         NWJhx1buU2rTrw53F76DT+i3uW28zEO6+3AIvgiuXzKMI4MZCoTzjR8yJN0n2CedYQW+
         9OXUw8Zl+Sf6zNo+ZdsC8Okjrf1PfgkOc662An0qiFP949lKn/OaFZX9WMcKEQwRQrnP
         QrELCC1nggAu5vK8dDkuWZ8+jawiBdJSzBO2G2uImRfSNEvMSLRF6P6lVTPhEbiiSw/2
         pXoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=/uyr94JnPISQut0hE1li4tFRlu1mk248WXZ6mjsl4Mg=;
        b=PoBwQd1vzSrsVNtwRol7m0mW2cg1KFez3oIQ2kOuqbYXfm8KlaIs+BpXOXGkmmsKiz
         PA2A3NuLitk7RGanRxeKRiOBGQK7ATbWJipP9A5gg48fXKwLUKV83twd8Fi0Lt2vROJ4
         a4d7MaHnaMNRQZQUFrW8Vj9FYE/zGLdxmpEy0kt3V7p9h4Z1HATdj7vkCQe31M8VVTls
         AzrJC+RQThcSBR/Hgd4EmIZquAifrtZxIY1JivvY0Cyfnm9eEPLGtkzmbeJqI7xwxa1I
         LVKFSj0l+F0TdBKIX2ipaGiEJuiBISRjgojg5mTAhFa1YJG/zoNKWhfoSB9vQQL6/ZOi
         t6hQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id t4si1730759lje.28.2019.05.15.08.11.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 08:11:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hQvZD-0001Xm-0R; Wed, 15 May 2019 18:11:39 +0300
Subject: [PATCH RFC 4/5] mm: Export round_hint_to_min()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, ktkhai@virtuozzo.com,
 mhocko@suse.com, keith.busch@intel.com, kirill.shutemov@linux.intel.com,
 pasha.tatashin@oracle.com, alexander.h.duyck@linux.intel.com,
 ira.weiny@intel.com, andreyknvl@google.com, arunks@codeaurora.org,
 vbabka@suse.cz, cl@linux.com, riel@surriel.com, keescook@chromium.org,
 hannes@cmpxchg.org, npiggin@gmail.com, mathieu.desnoyers@efficios.com,
 shakeelb@google.com, guro@fb.com, aarcange@redhat.com, hughd@google.com,
 jglisse@redhat.com, mgorman@techsingularity.net, daniel.m.jordan@oracle.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
Date: Wed, 15 May 2019 18:11:38 +0300
Message-ID: <155793309872.13922.9196517703774034670.stgit@localhost.localdomain>
In-Reply-To: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
References: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 include/linux/mman.h |   14 ++++++++++++++
 mm/mmap.c            |   13 -------------
 2 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/include/linux/mman.h b/include/linux/mman.h
index 4b08e9c9c538..69feb3144c12 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -4,6 +4,7 @@
 
 #include <linux/mm.h>
 #include <linux/percpu_counter.h>
+#include <linux/security.h>
 
 #include <linux/atomic.h>
 #include <uapi/linux/mman.h>
@@ -73,6 +74,19 @@ static inline void vm_unacct_memory(long pages)
 	vm_acct_memory(-pages);
 }
 
+/*
+ * If a hint addr is less than mmap_min_addr change hint to be as
+ * low as possible but still greater than mmap_min_addr
+ */
+static inline unsigned long round_hint_to_min(unsigned long hint)
+{
+	hint &= PAGE_MASK;
+	if (((void *)hint != NULL) &&
+	    (hint < mmap_min_addr))
+		return PAGE_ALIGN(mmap_min_addr);
+	return hint;
+}
+
 /*
  * Allow architectures to handle additional protection bits
  */
diff --git a/mm/mmap.c b/mm/mmap.c
index 46266f6825ae..b2a1f77643cd 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1318,19 +1318,6 @@ struct anon_vma *find_mergeable_anon_vma(struct vm_area_struct *vma)
 	return NULL;
 }
 
-/*
- * If a hint addr is less than mmap_min_addr change hint to be as
- * low as possible but still greater than mmap_min_addr
- */
-static inline unsigned long round_hint_to_min(unsigned long hint)
-{
-	hint &= PAGE_MASK;
-	if (((void *)hint != NULL) &&
-	    (hint < mmap_min_addr))
-		return PAGE_ALIGN(mmap_min_addr);
-	return hint;
-}
-
 static inline int mlock_future_check(struct mm_struct *mm,
 				     unsigned long flags,
 				     unsigned long len)

