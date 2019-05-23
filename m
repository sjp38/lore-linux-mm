Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54C3EC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:34:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00DC921773
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:34:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="hQux6/iJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00DC921773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 702046B027D; Thu, 23 May 2019 11:34:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6386A6B0280; Thu, 23 May 2019 11:34:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52B8B6B027F; Thu, 23 May 2019 11:34:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 297CD6B027C
	for <linux-mm@kvack.org>; Thu, 23 May 2019 11:34:43 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id w184so5747871qka.15
        for <linux-mm@kvack.org>; Thu, 23 May 2019 08:34:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8d3qZxuduenTYxmVtLo/HTiLB+fwW/lCyyNPj/qu33U=;
        b=G4POJojfjW5pONjrBiisa0WuaQLNY+aucoIVXi8gE5yvqRZumZsQHtPLhkr83BdtIh
         Rm0sQxnSlnvy9pC8BLQRMAcsiga2HTr60z7UYbIN1jqltq/R6AstiZQdloBKshVh9rD+
         dd1k9BiObwvoILDvWDrqaHFJ/dNfHbWLeUMbyAT5TKk9ZEKOgIbmc+awyaQTh8UH0T8i
         J9h9TeDVL3SjmomOXqJuN5lm0ftNQnU8vpnTTSo6QxQXSXGv6es2+J3AYIsmuu8GzINE
         9WPqVid5Z5p0DA5P4rNM2bSJZMWWElRLJ+xx7H0RHEakd6R9JpZdP5GKQgC3vLLhLjfK
         aw2g==
X-Gm-Message-State: APjAAAXwj3eV9Q0H+SyQ7P8PfNvsEiSn/QX3aEhR3b3/LF0oo1Qk9kbC
	051TRKE0jbGs2NTSbKmj/lgnjZvxRyyzSnlMDqjmyML4fGzrhz3i+nO1bb0MJbBaT26fRw/lKH2
	zxaLESYxP+bB9ZxJGADiS0swa385n8PeJ/egABrfwgL0Ub4PEnBey/uBBL6St28TdiA==
X-Received: by 2002:a05:620a:113a:: with SMTP id p26mr75100447qkk.12.1558625682918;
        Thu, 23 May 2019 08:34:42 -0700 (PDT)
X-Received: by 2002:a05:620a:113a:: with SMTP id p26mr75100351qkk.12.1558625681846;
        Thu, 23 May 2019 08:34:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558625681; cv=none;
        d=google.com; s=arc-20160816;
        b=F1vBZADb0q88hoaNmBNEFw58RNpqQy8LSPU+tamLw+lkfaMoSZ8S9HU47jrR0QODX/
         nXjv0wp63IuUlaAQtY/vDIoGIVicJPXIQEGg/Ec161U9u1FlyoW/kg4Xg88m3HMUQNXH
         7ITIJf1MsMKwXzaR1qY1ON/MaCees76o8f4JvX3u+dARIstVu4oilhLWPI50CMMFzybI
         RviFqN/6oooloYZK9ZRbaLsdSzej9+mcMThaFn8Us/MpR+uTYBftIyPXlNLR7zZQXE6l
         1o4U4dbUeHSig90gaAolidmwvMnmZNE7UOX+0JWY7AuZ/yJJgOhSsAKgC41RDjmf0ArG
         kdqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=8d3qZxuduenTYxmVtLo/HTiLB+fwW/lCyyNPj/qu33U=;
        b=ByU+Q7VngtHVrGWSVqNDXFUMNF6cAM0TqKGjtxLNIultYe0PIcrtGb2G0d6+drgz8H
         fYx01vQEJ0s3EqwnEp5x4GFMliqO5R1rFRLAo2yeW6pWaEQw9VbLWl8F9U30i2duQ9UG
         Fe2LuYEz1uZUf2lVw1QaZxj+abD3JFfsfPiaShRThH/gnVbmHyUXh6jLh33wkqOt+NEO
         aj3f4dtRygjsNEDa86vRLz+lHgohkSr6YBysJKNtV+0uEjD6nfA0jU6LUL4gAOXLZytY
         v7+e9WK5EO8FcAzWVd3F2nMEpH5jcq+rxjubj65UDAwtOI+NN4tUD7d5E/wHFnb8d7o0
         7MgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="hQux6/iJ";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z142sor15321342qka.71.2019.05.23.08.34.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 08:34:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="hQux6/iJ";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=8d3qZxuduenTYxmVtLo/HTiLB+fwW/lCyyNPj/qu33U=;
        b=hQux6/iJ6hqg+JBrYX1VSUyG5Ws/3mnhZg2BHMv3L6kyfjzf8PCRUOnHPNnDo5Ei52
         EzmG7qHzV3jffzCQXKj0JUoEfaIP43zLaY5Wr6VzQ8nmDtD5NmA7j9TfXODD1YOs1F9H
         PZH2Za61bIL+znufcpgTJCwAGDEtZBaDT+uGjIxs4vHGmpuGCYXgRA67X3+xj2YEGoS7
         qxppgbz5Ak0ZlKqhXrbw3bOcAA4n662B0aWl2e6V6tWw4A7HXJaDEV3RGWl1ZbpgHojB
         dZ3Mex3pGWIaqI5HTw4cpQ7GxfHh8wiS7DQizBjbqw30fLSk5qlGsvcbGE4opOCxHQ2o
         yokw==
X-Google-Smtp-Source: APXvYqxEddBfU0Rf4mgWBf/qIenpeQFY2LV64soWSgPl9ghoFmgdVdxNL+eh6sZGq9t3KI14a4o+gg==
X-Received: by 2002:ae9:f70d:: with SMTP id s13mr75933217qkg.213.1558625681585;
        Thu, 23 May 2019 08:34:41 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id v69sm745374qkb.60.2019.05.23.08.34.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 08:34:39 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hTpjq-0004zZ-2a; Thu, 23 May 2019 12:34:38 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Subject: [RFC PATCH 05/11] mm/hmm: Improve locking around hmm->dead
Date: Thu, 23 May 2019 12:34:30 -0300
Message-Id: <20190523153436.19102-6-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190523153436.19102-1-jgg@ziepe.ca>
References: <20190523153436.19102-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

This value is being read without any locking, so it is just an unreliable
hint, however in many cases we need to have certainty that code is not
racing with mmput()/hmm_release().

For the two functions doing find_vma(), document that the caller is
expected to hold mmap_sem and thus also have a mmget().

For hmm_range_register acquire a mmget internally as it must not race with
hmm_release() when it sets valid.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 mm/hmm.c | 27 +++++++++++++++++++--------
 1 file changed, 19 insertions(+), 8 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index ec54be54d81135..d97ec293336ea5 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -909,8 +909,10 @@ int hmm_range_register(struct hmm_range *range,
 	range->start = start;
 	range->end = end;
 
-	/* Check if hmm_mm_destroy() was call. */
-	if (mirror->hmm->mm == NULL || mirror->hmm->dead)
+	/*
+	 * We cannot set range->value to true if hmm_release has already run.
+	 */
+	if (!mmget_not_zero(mirror->hmm->mm))
 		return -EFAULT;
 
 	range->hmm = mirror->hmm;
@@ -928,6 +930,7 @@ int hmm_range_register(struct hmm_range *range,
 	if (!range->hmm->notifiers)
 		range->valid = true;
 	mutex_unlock(&range->hmm->lock);
+	mmput(mirror->hmm->mm);
 
 	return 0;
 }
@@ -979,9 +982,13 @@ long hmm_range_snapshot(struct hmm_range *range)
 	struct vm_area_struct *vma;
 	struct mm_walk mm_walk;
 
-	/* Check if hmm_mm_destroy() was call. */
-	if (hmm->mm == NULL || hmm->dead)
-		return -EFAULT;
+	/*
+	 * Caller must hold the mmap_sem, and that requires the caller to have
+	 * a mmget.
+	 */
+	lockdep_assert_held(hmm->mm->mmap_sem);
+	if (WARN_ON(!atomic_read(&hmm->mm->mm_users)))
+		return -EINVAL;
 
 	do {
 		/* If range is no longer valid force retry. */
@@ -1077,9 +1084,13 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 	struct mm_walk mm_walk;
 	int ret;
 
-	/* Check if hmm_mm_destroy() was call. */
-	if (hmm->mm == NULL || hmm->dead)
-		return -EFAULT;
+	/*
+	 * Caller must hold the mmap_sem, and that requires the caller to have
+	 * a mmget.
+	 */
+	lockdep_assert_held(hmm->mm->mmap_sem);
+	if (WARN_ON(!atomic_read(&hmm->mm->mm_users)))
+		return -EINVAL;
 
 	do {
 		/* If range is no longer valid force retry. */
-- 
2.21.0

