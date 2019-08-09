Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D476C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15AB52089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15AB52089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F8416B027F; Fri,  9 Aug 2019 12:01:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CD9D6B0281; Fri,  9 Aug 2019 12:01:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 723C96B0282; Fri,  9 Aug 2019 12:01:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 16F126B027F
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:10 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id d65so1447276wmd.3
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qNF2sVjOm0Fr5K1gjWUSYdi3McA60touPCX3QvZmj6o=;
        b=LlAkmB+zdEZ1PDgKFU97wBCChUESrQxV3ZPacUZbArJ6Q6DIh5jXr2azPBXouUWSCr
         v38LJxBrxWtj7ixECiUWbU3YyhjzepqnywbwI0m8Uk29VIybhrCEUa1nnht2NWJjD0//
         ab4naFPCEtx9xtXkUcKegLDvyV75NNCzUsTP0iV6iHudEK9CDzasRl1DIlwDILLeqFtM
         /WYDFE56m46aw+n1NRIjWivFg+tvgD+EPehwjrFTu7LIa1sDN77LzEFLDf/cNaSNtvf1
         IPmlvMieZ2MSUnhAANyQebqnVysKVnIAXbgO3sL/SZM28kTIdd5RFfYSn25jRi3NL2Wr
         wWgw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAXBZ29fQVB0SkxL4TpTKdbqxRAQWziutZokY6NXwc7MtL2u8BrT
	LEf/FB3LZF6ozoHDTsQS7Vej2WIux3SfAYmQ8H5ORaxJUI+gkHTMaGFf23r1vdcwEN0XZZWkJ9i
	kT4biKi75w69qi5WWa+Mfe8RU9cDxdji0kEpH641PZ6y2zBFOfZXwbXKr0gjvQrIWCA==
X-Received: by 2002:a1c:f90f:: with SMTP id x15mr11352155wmh.69.1565366469649;
        Fri, 09 Aug 2019 09:01:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxghAiu7rKt/lE7KIlOT8n7La3vtw95FkoZivsrSt1Z+tqxCGNRSVzIXjBcYb7VMe7HZ1aJ
X-Received: by 2002:a1c:f90f:: with SMTP id x15mr11352038wmh.69.1565366468155;
        Fri, 09 Aug 2019 09:01:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366468; cv=none;
        d=google.com; s=arc-20160816;
        b=r890nObv8k+yjRqLR1WfaSeSmaxiMwBV5lEmi188OBxUMHJ7fXabGl0WLWDgNJq1vt
         Wjt6vCMg2ZodBffiBec7vsHFyCT9u/fMMfjIveEX2lAExb6rkTm4WSwAQEl9pxMB29dW
         5OMYANtrzWgmGPOno+pDy9ja+13N/tC7ME0fqguQzI6RCAiDjYnVDrI+k736IwwoRiuN
         90BVuy1GE8X1Oo41Oc1KQJirBajAL6p8YLLN/k0AtGXjXPF6Q421OfDUOn3uHAs1B1QO
         xXL4nW78JqT9Ao2qI4NGUDveznw37+IgB6YeVODUWWuh9Hfqabz69seBd9OFaH1w3fq9
         4yVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=qNF2sVjOm0Fr5K1gjWUSYdi3McA60touPCX3QvZmj6o=;
        b=oPXhU5N14OF1xpHHTC6iVhdzvI6Y2R8h/An4aRgmsXnrDgovr9IXZWlXD0c3QFce2q
         7C9tWva/xIeDxJ+mX93zCA6IcufOUCk5DUg0x6dc5Ux08BCzOee/t4zM7e1KsLHSmPYB
         wE3fOZoJJDAXtep4kwL7WitziNLwm0IED+WEKxl7vJK5o0/Ynv1lV/jwhfglDT29BDMe
         DDwqheqqjt4OpKSVVH2ITIGp2YZ89Un7uCxY4CFOiwl2cJWkSs19MUe2GPROcDqJUC3X
         hNAPZQ8tgx/X+HvP8xrGD8DC8TxhJbuqgTvyTQpIg75Uu7mosKhMEhbphP/DdA3kwU6i
         SuJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id l3si86764262wrp.426.2019.08.09.09.01.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 8A7A030208C5;
	Fri,  9 Aug 2019 19:01:07 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 891CD305B7A0;
	Fri,  9 Aug 2019 19:01:06 +0300 (EEST)
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
	He Chen <he.chen@linux.intel.com>,
	Zhang Yi <yi.z.zhang@linux.intel.com>
Subject: [RFC PATCH v6 37/92] KVM: VMX: Introduce SPP access bitmap and operation functions
Date: Fri,  9 Aug 2019 18:59:52 +0300
Message-Id: <20190809160047.8319-38-alazar@bitdefender.com>
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

Create access bitmap for SPP subpages, 4KB/128B = 32bits,
for each 4KB physical page, 32bits are required. The bitmap can
be easily accessed with a gfn. The initial access bitmap for each
physical page is 0xFFFFFFFF, meaning SPP is not enabled for the
subpages.

Co-developed-by: He Chen <he.chen@linux.intel.com>
Signed-off-by: He Chen <he.chen@linux.intel.com>
Co-developed-by: Zhang Yi <yi.z.zhang@linux.intel.com>
Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
Co-developed-by: Yang Weijiang <weijiang.yang@intel.com>
Signed-off-by: Yang Weijiang <weijiang.yang@intel.com>
Message-Id: <20190717133751.12910-5-weijiang.yang@intel.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/include/asm/kvm_host.h |  1 +
 arch/x86/kvm/mmu.c              | 50 +++++++++++++++++++++++++++++++++
 arch/x86/kvm/x86.c              | 11 ++++++++
 3 files changed, 62 insertions(+)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index c05984f39923..f0878631b12a 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -790,6 +790,7 @@ struct kvm_lpage_info {
 
 struct kvm_arch_memory_slot {
 	struct kvm_rmap_head *rmap[KVM_NR_PAGE_SIZES];
+	u32 *subpage_wp_info;
 	struct kvm_lpage_info *lpage_info[KVM_NR_PAGE_SIZES - 1];
 	unsigned short *gfn_track[KVM_PAGE_TRACK_MAX];
 };
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 8a6287cd2be4..f2774bbcfeed 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -1482,6 +1482,56 @@ static u64 *rmap_get_next(struct rmap_iterator *iter)
 	return sptep;
 }
 
+#define FULL_SPP_ACCESS		((u32)((1ULL << 32) - 1))
+
+static int kvm_subpage_create_bitmaps(struct kvm *kvm)
+{
+	struct kvm_memslots *slots;
+	struct kvm_memory_slot *memslot;
+	int i, j, ret;
+	u32 *buff;
+
+	for (i = 0; i < KVM_ADDRESS_SPACE_NUM; i++) {
+		slots = __kvm_memslots(kvm, i);
+		kvm_for_each_memslot(memslot, slots) {
+			buff = kvzalloc(memslot->npages*
+				sizeof(*memslot->arch.subpage_wp_info),
+				GFP_KERNEL);
+
+			if (!buff) {
+			      ret = -ENOMEM;
+			      goto out_free;
+			}
+			memslot->arch.subpage_wp_info = buff;
+
+			for(j = 0; j< memslot->npages; j++)
+			      buff[j] = FULL_SPP_ACCESS;
+		}
+	}
+
+	return 0;
+out_free:
+	for (i = 0; i < KVM_ADDRESS_SPACE_NUM; i++) {
+		slots = __kvm_memslots(kvm, i);
+		kvm_for_each_memslot(memslot, slots) {
+			if (memslot->arch.subpage_wp_info) {
+				kvfree(memslot->arch.subpage_wp_info);
+				memslot->arch.subpage_wp_info = NULL;
+			}
+		}
+	}
+
+	return ret;
+}
+
+static u32 *gfn_to_subpage_wp_info(struct kvm_memory_slot *slot, gfn_t gfn)
+{
+	unsigned long idx;
+
+	idx = gfn_to_index(gfn, slot->base_gfn, PT_PAGE_TABLE_LEVEL);
+	return &slot->arch.subpage_wp_info[idx];
+}
+
 #define for_each_rmap_spte(_rmap_head_, _iter_, _spte_)			\
 	for (_spte_ = rmap_get_first(_rmap_head_, _iter_);		\
 	     _spte_; _spte_ = rmap_get_next(_iter_))
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index ef6d9dd80086..2ac1e0aba1fc 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -9320,6 +9320,17 @@ void kvm_arch_destroy_vm(struct kvm *kvm)
 	kvm_hv_destroy_vm(kvm);
 }
 
+void kvm_subpage_free_memslot(struct kvm_memory_slot *free,
+			      struct kvm_memory_slot *dont)
+{
+
+	if (!dont || free->arch.subpage_wp_info !=
+	    dont->arch.subpage_wp_info) {
+		kvfree(free->arch.subpage_wp_info);
+		free->arch.subpage_wp_info = NULL;
+	}
+}
+
 void kvm_arch_free_memslot(struct kvm *kvm, struct kvm_memory_slot *free,
 			   struct kvm_memory_slot *dont)
 {

