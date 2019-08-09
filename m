Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3D41C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37F7C21783
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37F7C21783
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12EB16B0275; Fri,  9 Aug 2019 12:01:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10BBE6B0276; Fri,  9 Aug 2019 12:01:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD79C6B0278; Fri,  9 Aug 2019 12:01:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 843436B0275
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:02 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id b14so46797132wrn.8
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=R5WnIy8BTjOUviUs+VNtLVB+pL9PYE5tgpSS9yhBgLE=;
        b=YvG35WaNFYzP2uHFerhjpM4zk93YXBKLJ8LElabrBrG3D2VQe9IcHszEZ4zBaCuQn3
         60S4BTXp2JpRJ8PGa1FdI0HPthbkywHZGq8oYyreT8JP1bo4TFjTj/GxSXU1okCoxTCC
         naWjzP/J00eXFMyJFgU0rK7OBpZB+qqzDDw+rzC/892/Yjf2lSOmqx9I8Ud+KeZFB4YK
         ysNIhZ006aKsaQ8VfTK5+8kQDSuvTiBHY38rjuv4kHEq3gcXG9ahBd+XchvKFBuxX4MB
         V2SsxN3d2BwoZc8Cj3QIjPnLsR/SA47CCWMaVFsqnOo3zS0IZcY3Jtw36/d+OL8zB08N
         hoKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAXzm4LwBZoZ6DItZmdUB6C5iM3uMrjGe80tnGj+FVAyEo/pTTij
	RIiNiUumQ2gJYzmnw5FiEeiKB637MUpxL+ExuCUz3kmH48LZU5J4ICVR26pKndo8x9j/Tw3TpW+
	Cz0SRY6PHgYM1PIjeIk7IozrWuDmD8vtNKGqswQg+saIU+vmlvwK7ensL71rZQ+dkbw==
X-Received: by 2002:adf:e94e:: with SMTP id m14mr22519337wrn.230.1565366462094;
        Fri, 09 Aug 2019 09:01:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZTfssm1p+49vWu9H3xLLPhPHaUUww856qpZB+FHX8vYK5z5WnP+oIWbgUPuDoR/520pCw
X-Received: by 2002:adf:e94e:: with SMTP id m14mr22519181wrn.230.1565366460433;
        Fri, 09 Aug 2019 09:01:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366460; cv=none;
        d=google.com; s=arc-20160816;
        b=LvoagnlTYRRrJnh7CMCeTJx0bCi8WyzJ4aUPo3PntZcCLZuXgTHpZOwZveWOS5tCp9
         WjNv+hkg/EhdTwgOlVX5fI0d1KpNuanfxXcKDqh7CAsT95S09C3bHnG11Vi1p/FiPH7I
         BWOzjuNCwRw5F0pn+HMeAnPxIQqBJ6mX4VknHdl8Dp7yMAozDUA6jmFzkBONVX4Ztmd2
         lzyuNKZAgc9rXLiVIc/Q/wuk/SddNI3FRZau2Bq8T3d9LKesLrmVipCMkRNOYvtejgII
         i2KYmK+BOxigYmU00KCAK5zjnlqzNHlJuyvJXa59hpcZ/V9jH+sHG5fvLwXWEgK6IYwh
         FBOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=R5WnIy8BTjOUviUs+VNtLVB+pL9PYE5tgpSS9yhBgLE=;
        b=gGWkxF7aYgauOD6rjBKPTt/y9rc9InX27VNVAoDgUPECh9GPOSvM0l71J1Ut5adwLH
         /slCuL4l0ObwJWf9ziecIzFYIwUMf6Kd+HmKZbUUy35F97m87zHEqgBRdib5FtADbxZi
         w4Kg4zo2/+CZyHzEQria4SgV4F/M4M9VDe0YcCfp/FGpitnlqG78krBuliDmIzB4ef0b
         xEuVJD+QI7NNEZVkCzwO4ZFEFflYGJHnVuVUeJD6WKfOPkejBh+TB1WOzyAOnihXETBD
         mdaEEr8aRMYcRi2MJhYzIJNJcOqXNzhvq9QT4IosR51oipGqTEwDfHWQMyiaory17x4W
         0MBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id i5si84765318wrs.39.2019.08.09.09.01.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id CB08B305D3DE;
	Fri,  9 Aug 2019 19:00:59 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 870E7305B7A0;
	Fri,  9 Aug 2019 19:00:59 +0300 (EEST)
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
Subject: [RFC PATCH v6 22/92] kvm: x86: provide all page tracking hooks with the guest virtual address
Date: Fri,  9 Aug 2019 18:59:37 +0300
Message-Id: <20190809160047.8319-23-alazar@bitdefender.com>
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

This is needed because the emulator calls the page tracking code
irrespective of the current VMEXIT reason or available information.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/include/asm/kvm_host.h       |  2 +-
 arch/x86/include/asm/kvm_page_track.h |  9 +++++----
 arch/x86/kvm/mmu.c                    |  2 +-
 arch/x86/kvm/page_track.c             |  6 +++---
 arch/x86/kvm/x86.c                    | 16 ++++++++--------
 drivers/gpu/drm/i915/gvt/kvmgt.c      |  2 +-
 6 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 67ed934ca124..2d6bde6fa59f 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -1263,7 +1263,7 @@ void kvm_mmu_change_mmu_pages(struct kvm *kvm, unsigned int kvm_nr_mmu_pages);
 int load_pdptrs(struct kvm_vcpu *vcpu, struct kvm_mmu *mmu, unsigned long cr3);
 bool pdptrs_changed(struct kvm_vcpu *vcpu);
 
-int emulator_write_phys(struct kvm_vcpu *vcpu, gpa_t gpa,
+int emulator_write_phys(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
 			  const void *val, int bytes);
 
 struct kvm_irq_mask_notifier {
diff --git a/arch/x86/include/asm/kvm_page_track.h b/arch/x86/include/asm/kvm_page_track.h
index 18a94d180485..0492a85f3a44 100644
--- a/arch/x86/include/asm/kvm_page_track.h
+++ b/arch/x86/include/asm/kvm_page_track.h
@@ -32,8 +32,9 @@ struct kvm_page_track_notifier_node {
 	 * @bytes: the written length.
 	 * @node: this node
 	 */
-	void (*track_write)(struct kvm_vcpu *vcpu, gpa_t gpa, const u8 *new,
-			    int bytes, struct kvm_page_track_notifier_node *node);
+	void (*track_write)(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
+			    const u8 *new, int bytes,
+			    struct kvm_page_track_notifier_node *node);
 	void (*track_create_slot)(struct kvm *kvm, struct kvm_memory_slot *slot,
 				  unsigned long npages,
 				  struct kvm_page_track_notifier_node *node);
@@ -72,7 +73,7 @@ kvm_page_track_register_notifier(struct kvm *kvm,
 void
 kvm_page_track_unregister_notifier(struct kvm *kvm,
 				   struct kvm_page_track_notifier_node *n);
-void kvm_page_track_write(struct kvm_vcpu *vcpu, gpa_t gpa, const u8 *new,
-			  int bytes);
+void kvm_page_track_write(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
+			  const u8 *new, int bytes);
 void kvm_page_track_flush_slot(struct kvm *kvm, struct kvm_memory_slot *slot);
 #endif
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index f2d1d230d5b8..9898d863b6b6 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -5222,7 +5222,7 @@ static u64 *get_written_sptes(struct kvm_mmu_page *sp, gpa_t gpa, int *nspte)
 	return spte;
 }
 
-static void kvm_mmu_pte_write(struct kvm_vcpu *vcpu, gpa_t gpa,
+static void kvm_mmu_pte_write(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
 			      const u8 *new, int bytes,
 			      struct kvm_page_track_notifier_node *node)
 {
diff --git a/arch/x86/kvm/page_track.c b/arch/x86/kvm/page_track.c
index db5b906876bb..ff7defb4a1d2 100644
--- a/arch/x86/kvm/page_track.c
+++ b/arch/x86/kvm/page_track.c
@@ -236,8 +236,8 @@ EXPORT_SYMBOL_GPL(kvm_page_track_unregister_notifier);
  * The node should figure out if the written page is the one that node is
  * interested in by itself.
  */
-void kvm_page_track_write(struct kvm_vcpu *vcpu, gpa_t gpa, const u8 *new,
-			  int bytes)
+void kvm_page_track_write(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
+			  const u8 *new, int bytes)
 {
 	struct kvm_page_track_notifier_head *head;
 	struct kvm_page_track_notifier_node *n;
@@ -251,7 +251,7 @@ void kvm_page_track_write(struct kvm_vcpu *vcpu, gpa_t gpa, const u8 *new,
 	idx = srcu_read_lock(&head->track_srcu);
 	hlist_for_each_entry_rcu(n, &head->track_notifier_list, node)
 		if (n->track_write)
-			n->track_write(vcpu, gpa, new, bytes, n);
+			n->track_write(vcpu, gpa, gva, new, bytes, n);
 	srcu_read_unlock(&head->track_srcu, idx);
 }
 
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index f66db9473ea3..d3d159986243 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -5281,7 +5281,7 @@ static int vcpu_mmio_gva_to_gpa(struct kvm_vcpu *vcpu, unsigned long gva,
 	return vcpu_is_mmio_gpa(vcpu, gva, *gpa, write);
 }
 
-int emulator_write_phys(struct kvm_vcpu *vcpu, gpa_t gpa,
+int emulator_write_phys(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
 			const void *val, int bytes)
 {
 	int ret;
@@ -5289,14 +5289,14 @@ int emulator_write_phys(struct kvm_vcpu *vcpu, gpa_t gpa,
 	ret = kvm_vcpu_write_guest(vcpu, gpa, val, bytes);
 	if (ret < 0)
 		return 0;
-	kvm_page_track_write(vcpu, gpa, val, bytes);
+	kvm_page_track_write(vcpu, gpa, gva, val, bytes);
 	return 1;
 }
 
 struct read_write_emulator_ops {
 	int (*read_write_prepare)(struct kvm_vcpu *vcpu, void *val,
 				  int bytes);
-	int (*read_write_emulate)(struct kvm_vcpu *vcpu, gpa_t gpa,
+	int (*read_write_emulate)(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
 				  void *val, int bytes);
 	int (*read_write_mmio)(struct kvm_vcpu *vcpu, gpa_t gpa,
 			       int bytes, void *val);
@@ -5317,16 +5317,16 @@ static int read_prepare(struct kvm_vcpu *vcpu, void *val, int bytes)
 	return 0;
 }
 
-static int read_emulate(struct kvm_vcpu *vcpu, gpa_t gpa,
+static int read_emulate(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
 			void *val, int bytes)
 {
 	return !kvm_vcpu_read_guest(vcpu, gpa, val, bytes);
 }
 
-static int write_emulate(struct kvm_vcpu *vcpu, gpa_t gpa,
+static int write_emulate(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
 			 void *val, int bytes)
 {
-	return emulator_write_phys(vcpu, gpa, val, bytes);
+	return emulator_write_phys(vcpu, gpa, gva, val, bytes);
 }
 
 static int write_mmio(struct kvm_vcpu *vcpu, gpa_t gpa, int bytes, void *val)
@@ -5395,7 +5395,7 @@ static int emulator_read_write_onepage(unsigned long addr, void *val,
 			return X86EMUL_PROPAGATE_FAULT;
 	}
 
-	if (!ret && ops->read_write_emulate(vcpu, gpa, val, bytes))
+	if (!ret && ops->read_write_emulate(vcpu, gpa, addr, val, bytes))
 		return X86EMUL_CONTINUE;
 
 	/*
@@ -5556,7 +5556,7 @@ static int emulator_cmpxchg_emulated(struct x86_emulate_ctxt *ctxt,
 		return X86EMUL_CMPXCHG_FAILED;
 
 	kvm_vcpu_mark_page_dirty(vcpu, gpa >> PAGE_SHIFT);
-	kvm_page_track_write(vcpu, gpa, new, bytes);
+	kvm_page_track_write(vcpu, gpa, addr, new, bytes);
 
 	return X86EMUL_CONTINUE;
 
diff --git a/drivers/gpu/drm/i915/gvt/kvmgt.c b/drivers/gpu/drm/i915/gvt/kvmgt.c
index dd3dfd00f4e6..4bd2cdf79f86 100644
--- a/drivers/gpu/drm/i915/gvt/kvmgt.c
+++ b/drivers/gpu/drm/i915/gvt/kvmgt.c
@@ -1550,7 +1550,7 @@ static int kvmgt_page_track_remove(unsigned long handle, u64 gfn)
 	return 0;
 }
 
-static void kvmgt_page_track_write(struct kvm_vcpu *vcpu, gpa_t gpa,
+static void kvmgt_page_track_write(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
 		const u8 *val, int len,
 		struct kvm_page_track_notifier_node *node)
 {

