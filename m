Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2F5196B026F
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 14:07:13 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id w74so7319115wmf.0
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 11:07:13 -0800 (PST)
Received: from mx02.buh.bitdefender.com (mx02.bbu.dsd.mx.bitdefender.com. [91.199.104.133])
        by mx.google.com with ESMTPS id o6si10442581wrh.425.2017.12.18.11.07.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 11:07:11 -0800 (PST)
From: =?UTF-8?q?Adalber=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v4 16/18] kvm: x86: hook in kvmi_msr_event()
Date: Mon, 18 Dec 2017 21:06:40 +0200
Message-Id: <20171218190642.7790-17-alazar@bitdefender.com>
In-Reply-To: <20171218190642.7790-1-alazar@bitdefender.com>
References: <20171218190642.7790-1-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, =?UTF-8?q?Mihai=20Don=C8=9Bu?= <mdontu@bitdefender.com>, Adalbert Lazar <alazar@bitdefender.com>

From: Adalbert Lazar <alazar@bitdefender.com>

Inform the guest introspection tool that an MSR is going to be changed.

The kvmi_msr_event() function will check a bitmap of MSR-s of interest
(configured via a KVMI_CONTROL_EVENTS(KVMI_MSR_CONTROL) request) and, if
the new value differs from the previous one, it will generate a
notification. The introspection tool can respond by allowing the guest
to continue with normal execution or by discarding the change.

This is meant to prevent malicious changes to MSR-s such as
MSR_IA32_SYSENTER_EIP.

Signed-off-by: Mihai DonE?u <mdontu@bitdefender.com>
---
 arch/x86/kvm/x86.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 284bb4c740fa..271028ccbeca 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -1111,6 +1111,9 @@ EXPORT_SYMBOL_GPL(kvm_enable_efer_bits);
  */
 int kvm_set_msr(struct kvm_vcpu *vcpu, struct msr_data *msr)
 {
+	if (!kvmi_msr_event(vcpu, msr))
+		return 1;
+
 	switch (msr->index) {
 	case MSR_FS_BASE:
 	case MSR_GS_BASE:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
