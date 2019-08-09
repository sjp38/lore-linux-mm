Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D90A4C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CD2E2089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CD2E2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA5666B0273; Fri,  9 Aug 2019 12:01:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7D916B0276; Fri,  9 Aug 2019 12:01:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7732E6B0273; Fri,  9 Aug 2019 12:01:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 25AD96B0275
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:02 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id h8so46777917wrb.11
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=9BVgq/DnmtOM71Szo8nyUd3ZOSEmtHNG0//NHPf2Kgw=;
        b=ZwY4gWvsYzY83RU86ryZgsAWLLfGWtB7CZFx6Fbji9m811IFAoDCVWFJesKEfy1Ztf
         VlEv4DYo7ZjMsJcEGZJBBJSdREk0bNGuHOfRuBCn23Db1WtB1qaV8y3HwRRbueJrSx+G
         odFOnoMAHKph7YN+hEbKAlv7FlT4xR4Eng1JCtRmkaRc1VlPZFuBa87D2FyqVNvtv4ig
         +9EVCZX2viQEtyn9oANcRngVfq2iiaVSctkh734Gr+suFL9w1aHw42gcVsiqEm+ceeqX
         91JLOOkHYIpXRWjbBVqwaqKQCRf5/nS6WKK2TrAYS6/kmoX1DK+MncFsIviD8HiQ1eeK
         yARA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAVui/tSvNXXZiK9YcOw4KDWNji/YCyMkcV899fam2FCp24dsfvf
	c1SdVgO76BGNMZCmXNCh2gnvTNxrAXXNkfI311uTDfw1TywVuwtB57fQcqg85D78ANN3SZwCngZ
	f+ey5l7GEG9Icb+xALda4GxNtE3cYPZ1UZ/dvuVyki0yb/5c7sSwzD2b69NjbeIT2rw==
X-Received: by 2002:a5d:4602:: with SMTP id t2mr24802880wrq.340.1565366461717;
        Fri, 09 Aug 2019 09:01:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyx6cG+PJhTjy9/8uM+LykJHTaLbe2O0vQP7Kv18Wi64wnk1cO3SrjlXbzeuWr1tDwF9BU5
X-Received: by 2002:a5d:4602:: with SMTP id t2mr24802753wrq.340.1565366460345;
        Fri, 09 Aug 2019 09:01:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366460; cv=none;
        d=google.com; s=arc-20160816;
        b=WitZL8a8ifAdYGQXDwqwAAXTInqc1IU4JKoe4hktV4+4KOMjsn9kCBg86lXW0bGCNh
         MxuI/a6l9ocfiIum3x1KOBwuDX7NCCw/mo7KzAcb4NDI7i+jjkrf2UpxUl92ZHK6Clr5
         tqb5c+DdGAaOr8JEt1uyD4G6txIu7dZj5ICu8ftfeAf290iSeNiHiooDjDeMUQeSi0qO
         qkVWnBeMKqmqZXAhkkIDw9kbi3Agkr9O/liuzLTXLehSq47b+wpWfUxzwBre+1WCJiHa
         5hsAgJpSmmLLtuKmzQV8+jo1P4KhtT1T7iswCwSPFIfopeGmKAiKVPCnf2Dgm/wUuFsK
         q5Mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=9BVgq/DnmtOM71Szo8nyUd3ZOSEmtHNG0//NHPf2Kgw=;
        b=wkv611vq1CQLqTw1TdVZWGGjpKsIF/pjObKf9NNFGBoevtGZv+MMxKa4fhV0cWKuyZ
         UZqiKIpDdoqBFw/J5T8ratRRtwMDjqTpxy4j/sCZdvtLMYrWPYqFz90140+XFGzd5eJV
         ENsQQa28l0z+1u6IUI8ccEXILcbK28RVg2V00eGftza04E/nO/Zdx0QcOK+ioySv+pG8
         P2aBk2HnzUb8hFA/22jeorq/5iSgMSj4uBzQVK9SsoCRSYpFEFi+bwbnons6l0yFbSwf
         GH3oTyvyNda86cuED27k73FQXUcGjfo99OTX07QzqnvDNxqhHcMAiJoEsksaBEHe1MC1
         gWzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id t16si4129747wmj.164.2019.08.09.09.00.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 8A7F3305D3DD;
	Fri,  9 Aug 2019 19:00:59 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 4461E305B7A3;
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
	=?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>,
	Xiao Guangrong <guangrong.xiao@gmail.com>
Subject: [RFC PATCH v6 21/92] kvm: page track: add track_create_slot() callback
Date: Fri,  9 Aug 2019 18:59:36 +0300
Message-Id: <20190809160047.8319-22-alazar@bitdefender.com>
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

This is used to add page access notifications as soon as a slot appears.

CC: Xiao Guangrong <guangrong.xiao@gmail.com>
Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/include/asm/kvm_page_track.h |  5 ++++-
 arch/x86/kvm/page_track.c             | 18 ++++++++++++++++--
 arch/x86/kvm/x86.c                    |  2 +-
 3 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/kvm_page_track.h b/arch/x86/include/asm/kvm_page_track.h
index 172f9749dbb2..18a94d180485 100644
--- a/arch/x86/include/asm/kvm_page_track.h
+++ b/arch/x86/include/asm/kvm_page_track.h
@@ -34,6 +34,9 @@ struct kvm_page_track_notifier_node {
 	 */
 	void (*track_write)(struct kvm_vcpu *vcpu, gpa_t gpa, const u8 *new,
 			    int bytes, struct kvm_page_track_notifier_node *node);
+	void (*track_create_slot)(struct kvm *kvm, struct kvm_memory_slot *slot,
+				  unsigned long npages,
+				  struct kvm_page_track_notifier_node *node);
 	/*
 	 * It is called when memory slot is being moved or removed
 	 * users can drop write-protection for the pages in that memory slot
@@ -51,7 +54,7 @@ void kvm_page_track_cleanup(struct kvm *kvm);
 
 void kvm_page_track_free_memslot(struct kvm_memory_slot *free,
 				 struct kvm_memory_slot *dont);
-int kvm_page_track_create_memslot(struct kvm_memory_slot *slot,
+int kvm_page_track_create_memslot(struct kvm *kvm, struct kvm_memory_slot *slot,
 				  unsigned long npages);
 
 void kvm_slot_page_track_add_page(struct kvm *kvm,
diff --git a/arch/x86/kvm/page_track.c b/arch/x86/kvm/page_track.c
index 3052a59a3065..db5b906876bb 100644
--- a/arch/x86/kvm/page_track.c
+++ b/arch/x86/kvm/page_track.c
@@ -34,10 +34,13 @@ void kvm_page_track_free_memslot(struct kvm_memory_slot *free,
 		}
 }
 
-int kvm_page_track_create_memslot(struct kvm_memory_slot *slot,
+int kvm_page_track_create_memslot(struct kvm *kvm, struct kvm_memory_slot *slot,
 				  unsigned long npages)
 {
-	int  i;
+	struct kvm_page_track_notifier_head *head;
+	struct kvm_page_track_notifier_node *n;
+	int idx;
+	int i;
 
 	for (i = 0; i < KVM_PAGE_TRACK_MAX; i++) {
 		slot->arch.gfn_track[i] =
@@ -47,6 +50,17 @@ int kvm_page_track_create_memslot(struct kvm_memory_slot *slot,
 			goto track_free;
 	}
 
+	head = &kvm->arch.track_notifier_head;
+
+	if (hlist_empty(&head->track_notifier_list))
+		return 0;
+
+	idx = srcu_read_lock(&head->track_srcu);
+	hlist_for_each_entry_rcu(n, &head->track_notifier_list, node)
+		if (n->track_create_slot)
+			n->track_create_slot(kvm, slot, npages, n);
+	srcu_read_unlock(&head->track_srcu, idx);
+
 	return 0;
 
 track_free:
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 30cf0d162aa8..f66db9473ea3 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -9350,7 +9350,7 @@ int kvm_arch_create_memslot(struct kvm *kvm, struct kvm_memory_slot *slot,
 		}
 	}
 
-	if (kvm_page_track_create_memslot(slot, npages))
+	if (kvm_page_track_create_memslot(kvm, slot, npages))
 		goto out_free;
 
 	return 0;

