Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F808C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE29920693
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="tW+zNphq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE29920693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C47EE8E002C; Wed, 31 Jul 2019 11:13:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B828A8E002A; Wed, 31 Jul 2019 11:13:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A24838E002C; Wed, 31 Jul 2019 11:13:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 37DD28E002A
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:13:57 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y24so42671105edb.1
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:13:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=I5PL3KEd8NdLoJF+LQ8UkD4dkMItZA8rJO7OBoBpg0o=;
        b=LZxdH7QbKUjlvsNgxgJ4tyM0nX75348OHEUoIcpz1FFioDD/dgs7ktBS8vq6XU5Mkg
         ceoNU5qV3lZMzdntF3/pTcN2iwdkDj7X6n/UExjGphu4mgJrVtkAUEVmeGvl6QotUHLA
         J6qMLhGQw0bv4O610kgGK/SQ9SN9ltLvTikuxSVl3BqGVXyG3bwsrYJvNWknbmsVqgxV
         60Karm7J9tfZndfdemLjcecUpj5MoWjZ9FwphO4Q3Kz4mx5/JMhHss4VygSZcgKRLBk6
         XBcdPyhpmfmf8b7YdZdQvjkZ1z15bOzOefS5gjvMoct0XEEy+X7otZb1kk1fsBoXkrb0
         MsCg==
X-Gm-Message-State: APjAAAXvHjEXH3zwLQpjljEwTEVfzUKreJiX0oZOJ6SlwYf1ce2HhmLB
	LZxYySTM/5bvr9KxFsJb2KRsR+nMQLkROVtGe7cmyRYP1DdTLUcfiChnw1Znm+ZpiHyr7Q8VAiS
	EqeCPdAOXmSaOat88o3N37pXyvhVX9ooUOTlUkb6sAw6vS9LErlHzsT+CjQhu8Ws=
X-Received: by 2002:a50:a3ec:: with SMTP id t41mr107388220edb.43.1564586036806;
        Wed, 31 Jul 2019 08:13:56 -0700 (PDT)
X-Received: by 2002:a50:a3ec:: with SMTP id t41mr107388130edb.43.1564586035915;
        Wed, 31 Jul 2019 08:13:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586035; cv=none;
        d=google.com; s=arc-20160816;
        b=Ks+ygNAbxouddKDHyeJmdDTE9U8LLgOXyXDWdqBcY3elJ30l0PvJ2Pe2lDufy9sdkb
         7jf3xgjwiDrcOgtdOLs00jB6ecIJTRJnmIhaE4uRoZYLU8ylEAptsbFjHCMu73zwDkav
         XRm70O+vrfG16gtJJjtLbAWnFupo7yTJuZa/JOzY0Q+10mnFnvxSM9hT5PeFt1W2pWEt
         OhcKEsyvizFxL2zOAv8CKyDmZXdM2ZqIX4F93iNzF+2KZY1BIA6N55LYveGikIEFf66K
         uPil/rOWe9OqOreewLBmdOD+WL0KiCP5Ap5QSDpiRJ+ztloQ3bOy5T9PsxicfuwFSLM1
         72Iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=I5PL3KEd8NdLoJF+LQ8UkD4dkMItZA8rJO7OBoBpg0o=;
        b=jZl2koepLvUIxr8pcz/QOFG50UneVr9RgJ0M+FEG2Ve55ocNMwuu0zakL0u/Aef8Ss
         Rq2CopoJ2M3zmW/K49ErBKfwcPwltMuKiSROvo5l9NfRqoQhz+6k4JW4Yy/rSrAjXX99
         tRtLFXsY96oJ9LSn/M1ArMxKFfbvFez7j1GDkg9Hh4ptpyzvNGNbRPdvhxKw8bDN1+mQ
         0tiMdojc4htO5SuNXAbbVELkE6kXopM03pVDFzo2JCmSp4a+sTbcL1/nExCZMbkLsgsY
         h8onrRVOvRkRo0Er4ymHuHlWQtFDSrqJSrBu4T2CleGJrjXQCv5fAGDV8xZjGlntLOFL
         4+tQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=tW+zNphq;
       spf=neutral (google.com: 209.85.220.41 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s23sor22389897eji.11.2019.07.31.08.13.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:13:55 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.41 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=tW+zNphq;
       spf=neutral (google.com: 209.85.220.41 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=I5PL3KEd8NdLoJF+LQ8UkD4dkMItZA8rJO7OBoBpg0o=;
        b=tW+zNphqnZbkGHkrMBxx1TXe9FglfbohupscPg50rqzrfHLWW9Hl0Z+CMMOXjE/R2+
         NcyfhCCsOWXcuwckjmfDmtUusVsnWuowFpyaegX4gCHmyqrGBy+MQMUADGcZpvVKZ512
         11xIjMWWAyW63Hda6ArgtSMycjMggoGiwik1SYPbJausNlmbXMmpld6k3+d5JCJ4LZJP
         gwHYjVnbIrQYu9TGb2+5XJG8HpaJESPi+R23zoUlviPx31pjGUmVrMYLiGF/H3Dcw0QM
         E2t8w4UFu33JUkrOE5ctmB9g/FhPzqGB/iO94n+xj19M9EujxQQ7zv77d7Yw2DGds/F/
         6oYA==
X-Google-Smtp-Source: APXvYqzcY0rGlEFl7gKQAV09OPdwNja6Zvxs45AN38Cu6T9Con7khC9d8WVErECQGCkC99X7sSihKQ==
X-Received: by 2002:a17:906:2557:: with SMTP id j23mr93846289ejb.228.1564586035522;
        Wed, 31 Jul 2019 08:13:55 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id p43sm17365793edc.3.2019.07.31.08.13.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:13:53 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 809A21048A8; Wed, 31 Jul 2019 18:08:17 +0300 (+03)
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
Subject: [PATCHv2 56/59] x86/mktme: Document the MKTME kernel configuration requirements
Date: Wed, 31 Jul 2019 18:08:10 +0300
Message-Id: <20190731150813.26289-57-kirill.shutemov@linux.intel.com>
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

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/x86/mktme/index.rst               | 1 +
 Documentation/x86/mktme/mktme_configuration.rst | 6 ++++++
 2 files changed, 7 insertions(+)
 create mode 100644 Documentation/x86/mktme/mktme_configuration.rst

diff --git a/Documentation/x86/mktme/index.rst b/Documentation/x86/mktme/index.rst
index a3a29577b013..0f021cc4a2db 100644
--- a/Documentation/x86/mktme/index.rst
+++ b/Documentation/x86/mktme/index.rst
@@ -7,3 +7,4 @@ Multi-Key Total Memory Encryption (MKTME)
 
    mktme_overview
    mktme_mitigations
+   mktme_configuration
diff --git a/Documentation/x86/mktme/mktme_configuration.rst b/Documentation/x86/mktme/mktme_configuration.rst
new file mode 100644
index 000000000000..7d56596360cb
--- /dev/null
+++ b/Documentation/x86/mktme/mktme_configuration.rst
@@ -0,0 +1,6 @@
+MKTME Configuration
+===================
+
+CONFIG_X86_INTEL_MKTME
+        MKTME is enabled by selecting CONFIG_X86_INTEL_MKTME on Intel
+        platforms supporting the MKTME feature.
-- 
2.21.0

