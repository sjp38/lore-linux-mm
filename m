Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F785C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:03:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DD3A2089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:03:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DD3A2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28F106B028C; Fri,  9 Aug 2019 12:01:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 217C66B028D; Fri,  9 Aug 2019 12:01:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1306B6B028E; Fri,  9 Aug 2019 12:01:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id B97E76B028D
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:20 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id v11so4023706wrg.2
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6tu1vE4ORS7O0Im5/k7kjtVvnuYwO/XuHjstLyxohBM=;
        b=tTQjiVSLmkcSKTiZ42GyPKG8ab5tCAdLm44QxRDfuFumn5Vdd8YKbXZ2qiybJA+MUX
         plpcNgmBBL1rbQM/eVTrm7pk8d+GtpB1Q/SZIjZWByysSkcEUgEE7pWHA4F0aZ9dL5Aa
         06zxIMGMg+2aw3twDnYczIG6TyjOWpuB6H/hpFnW7LJD0Ma1nZb2PKljgusL54WU7lkV
         5oXoARRBScRqLqbdzj+vXR7cjrY3rXNQ86tCDj4q3gWwLCC3GmDoLScDuGiHfnqeVtM0
         VHSKbLlb3PdS4plD/QNs0Yt1rh3gS8jiciyM0VkdyYQ7RRPDSFlzgUArrQ1bk0hAPhZV
         hNNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAW9z0abtdYBNYweIxU2+StxDNleFaaX9JwkFH/0K761BLQt0Q/O
	GgKkfRvDOrLj+uiA5pKiSonxnAhNzlFnSz50D68yuXS//52z2KzZyd7oTZZYSciVdX81VGZbsfG
	q/QTKDnXFOX0bPpfQ9ZCPsT3PvGKMArF+9UbFMokdhYWge1UPS05wGSyVjrIgF7G2Qg==
X-Received: by 2002:a7b:cc81:: with SMTP id p1mr11261614wma.107.1565366480339;
        Fri, 09 Aug 2019 09:01:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxoLOBY2rHQGFVFs3mZgZDcmVw6Gvk4VJ2+QlrDKL0v/VYymk0y+73MKkLgCGPKv7/zxT2i
X-Received: by 2002:a7b:cc81:: with SMTP id p1mr11261523wma.107.1565366479326;
        Fri, 09 Aug 2019 09:01:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366479; cv=none;
        d=google.com; s=arc-20160816;
        b=q48wxIHAqefNA+jYrZupexZofURo9dfK5oMTVjlq1VkDf+QfKCg4TSbCA+w/GGSWbf
         yWnw2VNju1VoUV843Ct9FfhzjbHYXAK6lJPQrK3roBQco/NxklfN8cm8+7AWpeDUpfKt
         /cYDhg75a2L7ThcVuX3D5ctANZ0KvTqVKZesMOUkpySxj03m4oCGqD2P8OtflD5FkgAU
         8MrqTNqepqCpowgXVuSTCm7cYiV67hEwg3NWDsG5iWrjwLl9sT17cuLsFiUz440QvlYD
         wQSg6dQmmoiSG+krf/9IXL/eZAMDQ1gaVdZ+8mbwYyS30uzP5l0TIrDCj8/vYAK1lOlT
         kPGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=6tu1vE4ORS7O0Im5/k7kjtVvnuYwO/XuHjstLyxohBM=;
        b=K1s9YrsJOmBOcXztCdwfiBge0YO85BYO28tkPG1HU3KlQ2cTXkBx1MlUGA5XRIlpaW
         n9rOr2gGGEXE43cKhUHXc9G6pQz7woCPoUhRucGflpTMLCVm9BP7CweClHHut1EHCo/X
         jhYiAcvDDxI1t2QQHGcihLrn04v0Uy0C8IBA+HRuSsHLWgKJgFE4zZQNUxiyzrzqEcSS
         kLP/l1ptan2FNLlkYBIHb0HQ3u+cs/Y80BWhjXhZrypkqBBT02PosG3prfGakC4oXgDU
         a+1xgaJ0p2Q8meltbsFga2tgmvXFtFjNeLp+IWuygVUYPhozFuOT1RWsbIiH3oai6gih
         DYPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id a14si6323278wru.250.2019.08.09.09.01.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id C10A8305D349;
	Fri,  9 Aug 2019 19:01:18 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 77BCD305B7A1;
	Fri,  9 Aug 2019 19:01:18 +0300 (EEST)
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
Subject: [RFC PATCH v6 48/92] kvm: add kvm_vcpu_kick_and_wait()
Date: Fri,  9 Aug 2019 19:00:03 +0300
Message-Id: <20190809160047.8319-49-alazar@bitdefender.com>
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

This function is needed for the KVMI_PAUSE_VCPU command. There are
cases when it is easier for the introspection tool if it knows that
the vCPU doesn't run guest code when the command is completed, without
waiting for the KVMI_EVENT_PAUSE_VCPU event.

Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 include/linux/kvm_host.h |  1 +
 virt/kvm/kvm_main.c      | 10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index ae4106aae16e..09bc06747642 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -738,6 +738,7 @@ void kvm_arch_vcpu_blocking(struct kvm_vcpu *vcpu);
 void kvm_arch_vcpu_unblocking(struct kvm_vcpu *vcpu);
 bool kvm_vcpu_wake_up(struct kvm_vcpu *vcpu);
 void kvm_vcpu_kick(struct kvm_vcpu *vcpu);
+void kvm_vcpu_kick_and_wait(struct kvm_vcpu *vcpu);
 int kvm_vcpu_yield_to(struct kvm_vcpu *target);
 void kvm_vcpu_on_spin(struct kvm_vcpu *vcpu, bool usermode_vcpu_not_eligible);
 
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 2e11069b9565..5256d7321d0e 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -2370,6 +2370,16 @@ void kvm_vcpu_kick(struct kvm_vcpu *vcpu)
 EXPORT_SYMBOL_GPL(kvm_vcpu_kick);
 #endif /* !CONFIG_S390 */
 
+void kvm_vcpu_kick_and_wait(struct kvm_vcpu *vcpu)
+{
+	if (kvm_vcpu_wake_up(vcpu))
+		return;
+
+	if (kvm_request_needs_ipi(vcpu, KVM_REQUEST_WAIT))
+		smp_call_function_single(vcpu->cpu, ack_flush, NULL, 1);
+}
+EXPORT_SYMBOL_GPL(kvm_vcpu_kick_and_wait);
+
 int kvm_vcpu_yield_to(struct kvm_vcpu *target)
 {
 	struct pid *pid;

