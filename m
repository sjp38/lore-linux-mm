Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19693C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:55:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D51F0214DA
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:55:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D51F0214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A4C3B8E000C; Tue, 29 Jan 2019 11:54:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97F958E0008; Tue, 29 Jan 2019 11:54:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 825E98E000C; Tue, 29 Jan 2019 11:54:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4AAD98E0008
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:54:55 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id d196so22331750qkb.6
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:54:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uF0Rg6OUe55CoYMP7oripH2m8c1bWkRZFMmBzBzXOKY=;
        b=Tl9sPdDurS5fwUTcdKuUXAy6gdyYpXiLJM+jJYx2XcJaK7/PWmiS5upMcd0R/94zsX
         IwD4SQ5yiFWfwIPaSLTxNlNm2bzNLyADUxIbwvSswWbfxBQAehcrWsGUxH0gkNlLC1L5
         GziRh6I0CCkSskqhQ7HSXRoongMhcomu9rIkGGa12fAohrmvkjEZwqoDHaT53tMy2Dfk
         pI0PqEPlfUt406XdzXH4pgnY0IQsP+NfTPGVy0YBzFcJRb+sJBWECe/1tb5Hw0Y/9VUS
         dVeHIT69s+/Q/jG05AmJ7641DuLBDScXviYuxLd43TF2USAEyrIwf1R1g8/K1B0/WmIl
         am6w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukdwZN1iDXTHUP9FXiCiNQ2JcCH4TxcuANeGuNmA7TSYKjEmDIPE
	EYdYBnrg+25DJuYYlyePgnajf9PXLZ2d2py3GwlYWPCtPs5irhdFMNoL2CBKFPQKmy8xW4mvZL7
	PPPwvSxgJImFLVSkeWIEGmHMlb44QMRHZsLGXM3mgSPvu3IbZNBHau5n3wxRHimPJpw==
X-Received: by 2002:a0c:c192:: with SMTP id n18mr24139901qvh.99.1548780895045;
        Tue, 29 Jan 2019 08:54:55 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7JR9s3tYoKsXJkJd3oerj4iXS/kFrzHaeiZjRpyIV46vVpamajUBRPY5hVJUWuj4q0dUkK
X-Received: by 2002:a0c:c192:: with SMTP id n18mr24139884qvh.99.1548780894557;
        Tue, 29 Jan 2019 08:54:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548780894; cv=none;
        d=google.com; s=arc-20160816;
        b=PH5cg9miUCTKSUId1d0lHDzG4hvPHQlNBKcd7R6m8UT5Q9Cb6UqRtgWmZA6TNtJgGp
         GDEFCA9ne81hvS3GlTGaujzY7CQvCfsvaaA0cfZP/C2wP1TEhr82AOrHeneYQukBCSZL
         pGol0JU9S1Oe9A9aT4Req1sQu1g+Hgbg7GY0Wxi5ba+BK3aUeyj94DNKG+9sEADQu4U8
         wEC1lUeApdwYNR5lUfs0RrBXBP7+DPvGrWijBE5T77ahITD31uUo3cmM5eO4HAJ+Xz15
         V84uDKOGXKCs1ttrNPOHEIns/V8eHQaddw7Szu9GRL3tpvoSFpS7uYfw5Zw74YLuNSd2
         OtbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=uF0Rg6OUe55CoYMP7oripH2m8c1bWkRZFMmBzBzXOKY=;
        b=Rz9XcH0ZXt5+uLQE9/5d2yg9B9crjxI7HVFPnO7uUnRpZecDjiDSvqhesA0y7/5tGz
         GskPvdMG3+e+MOv/n2xUI2XyXZTjTheIbZ4O1TPOW1iO7FZqu7Z13MPcOVqfPF51va9V
         kPnwbDUk3zImEYyzrRUOfHREqs80mDpvBTuW9Ci1C51BQFayI8s/l11HcK+3/tPPObvt
         10ofUxyXoxtQN2l19/TzlorZFO5MDB/lbaYV7DfnI7jO3WSMQKtv1MfJhZgH00xqQJW1
         W7TdfZBS6V8yyEE9Nxn78aW2p+7OQN4claSI/5xZRr0GugtQAg/FqKk03Ihaj45jKOmt
         fsfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f57si963291qtf.362.2019.01.29.08.54.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 08:54:54 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9CB7281DE9;
	Tue, 29 Jan 2019 16:54:53 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 97C9D102BCEB;
	Tue, 29 Jan 2019 16:54:52 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH 10/10] mm/hmm: add helpers for driver to safely take the mmap_sem
Date: Tue, 29 Jan 2019 11:54:28 -0500
Message-Id: <20190129165428.3931-11-jglisse@redhat.com>
In-Reply-To: <20190129165428.3931-1-jglisse@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 29 Jan 2019 16:54:53 +0000 (UTC)
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

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/hmm.h | 50 ++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 47 insertions(+), 3 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index b3850297352f..4a1454e3efba 100644
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

