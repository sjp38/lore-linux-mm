Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EB82C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:17:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00A7620879
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:17:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00A7620879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7ABE56B000C; Tue, 14 May 2019 09:17:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 786BD6B000D; Tue, 14 May 2019 09:17:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5887A6B000E; Tue, 14 May 2019 09:17:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 058266B000C
	for <linux-mm@kvack.org>; Tue, 14 May 2019 09:17:02 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id 206so721279wmb.0
        for <linux-mm@kvack.org>; Tue, 14 May 2019 06:17:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ljDEI5wRVFawwIewIlFmLcuWyWda410CfkNvL+gmA1U=;
        b=ar9PFyI7d5vEd7kTsfwOcJmSGp63MBOUbZZqM0ijBfz5cg5rJHyO/xWWScwwSQgCSz
         Wd2JlBYMIuvL1gR4GPSjljDZk2BkgVRzpj9ZT9Vl78L/4wz/VvIQGwVQzmq3sphFuCdQ
         T+p18rnBHICFTLmDNXxERulyS/MvFyN/nrTvc+EciW/637dxonto6iDQUF5936F1Tokm
         PBjq2RlCKZjZFZ9P9x4tsRoSkoEeZs5wtc/PGdThyJmR6QieQVfa5WIfbCFbDxYJY9qr
         tR35gZiwTev/1mD0uh1Y7dLjtQgG/0qfPCd28ki24EtHKSRYBlcmQJv8NS1TdK4OsF3g
         TETg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUmMdD8wuWCA3FBf3ETTMCR/ghH8jb+/N/jV0ccJGU1qiqO4ywe
	doLHrD5UrhnOkX4CXbLPxNSMDVLLbkSbMsAPCAWdbigYUsvwcGKBW/UuG63gFBo9yfabe2Mc4yw
	8AUtKph1RvkQcD/CqBoMphfFLaSKTlRgka4Y47/YZ/QJNhyHff52RpsKdexBFRH8LOw==
X-Received: by 2002:a05:6000:43:: with SMTP id k3mr21866914wrx.234.1557839821551;
        Tue, 14 May 2019 06:17:01 -0700 (PDT)
X-Received: by 2002:a05:6000:43:: with SMTP id k3mr21866837wrx.234.1557839820039;
        Tue, 14 May 2019 06:17:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557839820; cv=none;
        d=google.com; s=arc-20160816;
        b=avWBEnCxV/sKUdjq+5WXyLkGKrv6VxloW6aDyB4zkeR1V2gzh70zDQj6W6GdwOd2b2
         6zZt77A1T8fNIxgWUXY0Hk3B8aUAbLikT/JCRM+C5Vkv4YVZ7/FQrDwlkjSyJxJyjYvK
         7S8N7PWTrNoraxlOR6xgYpSVe2qwMBQ5t+2vdXZFQw6OW77kK3EaYe9irK3PKI645hVY
         qBNmsamMCL70xD5m9CQF+t6iuHAHq/2O+iO8UFypAwWhC/n3kMy4U6wxFvPg8WwGI+eD
         wYAIhMzbqaVh57Uqufjrq+PX7ukXIpzJNsypl6ou2vhi9RdnVQO1ZigJkuShK7VoqHd9
         KlVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ljDEI5wRVFawwIewIlFmLcuWyWda410CfkNvL+gmA1U=;
        b=eSdrU7cRmT4rMLpXKbDxcg+Nh+FuKFAsJFKGQdb6n6Qbd/GmOqks3yccUvYGatVAbo
         3tUlfl+y0B3KSQU2Krjr4FPmv1FWcWdic0TvFItaGBWDrxa1cBp5GK+VE9nL3Qs/Klow
         NXEr9L9rdxWCPx2U0HXE3piBjK8NkMSiZA9fGLQTQpQeAabcIZspjpe1f3gDKSvzLMSe
         Jp76I/YTr/BPu0IgNHiRG6OmBglRTUDr/I+oofLa6RPx6gKVujRYgGZ2oHjkSA52ZSlE
         dmhG31Zp5nA8FgRffj8Jt6mEIR4vpuBj4IvYBvO+quInx978bCsqHc5uLNx3qq+UCSfg
         udZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 91sor3120573wrk.4.2019.05.14.06.16.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 06:17:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqyoalSThS0pSE7N8sUVpxlOVAILQIDieoXie4XGja4UBj+IPrLGODtVhuz+nrtZqWL+oyjzXQ==
X-Received: by 2002:adf:b35e:: with SMTP id k30mr2739640wrd.178.1557839819722;
        Tue, 14 May 2019 06:16:59 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id u125sm7196076wme.15.2019.05.14.06.16.58
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 May 2019 06:16:59 -0700 (PDT)
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
Subject: [PATCH RFC v2 2/4] mm/ksm: introduce ksm_leave() helper
Date: Tue, 14 May 2019 15:16:52 +0200
Message-Id: <20190514131654.25463-3-oleksandr@redhat.com>
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

Move MADV_UNMERGEABLE part of ksm_madvise() into a dedicated helper
since it will be further used for unmerging VMAs forcibly.

This does not bring any functional changes.

Signed-off-by: Oleksandr Natalenko <oleksandr@redhat.com>
---
 mm/ksm.c | 32 ++++++++++++++++++++++----------
 1 file changed, 22 insertions(+), 10 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 02fdbee394cc..e9f3901168bb 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2478,6 +2478,25 @@ static int ksm_enter(struct mm_struct *mm, struct vm_area_struct *vma,
 	return 0;
 }
 
+static int ksm_leave(struct vm_area_struct *vma, unsigned long start,
+		unsigned long end, unsigned long *vm_flags)
+{
+	int err;
+
+	if (!(*vm_flags & VM_MERGEABLE))
+		return 0;		/* just ignore the advice */
+
+	if (vma->anon_vma) {
+		err = unmerge_ksm_pages(vma, start, end);
+		if (err)
+			return err;
+	}
+
+	*vm_flags &= ~VM_MERGEABLE;
+
+	return 0;
+}
+
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		unsigned long end, int advice, unsigned long *vm_flags)
 {
@@ -2492,16 +2511,9 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		break;
 
 	case MADV_UNMERGEABLE:
-		if (!(*vm_flags & VM_MERGEABLE))
-			return 0;		/* just ignore the advice */
-
-		if (vma->anon_vma) {
-			err = unmerge_ksm_pages(vma, start, end);
-			if (err)
-				return err;
-		}
-
-		*vm_flags &= ~VM_MERGEABLE;
+		err = ksm_leave(vma, start, end, vm_flags);
+		if (err)
+			return err;
 		break;
 	}
 
-- 
2.21.0

