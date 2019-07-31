Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C859AC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:13:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 808D621842
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:13:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="vfdW7e5V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 808D621842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0F1C8E0023; Wed, 31 Jul 2019 11:13:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE8CB8E0022; Wed, 31 Jul 2019 11:13:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 912088E0023; Wed, 31 Jul 2019 11:13:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 41FD58E0021
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:13:52 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r21so42620012edc.6
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:13:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uIXZ0F8v9y0X5Vlr65FlBUe43ILwGFJ310V1qk1n87Y=;
        b=TGJIYCVaC5e4y2oxMu6TcvezqOdlle09Cuq8RwMMF4hyH2+LzO8fuimGky5C+AroIL
         FxtHT3qVcidir/YPkF/um0l1DrGD3moQmBh7hz8DoCsZM54TldENvaSP87ksjtLdoG43
         BasC9W9YLl00ibsBQGgVbH+XUQCJGSLYLIiqIRfWTQ1aRUIFb6wzRLKUpuLj3hzU5cQh
         yO1/wTt+iwkNm0K8XV70EmmMJAL3elCYzO8WbtuHTP7wEfMnzH8pFB3ozQI90kkNGj+X
         lLJ1x0KrG94KxiReHsEQJZMn6G2g3j/xa6lBFuhwMksKaYg8JsWcQ9thBUn38mcZDfvf
         f5Yg==
X-Gm-Message-State: APjAAAUOc8Q20ghQrdQW6YUqu+UGCA/izSACXSjt71WmgzI/0j6atTkR
	DVVWZkpigSniv3jSAU7QnjLdqxaoF0LRG7NuZzlOHNOvB/W3p9PPuCOqIniCjanHbyKmQZkpxRy
	UlFUgSMQo7vhnFx2Skj002G63yl15mDule88A6CdpyVoHnUcP828RbT68a8VLyfE=
X-Received: by 2002:a17:906:2555:: with SMTP id j21mr96482485ejb.231.1564586031811;
        Wed, 31 Jul 2019 08:13:51 -0700 (PDT)
X-Received: by 2002:a17:906:2555:: with SMTP id j21mr96482352ejb.231.1564586030232;
        Wed, 31 Jul 2019 08:13:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586030; cv=none;
        d=google.com; s=arc-20160816;
        b=sLjudbY6SXJr/jNTxxZjxwnT3/s8MSPLV5oqi7lAWUlfHhrYQc5H0O5Q/e7JRu9BT9
         GE9Ymv5p51Jkt5srwpi0/bWd2IjWBNcACd/xtub9jjwn9Uof1xU7AeJ6s0QKBOECKZd6
         Sw8m9fkqROBuccfoOq+1ZWQdoXIGo0aZ/KvaLfZlOtbqvv+uI9CJjqq5hzLYuCDP9O15
         bhQ4jl7V8+uXf12XHT+pvpoH03go5GPMcZz4vgI1ZeEtZznQDJTIEMCNaScI89Ufu4xO
         +jj86gvo0FmQsSkgwURbIfKuAS2apKAL/SsKHDEteSKBrEoMcNzo4Ff9LhTb1VeSKMxO
         CjEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=uIXZ0F8v9y0X5Vlr65FlBUe43ILwGFJ310V1qk1n87Y=;
        b=HC3vl6vjcG8XGwXJmznTQevNxofRW6UW1HJB0JvhIm/wDt+WGHdZBVef4v9XP/J4sb
         ItISXVfRYSTUlncZRV7N31KFRli8XhIdtLJbA6Q70Fz9hHGxAnAbRHg3W+/n06bUsDs2
         7VZe1AFPLNjPMy7i2wZ8wspKpYEvTKR/bt7Ypxy40NqYM6v6m+A+6Odx902+12L9nKBu
         J8ST8luEgMG3gvewVAOxfWFtAAn7UcHnV6BLsjlBoxGVRqr+qMmUH3q20NGR5nGPenRG
         Q8r2Wq1CfNNoWRLqLxH/uen+qXnDuZN83vWO5rrd0j4NMSHfVqGx5zTRSpqswSKx8vmT
         9qBA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=vfdW7e5V;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l22sor52317825eda.1.2019.07.31.08.13.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:13:50 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=vfdW7e5V;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=uIXZ0F8v9y0X5Vlr65FlBUe43ILwGFJ310V1qk1n87Y=;
        b=vfdW7e5VZM1NTRsW9Qj9s3ymywg9Z9eZf0L8H23FhduBuIwBKrkUvK2YDh7+VgvO2z
         3q9p0yQ2/EX6CTrY+uDCaCJl6TyJDc+BnE2CZKywXpecMsM8Q5tNHXv9bcx8OOj8tnBm
         QH3O/qxckPbmTmy4X1F0rKZmU1UXd0VSYVNKsK+ChAul5R8pVMmYFyXbEmcIU9HHfUbN
         frKzsjweIKsQ0mnZrk/2o3FUXu9XTU+CZ3leIN6sTXmycUuVIoqiQg6NFsv1CV7J2zOR
         MHvIFNk9NC4quOBkwU2rhdIHH54BaXnZovl+oi4BNME3i/u2OjU/uJHdK2YV59LnCg7W
         X1VQ==
X-Google-Smtp-Source: APXvYqwYeWMLltpEBPBckLNCM+g7S+IY4Us955LLaX0vHxxronyzv/ZLKgeH3uRrChjLLmvrEg+r8g==
X-Received: by 2002:a50:c28a:: with SMTP id o10mr105376291edf.182.1564586029913;
        Wed, 31 Jul 2019 08:13:49 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id j10sm12539092ejk.23.2019.07.31.08.13.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:13:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 095281045FD; Wed, 31 Jul 2019 18:08:17 +0300 (+03)
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
Subject: [PATCHv2 39/59] keys/mktme: Support CPU hotplug for MKTME key service
Date: Wed, 31 Jul 2019 18:07:53 +0300
Message-Id: <20190731150813.26289-40-kirill.shutemov@linux.intel.com>
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
 security/keys/mktme_keys.c | 47 +++++++++++++++++++++++++++++++++++++-
 1 file changed, 46 insertions(+), 1 deletion(-)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index 70662e882674..b042df73899d 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -460,9 +460,46 @@ static int mktme_alloc_pconfig_targets(void)
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
+	if (mktme_available_keyids == mktme_nr_keyids()) {
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
 	if (mktme_nr_keyids() < 1)
@@ -500,10 +537,18 @@ static int __init init_mktme(void)
 	if (!encrypt_count)
 		goto free_targets;
 
+	cpuhp = cpuhp_setup_state_nocalls(CPUHP_AP_ONLINE_DYN,
+					  "keys/mktme_keys:online",
+					  NULL, mktme_cpu_teardown);
+	if (cpuhp < 0)
+		goto free_encrypt;
+
 	ret = register_key_type(&key_type_mktme);
 	if (!ret)
 		return ret;			/* SUCCESS */
 
+	cpuhp_remove_state_nocalls(cpuhp);
+free_encrypt:
 	kvfree(encrypt_count);
 free_targets:
 	free_cpumask_var(mktme_leadcpus);
-- 
2.21.0

