Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C1C9C10F03
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:40:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD9812087C
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:40:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD9812087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E887F6B026B; Mon, 25 Mar 2019 10:40:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E13DF6B026C; Mon, 25 Mar 2019 10:40:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C42C46B026D; Mon, 25 Mar 2019 10:40:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 975836B026B
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 10:40:24 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id x12so10376556qtk.2
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 07:40:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3Ti6IjAWZ9nxGji48U2finShhN9k8Ywg/5Fu3MYAh2E=;
        b=pHTejNRsOh2StvbfUohWf4zqb2jA/eYa8WZEOfK1lsdGUO9ev+w1k3peDK4bsiP7YP
         gGB81vfnTcituxN8HA+XDs9inPj9DukLe6rZi0eaJC67OUHMPVZbEvzIyw6HCzLHZFkF
         LKtclqXuUQMlyFK9aMoXLjjEeLFMiZo9a5GvH8JIg9+j8oGwbI9V+iQjTUoWqoZsR/XI
         vJta7t4gLCAuaMrpbrzz3xp8TlyODTUfc2iu4M0mYZjBNSbcU6yTVIJZeDVH8DhDQzSB
         FGbaDWt4JxKpJh6Rv+tRPgP0nlMZQInbCD7w33v0+8viW5Qj6iZYQnP3Dvqv3N4NJH4r
         wvEw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUuUgyLd55CP0pncw92O5rCGdVt3+9jdiSJzP9G1RouCOneDU02
	dRdLvIDjB7CRNK+myUWdBn/5TevLMmXKHAS3PXPDJRgGGYCiPzvv3hGmmuh5lWkavTdRDpgbJzo
	P+kOL7p4OMBVeU8tMd4H917RNckj/K+R03dq7sGOP3oYGNgZC7d/FnvkL7xEIKR7SKQ==
X-Received: by 2002:ae9:df41:: with SMTP id t62mr18588024qkf.150.1553524824359;
        Mon, 25 Mar 2019 07:40:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsHbmjhw+8w4oeQfNeqRp0OA9YeOtyILg8DCdvm10zPywiGBTb/fWWFaP0qp+wdLt+TbfC
X-Received: by 2002:ae9:df41:: with SMTP id t62mr18587972qkf.150.1553524823657;
        Mon, 25 Mar 2019 07:40:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553524823; cv=none;
        d=google.com; s=arc-20160816;
        b=Ry72aUJD6DI9cFrz88TVBL5UfrNK2hX84NwKl/W8bLw6zcwY9Cag/S05Vgd/2hC8wP
         B1aLFJd7UqeLjY3uHc3NWDHzMWGMCU25SmQPK8xQUG4W8fWqkkRKYmZSbfypKdzTLkuV
         SgFcQPJWdtdffkn1W9qRBloGA2ydbtc0RP0NEDC0j92mB0FmT6PvWxfD/qtiMJ6wtNct
         qYIV0bQpMCvCWqh7fFiVeCFDfCZGbpW/+ItXMFdDX3DUghkpKGYjX4pN8vjFY9OVuozV
         JuycLp08T8K2LrMYGaLP+Ch/0D7LKwDDrXmi6gQ7FtNpMbHUgFAKOukVcrVyLySG/rmk
         9oHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=3Ti6IjAWZ9nxGji48U2finShhN9k8Ywg/5Fu3MYAh2E=;
        b=uMMv+DRon/mShq7Rv+DH3SFiGwcICNTKeIxP7KmUQnuoH8PQqq4tqkwv66jxVgXiTp
         0Slsx/Ras3I6Kqu5GtwPuxNUucx/qPDSXAb4EYh4vnSerubB8cLV95EPbJDKjTyaZEow
         X6jB5AMY/cXqwdmuWefV82bHMP9VoJh4fIvenPOKAqrBV4snAeHIm5taWk9rtuRmByKG
         vg2GeLuo1YH2KXxObkF1zrOBWa8dWdNoALZwQshkzK0qHjniNMtF31bYcwHCniL5yIYo
         cv6KgiRQtqHqOXl7EDtiIHzDcrCUSNLwGwWuqIzHZlVtnx5j4tVH266SYdFZilYQLAfm
         CxbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o13si5020813qtm.11.2019.03.25.07.40.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 07:40:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CEC44821E5;
	Mon, 25 Mar 2019 14:40:22 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2ABDC1001DC8;
	Mon, 25 Mar 2019 14:40:22 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v2 10/11] mm/hmm: add helpers for driver to safely take the mmap_sem v2
Date: Mon, 25 Mar 2019 10:40:10 -0400
Message-Id: <20190325144011.10560-11-jglisse@redhat.com>
In-Reply-To: <20190325144011.10560-1-jglisse@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Mon, 25 Mar 2019 14:40:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

The device driver context which holds reference to mirror and thus to
core hmm struct might outlive the mm against which it was created. To
avoid every driver to check for that case provide an helper that check
if mm is still alive and take the mmap_sem in read mode if so. If the
mm have been destroy (mmu_notifier release call back did happen) then
we return -EINVAL so that calling code knows that it is trying to do
something against a mm that is no longer valid.

Changes since v1:
    - removed bunch of useless check (if API is use with bogus argument
      better to fail loudly so user fix their code)

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/hmm.h | 50 ++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 47 insertions(+), 3 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index f3b919b04eda..5f9deaeb9d77 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -438,6 +438,50 @@ struct hmm_mirror {
 int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm);
 void hmm_mirror_unregister(struct hmm_mirror *mirror);
 
+/*
+ * hmm_mirror_mm_down_read() - lock the mmap_sem in read mode
+ * @mirror: the HMM mm mirror for which we want to lock the mmap_sem
+ * Returns: -EINVAL if the mm is dead, 0 otherwise (lock taken).
+ *
+ * The device driver context which holds reference to mirror and thus to core
+ * hmm struct might outlive the mm against which it was created. To avoid every
+ * driver to check for that case provide an helper that check if mm is still
+ * alive and take the mmap_sem in read mode if so. If the mm have been destroy
+ * (mmu_notifier release call back did happen) then we return -EINVAL so that
+ * calling code knows that it is trying to do something against a mm that is
+ * no longer valid.
+ */
+static inline int hmm_mirror_mm_down_read(struct hmm_mirror *mirror)
+{
+	struct mm_struct *mm;
+
+	/* Sanity check ... */
+	if (!mirror || !mirror->hmm)
+		return -EINVAL;
+	/*
+	 * Before trying to take the mmap_sem make sure the mm is still
+	 * alive as device driver context might outlive the mm lifetime.
+	 *
+	 * FIXME: should we also check for mm that outlive its owning
+	 * task ?
+	 */
+	mm = READ_ONCE(mirror->hmm->mm);
+	if (mirror->hmm->dead || !mm)
+		return -EINVAL;
+
+	down_read(&mm->mmap_sem);
+	return 0;
+}
+
+/*
+ * hmm_mirror_mm_up_read() - unlock the mmap_sem from read mode
+ * @mirror: the HMM mm mirror for which we want to lock the mmap_sem
+ */
+static inline void hmm_mirror_mm_up_read(struct hmm_mirror *mirror)
+{
+	up_read(&mirror->hmm->mm->mmap_sem);
+}
+
 
 /*
  * To snapshot the CPU page table you first have to call hmm_range_register()
@@ -463,7 +507,7 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror);
  *          if (ret)
  *              return ret;
  *
- *          down_read(mm->mmap_sem);
+ *          hmm_mirror_mm_down_read(mirror);
  *      again:
  *
  *          if (!hmm_range_wait_until_valid(&range, TIMEOUT)) {
@@ -476,13 +520,13 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror);
  *
  *          ret = hmm_range_snapshot(&range); or hmm_range_fault(&range);
  *          if (ret == -EAGAIN) {
- *              down_read(mm->mmap_sem);
+ *              hmm_mirror_mm_down_read(mirror);
  *              goto again;
  *          } else if (ret == -EBUSY) {
  *              goto again;
  *          }
  *
- *          up_read(&mm->mmap_sem);
+ *          hmm_mirror_mm_up_read(mirror);
  *          if (ret) {
  *              hmm_range_unregister(range);
  *              return ret;
-- 
2.17.2

