Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4F7406B0271
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 14:07:15 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c82so7818921wme.8
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 11:07:15 -0800 (PST)
Received: from mx02.buh.bitdefender.com (mx02.bbu.dsd.mx.bitdefender.com. [91.199.104.133])
        by mx.google.com with ESMTPS id 80si18836wmi.67.2017.12.18.11.07.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 11:07:14 -0800 (PST)
From: =?UTF-8?q?Adalber=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v4 17/18] kvm: x86: handle the introspection hypercalls
Date: Mon, 18 Dec 2017 21:06:41 +0200
Message-Id: <20171218190642.7790-18-alazar@bitdefender.com>
In-Reply-To: <20171218190642.7790-1-alazar@bitdefender.com>
References: <20171218190642.7790-1-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, =?UTF-8?q?Mihai=20Don=C8=9Bu?= <mdontu@bitdefender.com>, Adalbert Lazar <alazar@bitdefender.com>, =?UTF-8?q?Mircea=20C=C3=AErjaliu?= <mcirjaliu@bitdefender.com>, =?UTF-8?q?Nicu=C8=99or=20C=C3=AE=C8=9Bu?= <ncitu@bitdefender.com>

From: Adalbert Lazar <alazar@bitdefender.com>

Two hypercalls (KVM_HC_MEM_MAP, KVM_HC_MEM_UNMAP) are used by the
introspection tool running in a VM to map/unmap memory from the
introspected VM-s.

The third hypercall (KVM_HC_XEN_HVM_OP) is used by the code residing
inside the introspected guest to call the introspection tool and to report
certain details about its operation. For example, a classic antimalware
remediation tool can report what it has found during a scan.

Signed-off-by: Mircea CA(R)rjaliu <mcirjaliu@bitdefender.com>
Signed-off-by: NicuE?or CA(R)E?u <ncitu@bitdefender.com>
---
 arch/x86/kvm/x86.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 271028ccbeca..9a3c315b13e4 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -6333,7 +6333,8 @@ int kvm_emulate_hypercall(struct kvm_vcpu *vcpu)
 
 	r = kvm_skip_emulated_instruction(vcpu);
 
-	if (kvm_hv_hypercall_enabled(vcpu->kvm))
+	if (kvm_hv_hypercall_enabled(vcpu->kvm)
+			&& !kvmi_is_agent_hypercall(vcpu))
 		return kvm_hv_hypercall(vcpu);
 
 	nr = kvm_register_read(vcpu, VCPU_REGS_RAX);
@@ -6371,6 +6372,16 @@ int kvm_emulate_hypercall(struct kvm_vcpu *vcpu)
 		ret = kvm_pv_clock_pairing(vcpu, a0, a1);
 		break;
 #endif
+	case KVM_HC_MEM_MAP:
+		ret = kvmi_host_mem_map(vcpu, (gva_t)a0, (gpa_t)a1, (gpa_t)a2);
+		break;
+	case KVM_HC_MEM_UNMAP:
+		ret = kvmi_host_mem_unmap(vcpu, (gpa_t)a0);
+		break;
+	case KVM_HC_XEN_HVM_OP:
+		kvmi_hypercall_event(vcpu);
+		ret = 0;
+		break;
 	default:
 		ret = -KVM_ENOSYS;
 		break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
