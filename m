Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3BCDD6B0272
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 14:07:17 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id o2so7314595wmf.2
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 11:07:17 -0800 (PST)
Received: from mx02.buh.bitdefender.com (mx02.bbu.dsd.mx.bitdefender.com. [91.199.104.133])
        by mx.google.com with ESMTPS id a69si23704wme.11.2017.12.18.11.07.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 11:07:15 -0800 (PST)
From: =?UTF-8?q?Adalber=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v4 06/18] kvm: vmx: export the availability of EPT views
Date: Mon, 18 Dec 2017 21:06:30 +0200
Message-Id: <20171218190642.7790-7-alazar@bitdefender.com>
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

This is used to validate the KVMI_GET_PAGE_ACCESS and KVMI_SET_PAGE_ACCESS
commands when the guest introspection tool selects a different EPT view.

Signed-off-by: Adalbert LazA?r <alazar@bitdefender.com>
---
 arch/x86/include/asm/kvm_host.h | 1 +
 arch/x86/kvm/vmx.c              | 2 ++
 arch/x86/kvm/x86.c              | 3 +++
 3 files changed, 6 insertions(+)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 239eb628f8fb..2cf03ed181e6 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -1162,6 +1162,7 @@ extern u64  kvm_max_tsc_scaling_ratio;
 extern u64  kvm_default_tsc_scaling_ratio;
 
 extern u64 kvm_mce_cap_supported;
+extern bool kvm_eptp_switching_supported;
 
 enum emulation_result {
 	EMULATE_DONE,         /* no further processing */
diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index 5487e0242030..093a2e1f7ea6 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -6898,6 +6898,8 @@ static __init int hardware_setup(void)
 		kvm_x86_ops->cancel_hv_timer = NULL;
 	}
 
+	kvm_eptp_switching_supported = cpu_has_vmx_vmfunc();
+
 	kvm_set_posted_intr_wakeup_handler(wakeup_handler);
 
 	kvm_mce_cap_supported |= MCG_LMCE_P;
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 4b0c3692386d..e7db70ac1f82 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -138,6 +138,9 @@ module_param(lapic_timer_advance_ns, uint, S_IRUGO | S_IWUSR);
 static bool __read_mostly vector_hashing = true;
 module_param(vector_hashing, bool, S_IRUGO);
 
+bool __read_mostly kvm_eptp_switching_supported;
+EXPORT_SYMBOL_GPL(kvm_eptp_switching_supported);
+
 #define KVM_NR_SHARED_MSRS 16
 
 struct kvm_shared_msrs_global {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
