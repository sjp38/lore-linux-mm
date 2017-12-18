Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id BD5516B026C
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 14:07:09 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id w141so7834546wme.1
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 11:07:09 -0800 (PST)
Received: from mx02.buh.bitdefender.com (mx02.bbu.dsd.mx.bitdefender.com. [91.199.104.133])
        by mx.google.com with ESMTPS id y20si7435wmd.200.2017.12.18.11.07.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 11:07:08 -0800 (PST)
From: =?UTF-8?q?Adalber=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v4 15/18] kvm: x86: hook in kvmi_xsetbv_event()
Date: Mon, 18 Dec 2017 21:06:39 +0200
Message-Id: <20171218190642.7790-16-alazar@bitdefender.com>
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

Notify the guest introspection tool that the extended control register
has been changed.

Signed-off-by: Mihai DonE?u <mdontu@bitdefender.com>
---
 arch/x86/kvm/x86.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 8f5cc81c8760..284bb4c740fa 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -765,6 +765,9 @@ static int __kvm_set_xcr(struct kvm_vcpu *vcpu, u32 index, u64 xcr)
 
 int kvm_set_xcr(struct kvm_vcpu *vcpu, u32 index, u64 xcr)
 {
+	if (xcr != vcpu->arch.xcr0)
+		kvmi_xsetbv_event(vcpu);
+
 	if (kvm_x86_ops->get_cpl(vcpu) != 0 ||
 	    __kvm_set_xcr(vcpu, index, xcr)) {
 		kvm_inject_gp(vcpu, 0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
