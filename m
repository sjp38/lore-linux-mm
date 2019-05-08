Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE4DEC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 628D921734
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 628D921734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17AF26B0297; Wed,  8 May 2019 10:44:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBAAE6B02A2; Wed,  8 May 2019 10:44:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC2686B029F; Wed,  8 May 2019 10:44:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0EB796B029D
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:51 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id u1so7217206plk.10
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=C0qd/ZrLjU/aqPZxyXdJXxvU47OZwk6fFZiZPrrOo54=;
        b=KbprH3MTbTVcuX/91/KixUnU8xCDFHpemYaUEzI7JsiWlREU0JUEf8koBwzHCcvji2
         mB3pijdXH90a4DneKit4YsVDOgC1UAeHFmC0I94BFW8VCQAYaPVmTDbUnUQAqRf+aqZv
         StLq3NijrQH5Hs0oB6WdfA+RcMggPHvzgBQ1im6UNltKo6pSQrr4QPcjja1MjJxn7sVM
         TADjDjZ4IxbvJUEHei5MJF0PEjNmRKBFcifWBY+ZCaphMo42YGQlyHK/jRY4uUkqirv5
         TSpkc2cDIO4Zrvi3C3MZriJajEc5rMUMi42e+931kymbgRgujVAFnepxZXuMeVwU8cvY
         H2xA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWvqZJlTgmEqyNKf2Kwv2JC2wr0ASXZ0k+ZSGE3CkcEg4Of4Zcp
	rKMihArZMgXcfhKNw0vJKfeE136EFBLViwBpszw8GWWBc2PVZfUdW9ZGMJRVkgwvxYyV9XDhj1W
	POIGVz4s8T8an9piH6PnvSv1FU1HCniObYFRZU7VUTkXhWsTjfR+6QXBnp1X78AsY8Q==
X-Received: by 2002:a63:d0e:: with SMTP id c14mr7072436pgl.345.1557326690729;
        Wed, 08 May 2019 07:44:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzAn7c9gJqgN7ZlcbBN4ykIcAie7uMNG2JV6/yp/QCr/YiwEP7NeH8kf1sDV6rQ9rZ3EGF
X-Received: by 2002:a63:d0e:: with SMTP id c14mr7072295pgl.345.1557326689423;
        Wed, 08 May 2019 07:44:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326689; cv=none;
        d=google.com; s=arc-20160816;
        b=CsTqRI33tGNkTfVjSjkzWomn+WY8z8ZKbj2cEADSSSF1z+4hTKqILQoppTGqSTD+nf
         +jRZyFV8+I0TfhmOSnNZekgcg6EaiodyAiDVgrGLKmr5bRt4YHQdF4N8IDvxMaEUMSWS
         aV0LUC1elGq/DQl6a/n5xjOBPnlS3/lp/7B2I4wYSpmokZh2tfHfyrEfGftvY8hiDqxr
         7DLM5qzPmUGiWhyAYhkTPgBCC1UEWpLLHrqMKffeZ6zdZz3IG0KIDCKtlx73UPsRI2bU
         a8IHisiyJHKo9577eQHggw/LzVHJI1C/nAWjTvg54zDntlC836HVNhU4bk1/AA2z8eIP
         zSbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=C0qd/ZrLjU/aqPZxyXdJXxvU47OZwk6fFZiZPrrOo54=;
        b=w4OefjDvK6sduhk0gpZ20NiO7cKGixX0i0DUeOMTNS7E9YFmUXYVkooaXhurQXuH81
         2plUq7foWjTx0oeWhiIEuo5qPue1VCohQHeAGaykMuoUffm05yylrcsWe0ompuBfEbDK
         OB3PKX2JRDQ80G3G/AclzLHfLCSrRdgfwBlj5qeD6ATaBYFLHJHlP6P5N0ymGOUa7kwM
         8djckYTCJ1joMbJRlYNC7tyAQbeRRdq9U6ixdWkHfxbYE3CwH1wWhzbAJA3SYrRpwuiW
         k5QnmBjp8qNQz1LRbM3QWjgNMnXn1KK3iRp5gpb/qd9ocHuEM0ttnm/wGs3H+Ua8fbZi
         vQuw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id e61si23294206plb.123.2019.05.08.07.44.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:49 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by FMSMGA003.fm.intel.com with ESMTP; 08 May 2019 07:44:44 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 9F78EC1D; Wed,  8 May 2019 17:44:30 +0300 (EEST)
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
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 39/62] keys/mktme: Find new PCONFIG targets during memory hotplug
Date: Wed,  8 May 2019 17:43:59 +0300
Message-Id: <20190508144422.13171-40-kirill.shutemov@linux.intel.com>
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

From: Alison Schofield <alison.schofield@intel.com>

Introduce a helper function that detects a newly added PCONFIG
target. This will be used in the MKTME memory hotplug notifier
to determine if a new PCONFIG target has been added that needs
to have its Key Table programmed.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 39 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index 3dfc0647f1e5..2c975c48fe44 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -543,6 +543,45 @@ static int mktme_cpu_teardown(unsigned int cpu)
 	return ret;
 }
 
+static int mktme_get_new_pconfig_target(void)
+{
+	unsigned long *prev_map, *tmp_map;
+	int new_target;		/* New PCONFIG target to program */
+
+	/* Save the current mktme_target_map bitmap */
+	prev_map = bitmap_alloc(topology_max_packages(), GFP_KERNEL);
+	bitmap_copy(prev_map, mktme_target_map, sizeof(mktme_target_map));
+
+	/* Update the global targets - includes mktme_target_map */
+	mktme_update_pconfig_targets();
+
+	/* Nothing to do if the target bitmap is unchanged */
+	if (bitmap_equal(prev_map, mktme_target_map, sizeof(prev_map))) {
+		new_target = -1;
+		goto free_prev;
+	}
+
+	/* Find the change in the target bitmap */
+	tmp_map = bitmap_alloc(topology_max_packages(), GFP_KERNEL);
+	bitmap_andnot(tmp_map, prev_map, mktme_target_map,
+		      sizeof(prev_map));
+
+	/* There should only be one new target */
+	if (bitmap_weight(tmp_map, sizeof(tmp_map)) != 1) {
+		pr_err("%s: expected %d new target, got %d\n", __func__, 1,
+		       bitmap_weight(tmp_map, sizeof(tmp_map)));
+		new_target = -1;
+		goto free_tmp;
+	}
+	new_target = find_first_bit(tmp_map, sizeof(tmp_map));
+
+free_tmp:
+	bitmap_free(tmp_map);
+free_prev:
+	bitmap_free(prev_map);
+	return new_target;
+}
+
 static int __init init_mktme(void)
 {
 	int ret, cpuhp;
-- 
2.20.1

