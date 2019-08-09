Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06A4EC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:06:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D0672086A
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:06:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D0672086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E5116B02F7; Fri,  9 Aug 2019 12:03:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 796BC6B02F8; Fri,  9 Aug 2019 12:03:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A9D76B02F9; Fri,  9 Aug 2019 12:03:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 216F96B02F7
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:03:43 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id r1so1348955wmr.1
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:03:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eca2/JD+sL3XG7K3V2sgQPxJhZqpMQZ43HIZUzw+36o=;
        b=RThn28vcn/3oOT0xZl9fDX1t/BsSvgVKDJr5Ir69QGXBv59jBEgGp+ilS6VfK62b2s
         PgCFU0IoWsInB5Y0lkMJemQ6NhnXPnakW8gcy9lGZV50tXVCIJiwUUJHeG8UY8R+5tKc
         7VPock2X3uIsCHhshGFqVu5j/wf4U5EZTDJ/Ty/u8X9Cl5QvTxb8fHB28l/lm838fjsb
         A+2PUkrGeky7qWgpW49Ccw4ftr+r7NEGUsXo0uKrafT7qeHhZPz0tHbaMK6N782VTNl4
         xuRi7qJCK4y1vagcVJ8lxJbuLNkIKV1AYdJt99/oY2fQZA2S43+MoshX4lN1tljiqYJx
         wq0Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAUSlx85etJtzASAA+Kq8yGLryPUd7ag+7rKtxclSgG/lUXCHaH+
	F+vlVMsS6ddZJTpHldMERrVQzJ89Y6PVNjDJe7bSlzxsnt+9a0Lb29hHGCNEmyNGFo3+aeJqU6M
	YgHCguGQ+X0XI8aq/aMkVWnkQNzNm6kZyJl6T9GIgXfnqLXqRHSAHLOnKIdTnQANSyQ==
X-Received: by 2002:a05:600c:207:: with SMTP id 7mr10482390wmi.146.1565366622611;
        Fri, 09 Aug 2019 09:03:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjKKIWMGV1S2t4QH9Gh3BMAPGzCC3y4XxnQn9jA15x3DOyYv5Lm7lgZsLr5OD6XFmFPJeb
X-Received: by 2002:a05:600c:207:: with SMTP id 7mr10470659wmi.146.1565366499301;
        Fri, 09 Aug 2019 09:01:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366499; cv=none;
        d=google.com; s=arc-20160816;
        b=QigEdziixZiBSHylNim/7yJ8k62iKuzxAJk4r39+NX7xsojOfZidyNmamVU/OukFFV
         MwYSY9YY47jaKTbOJggTyQfdCdBGcQ1//fqrzyRix73If1q+wmxVrIo59s6WSifcR24N
         yCXdjBdMhN4SAlZilw246T/6Da75wfMoWuHdg5ZKwUYdvVZ3CnZlNnmaz3+S/QETeVQA
         /MVbcOLbIhYf4PrXiHc3bbNW//OKJOQ6tpWsmURsxtmiXOp+6/ELFoRQPVMWAZzp/wX6
         DtZ3Zqfvt45oAaodosChXJ2oPlY2SfMD3aqJ9hlIX9XxLjWhsiU2GAIQBTexnIhT1RvV
         d96Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=eca2/JD+sL3XG7K3V2sgQPxJhZqpMQZ43HIZUzw+36o=;
        b=ip1HjcQLbaZUrDAp/7Vt1fEIlbQRMbULMdiVBBnnF+bEUnJfUKmsjwgDwBQiijQdFO
         qmsAZhn7UfOfqn/tq7SyqrabpX5wyO+PpPhEMoNEMPvPp9B66eqKFmpjuR3LepE9ermA
         M1ZXOw1mL5UtE005QjaiVqlTk54BurQm+hzbU9/gi5FvFi6TZAW6ghGG7XYFvgJwrZwI
         1k+a8JC8qSVMnESg89n9T68OJja/SAg8P0NuO6fYEXBSyEb48JpqTQo1hg693F+UGiG/
         ewZGIOBbj4N0p8lB2q566jXYZckUVnKwT/cdg8EcKdFRlYaF6bYfU2wW1okhjoaG/KQh
         Vkag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id o9si380139wrm.242.2019.08.09.09.01.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id A4D1C305D35C;
	Fri,  9 Aug 2019 19:01:38 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id E68C0305B7A1;
	Fri,  9 Aug 2019 19:01:35 +0300 (EEST)
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
	=?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>,
	Joerg Roedel <joro@8bytes.org>
Subject: [RFC PATCH v6 74/92] kvm: x86: do not unconditionally patch the hypercall instruction during emulation
Date: Fri,  9 Aug 2019 19:00:29 +0300
Message-Id: <20190809160047.8319-75-alazar@bitdefender.com>
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

From: Mihai Donțu <mdontu@bitdefender.com>

It can happened for us to end up emulating the VMCALL instruction as a
result of the handling of an EPT write fault. In this situation, the
emulator will try to unconditionally patch the correct hypercall opcode
bytes using emulator_write_emulated(). However, this last call uses the
fault GPA (if available) or walks the guest page tables at RIP,
otherwise. The trouble begins when using KVMI, when we forbid the use of
the fault GPA and fallback to the guest pt walk: in Windows (8.1 and
newer) the page that we try to write into is marked read-execute and as
such emulator_write_emulated() fails and we inject a write #PF, leading
to a guest crash.

The fix is rather simple: check the existing instruction bytes before
doing the patching. This does not change the normal KVM behaviour, but
does help when using KVMI as we no longer inject a write #PF.

CC: Joerg Roedel <joro@8bytes.org>
Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/x86.c | 23 ++++++++++++++++++++---
 1 file changed, 20 insertions(+), 3 deletions(-)

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 04b1d2916a0a..965c4f0108eb 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -7363,16 +7363,33 @@ int kvm_emulate_hypercall(struct kvm_vcpu *vcpu)
 }
 EXPORT_SYMBOL_GPL(kvm_emulate_hypercall);
 
+#define KVM_HYPERCALL_INSN_LEN 3
+
 static int emulator_fix_hypercall(struct x86_emulate_ctxt *ctxt)
 {
+	int err;
 	struct kvm_vcpu *vcpu = emul_to_vcpu(ctxt);
-	char instruction[3];
+	char buf[KVM_HYPERCALL_INSN_LEN];
+	char instruction[KVM_HYPERCALL_INSN_LEN];
 	unsigned long rip = kvm_rip_read(vcpu);
 
+	err = emulator_read_emulated(ctxt, rip, buf, sizeof(buf),
+				     &ctxt->exception);
+	if (err != X86EMUL_CONTINUE)
+		return err;
+
 	kvm_x86_ops->patch_hypercall(vcpu, instruction);
+	if (!memcmp(instruction, buf, sizeof(instruction)))
+		/*
+		 * The hypercall instruction is the correct one. Retry
+		 * its execution maybe we got here as a result of an
+		 * event other than #UD which has been resolved in the
+		 * mean time.
+		 */
+		return X86EMUL_CONTINUE;
 
-	return emulator_write_emulated(ctxt, rip, instruction, 3,
-		&ctxt->exception);
+	return emulator_write_emulated(ctxt, rip, instruction,
+				       sizeof(instruction), &ctxt->exception);
 }
 
 static int dm_request_for_irq_injection(struct kvm_vcpu *vcpu)

