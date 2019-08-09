Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04807C32756
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78BE72089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78BE72089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9210D6B0280; Fri,  9 Aug 2019 12:01:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8351B6B0281; Fri,  9 Aug 2019 12:01:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 527E86B0282; Fri,  9 Aug 2019 12:01:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id E81FF6B027D
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:07 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id r4so47049961wrt.13
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+FIAemLMRlIfhgcTiA7ITFnfhEIXP9Ocq3H1+0v3ATA=;
        b=qXzD9iwuUppAzr/to2C5Hiv2De0+HdIGufMKzLHDGt0S/fEMdqg6d2RoQ8Kc9GdQn7
         e19KnljBEHc/5aLw+h2xy7QmkcHvIfJXd++R2s7O9hLGYFc/Z3hWa5KV0CQpMefOG41S
         cL8rmPGnkSQpzho0RkVcA7xVOEZzWa2UxoP/L2LHerAP7eUd8hnsLBAV6bKpIoDTwzxI
         /U7gz2cFtv8pPnU/kIcis+IwXeqkIyg45qw4HpjkQt7qVmSu1hsEIWaoErzekwrwnDtT
         VNR3KLo7rM1addCNJFWBU3I+YMRgPpwIzXtT6qeIqb5IQ2TWAft1XunKVK52PqGyi73S
         PZ/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAVeWxBo/V6t3VJWw+bSQIuGUvRCRkv8PbhWCLaYe8oYERbO2LJR
	kEpsR/7SDcTNhfHqV8mWBdnu1/c1+gnSkreYm1/u1muJwmjGrg8ktj2U9+YEI60RJCEXiJWJK8I
	I8DTAJYUPA5Ck3T1Li05lB1oOdXd+RaRc/+SH8iGcPLKh5bpxm9bpeZJAmBTki9wX9Q==
X-Received: by 2002:a1c:be05:: with SMTP id o5mr11910990wmf.52.1565366467485;
        Fri, 09 Aug 2019 09:01:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxBldVLVODoBpM2Mm8/7mpsqSU9WRe8d5SMPrsuBoOLqyO0fXT632ve95mJ08b1JBbC98r
X-Received: by 2002:a1c:be05:: with SMTP id o5mr11910834wmf.52.1565366465802;
        Fri, 09 Aug 2019 09:01:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366465; cv=none;
        d=google.com; s=arc-20160816;
        b=DN7rhm1E9rYy6e5/LSQ2BnZluEVHW4Rk4+XMpEzqqcUBLPvgXfhcMCUZpYRX84R2p7
         pGDX3JsEF1NR40302EwWoR4CfnS25uo1ioejrgLDzbAGHZ6UaYsaufAQwBn4oPWafEpm
         64k2JwYZON043giXKe0591WuvTp0Ff8CNyJv7MLrrCAGxDmxoFUfaNBwxXbFA2ne5fWz
         xD9Yk5k3DRIkyVgSqTUoKOCKdMJ5naizC54AGZqzY05Ki9aUiRRb95IKzvJUgTH7fD3g
         hrs2JSwvUEVCcIqbciZOZ9TBQJGTvWV2R5MKtYsRKm37CKBQXaW2eAePbVWDlPiyeopS
         i6Yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=+FIAemLMRlIfhgcTiA7ITFnfhEIXP9Ocq3H1+0v3ATA=;
        b=TSJ4NdBfqCalM82ZUxqoODC0TY8s+ctGQ3kaqzAXQ5qHikJgJDBRt6NkRnrTRbdVBy
         Du5ASOQNYsdU2Dh2mYjtm68NjS01u/joNLa0PZXGXweI0dS7aFUOr7/qDtqbcT2k1kx3
         mRsNGypM2s3WlGma77E++1Jn+et6rJHMFof4wDhSsPLZn+0qddtScjeaXPNhdPZUjhNV
         Q6YIx0A62kef9hYHfMOL0Cl44oeGPgN+GHSgMP8p/g1pg7/HeQtT48c1AUnMtueY9sTX
         79IztKo2L/vC7+ZAW5asATfWuzw8qhzTNGIT0LJubiDtZHL6tSRFxePX7GSxNS3abJqJ
         kTsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id y8si7841394wrt.371.2019.08.09.09.01.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 32A34305D342;
	Fri,  9 Aug 2019 19:01:05 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id DC1E1305B7A3;
	Fri,  9 Aug 2019 19:01:04 +0300 (EEST)
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
	yi.z.zhang@linux.intel.com
Subject: [RFC PATCH v6 34/92] Documentation: Introduce EPT based Subpage Protection
Date: Fri,  9 Aug 2019 18:59:49 +0300
Message-Id: <20190809160047.8319-35-alazar@bitdefender.com>
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

From: Yang Weijiang <weijiang.yang@intel.com>

Co-developed-by: yi.z.zhang@linux.intel.com
Signed-off-by: yi.z.zhang@linux.intel.com
Co-developed-by: Yang Weijiang <weijiang.yang@intel.com>
Signed-off-by: Yang Weijiang <weijiang.yang@intel.com>
Message-Id: <20190717133751.12910-2-weijiang.yang@intel.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/spp_kvm.txt | 173 ++++++++++++++++++++++++++
 1 file changed, 173 insertions(+)
 create mode 100644 Documentation/virtual/kvm/spp_kvm.txt

diff --git a/Documentation/virtual/kvm/spp_kvm.txt b/Documentation/virtual/kvm/spp_kvm.txt
new file mode 100644
index 000000000000..bdf94922cba9
--- /dev/null
+++ b/Documentation/virtual/kvm/spp_kvm.txt
@@ -0,0 +1,173 @@
+EPT-Based Sub-Page Protection (SPP) for KVM
+====================================================
+
+1.Overview
+  EPT-based Sub-Page Protection(SPP) allows VMM to specify
+  fine-grained(128byte per sub-page) write-protection for guest physical
+  memory. When it's enabled, the CPU enforces write-access permission
+  for the sub-pages within a 4KB page, if corresponding bit is set in
+  permission vector, write to sub-page region is allowed, otherwise,
+  it's prevented with a EPT violation.
+
+2.SPP Operation
+  Sub-Page Protection Table (SPPT) is introduced to manage sub-page
+  write-access permission.
+
+  It is active when:
+  a) large paging is disabled on host side.
+  b) "sub-page write protection" VM-execution control is 1.
+  c) SPP is initialized with KVM_INIT_SPP ioctl successfully.
+  d) Sub-page permissions are set with KVM_SUBPAGES_SET_ACCESS ioctl
+     successfully. see below sections for details.
+
+  __________________________________________________________________________
+
+  How SPP hardware works:
+  __________________________________________________________________________
+
+  Guest write access --> GPA --> Walk EPT --> EPT leaf entry -----|
+  |---------------------------------------------------------------|
+  |-> if VMexec_control.spp && ept_leaf_entry.spp_bit (bit 61)
+       |
+       |-> <false> --> EPT legacy behavior
+       |
+       |
+       |-> <true>  --> if ept_leaf_entry.writable
+                        |
+                        |-> <true>  --> Ignore SPP
+                        |
+                        |-> <false> --> GPA --> Walk SPP 4-level table--|
+                                                                        |
+  |------------<----------get-the-SPPT-point-from-VMCS-filed-----<------|
+  |
+  Walk SPP L4E table
+  |
+  |---> if-entry-misconfiguration ------------>-------|-------<---------|
+   |                                                  |                 |
+  else                                                |                 |
+   |                                                  |                 |
+   |   |------------------SPP VMexit<-----------------|                 |
+   |   |                                                                |
+   |   |-> exit_qualification & sppt_misconfig --> sppt misconfig       |
+   |   |                                                                |
+   |   |-> exit_qualification & sppt_miss --> sppt miss                 |
+   |---|                                                                |
+       |                                                                |
+  walk SPPT L3E--|--> if-entry-misconfiguration------------>------------|
+                 |                                                      |
+                else                                                    |
+                 |                                                      |
+                 |                                                      |
+          walk SPPT L2E --|--> if-entry-misconfiguration-------->-------|
+                          |                                             |
+                         else                                           |
+                          |                                             |
+                          |                                             |
+                   walk SPPT L1E --|-> if-entry-misconfiguration--->----|
+                                   |
+                                 else
+                                   |
+                                   |-> if sub-page writable
+                                   |-> <true>  allow, write access
+                                   |-> <false> disallow, EPT violation
+  ______________________________________________________________________________
+
+3.IOCTL Interfaces
+
+    KVM_INIT_SPP:
+    Allocate storage for sub-page permission vectors and SPPT root page.
+
+    KVM_SUBPAGES_GET_ACCESS:
+    Get sub-page write permission vectors for given continuous guest pages.
+
+    KVM_SUBPAGES_SET_ACCESS
+    Set sub-pages write permission vectors for given continuous guest pages.
+
+    /* for KVM_SUBPAGES_GET_ACCESS and KVM_SUBPAGES_SET_ACCESS */
+    struct kvm_subpage_info {
+       __u64 gfn; /* the first page gfn of the continuous pages */
+       __u64 npages; /* number of 4K pages */
+       __u64 *access_map; /* sub-page write-access bitmap array */
+    };
+
+    #define KVM_SUBPAGES_GET_ACCESS   _IOR(KVMIO,  0x49, __u64)
+    #define KVM_SUBPAGES_SET_ACCESS   _IOW(KVMIO,  0x4a, __u64)
+    #define KVM_INIT_SPP              _IOW(KVMIO,  0x4b, __u64)
+
+4.Set Sub-Page Permission
+
+  * To enable SPP protection, system admin sets sub-page permission via
+    KVM_SUBPAGES_SET_ACCESS ioctl:
+
+    (1) If the target 4KB pages are there, it locates EPT leaf entries
+        via the guest physical addresses, sets the bit 61 of the corresponding
+        entries to enable sub-page protection, then set up SPPT paging structure.
+    (2) otherwise, stores the [gfn,permission] mappings in KVM data structure. When
+        EPT page-fault is generated due to access to target page, it settles
+        EPT entry configuration together with SPPT setup, this is called lazy mode
+        setup.
+
+   The SPPT paging structure format is as below:
+
+   Format of the SPPT L4E, L3E, L2E:
+   | Bit    | Contents                                                                 |
+   | :----- | :------------------------------------------------------------------------|
+   | 0      | Valid entry when set; indicates whether the entry is present             |
+   | 11:1   | Reserved (0)                                                             |
+   | N-1:12 | Physical address of 4KB aligned SPPT LX-1 Table referenced by this entry |
+   | 51:N   | Reserved (0)                                                             |
+   | 63:52  | Reserved (0)                                                             |
+   Note: N is the physical address width supported by the processor. X is the page level
+
+   Format of the SPPT L1E:
+   | Bit   | Contents                                                          |
+   | :---- | :---------------------------------------------------------------- |
+   | 0+2i  | Write permission for i-th 128 byte sub-page region.               |
+   | 1+2i  | Reserved (0).                                                     |
+   Note: 0<=i<=31
+
+5.SPPT-induced VM exit
+
+  * SPPT miss and misconfiguration induced VM exit
+
+    A SPPT missing VM exit occurs when walk the SPPT, there is no SPPT
+    misconfiguration but a paging-structure entry is not
+    present in any of L4E/L3E/L2E entries.
+
+    A SPPT misconfiguration VM exit occurs when reserved bits or unsupported values
+    are set in SPPT entry.
+
+    *NOTE* SPPT miss and SPPT misconfigurations can occur only due to an
+    attempt to write memory with a guest physical address.
+
+  * SPP permission induced VM exit
+    SPP sub-page permission induced violation is reported as EPT violation
+    thesefore causes VM exit.
+
+6.SPPT-induced VM exit handling
+
+  #define EXIT_REASON_SPP                 66
+
+  static int (*const kvm_vmx_exit_handlers[])(struct kvm_vcpu *vcpu) = {
+    ...
+    [EXIT_REASON_SPP]                     = handle_spp,
+    ...
+  };
+
+  New exit qualification for SPPT-induced vmexits.
+
+  | Bit   | Contents                                                          |
+  | :---- | :---------------------------------------------------------------- |
+  | 10:0  | Reserved (0).                                                     |
+  | 11    | SPPT VM exit type. Set for SPPT Miss, cleared for SPPT Misconfig. |
+  | 12    | NMI unblocking due to IRET                                        |
+  | 63:13 | Reserved (0)                                                      |
+
+  In addition to the exit qualification, guest linear address and guest
+  physical address fields will be reported.
+
+  * SPPT miss and misconfiguration induced VM exit
+    Allocate a physical page for the SPPT and set the entry correctly.
+
+  * SPP permission induced VM exit
+    This kind of VM exit is left to VMI tool to handle.

