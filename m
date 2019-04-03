Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DB36C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:34:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 551E32084B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:34:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 551E32084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D62BF6B0274; Wed,  3 Apr 2019 15:33:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE9826B0275; Wed,  3 Apr 2019 15:33:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B89136B0276; Wed,  3 Apr 2019 15:33:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 92CAB6B0274
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 15:33:43 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id g25so130231qkm.22
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 12:33:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jtYULlHKq/3/5SkfVuC3rY1FhUrrAMSpMPLKLzXxOkE=;
        b=YsaZ0kdYg9HtU71bFjZGW0DU8l7gUQd0tkSOjkVPvIsI0F3fxJagSxL2oFw1tf6tf3
         n+i+0svNDBhQJP+px9LWkvUPpVWZk5iuNRTS5wYP+M1c9cvh7Yuyf8tsgNWRqP5gBQ97
         bvn6YImN4IYy3LqJi+XBS5hCYzzr8lGZaq318BA4m2OPdq1PFvu53QHYnIbg7pQYfPuO
         XcBu2S9W7Q8wjkOvlta2b015MktkF+yuXcP1wr+C3IF/j5ARucS+UVU9A2iX6goygkRQ
         o4f/UK8a8zyRhw22iw8S1EsLfrJIOcXg59IvCn94Lz6jxd/gLPOcBb+VNA79ZMiyl9Uf
         KRlA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXK72yPmnFZ05s2CnKqEx9ohKVpP+xQTh/di09VpxFH6lfE0DMb
	xW9mxtoYPP9R6g3HadpZfa8H0ttQCPNP5bKY6xVbTpHj+EPjdVlHPoiOrFEIyw5gpC7YbNTmm6z
	TM/1K3xC/klAM2OvgyBLRWWaQxTRj6maaDSpMHxvWGzF3LtYhfDTKvLDpYV0gTENOZg==
X-Received: by 2002:ae9:c219:: with SMTP id j25mr1671260qkg.82.1554320023381;
        Wed, 03 Apr 2019 12:33:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1UJd9QfSHQjm4HKLmBjUBl9xPgOqtBol9N6qteWZxICfyQ9rnqh3KHzypgwBDuHYPHUjV
X-Received: by 2002:ae9:c219:: with SMTP id j25mr1671220qkg.82.1554320022857;
        Wed, 03 Apr 2019 12:33:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554320022; cv=none;
        d=google.com; s=arc-20160816;
        b=jTk2e5PkQ4dVJjDkvLMI5cNUFRH4vxSrynn77gEr5OCUFrkLP40bMde6vPJVfCRLxR
         mpcKiZLuy8Jlg71HUKwhRuLIGRpzejUBXO8tW2SLG37PEVDA+QVu5jDbFrf81cA20ILH
         ErIvnh2GNqoX9lCETx8U82pQLHTjQLYz7qC3Y7JnjY0ShJ4t3xafZ51/fuAeyo8RGt2m
         7tSFDGIL2Y8ZHQ7YMzKzyRGSsfDiZ+GfLMmBzsIzfKi2vEawgk2+tJHNXUl5QGjzoqlA
         WX+1vcGNCld8Nm9zYrI3JLtq8v/dhkpRz+rRzOkqV0ZKsgTYIa94uyzuzaMUYhMvrcee
         jbpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=jtYULlHKq/3/5SkfVuC3rY1FhUrrAMSpMPLKLzXxOkE=;
        b=Am4TyTiTfwIcCFNV0fJIObmC/0Aq3503+knwSinRA1CSAnhnyuIUb3MWwq6trIMaIt
         r9QqEpd2OMmUEE+uUbVv73oYaArd4bNwZ6BLgzcuDwbvZcOUgM8Xy5z6GTrhJwewKzbH
         xnesFGQDOmGyDz+TyzyVaone9+JInCBGYtEbvPoCjm1e72lqwntP1HOPLaaNNo+V7dh7
         JdG/t/6Rl4fO2JkwLGTJVQf9tK6ZRZteX5g9Xz7Uz5wdUj/iYPg0boRiOJ4qRQLe7pbM
         Jt5V6XkFt8IIAEzCVpBCgzWgiEBbdXu6s/Z8DG53fyUh/QbRDLVhV18joyFyPXeghOpu
         LV0A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u13si5148974qve.103.2019.04.03.12.33.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 12:33:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 21AB33001C82;
	Wed,  3 Apr 2019 19:33:42 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-125-190.rdu2.redhat.com [10.10.125.190])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 034E2605CA;
	Wed,  3 Apr 2019 19:33:40 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Ira Weiny <ira.weiny@intel.com>
Subject: [PATCH v3 10/12] mm/hmm: add helpers to test if mm is still alive or not
Date: Wed,  3 Apr 2019 15:33:16 -0400
Message-Id: <20190403193318.16478-11-jglisse@redhat.com>
In-Reply-To: <20190403193318.16478-1-jglisse@redhat.com>
References: <20190403193318.16478-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Wed, 03 Apr 2019 19:33:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

The device driver can have kernel thread or worker doing work against
a process mm and it is useful for those to test wether the mm is dead
or alive to avoid doing useless work. Add an helper to test that so
that driver can bail out early if a process is dying.

Note that the helper does not perform any lock synchronization and thus
is just a hint ie a process might be dying but the helper might still
return the process as alive. All HMM functions are safe to use in that
case as HMM internal properly protect itself with lock. If driver use
this helper with non HMM functions it should ascertain that it is safe
to do so.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ira Weiny <ira.weiny@intel.com>
---
 include/linux/hmm.h | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index e5834082de60..a79fcc6681f5 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -438,6 +438,30 @@ struct hmm_mirror {
 int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm);
 void hmm_mirror_unregister(struct hmm_mirror *mirror);
 
+/*
+ * hmm_mirror_mm_is_alive() - test if mm is still alive
+ * @mirror: the HMM mm mirror for which we want to lock the mmap_sem
+ * Returns: false if the mm is dead, true otherwise
+ *
+ * This is an optimization it will not accurately always return -EINVAL if the
+ * mm is dead ie there can be false negative (process is being kill but HMM is
+ * not yet inform of that). It is only intented to be use to optimize out case
+ * where driver is about to do something time consuming and it would be better
+ * to skip it if the mm is dead.
+ */
+static inline bool hmm_mirror_mm_is_alive(struct hmm_mirror *mirror)
+{
+	struct mm_struct *mm;
+
+	if (!mirror || !mirror->hmm)
+		return false;
+	mm = READ_ONCE(mirror->hmm->mm);
+	if (mirror->hmm->dead || !mm)
+		return false;
+
+	return true;
+}
+
 
 /*
  * Please see Documentation/vm/hmm.rst for how to use the range API.
-- 
2.17.2

