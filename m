Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32087C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:09:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE1E72064A
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:09:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="MLb+AaSc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE1E72064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E207A8E001B; Wed, 31 Jul 2019 11:08:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAD0B8E0003; Wed, 31 Jul 2019 11:08:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BFC0E8E001B; Wed, 31 Jul 2019 11:08:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7273E8E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:08:32 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y3so42572799edm.21
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:08:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zVlcJDBaDTqmSz97nQxl4DvHh1B1aL9m42IztWqYpgk=;
        b=TmByCOrRsm5qYDKS0I9NxDKd9Ta4lNKFzml6OS7T+sPAT5Wr/OKztjxSDDYp5eYk/9
         JjrvhB+7ZLzFGdEOLOF4VOgrXd/1rYVxYVzuaqh2JYUYPW8QwcpVfGHPRvwUuoVK3wZi
         LK+GG49azhJt4rlIaVTWb4ltZKvnCUnqoIxml7s+/Mds9u8gt6ZykPGqdIqhXVkwcuBl
         c4uBqN0mBsBBrQONysuJG06xUrxApYDg1irDNtdsmfJCqp0VHRdtDV2k3RSuo6GDsvgm
         5lwX9wPcDJVatfwrovosyu846HhKKbIOh2p23klpHneo+gdPlvyeUebHBgTMZoGhXU/D
         ywSw==
X-Gm-Message-State: APjAAAU93P0sUmurnhg3fT4IPbvHmHHWnV6z5plSe79z+XY2Ej1gyBXz
	IhuVkCdWnN6hEYHrKHgJ3yYRFehQQ0mnA31L8WZEuO0Lxqc6t319XPS9WYiRGE00fQZ8k3i/oxP
	y40OcrCi4diQ5iPXIHzV/N2R98OO7ydMPQmVlwGz5s+YUWVY9VnxNSbrMG39BFv8=
X-Received: by 2002:a17:906:f742:: with SMTP id jp2mr2568625ejb.87.1564585711997;
        Wed, 31 Jul 2019 08:08:31 -0700 (PDT)
X-Received: by 2002:a17:906:f742:: with SMTP id jp2mr2568496ejb.87.1564585710527;
        Wed, 31 Jul 2019 08:08:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564585710; cv=none;
        d=google.com; s=arc-20160816;
        b=jKZ/znf9fqYFvyvAo1HwqD1axA6647F5YhYZNOOUzrxL+JX4DXW1gQp4JNMPkXkOHQ
         RQJy45Ox4EvNWrOaiKAUp4FRLROR8FwAgShzPZukS8tkSNlKGO062gdRH6ObMUHE85KZ
         JbMcofogd7ZFKo7CYKfN3oMXHAFJ4NE8RzYgCa+Cpcx30eP4Ly9iUftId458/5RE4qTi
         OatsWynis+QnuDLUi4XJLgLXLGfpc/B2eGa7T9sZnWzJXMbldOGkuYXyy6XLCQQ6jlxh
         cv7GwVuptxFd9IIpcKmC+Ex7bnu9JR3OxR5jPAiuerIAxJU+dPdFpaz8heCYZy35fiYH
         ISlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=zVlcJDBaDTqmSz97nQxl4DvHh1B1aL9m42IztWqYpgk=;
        b=JB95Kh7xVvzu2AIVi2Q0cB8t9H6/JY9VqCkOUpb+dBhQr8OQJxGMAajV16ncLkv1tz
         54qWwSTI164JphJKKs2Nq7fi2VrM7Uk5mPcmb6GFIkBrGVVfe8cWZ7Br9oTryW1yGApg
         neIAthrkOx8Yb8lF23rOJ8G5O9kDyX22Vzjt1E+tstNAaT5cWd1cmb9ece31k0IL17T5
         PIaQghWwYJ3aCTPYHutmdJq6CB29iUJ3pwt3VW2qJhwaeYkPr9LJ5EO+oeQj2e97hXNS
         jJVDziDJfGrC9CAZQpJl8fI3mnj53yQDeRNs8DPSjk6XO2ZmdZE0DxUSkJYmKjk0uWoL
         h0GQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=MLb+AaSc;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g25sor52126822edc.19.2019.07.31.08.08.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:08:30 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=MLb+AaSc;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=zVlcJDBaDTqmSz97nQxl4DvHh1B1aL9m42IztWqYpgk=;
        b=MLb+AaScf0hGsrpPSDd87+yWF18Ne5YphyrJDosl5qgEGBpjx5dqprcz8D6TDurakx
         v7dksS8vdyH98KwRfDrtg/ZbAe6E5vhUhxog7UiBo5/z7ZxDluJryzZrq7ii40mFem3i
         jMx9cmbPY8ZVw9geHuaHGUyOzRRTLmVrMwDlEzypgFsoq1OKR/Xmb+uMJ6IghodwNO1n
         RZiP1ftmR0Lj/uf8ewWim1E6GUd1B5u7cpUbveVRjMCNi8uIaEVIr/L9O6TQUka6NeYB
         zDwBJBoONjQlX/jht6jQVRNO6og/Cy7j8akyt5hXZpmDzorFoOnlfMMXa/CagiuWGoH+
         adxA==
X-Google-Smtp-Source: APXvYqyr56BhZiXrSd8f2fq+Z375JbAoHMRws8MKCqxmheMr9Uoh5vHG5eCnsq/pE6efizao1axriw==
X-Received: by 2002:a05:6402:3d5:: with SMTP id t21mr107048118edw.13.1564585710210;
        Wed, 31 Jul 2019 08:08:30 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id s2sm5403001ejf.11.2019.07.31.08.08.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:08:28 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id E8A5B1045FA; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 36/59] keys/mktme: Require ACPI HMAT to register the MKTME Key Service
Date: Wed, 31 Jul 2019 18:07:50 +0300
Message-Id: <20190731150813.26289-37-kirill.shutemov@linux.intel.com>
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

The ACPI HMAT will be used by the MKTME key service to identify
topologies that support the safe programming of encryption keys.
Those decisions will happen at key creation time and during
hotplug events.

To enable this, we at least need to have the ACPI HMAT present
at init time. If it's not present, do not register the type.

If the HMAT is not present, failure looks like this:
[ ] MKTME: Registration failed. ACPI HMAT not present.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index 2d90cc83e5ce..6265b62801e9 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -2,6 +2,7 @@
 
 /* Documentation/x86/mktme/ */
 
+#include <linux/acpi.h>
 #include <linux/cred.h>
 #include <linux/cpu.h>
 #include <linux/init.h>
@@ -445,6 +446,12 @@ static int __init init_mktme(void)
 
 	mktme_available_keyids = mktme_nr_keyids();
 
+	/* Require an ACPI HMAT to identify MKTME safe topologies */
+	if (!acpi_hmat_present()) {
+		pr_warn("MKTME: Registration failed. ACPI HMAT not present.\n");
+		return -EINVAL;
+	}
+
 	/* Mapping of Userspace Keys to Hardware KeyIDs */
 	mktme_map = kvzalloc((sizeof(*mktme_map) * (mktme_nr_keyids() + 1)),
 			     GFP_KERNEL);
-- 
2.21.0

