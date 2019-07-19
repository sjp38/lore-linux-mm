Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1159EC76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:10:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0F82218C3
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:10:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="MCIj12XQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0F82218C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68F188E0010; Fri, 19 Jul 2019 00:10:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 618218E0001; Fri, 19 Jul 2019 00:10:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B9768E0010; Fri, 19 Jul 2019 00:10:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 172018E0001
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:10:37 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 8so12616006pgl.3
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:10:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wk+trpDqGMtNDYoVoz3Dbp0exCbSkeF3kEOSvtwa9Bs=;
        b=W9cFcTprUWl7p4wv8MC0IWxI8iljpgVSqza1upUIB13/U0+0GTn9pATct9noK8dC7O
         bupTrUW/zfzq1fkDiuC3bSD0fLJOiBT7q63NfaPe6B2EvUqEhpUz8aeWQqZCtIhPsKXo
         HbZGwPEPp+mM9uEgXdkGCyOhdXFFuXlPxDB76LyE6tEricWxOCk5ZH5pWvmPSgvCqccI
         uzUJzm5WsrZJtl6g8o2Qhwe3LaQQ5bTDJTjO2vB2zdcdL/T5qMaqnQXj5Aojie4IEoLp
         OKeiOL2w09oqCpS/0SNDemUffwzwj3ih2yTlCua5DjaxQCVvdc8ozaif18DYy8ZhlGyU
         eeEQ==
X-Gm-Message-State: APjAAAWRwsSn8J2CAXRtsVmHst+Z5JKBAFAvKZAAj9i4hXVFAEVKmCVz
	0izoyQkjvwLgO6quYDgrzXQnmMMF613GjBTuCDHODAp+r5SEpYzlrOD+lQM/CKZAM3y0AjSfJkx
	mPdIlHyq09UfLnvkkc6c4bndvoLXBCa8EGiLdzgNml1YD71Y/Nw2x6LCasb6JQ/CmQg==
X-Received: by 2002:a17:902:2a29:: with SMTP id i38mr54710077plb.46.1563509436786;
        Thu, 18 Jul 2019 21:10:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxkGWN9oq6dBG8omxqKVRu7zonNLJYVElpfCKTyXw+IwLIjHrqXf7bT9F7POxoE25QX0wWz
X-Received: by 2002:a17:902:2a29:: with SMTP id i38mr54710005plb.46.1563509436011;
        Thu, 18 Jul 2019 21:10:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563509436; cv=none;
        d=google.com; s=arc-20160816;
        b=MhAXc496gKH+fmAMzTI19ymu5kLICYhA+87p9xhhYDYVLJYjCycedQfAAtYoB0WF5f
         1SQCSpmg3h78s/cTOcRUc2bf5Xef9asn7i0/DMzX2k4b0EaK43DGKIe16KZ9ew8RUDFL
         EtSS069PJabpngrCu7lf/BSzhs00wgsmsT5lQv4nm+mkeKA9EOxva5yntqU3xKQxSD6S
         cdXGdmT7rb/D9LT+47ZaDnJ4khLATkjD1eK8hSYhg+HpSC8E5VxqY4es0nV9CIZMCXWl
         Nea2Fg16LKvz9B+990DvHhKGEg1AZP/xrpjxwjOYwX6C4f52lX714l6q4LRezsxcfi+P
         TafQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=wk+trpDqGMtNDYoVoz3Dbp0exCbSkeF3kEOSvtwa9Bs=;
        b=c/CE9ZW/gVvPzJJZ6qqQnQrIjgE1medFcD6+Hhd0HFuzRcSTL91RxZ1TsNaznsXwrL
         pLFZrL1acx07N3x2FhjOnSOQoYyQB7Fl6b1pvUgoAAb87r+eNSysoGiFdAsxo6q9RnMv
         whVdOHIS0AoJM6C8VoJYef5iG51lmWAkDSaOrNJOEnxNLRBHL2rp38jEgSHR/pOe6MuE
         mPMmXd8tsuZSuV7MqNPAOakWk8Vuv6SXQccuY+dvPdGm0gbBJ8yXM7Z1G6ZXQsLe+Q1H
         XbH2+fTK+WhhBhqCKF9fgIo41Brz0iBKONF/aGWCLt+N7u4xqbiuXmFcwRkAnXqnZqkb
         fceg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=MCIj12XQ;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a10si3438105pfc.215.2019.07.18.21.10.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:10:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=MCIj12XQ;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A398421872;
	Fri, 19 Jul 2019 04:10:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563509435;
	bh=ND04iyBGZU9uwTapA7OgOZosgZe0ucRFwjwX9sHc5uY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=MCIj12XQF6u63qiSX5RXWmaW9rKHW7Wra8X0q4FPLxtfRxLOGi3tmIDOGY6wXsX9A
	 nheKMhXt3M/2P3SolXApYLyQbEurGzrU2eWzosv57v0aENCMfp/eyVx3fYrU6SEtB9
	 5xVwSRsBTfgsxWONr58FV+QNWxMrVClMtqfphfEY=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Andy Lutomirski <luto@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Florian Weimer <fweimer@redhat.com>,
	Jann Horn <jannh@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 091/101] mm/gup.c: remove some BUG_ONs from get_gate_page()
Date: Fri, 19 Jul 2019 00:07:22 -0400
Message-Id: <20190719040732.17285-91-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719040732.17285-1-sashal@kernel.org>
References: <20190719040732.17285-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andy Lutomirski <luto@kernel.org>

[ Upstream commit b5d1c39f34d1c9bca0c4b9ae2e339fbbe264a9c7 ]

If we end up without a PGD or PUD entry backing the gate area, don't BUG
-- just fail gracefully.

It's not entirely implausible that this could happen some day on x86.  It
doesn't right now even with an execute-only emulated vsyscall page because
the fixmap shares the PUD, but the core mm code shouldn't rely on that
particular detail to avoid OOPSing.

Link: http://lkml.kernel.org/r/a1d9f4efb75b9d464e59fd6af00104b21c58f6f7.1561610798.git.luto@kernel.org
Signed-off-by: Andy Lutomirski <luto@kernel.org>
Reviewed-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Florian Weimer <fweimer@redhat.com>
Cc: Jann Horn <jannh@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/gup.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 43c71397c7ca..f3088d25bd92 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -458,11 +458,14 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
 		pgd = pgd_offset_k(address);
 	else
 		pgd = pgd_offset_gate(mm, address);
-	BUG_ON(pgd_none(*pgd));
+	if (pgd_none(*pgd))
+		return -EFAULT;
 	p4d = p4d_offset(pgd, address);
-	BUG_ON(p4d_none(*p4d));
+	if (p4d_none(*p4d))
+		return -EFAULT;
 	pud = pud_offset(p4d, address);
-	BUG_ON(pud_none(*pud));
+	if (pud_none(*pud))
+		return -EFAULT;
 	pmd = pmd_offset(pud, address);
 	if (!pmd_present(*pmd))
 		return -EFAULT;
-- 
2.20.1

