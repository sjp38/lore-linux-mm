Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F51EC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:04:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C7182089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:04:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C7182089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9BCD6B0299; Fri,  9 Aug 2019 12:01:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E27FB6B029D; Fri,  9 Aug 2019 12:01:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2F516B029E; Fri,  9 Aug 2019 12:01:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 89BC66B0299
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:31 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id t10so1728286wrn.10
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dFDd51/iRhglx+TerHt82UXln26Dp7TInCnSwh6yaL4=;
        b=AHEQfv1idfjppeFDYyd2v2jHNyWjGkMMOQINsSX4jMim1bQa2BCtpDph0qKJ3Ltu7e
         kFQzTy1XLCOLYvhunEw9kjD0e23cz66nR0Qk6E00gc6CrxipU/HsJsIu2cwOs7fu9zjX
         wCcGZ4oHAuq+tnVlcqIbMU53wOB9YOle6Ed+naSRzjN06bzL+ZFvZ3YDyB9wM34ATvyQ
         b+lzemOeB0v/kF0CJcPvp8O2dsi70ligJH0aHjGsb2823qeoGLA+Qpa7ovbZuto12h15
         HvGvwwmfG0PLgQywEAacwlL3eyjWVzrakCZcnMXd0xH9Z0+39dC0b1ZHdEAauCLyI8bG
         ckEQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAVZTjxqgzHRx6Ch5PEev3mrZVOVCQjr8018NO+i0QrWJD9DewRq
	UlOszvQfbqX2FbtxuCdZIkLk+PIaRJC2IE6IYLN77o3eKGxWx4qB6g850bXNTY9s97zSoqhUeai
	qEG0c3XYZKTMv9Fbi7yV1Ydy3Lke83lTfq6F7gk1Pdw3/nCQzP8Vn6/7Hj9ojMTM+8Q==
X-Received: by 2002:adf:aa85:: with SMTP id h5mr14735389wrc.329.1565366491127;
        Fri, 09 Aug 2019 09:01:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8g20nDpaxB2Qtnp/0fud8ap+UJ2KQaWSjb03XbjgYoTB4/esTjh/LdLUN8+/JU0k83IWk
X-Received: by 2002:adf:aa85:: with SMTP id h5mr14735298wrc.329.1565366490127;
        Fri, 09 Aug 2019 09:01:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366490; cv=none;
        d=google.com; s=arc-20160816;
        b=XdBAhBU2K1WaUx24a3FBHIsLV3a+3Y7wi6xh+2o66YXlCDFGm952XRvYP1Cgw/Qt1r
         3w7l4c8g1tJhGKNkdpkF0S5TLRnzpVuzyMlCx1kq7Ln6KojsmgWmz1xrMCf6clyjKGir
         wMWlFb8ofHnN7f/scVGkWwZt8JxowqmykMs2ustGKO6QTzM8ClGWF/oWLSFDotdg6oIK
         SHEoO7JuUXN14jUSRSJs1MIlbzOOY3xX47ZorO+3i1VzLttpstbYoKqQXCeTsHGleUck
         uhwyZxIlCK57/GLBsDw6YQm9GIoEigpMXCF8DILBuY/I4fzHxuVlDaxSu1kSI1ZGC3dr
         A/5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=dFDd51/iRhglx+TerHt82UXln26Dp7TInCnSwh6yaL4=;
        b=YrQbyFi/VV5oZkVIR00cqN0NfyfroeiUjA0stC/vHzdaLBoYaeZsT/pbz6cuqj3iLP
         c6hOGMT/SLUosI87RgSWp5esHsl7lLDi1tB3GBudZnXvP5RBRLTjTdHQgPLkvgC6HrZx
         fPCV1BOMwQFqcRxPkW4ulwtECeyjpdoSjn0TzMxwoUkVblzYckUuS5iLwXKb1lbzXL5Z
         Jj7GhccE24k2etoChwbUZa8R4m4H4+rgrMCaC9rOBquh60oGAHJpDDKYsQ15FaBgbUE3
         EJ8aTvcxSpAZyCoUUzRIHOwbCDv/rhDHkP03f8ItluCJj6DkO8NZPDHqQEpwGldJxIQe
         D5vA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id f11si4271348wmg.84.2019.08.09.09.01.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 80E2D305D357;
	Fri,  9 Aug 2019 19:01:29 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 9DD82305B7A1;
	Fri,  9 Aug 2019 19:01:28 +0300 (EEST)
From: =?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	=?UTF-8?q?Samuel=20Laur=C3=A9n?= <samuel.lauren@iki.fi>,
	Patrick Colp <patrick.colp@oracle.com>,
	Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Weijiang Yang <weijiang.yang@intel.com>, Zhang@kvack.org,
	Yu C <yu.c.zhang@intel.com>,
	=?UTF-8?q?Mihai=20Don=C8=9Bu?= <mdontu@bitdefender.com>,
	=?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v6 66/92] kvm: introspection: add custom input when single-stepping a vCPU
Date: Fri,  9 Aug 2019 19:00:21 +0300
Message-Id: <20190809160047.8319-67-alazar@bitdefender.com>
In-Reply-To: <20190809160047.8319-1-alazar@bitdefender.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The introspection tool can respond to a KVMI_EVENT_PF event with custom
input for the current instruction. This input is used to trick the guest
software into believing it has read certain data, in order to hide the
content of certain memory areas (eg. hide injected code from integrity
checkers). There are cases when this can happen while the vCPU has to
be single stepped, Either the current instruction is not supported by
the KVM emulator or the introspection tool requested single-stepping.

This patch saves the old data, write the custom input, start the single
stepping and restore the old data.

Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 virt/kvm/kvmi.c     | 119 ++++++++++++++++++++++++++++++++++++++++++++
 virt/kvm/kvmi_int.h |   3 ++
 2 files changed, 122 insertions(+)

diff --git a/virt/kvm/kvmi.c b/virt/kvm/kvmi.c
index 3dfedf3ae739..06dc23f40ded 100644
--- a/virt/kvm/kvmi.c
+++ b/virt/kvm/kvmi.c
@@ -1618,6 +1618,116 @@ int kvmi_cmd_pause_vcpu(struct kvm_vcpu *vcpu, bool wait)
 	return 0;
 }
 
+static int write_custom_data_to_page(struct kvm_vcpu *vcpu, gva_t gva,
+					u8 *backup, size_t bytes)
+{
+	u8 *ptr_page, *ptr;
+	struct page *page;
+	gpa_t gpa;
+
+	gpa = kvm_mmu_gva_to_gpa_system(vcpu, gva, NULL);
+	if (gpa == UNMAPPED_GVA)
+		return -KVM_EINVAL;
+
+	ptr_page = get_page_ptr(vcpu->kvm, gpa, &page, true);
+	if (!ptr_page)
+		return -KVM_EINVAL;
+
+	ptr = ptr_page + (gpa & ~PAGE_MASK);
+
+	memcpy(backup, ptr, bytes);
+	use_custom_input(vcpu, gva, ptr, bytes);
+
+	put_page_ptr(ptr_page, page);
+
+	return 0;
+}
+
+static int write_custom_data(struct kvm_vcpu *vcpu)
+{
+	struct kvmi *ikvm = IKVM(vcpu->kvm);
+	struct kvmi_vcpu *ivcpu = IVCPU(vcpu);
+	size_t bytes = ivcpu->ctx_size;
+	gva_t gva = ivcpu->ctx_addr;
+	u8 *backup;
+
+	if (ikvm->ss_custom_size)
+		return 0;
+
+	if (!bytes)
+		return 0;
+
+	backup = ikvm->ss_custom_data;
+
+	while (bytes) {
+		size_t offset = gva & ~PAGE_MASK;
+		size_t chunk = min(bytes, PAGE_SIZE - offset);
+
+		if (write_custom_data_to_page(vcpu, gva, backup, chunk))
+			return -KVM_EINVAL;
+
+		bytes -= chunk;
+		backup += chunk;
+		gva += chunk;
+		ikvm->ss_custom_size += chunk;
+	}
+
+	return 0;
+}
+
+static int restore_backup_data_to_page(struct kvm_vcpu *vcpu, gva_t gva,
+					u8 *src, size_t bytes)
+{
+	u8 *ptr_page, *ptr;
+	struct page *page;
+	gpa_t gpa;
+
+	gpa = kvm_mmu_gva_to_gpa_system(vcpu, gva, NULL);
+	if (gpa == UNMAPPED_GVA)
+		return -KVM_EINVAL;
+
+	ptr_page = get_page_ptr(vcpu->kvm, gpa, &page, true);
+	if (!ptr_page)
+		return -KVM_EINVAL;
+
+	ptr = ptr_page + (gpa & ~PAGE_MASK);
+
+	memcpy(ptr, src, bytes);
+
+	put_page_ptr(ptr_page, page);
+
+	return 0;
+}
+
+static void restore_backup_data(struct kvm_vcpu *vcpu)
+{
+	struct kvmi *ikvm = IKVM(vcpu->kvm);
+	struct kvmi_vcpu *ivcpu = IVCPU(vcpu);
+	size_t bytes = ikvm->ss_custom_size;
+	gva_t gva = ivcpu->ctx_addr;
+	u8 *backup;
+
+	if (!bytes)
+		return;
+
+	backup = ikvm->ss_custom_data;
+
+	while (bytes) {
+		size_t offset = gva & ~PAGE_MASK;
+		size_t chunk = min(bytes, PAGE_SIZE - offset);
+
+		if (restore_backup_data_to_page(vcpu, gva, backup, chunk))
+			goto out;
+
+		bytes -= chunk;
+		backup += chunk;
+		gva += chunk;
+	}
+
+out:
+	ikvm->ss_custom_size = 0;
+}
+
 void kvmi_stop_ss(struct kvm_vcpu *vcpu)
 {
 	struct kvmi_vcpu *ivcpu = IVCPU(vcpu);
@@ -1642,6 +1752,8 @@ void kvmi_stop_ss(struct kvm_vcpu *vcpu)
 
 	ikvm->ss_level = 0;
 
+	restore_backup_data(vcpu);
+
 	kvmi_arch_stop_single_step(vcpu);
 
 	atomic_set(&ikvm->ss_active, false);
@@ -1676,6 +1788,7 @@ static bool kvmi_acquire_ss(struct kvm_vcpu *vcpu)
 						KVM_REQUEST_WAIT);
 
 	ivcpu->ss_owner = true;
+	ikvm->ss_custom_size = 0;
 
 	return true;
 }
@@ -1690,6 +1803,12 @@ static bool kvmi_run_ss(struct kvm_vcpu *vcpu, gpa_t gpa, u8 access)
 
 	kvmi_arch_start_single_step(vcpu);
 
+	err = write_custom_data(vcpu);
+	if (err) {
+		kvmi_err(ikvm, "writing custom data failed, err %d\n", err);
+		return false;
+	}
+
 	err = kvmi_get_gfn_access(ikvm, gfn, &old_access, &old_write_bitmap);
 	/* likely was removed from radix tree due to rwx */
 	if (err) {
diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
index 1550fe33ed48..5485529db06b 100644
--- a/virt/kvm/kvmi_int.h
+++ b/virt/kvm/kvmi_int.h
@@ -160,6 +160,9 @@ struct kvmi {
 		u8 old_access;
 		u32 old_write_bitmap;
 	} ss_context[SINGLE_STEP_MAX_DEPTH];
+	u8 ss_custom_data[KVMI_CTX_DATA_SIZE];
+	size_t ss_custom_size;
+	gpa_t ss_custom_addr;
 	u8 ss_level;
 	atomic_t ss_active;
 

