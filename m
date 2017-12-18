Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EBAF96B026F
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 14:07:14 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id p190so7845017wmd.0
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 11:07:14 -0800 (PST)
Received: from mx02.buh.bitdefender.com (mx02.bbu.dsd.mx.bitdefender.com. [91.199.104.133])
        by mx.google.com with ESMTPS id r7si10348283wrg.184.2017.12.18.11.07.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 11:07:13 -0800 (PST)
From: =?UTF-8?q?Adalber=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v4 18/18] kvm: x86: hook in kvmi_trap_event()
Date: Mon, 18 Dec 2017 21:06:42 +0200
Message-Id: <20171218190642.7790-19-alazar@bitdefender.com>
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

Inform the guest introspection tool that the exception (from a previous
KVMI_INJECT_EXCEPTION command) was not successfully injected.

It can happen for the tool to queue a pagefault but have it overwritten
by an interrupt picked up during guest reentry. kvmi_trap_event() is
used to inform the tool of all pending traps giving it a chance to
determine if it should try again later.

Signed-off-by: Mihai DonE?u <mdontu@bitdefender.com>
---
 arch/x86/kvm/x86.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 9a3c315b13e4..b3825658528a 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -7058,6 +7058,15 @@ static int vcpu_enter_guest(struct kvm_vcpu *vcpu)
 		goto cancel_injection;
 	}
 
+	if (kvmi_lost_exception(vcpu)) {
+		local_irq_enable();
+		preempt_enable();
+		vcpu->srcu_idx = srcu_read_lock(&vcpu->kvm->srcu);
+		r = 1;
+		kvmi_trap_event(vcpu);
+		goto cancel_injection;
+	}
+
 	kvm_load_guest_xcr0(vcpu);
 
 	if (req_immediate_exit) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
