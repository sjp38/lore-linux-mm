Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C29CC4646C
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D59F220665
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="o/tFvhN2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D59F220665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E07F06B0008; Mon, 24 Jun 2019 17:02:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB5D58E0002; Mon, 24 Jun 2019 17:02:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2E3B6B000C; Mon, 24 Jun 2019 17:02:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 631B36B0008
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:02:05 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id 21so70024wmj.4
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 14:02:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2HyibpLykYkiKTwGwDVDE6Jz0uAzR58LFXlNi/YRy3U=;
        b=AdmJ7ofz2m7I9PyYmBo29XE77XmQJLSkkrrbbHC0wNVNRXA8RB0uoIykV76D0niWSR
         pCbgclK2dgeio1G0l2R1ituDUwJ0+lXhca/bPGuo6b+fW/vcxzL50TrSQPODcAVFtSAJ
         8YUux5zGMEt+7C0uTqIl6S7Hz+qEBLARpNaJIGmRCsJ60MwjBtLrb3cVECzG3/smmjTZ
         73Y+84EDwdgjKp1OH3goapZQ8QJleF1wWrTN2A/ighHBWuqtWoANR8w1yFDQsKAGM6tf
         B7WHWI7EUFdNB/BzU+F6F4BIrrxi1RVTSLlla9RA/hzbKqQmVf12MZ/jNsLbHL7g5026
         nxzg==
X-Gm-Message-State: APjAAAXXEsXdqa8xTZX4E222NldEgzhyfbK4qIKWfFU8kjIknWmdutnF
	CrfuSKF4j0oTlDjiTXopewjYENdt8nnYsziiJfN86J+TYP4zd4E2p72Rsfn38XrblWbXcIPtGvu
	YSCRJ/Cj2mtnxIE50IgYNzIIUXHh8e4dK/bDlPfRJFU2jcb9fjfvzWcSqmOKnahRmAw==
X-Received: by 2002:adf:fbc7:: with SMTP id d7mr4577515wrs.224.1561410124768;
        Mon, 24 Jun 2019 14:02:04 -0700 (PDT)
X-Received: by 2002:adf:fbc7:: with SMTP id d7mr4577491wrs.224.1561410123980;
        Mon, 24 Jun 2019 14:02:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561410123; cv=none;
        d=google.com; s=arc-20160816;
        b=YCWelJbfnPOf6CktV+AqjLi1DS+xJ6UtVWYghiOcFXGLKawZfOktE8EY3d09YH5d5P
         WGMHf/+3YFUOtbBZ+b25cRXDT+wTtrVuPLXXP5jqed2EzJFttIJ3DA/eyVbi4QWNOx/C
         1QI3vdJWdmfTyfB0KIOhtogP5OGGPrRNXD+S4L2Ujp6IMievRdBEjNlPderf6rxJWZ07
         85CZAXUd97/EExvBfYHw8NNW0vLMD892fT4SCwwNiWjMDRNMxTTAtUACQJcqMHTLfj1p
         yufbYAtUjDD7Y4ZKJaz7lhf7RnimbgT4dwGRFm4i2RG5PwQSkQC44iYjtXstfHKDBymf
         YlgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=2HyibpLykYkiKTwGwDVDE6Jz0uAzR58LFXlNi/YRy3U=;
        b=wcH1LaYNeuMYEUjUvmnsvsYgJatuugyiGsxQ3yDJZLi4E+pYFh4m9NeIPC+729twMj
         0VI6UGqvpntvul7C75AWElEagrFrnsfqQZES/n2hrGODjAY2JJ0eL8AQLwwdMiZULQs5
         wzRvLcbuWCdoiun+nhAv+BBZo0WtM1uJ/G4U2QaTUv1b2fO6xarna4JrI4aSufdtqunk
         o4t3nWdE9d8tBVNBmO38uYVBehGv29isxs/+N07s58LawsNvfeYLno5qQm32keQgAPOK
         S6a8O01vO5LUC8yTr/zsoItuJlcOeBkyrlhZ9wYZdzUxinoAHFU4DjqMRh1H7lnGR+ag
         9+7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="o/tFvhN2";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v15sor7233665wrp.38.2019.06.24.14.02.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 14:02:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="o/tFvhN2";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=2HyibpLykYkiKTwGwDVDE6Jz0uAzR58LFXlNi/YRy3U=;
        b=o/tFvhN275Le/5WQ2vu2fc7dpnfllCtch7SunXoc0gfrceioMrV84vJNXj3fcaoXjc
         qKdfy6+FErMOpWLLywUqcU/CCvqkzz60BPZVTd/0tIIXWv44kB8+wkXkIP3fIfmQuRfU
         VCtdLewh0B23U6TTG5KtYq7rxUdtI/n6yUmErMCpp/rXPr3h474Gd7GbjYQ+iiDYdpy1
         7shV4eVpmV49XoNejllG2+McGSuy2k7ZkrwJwBNEK6NQF3+JDLsqVqku3k4UUdsaGuab
         CgCCYDDWmuYZ06PXgv5ghP0Ro725vIEY+j0ePamWI4Lrm/GuhZ/Rebt3wxbycRP+uaHI
         i7Cw==
X-Google-Smtp-Source: APXvYqxbykTnskxCEk6vJXnhGhJhL+Hc/YVg3s4yNHZO6Rq1Ef69wTB8s8QzzXVmzALZYfvIEAb5sA==
X-Received: by 2002:adf:fa4c:: with SMTP id y12mr96903628wrr.282.1561410123670;
        Mon, 24 Jun 2019 14:02:03 -0700 (PDT)
Received: from ziepe.ca ([66.187.232.66])
        by smtp.gmail.com with ESMTPSA id x11sm469693wmg.23.2019.06.24.14.02.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Jun 2019 14:02:02 -0700 (PDT)
Received: from jgg by jggl.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hfW6D-0001Mb-0S; Mon, 24 Jun 2019 18:02:01 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Felix.Kuehling@amd.com
Cc: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>,
	Christoph Hellwig <hch@lst.de>,
	Philip Yang <Philip.Yang@amd.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH v4 hmm 08/12] mm/hmm: Use lockdep instead of comments
Date: Mon, 24 Jun 2019 18:01:06 -0300
Message-Id: <20190624210110.5098-9-jgg@ziepe.ca>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190624210110.5098-1-jgg@ziepe.ca>
References: <20190624210110.5098-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

So we can check locking at runtime.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Acked-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
v2
- Fix missing & in lockdeps (Jason)
---
 mm/hmm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 1eddda45cefae7..6f5dc6d568feb1 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -246,11 +246,11 @@ static const struct mmu_notifier_ops hmm_mmu_notifier_ops = {
  *
  * To start mirroring a process address space, the device driver must register
  * an HMM mirror struct.
- *
- * THE mm->mmap_sem MUST BE HELD IN WRITE MODE !
  */
 int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)
 {
+	lockdep_assert_held_exclusive(&mm->mmap_sem);
+
 	/* Sanity check */
 	if (!mm || !mirror || !mirror->ops)
 		return -EINVAL;
-- 
2.22.0

