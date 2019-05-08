Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A8A7C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEBC021734
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEBC021734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44C076B029A; Wed,  8 May 2019 10:44:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 175EF6B029F; Wed,  8 May 2019 10:44:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E413C6B0296; Wed,  8 May 2019 10:44:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9FF536B0296
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:50 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id l13so12821434pgp.3
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7eEV193O1yOekktulhSkIW0ieskAH9Mu6tK3MJFJ1ek=;
        b=UwYJOVIbL5KnuMk6y1gUtUOcaMIZCDrRQRxyjAgSptQ4bzUcMBUbq4GMjTvq6Ubkq5
         5rSZm5FgcQjqd8K5aHoXqxIQIKUNbVogYLKkuD0EWPP0rOZzly7K2l7Vs8DEkmiFWIwh
         xd9CkIjRwiq8MfLw/kUBCT/wHKzAdQAgYkOPRW/l/dDx74XivoobfBdkDdjwRsApXk/8
         k5ADmeVVB9Bnbz/DO3tyv2jXeCeLnMQrrKaUnLH5+uPIgKISGqVGrMngPWNcogewoTeS
         3IUj1HNlX4BrgKdgIwlhVNdCvamJ5IVmsy/kvi74YWUY89jRcraszRSNG0hKrTOVYUIr
         shVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWwdTPpOddW5kkAnDyCB56PSF4rOI7ucxNP4qkupwYCf+sFHUCg
	uTcm2nBoO3PThTSxgkpNqDQs/FfhPkGxkJENw3FJMqmf1RlegLsaDzCuXMHF1WqT/ZzTTbULd2x
	clqW5nLZulGYznfVz8X9NMpS558RJpWtnMCMwG+TCemV+R8OXnDDRK3UAqxqYmtw/iQ==
X-Received: by 2002:a17:902:684b:: with SMTP id f11mr39991296pln.96.1557326690301;
        Wed, 08 May 2019 07:44:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGwtETZMcVWA5tJeFt3lJmBt2h2a6fxNfy6uQMqdsddeQfttQZZRquhmw1aJ3lLZTskRsd
X-Received: by 2002:a17:902:684b:: with SMTP id f11mr39991146pln.96.1557326688959;
        Wed, 08 May 2019 07:44:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326688; cv=none;
        d=google.com; s=arc-20160816;
        b=R+Uvqn7gzP1Fdc8Ai1btaEfTwxVfEwH1Lahk/AYitTqTKDABsyF3Wulk9NVnvo2kBS
         d7iQZJLZGOK9mt/+/LdJM/t81/PEB3RcI3b38wFHCychEofQ0lJesA1MB+O2TIDAmUQC
         vL96QyXfUJslGg3otss0V6BHgpiNpZ7UKEoyHYHGfwqeXFFblIky+3SrAU2LBPNn81QI
         YniMy3p2mBZY3HC9GRVsRCXCPDbBlB5s9gHgigVBS9UyaiXULp/JPee6kU++RxL2XjxE
         m0vFVArRipmFlManijskR0AZZpOD4/BJH62bRzKJt6GKX4TQZcENkxhgQsWwoTeIe5Ij
         kahg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=7eEV193O1yOekktulhSkIW0ieskAH9Mu6tK3MJFJ1ek=;
        b=EgOMfucKTPjkgeW+Xh5BZuD/rnMVXvlSVvNfv0pqmzvSvCdBqNqmjLlhNY0j9dFi5m
         G7LZSWvFGJ5Zn1QFwChUy+3s0WSdhPXKcu8wtok19DZnqDn4YI8RF9PMOoy/1gYPmfVP
         uuF9pwpg4Nmx61KCZ0eDuFkJOYQXIB/uJ2YAdkwd27SXB44IgrQHZhRX6uTtJ+TSh7YP
         Giy76dKhgX0z2tI2wyDp0n5GGp8MEILMzn5Cc25S2GPWk0mBmTG2Zmg1WymvFMi/JFj6
         UOern+Vizt47/g5BGkz9LVGw/YSJriZ8XQjiWsrXlBMGo++JtXREyWqQBY9CPCbmo/z8
         HlLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id g13si12322802pgs.161.2019.05.08.07.44.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:48 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga004.fm.intel.com with ESMTP; 08 May 2019 07:44:44 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 9190FC01; Wed,  8 May 2019 17:44:30 +0300 (EEST)
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
Subject: [PATCH, RFC 38/62] keys/mktme: Support CPU hotplug for MKTME key service
Date: Wed,  8 May 2019 17:43:58 +0300
Message-Id: <20190508144422.13171-39-kirill.shutemov@linux.intel.com>
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

The MKTME encryption hardware resides on each physical package.
The encryption hardware includes 'Key Tables' that must be
programmed identically across all physical packages in the
platform. Although every CPU in a package can program its key
table, the kernel uses one lead CPU per package for programming.

CPU Hotplug Teardown
--------------------
MKTME manages CPU hotplug teardown to make sure the ability to
program all packages is preserved when MKTME keys are present.

When MKTME keys are not currently programmed, simply allow
the teardown, and set "mktme_allow_keys" to false. This will
force a re-evaluation of the platform topology before the next
key creation. If this CPU teardown mattered, MKTME key service
will report an error and fail to create the key. (User can
online that CPU and try again)

When MKTME keys are currently programmed, allow teardowns
of non 'lead CPU's' and of CPUs where another, core sibling
CPU, can take over as lead. Do not allow teardown of any
lead CPU that would render a hardware key table unreachable!

CPU Hotplug Startup
-------------------
CPUs coming online are of interest to the key service, but since
the service never needs to block a CPU startup event, nor does it
need to prepare for an onlining CPU, a callback is not implemented.

MKTME will catch the availability of the new CPU, if it is
needed, at the next key creation time. If keys are not allowed,
that new CPU will be part of the topology evaluation to determine
if keys should now be allowed.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 51 +++++++++++++++++++++++++++++++++++---
 1 file changed, 48 insertions(+), 3 deletions(-)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index 734e1d28eb24..3dfc0647f1e5 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -102,9 +102,9 @@ void mktme_percpu_ref_release(struct percpu_ref *ref)
 		return;
 	}
 	percpu_ref_exit(ref);
-	spin_lock_irqsave(&mktme_map_lock, flags);
+	spin_lock_irqsave(&mktme_lock, flags);
 	mktme_release_keyid(keyid);
-	spin_unlock_irqrestore(&mktme_map_lock, flags);
+	spin_unlock_irqrestore(&mktme_lock, flags);
 }
 
 enum mktme_opt_id {
@@ -506,9 +506,46 @@ static int mktme_alloc_pconfig_targets(void)
 	return 0;
 }
 
+static int mktme_cpu_teardown(unsigned int cpu)
+{
+	int new_leadcpu, ret = 0;
+	unsigned long flags;
+
+	/* Do not allow key programming during cpu hotplug event */
+	spin_lock_irqsave(&mktme_lock, flags);
+
+	/*
+	 * When no keys are in use, allow the teardown, and set
+	 * mktme_allow_keys to FALSE. That forces an evaluation
+	 * of the topology before the next key creation.
+	 */
+	if (!mktme_map->mapped_keyids) {
+		mktme_allow_keys = false;
+		goto out;
+	}
+	/* Teardown CPU is not a lead CPU. Allow teardown. */
+	if (!cpumask_test_cpu(cpu, mktme_leadcpus))
+		goto out;
+
+	/* Teardown CPU is a lead CPU. Look for a new lead CPU. */
+	new_leadcpu = cpumask_any_but(topology_core_cpumask(cpu), cpu);
+
+	if (new_leadcpu < nr_cpumask_bits) {
+		/* New lead CPU found. Update the programming mask */
+		__cpumask_clear_cpu(cpu, mktme_leadcpus);
+		__cpumask_set_cpu(new_leadcpu, mktme_leadcpus);
+	} else {
+		/* New lead CPU not found. Do not allow CPU teardown */
+		ret = -1;
+	}
+out:
+	spin_unlock_irqrestore(&mktme_lock, flags);
+	return ret;
+}
+
 static int __init init_mktme(void)
 {
-	int ret;
+	int ret, cpuhp;
 
 	/* Verify keys are present */
 	if (mktme_nr_keyids < 1)
@@ -553,10 +590,18 @@ static int __init init_mktme(void)
 	if (!mktme_key_store)
 		goto free_bitmap;
 
+	cpuhp = cpuhp_setup_state_nocalls(CPUHP_AP_ONLINE_DYN,
+					  "keys/mktme_keys:online",
+					  NULL, mktme_cpu_teardown);
+	if (cpuhp < 0)
+		goto free_store;
+
 	ret = register_key_type(&key_type_mktme);
 	if (!ret)
 		return ret;			/* SUCCESS */
 
+	cpuhp_remove_state_nocalls(cpuhp);
+free_store:
 	kfree(mktme_key_store);
 free_bitmap:
 	bitmap_free(mktme_bitmap_user_type);
-- 
2.20.1

