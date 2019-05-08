Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46303C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:44:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FE99218BC
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:44:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FE99218BC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEA376B0270; Wed,  8 May 2019 10:44:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF8CD6B026E; Wed,  8 May 2019 10:44:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FB1A6B026D; Wed,  8 May 2019 10:44:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 550126B026A
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:41 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 5so6721700pff.11
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rhG5yn7GLfSHaDKkVIZRLQk3h60qOXt5jTZAW01pjMo=;
        b=tsVZRKp3WkI8dfz52GUTa8hL45QnFqwpRtme4FAZoF+lBXV7yLWtVQp4nIEOxZ2Mwz
         R3knAiTUNuHA0urd5BTaGjJBym8C9sN3Qgik25gUjJDqCffktOfdYQsZHkIQ29m/XsRJ
         QC8GWOFuuzuPA+cgfGKg9o1FcT8do9e3D43F6J8qwgKxwK+EpfK2SHf9BfambI1SGVum
         N5/owJHpVsosZJke8/STyCHxQjtZ6qmKkRlbt0vr0oCQRmOdCa5C0cFSCpbaHM3gS2wI
         6hjENVoUvUVqRRWyvqqZnU1zh9sZx0RjI77/eC77Gmwto0hMibw++hEfwm1oGjNBuaNe
         cndw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVQdd+HwgUgK33NsYy6wyHSsJ5yHEW71IRUr4Grzz/ZyXdibBX2
	EUWPZHDQ5wHgNFDj8ywFMM9K+qQ7anpMz24T6I9U5BVoZRrx3M6IbWGFxNOxp2X2gQY+k5rEgfp
	tpng8+OSUL7/cw0CeXQc/CcAFQP8U67WCMnd/jJUooXb/RL2sRQtmqKnxFeL9F15H0g==
X-Received: by 2002:aa7:881a:: with SMTP id c26mr45687033pfo.254.1557326681004;
        Wed, 08 May 2019 07:44:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOfhFvQZxmXYO1V4XK1CZAgkZlqWKAlEunKSwIi446olE5dsMGWR9EBvmO6UTcNORw05B1
X-Received: by 2002:aa7:881a:: with SMTP id c26mr45686906pfo.254.1557326679880;
        Wed, 08 May 2019 07:44:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326679; cv=none;
        d=google.com; s=arc-20160816;
        b=VehZCG2xUC+fpcUt1Tcn4D4QjtMZCAuOWrGTHMtwUENlvUEJLD/pa6xeNR0AOovzkY
         w0tRuSerfEdVPDmrypNwRTTLfUfx2IMqtZqDTSId2zuXzbVZsVGHWYkvWKKn3N+nLdXU
         5VB9OhNge4v+AA/xUa06bP02mHeIdsXtpd50E0RQ7dQm+rX+6NLwyiISBRSru40B/4he
         VLOeqUSNx93v90u/dSiFhH+OlHu3TxZ3l9Leas4VBOU4w5GQPLvdFjybV1Bw4F7QnHkf
         0Lf1JfGw3DKJQEWC4YMTRlv73tT8Qaul3PcJhujHe9QFGcZIBe66m98Y5Cd70kdT8J9N
         KaHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=rhG5yn7GLfSHaDKkVIZRLQk3h60qOXt5jTZAW01pjMo=;
        b=gXrR1p1wxkKZtk85D0g/tKJfWZinf07BO44HZmJJ73VBna9GhAciyHz/3j9F6cURon
         WRXMqLAbaD4FWB73w7u2AGmH/xs+d9XSc16C6Ff6qGywx6d6XLkTSBbrH2vE2SkYDNTj
         sf87qoGRAU2kYRjReW89kjQd37lhkT940wJCQJDRNADr8Nlc/HZ9D/ygkg0G5+2RLRsK
         zFUefrzfkqgICFz3KMi+sfJsGEHAxQVG4YjkWVGzPr5TjKpxVxtx/lxwn68xbsuAHIUQ
         UOdDV2JHtNkMzejNakZRVEUlq1oYY0Rp9/EyZTZ4Od0U6rPrtQjClhywO0QgXgbsVDjT
         VGzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id k12si23661077pls.436.2019.05.08.07.44.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:39 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga005.fm.intel.com with ESMTP; 08 May 2019 07:44:35 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 243E9709; Wed,  8 May 2019 17:44:29 +0300 (EEST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
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
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 10/62] x86/mm: Detect MKTME early
Date: Wed,  8 May 2019 17:43:30 +0300
Message-Id: <20190508144422.13171-11-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We need to know the number of KeyIDs before page_ext is initialized.
We are going to use page_ext to store KeyID and it would be handly to
avoid page_ext allocation if there's no MKMTE in the system.

page_ext initialization happens before full CPU initizliation is complete.
Move detect_tme() call to early_init_intel().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/kernel/cpu/intel.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index e271264e238a..4c9fadb57a13 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -161,6 +161,8 @@ static bool bad_spectre_microcode(struct cpuinfo_x86 *c)
 	return false;
 }
 
+static void detect_tme(struct cpuinfo_x86 *c);
+
 static void early_init_intel(struct cpuinfo_x86 *c)
 {
 	u64 misc_enable;
@@ -311,6 +313,9 @@ static void early_init_intel(struct cpuinfo_x86 *c)
 	 */
 	if (detect_extended_topology_early(c) < 0)
 		detect_ht_early(c);
+
+	if (cpu_has(c, X86_FEATURE_TME))
+		detect_tme(c);
 }
 
 #ifdef CONFIG_X86_32
@@ -791,9 +796,6 @@ static void init_intel(struct cpuinfo_x86 *c)
 	if (cpu_has(c, X86_FEATURE_VMX))
 		detect_vmx_virtcap(c);
 
-	if (cpu_has(c, X86_FEATURE_TME))
-		detect_tme(c);
-
 	init_intel_energy_perf(c);
 
 	init_intel_misc_features(c);
-- 
2.20.1

