Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47635C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:17:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08CEE20879
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:17:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08CEE20879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27CD76B000E; Tue, 14 May 2019 09:17:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 204C36B0010; Tue, 14 May 2019 09:17:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F79B6B0266; Tue, 14 May 2019 09:17:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id B4A836B000E
	for <linux-mm@kvack.org>; Tue, 14 May 2019 09:17:04 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id y187so720843wmg.3
        for <linux-mm@kvack.org>; Tue, 14 May 2019 06:17:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=4NHszGXSdUYSHK5uiVaOzd/y+HHMtNL3fJ2rPoCVo3g=;
        b=XUAtjZS/9fzK+wy3QZxFQtKx7PjZvImbQ+7YVpByAcgua7iCFVW4Bge27fuXmclINO
         dSOfBrT3sKdx5GsWY2xGTvYvJ0Fp0enzuiPY/JXVTjm+zRDi/mnLeU5kpBYmADLkOJKK
         2GMG6IH3MVvVNNSNZApiS2HzM78bq+GHICcXBTkfE+fFDskRx+rGpCjgvyJWll2YIGFQ
         DIzcqMTb0XPX4zZzhbNK/x8C4AyEXtnjRMVXUScLuqpsRYnK2dg7+PshdopOi4kVxYy6
         LmCYxNxtCePeljoraj3QMouqo152gb2fnqWikthkoSanSJEAlulMdaBe/VQDrTRgGXGh
         G3Pg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWhS+/+00co5sX5T1Ej5j2sdN7CTr8T7WKL8ASEUTJ77VkP+0zh
	kL0LZKuHBAcBlefrTWl9dhvjYBU6q5RoYIN5t82bPZZN5AoOcbsWznB51J6E9R++Ta7VZjlx1wc
	Cr+zsLqy1vb8zWyIPJl/lUrdg9FOOSHSNB1u0Tw9/WY3f9azsnZKlWMtwCPpsJBrj6A==
X-Received: by 2002:adf:eb89:: with SMTP id t9mr18116644wrn.109.1557839824149;
        Tue, 14 May 2019 06:17:04 -0700 (PDT)
X-Received: by 2002:adf:eb89:: with SMTP id t9mr18116569wrn.109.1557839822917;
        Tue, 14 May 2019 06:17:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557839822; cv=none;
        d=google.com; s=arc-20160816;
        b=kZ9h0U4Qn1DAduVcwTWx5BfZM28htZjuMQ9kCv2cr+5SYKYLMg1qu3Y58GGaPnagGL
         nfKkZNva5IkoZs3ByPWW+v2Ete8LuxvuvSCN7SRGf4MDEK5DOYg6xfteAF2v4wPvHV40
         eppDaWS3Ma6RPLhywYjRmNNEX586OwlNPdWja4S3GN7VlIVBuk6ESRnCPyD8jrzG2eFO
         vPZo6wIbECwYY7j7wF+8jhAn5Yov3FEV9rI8QrzYL5g8+FRXqC41u5Hl76eopI1W9zqv
         r+OHJ2pw73ebAaXITUHlVDh/Kijw8GME0nf+sWVUEWLFhAW2/wkN1CS/iUv5cauylKbb
         FhUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=4NHszGXSdUYSHK5uiVaOzd/y+HHMtNL3fJ2rPoCVo3g=;
        b=Ek4B3MqyeqFE1uBVQpkNPmFPzVljqphT8afQHypHM9WKZlEA6yLc7WtQ9+qYBVZN9z
         l1Hs+B0UZkgh16QqrMCDjfWXo0HaqjVGQBXlmCY2hM+iQYONBZpJV0xG0azwrYFx2dHT
         Mx1anKefOmIgl1TpyupNf69uJNVMYwGk4DAOYOopuveFIVGlDujNWK1C6MDSG4JmKc3w
         sEzPxNSfcnS5uVBOTgnSbMdrbubCbQ8Fe78CnOPY03j0NIiSS6MN5SVHHmTfjatDhQJQ
         j3LdRC73tfQFMbSZGwHEvjWdbwcOLIPjh8DGmwQKc7xK7jvmWBmBmCOvv01vqe+iqfqc
         fSGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u7sor3088446wro.35.2019.05.14.06.17.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 06:17:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqz90MXu1Y+IegMsTYBwvQ7q04E4Nwy8CUaUfOYUksdQNjQvegVE/S1PVrMeC+cUogaaT3sQLA==
X-Received: by 2002:adf:cd0d:: with SMTP id w13mr21219109wrm.38.1557839822566;
        Tue, 14 May 2019 06:17:02 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id o4sm3420247wmc.38.2019.05.14.06.17.01
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 May 2019 06:17:01 -0700 (PDT)
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>,
	linux-mm@kvack.org
Subject: [PATCH RFC v2 4/4] mm/ksm: add force merging/unmerging documentation
Date: Tue, 14 May 2019 15:16:54 +0200
Message-Id: <20190514131654.25463-5-oleksandr@redhat.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190514131654.25463-1-oleksandr@redhat.com>
References: <20190514131654.25463-1-oleksandr@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Document respective sysfs knob.

Signed-off-by: Oleksandr Natalenko <oleksandr@redhat.com>
---
 Documentation/admin-guide/mm/ksm.rst | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/Documentation/admin-guide/mm/ksm.rst b/Documentation/admin-guide/mm/ksm.rst
index 9303786632d1..4302b92910ec 100644
--- a/Documentation/admin-guide/mm/ksm.rst
+++ b/Documentation/admin-guide/mm/ksm.rst
@@ -78,6 +78,17 @@ KSM daemon sysfs interface
 The KSM daemon is controlled by sysfs files in ``/sys/kernel/mm/ksm/``,
 readable by all but writable only by root:
 
+force_madvise
+        write-only control to force merging/unmerging for specific
+        task.
+
+        To mark the VMAs as mergeable, use:
+        ``echo PID > /sys/kernel/mm/ksm/force_madvise``
+
+        To unmerge all the VMAs, use:
+        ``echo -PID > /sys/kernel/mm/ksm/force_madvise``
+        (note the prepending "minus")
+
 pages_to_scan
         how many pages to scan before ksmd goes to sleep
         e.g. ``echo 100 > /sys/kernel/mm/ksm/pages_to_scan``.
-- 
2.21.0

