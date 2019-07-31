Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB9BAC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:15:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 843D720693
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:15:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="D/xOlMhr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 843D720693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A8058E0037; Wed, 31 Jul 2019 11:15:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 231C58E0035; Wed, 31 Jul 2019 11:15:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D3608E0037; Wed, 31 Jul 2019 11:15:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B1E548E0035
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:15:53 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w25so42574184edu.11
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:15:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dXgFqK9tRsaes8xbX8jlTX0gUbPqQYtilIkdLoU6CY4=;
        b=WBuc/t3iE0hZpWHukaaMWe3R8tNDIkqOmucvYPrFF9dReTQfLA+C9sKyoRaxLk5TOm
         9tBFG4UV5SDIuHuNhC7xMWLeYEcKNbR5BEoglORcV8N9NMHFFtNdObY96vBOvKhMoqux
         zW5OYumr+NH2AslhV8hbQc8p+n1C8eayGDlcBPhuEFeLK36VcXy0OQXXVTKreJQrhbgQ
         xjaladVk+qxOr/98TmMkZZXvPQOdRy6LEDJoC0M5T7YHs0vqbPIy2SFOozUbfUBw+hip
         ntuT59hwWJ7xaXO0uQOWCdoqy82b8x/jJvn7z2WN0b8hZeiV48erHQNMoIgNx5JliJDc
         0sPg==
X-Gm-Message-State: APjAAAVxziVQzbg24LPMw37RxXaIuquVRSKFmPty0tuJhctqdkaevfdn
	wzLxBV1qPIXdvqo5xrHR02ucbSDetmJHpASzCxckssG4SJVZq3kedGO88e3lY9cFTs1xeOFjFLn
	VQHlfVOceZC/oSMtboN1mG3kMtdLRorYYb8dQuuZrMmgHa3+22vp5T+y3LG2q6Rk=
X-Received: by 2002:a50:c35b:: with SMTP id q27mr108134600edb.98.1564586153300;
        Wed, 31 Jul 2019 08:15:53 -0700 (PDT)
X-Received: by 2002:a50:c35b:: with SMTP id q27mr108123126edb.98.1564586038933;
        Wed, 31 Jul 2019 08:13:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586038; cv=none;
        d=google.com; s=arc-20160816;
        b=pcDzrYW36TVMJam37Kc3FFlGqOWQqPjum9hdu+CftUEbKu+IsqwC6Dsw/yZ7qNpQ7u
         CqE+6ZW5Zv/rVa5NCRFJwcPD7HYIOCcEkRS1azc31ClLI4xVE0vtaHcjueeDoVoGLjx2
         LYBfYa8OndI2zSUxedCY6GnSWTOui2SSOYOf1D4gAMAch033NCvQ9EDn2saWrQjugIK+
         beFDvs88FiZXSZifqxhJgJS+B5IlM7oLOpOeWEJjfe4XZKDWUiC9QGK0Wk2z3xSsOSCB
         pRtt0RyINTUTWDFEDV+C9RYpvmJbkT6zzePx05cbALesdmk9ye1oytB7BbIJ1/eLWGIX
         onwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=dXgFqK9tRsaes8xbX8jlTX0gUbPqQYtilIkdLoU6CY4=;
        b=W2UmhMmgBbtsTuQR4sgExurZdLcuUPLq1ntO7cn+/dRDku3zyHmGMojhjqWqf8akzC
         DswwUHAAoMb1OfKpXmuyXq7GctXviO4zfwSczINl6f2liBLMVR9t3zegv69RAVZSJOpF
         AVGmDP/+3zO1FV3rBwHZPmAIhLzwcqgzgzXKQirBeXqF0FQ3HkZ970pePic5Vr7/6stb
         q9OliB9Dtg4HzLZ0s3Sy3pJYl7aozUcOnAmBLOwhmpgbacgYImRRbAfPjbzdSk/iVWDE
         XsTiSKxk5DSSDQrKezPNyeLAbEayALbcD3ZUMeafI3FCCVQi4j1tmImdWR07cnBqiO7j
         4Kww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="D/xOlMhr";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l33sor52321055edd.23.2019.07.31.08.13.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:13:58 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="D/xOlMhr";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=dXgFqK9tRsaes8xbX8jlTX0gUbPqQYtilIkdLoU6CY4=;
        b=D/xOlMhrdU0ZyN8+we4kbni7hHuGIfv/4U4Ig0LX9ewfIEajz0z1lI9iS5QnH6yCat
         sfE6Wxgj7gCcNgGeO8sqZDkOENTjXyGaq0eGqLegmkmODaaLkPBU23YDdAqvq4s4OSxZ
         N0A8Q4QWYpmDkk2dAzVYUHeLTCw2YmNW5FYuyTsyMmseshWxSznRJue51TmL0r+h8LG/
         vb4cNBRmMjzUCNNogPHi3S31sph/SJ/M4uXMSstfF9OC/trKRR9pDG2nUWbNR9Ymsx50
         ScB2FK2fZENk5csdIp1g+R48LmIGH0MJ/LiEr5bfor9Gh3Un92wYv/649p99ZIJ8QAGO
         S6YQ==
X-Google-Smtp-Source: APXvYqyagj0pny7ZfrRGD/QMhFKklBkFWmGDfmQgFU5rbWlHF6yWjUkfAl5cJt9AcGs7WHAa7fbavg==
X-Received: by 2002:a50:a485:: with SMTP id w5mr108547875edb.277.1564586038641;
        Wed, 31 Jul 2019 08:13:58 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id i8sm17219860edg.12.2019.07.31.08.13.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:13:57 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 3A5C3104604; Wed, 31 Jul 2019 18:08:17 +0300 (+03)
To: Andrew Morton <akpm@linux-foundation.org>,
	x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>
Cc: Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>,
	linux-mm@kvack.org,
	kvm@vger.kernel.org,
	keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 46/59] mm: Restrict MKTME memory encryption to anonymous VMAs
Date: Wed, 31 Jul 2019 18:08:00 +0300
Message-Id: <20190731150813.26289-47-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
References: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alison Schofield <alison.schofield@intel.com>

Memory encryption is only supported for mappings that are ANONYMOUS.
Test the VMA's in an encrypt_mprotect() request to make sure they all
meet that requirement before encrypting any.

The encrypt_mprotect syscall will return -EINVAL and will not encrypt
any VMA's if this check fails.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/mprotect.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 518d75582e7b..4b079e1b2d6f 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -347,6 +347,24 @@ static int prot_none_walk(struct vm_area_struct *vma, unsigned long start,
 	return walk_page_range(start, end, &prot_none_walk);
 }
 
+/*
+ * Encrypted mprotect is only supported on anonymous mappings.
+ * If this test fails on any single VMA, the entire mprotect
+ * request fails.
+ */
+static bool mem_supports_encryption(struct vm_area_struct *vma, unsigned long end)
+{
+	struct vm_area_struct *test_vma = vma;
+
+	do {
+		if (!vma_is_anonymous(test_vma))
+			return false;
+
+		test_vma = test_vma->vm_next;
+	} while (test_vma && test_vma->vm_start < end);
+	return true;
+}
+
 int
 mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	       unsigned long start, unsigned long end, unsigned long newflags,
@@ -533,6 +551,12 @@ static int do_mprotect_ext(unsigned long start, size_t len,
 				goto out;
 		}
 	}
+
+	if (keyid > 0 && !mem_supports_encryption(vma, end)) {
+		error = -EINVAL;
+		goto out;
+	}
+
 	if (start > vma->vm_start)
 		prev = vma;
 
-- 
2.21.0

