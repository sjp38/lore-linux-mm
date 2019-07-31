Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D401EC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:13:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A92421726
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:13:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="oLYDLyPe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A92421726
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31F3A8E0020; Wed, 31 Jul 2019 11:13:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2CFB88E0005; Wed, 31 Jul 2019 11:13:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BED48E0020; Wed, 31 Jul 2019 11:13:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C3E638E0005
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:13:50 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f19so42620124edv.16
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:13:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PzedmcWsRc3DhudY/wiWcVyq0AAagaASN0DGAs1EUfk=;
        b=R8RzN1CKnHaZIhUVqSMMCHTUEMYgB12cMCMfyZr7kFIsClKmm14vKFFQZ8yfOMrzh3
         jLXMICM39wOwKmTwf9VG11btw2v2L5vckqUk00oIKkFMggDAPhalYDkaLlcFCwfM26ka
         npnIfaDo8Npm4FwCyjRL/82obmOI2PctCOyPTnDIxkVBxjQoH8uXNbuWPq7K2WuI7nVH
         Zl61y1M2ZFDSta1XclRqhoXmYAaBfTkBNxrYh1CwPXxDQfqqeqZX0sVCd2GFpku8lQZM
         5isDJSMnbme9/TYCpvEhOSIUc1i8ngDbF3rrX5IUmfqMCdumCQfu9ojAum+OAGLreSG5
         g3Nw==
X-Gm-Message-State: APjAAAWL7/60RhknERL/4Y3V2CBoaHno4bA1FJ+n9Mzfb3sDsTNxoHXq
	NFXztp7mc21uC3gpdoKWQ4Q470kqF/Ic8RYAibKO8ZGagA6UZhv9iZmTsQ+DykJPdqV4Aanity6
	dVZnIQHynG8av5awiir9O7cpIhwSU43FnEmyqlQ32VriYb61quZwnFd/Oa3IXack=
X-Received: by 2002:aa7:dd09:: with SMTP id i9mr109849273edv.193.1564586030332;
        Wed, 31 Jul 2019 08:13:50 -0700 (PDT)
X-Received: by 2002:aa7:dd09:: with SMTP id i9mr109849142edv.193.1564586029040;
        Wed, 31 Jul 2019 08:13:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586029; cv=none;
        d=google.com; s=arc-20160816;
        b=tlhCHIilpx/OPSkykDMYCDKW9aLUNlglZTZOfUo7wXdZ+F2YxIhlsmaxgMkc+SF+cm
         I1PPkbMldDM91hMd1nd5bJPiXHHDHRtPk4shyMCiBXe5rdHVWpvZR2Y2L998fu/oFDTz
         PZnweN9EQ+LWf22t+M48Xu1aEJfMX51N5XV6GQMjXopVhvHr0QW4MZZ2fTgkIkMg7Mom
         psYCBeYNQfabKYaE2xf/qZF65WfHVppBBxTjGOlsv3LyD0FhJWlY7Nq4P74k+ehdsPLw
         xPSIdVzcsjm5Mzlf+UUB91yOHqEZ67CEH+Ryzn4AGGrZZGVc4MxR0EajIRSrxZRYuvoK
         2U1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=PzedmcWsRc3DhudY/wiWcVyq0AAagaASN0DGAs1EUfk=;
        b=s/Ewn/qepdjFUnS+RiaNb8qj4sQwilpo5C4qioS3QG/zfQaC9HRam64KHbu2Ys408z
         0eIHln1moIQ732ccM7O9q5XuFFnKw5cgMmkSrJ9ACUjDHC9i493GZBA3AhaEUmqmUqIy
         bdOWLTdUJhppuYhgzrUZj06xQ9qDen4wAOE8+foYlIcKHUrD7QB4JB2U2r/+DDXX/YgB
         1YG7X+Mei4mxttvaMBlKSa65yknjVJzySJCXDlIdzUCIG1c8e921zqsUyP72L7dxfLDP
         BjN6/3bYUMRIIQ+KQedzTCGSJYQ2MiJL89KbtRc9lFMikbAXWwuCDkwOlxWNSsHiCC1l
         f5Pg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=oLYDLyPe;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f3sor18863803ejq.0.2019.07.31.08.13.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:13:49 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=oLYDLyPe;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=PzedmcWsRc3DhudY/wiWcVyq0AAagaASN0DGAs1EUfk=;
        b=oLYDLyPe+JzY2m1J7wjX7AgBe2E4rUQv0fXNMOTxiG0nu3Kabo9U15Ufg7K6WUQgmi
         RNNtxu0DlWJ+voFj2zV59ecQN7UXfIGdJz6l2QQg7hl1DF1htbBcFoFM/zAI2mPjcI1U
         l3fEHvv0/1gka708wHD2qXwLZrc051+nm/YjhW0tIhCa72L/Tien3Zer+cqAIsJMVqNK
         L0WPnYRQdIixCyrAGbQRcVHhSuhtXWLR41Rx6IQOFrIz+x0hmONqrQ/gZtqcXxab8960
         yeuaFiFWFODRPxwK1POFLi1ZUqFHAQQefGlgCb9xVI6pv/BL6bFoNByecBEofA/OdSSY
         7nrg==
X-Google-Smtp-Source: APXvYqzcJGczjYcDRUjZLltV4/L8von3YErmNZFFERlXjz5jyiPEJ/PtKIEf2ACHSo4AM9+ctzEY3w==
X-Received: by 2002:a17:906:c2c9:: with SMTP id ch9mr2839424ejb.167.1564586028666;
        Wed, 31 Jul 2019 08:13:48 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id a18sm9661518ejp.2.2019.07.31.08.13.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:13:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id BF3F9103FDC; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 30/59] keys/mktme: Program MKTME keys into the platform hardware
Date: Wed, 31 Jul 2019 18:07:44 +0300
Message-Id: <20190731150813.26289-31-kirill.shutemov@linux.intel.com>
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

Finally, the keys are programmed into the hardware via each
lead CPU. Every package has to be programmed successfully.
There is no partial success allowed here.

Here a retry scheme is included for two errors that may succeed
on retry: MKTME_DEVICE_BUSY and MKTME_ENTROPY_ERROR.
However, it's not clear if even those errors should be retried
at this level. Perhaps they too, should be returned to user space
for handling.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 92 +++++++++++++++++++++++++++++++++++++-
 1 file changed, 91 insertions(+), 1 deletion(-)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index 272bff8591b7..3c641f3ee794 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -83,6 +83,96 @@ static const match_table_t mktme_token = {
 	{OPT_ERROR, NULL}
 };
 
+struct mktme_hw_program_info {
+	struct mktme_key_program *key_program;
+	int *status;
+};
+
+struct mktme_err_table {
+	const char *msg;
+	bool retry;
+};
+
+static const struct mktme_err_table mktme_error[] = {
+/* MKTME_PROG_SUCCESS     */ {"KeyID was successfully programmed",   false},
+/* MKTME_INVALID_PROG_CMD */ {"Invalid KeyID programming command",   false},
+/* MKTME_ENTROPY_ERROR    */ {"Insufficient entropy",		      true},
+/* MKTME_INVALID_KEYID    */ {"KeyID not valid",		     false},
+/* MKTME_INVALID_ENC_ALG  */ {"Invalid encryption algorithm chosen", false},
+/* MKTME_DEVICE_BUSY      */ {"Failure to access key table",	      true},
+};
+
+static int mktme_parse_program_status(int status[])
+{
+	int cpu, sum = 0;
+
+	/* Success: all CPU(s) programmed all key table(s) */
+	for_each_cpu(cpu, mktme_leadcpus)
+		sum += status[cpu];
+	if (!sum)
+		return MKTME_PROG_SUCCESS;
+
+	/* Invalid Parameters: log the error and return the error. */
+	for_each_cpu(cpu, mktme_leadcpus) {
+		switch (status[cpu]) {
+		case MKTME_INVALID_KEYID:
+		case MKTME_INVALID_PROG_CMD:
+		case MKTME_INVALID_ENC_ALG:
+			pr_err("mktme: %s\n", mktme_error[status[cpu]].msg);
+			return status[cpu];
+
+		default:
+			break;
+		}
+	}
+	/*
+	 * Device Busy or Insufficient Entropy: do not log the
+	 * error. These will be retried and if retries (time or
+	 * count runs out) caller will log the error.
+	 */
+	for_each_cpu(cpu, mktme_leadcpus) {
+		if (status[cpu] == MKTME_DEVICE_BUSY)
+			return status[cpu];
+	}
+	return MKTME_ENTROPY_ERROR;
+}
+
+/* Program a single key using one CPU. */
+static void mktme_do_program(void *hw_program_info)
+{
+	struct mktme_hw_program_info *info = hw_program_info;
+	int cpu;
+
+	cpu = smp_processor_id();
+	info->status[cpu] = mktme_key_program(info->key_program);
+}
+
+static int mktme_program_all_keytables(struct mktme_key_program *key_program)
+{
+	struct mktme_hw_program_info info;
+	int err, retries = 10; /* Maybe users should handle retries */
+
+	info.key_program = key_program;
+	info.status = kcalloc(num_possible_cpus(), sizeof(info.status[0]),
+			      GFP_KERNEL);
+
+	while (retries--) {
+		get_online_cpus();
+		on_each_cpu_mask(mktme_leadcpus, mktme_do_program,
+				 &info, 1);
+		put_online_cpus();
+
+		err = mktme_parse_program_status(info.status);
+		if (!err)			   /* Success */
+			return err;
+		else if (!mktme_error[err].retry)  /* Error no retry */
+			return -ENOKEY;
+	}
+	/* Ran out of retries */
+	pr_err("mktme: %s\n", mktme_error[err].msg);
+	return err;
+}
+
 /* Copy the payload to the HW programming structure and program this KeyID */
 static int mktme_program_keyid(int keyid, u32 payload)
 {
@@ -97,7 +187,7 @@ static int mktme_program_keyid(int keyid, u32 payload)
 	kprog->keyid = keyid;
 	kprog->keyid_ctrl = payload;
 
-	ret = MKTME_PROG_SUCCESS;	/* Future programming call */
+	ret = mktme_program_all_keytables(kprog);
 	kmem_cache_free(mktme_prog_cache, kprog);
 	return ret;
 }
-- 
2.21.0

