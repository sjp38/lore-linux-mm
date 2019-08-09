Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D7ECC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:03:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C13DE2089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:03:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C13DE2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C049D6B0289; Fri,  9 Aug 2019 12:01:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB4856B028B; Fri,  9 Aug 2019 12:01:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA2BB6B028C; Fri,  9 Aug 2019 12:01:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5F8C76B0289
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:18 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id b1so46834614wru.4
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=V5D+2RErP8axIuDnpt0irmDgWMaqm2mnBu8d1/W4K/k=;
        b=fvEZtaTYlqo4QpobLs4cvwcvcSEKtM4Mg7+FSGsBUQi501h0IW1LGO0aB+edfM6veh
         iPoI354YTw+jF4fBERiJG6q6kBIZCFgCoFDOhcUz7phdKpNpqcYtoBR9yggCFTyr35fy
         I+QqPMg66686PYPGT3cWRuOhnMVqn2sPNMftTRQbZk0iL0YcT2FZMJnHOTl/YQVKmqAD
         oD5pfCv9DZAERLjoqAQ1vDBMjKu4n5xSlQqJGI/aE7F113P1TUkiC+1xy/WZlp9/Kxs7
         UYSK3sY+OKHA0ta7oad+BSdYGeT/hh+ZkGBM8dDK1AznNrXJvqoLNfNHwy+lOnIwRhe/
         DzOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAVmQG6RvKfUVUvc3TUlzoSrNl439HMMzh/nkyBEjZs58T1/sCyr
	k79usUD4qvitsPEJhpHWjynIyUrg3hPMFiE82E4MWbUaOW2eyQq+qgVtUu2KLOqxFj6H3gXK2Cn
	ZX9/qXY1Ai/ENj1ucAFLrk3UCM1Gc521amhjDtGWb8Oo6pwd6EWy97tyt07feqvlgdg==
X-Received: by 2002:a05:6000:10c9:: with SMTP id b9mr11896018wrx.11.1565366477951;
        Fri, 09 Aug 2019 09:01:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTeQBRjjbsQopsVuU8A1hhvBmle1xHjjZzESqE/8vMy10IXiQYcGbHmiO2+6PgBFjKgX9v
X-Received: by 2002:a05:6000:10c9:: with SMTP id b9mr11895881wrx.11.1565366476541;
        Fri, 09 Aug 2019 09:01:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366476; cv=none;
        d=google.com; s=arc-20160816;
        b=IX62W/KbekhQ2D5alfNPat203K51eG/F6guVgRHOGi42oddJOXrRNUQprP/+j5/cKU
         2SfZ8lVhNTwB59zgiLlkbOsjH+dvN+pBCZy0nhndE2CNvOiXUaDldp806ujVOMnV070Y
         VYvaZZ13kISaHPZ0VHJbczr1YxnvhvwYc6GfrGSwmBr8T2TMcpIpoaguATSdmw+0VDww
         B44U8pSjoaOW8t1mEPHGEbZsJY84/HhWuyup6vLv5MjLD6rRg7ONi0vWseiVAowBbWMM
         JrXzFCiSBV8F0YfECux9JnT4/MQIjKtgfkw2p85aYyOwmiWE+sRFJXnk9G2l90B3uEXK
         GHcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=V5D+2RErP8axIuDnpt0irmDgWMaqm2mnBu8d1/W4K/k=;
        b=u9SdFxkQjR43N+VHdDgb6aDmyVYk7Zkgspz8qBy7pCsS6y77vwNU8P5hSxAX1GMo3Y
         1OfaSkCeiDIDfPYPT4/FFDwm263GL1hGbcRYDsMNX9F9E+C6lUyXCa55guqmNIOKd53k
         B6FiSw6vNFReIwYW63ZiAJcMnUpS4byvgg0oT9ZZhAIMdZdKj1jq/rqRGzZ+NtUdtVpN
         fMeVXROhpPpmUDwU7ToFFb8sq879X7MSk95OKqUmGAeNjUrHXydkZKtkM33lpYQJ2Kuw
         SBeP8M6pZWQA2wRnbXxWoHiEorvdiTnLHNRaQDUVvP4V9GcwfnOAU7A9Zz5mC/JK9wot
         6JLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id a4si9063251wro.235.2019.08.09.09.01.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id DC82D305D345;
	Fri,  9 Aug 2019 19:01:15 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 7EF77305B7A1;
	Fri,  9 Aug 2019 19:01:14 +0300 (EEST)
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
Subject: [RFC PATCH v6 44/92] kvm: introspection: extend the internal database of tracked pages with write_bitmap info
Date: Fri,  9 Aug 2019 18:59:59 +0300
Message-Id: <20190809160047.8319-45-alazar@bitdefender.com>
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

This will allow us to use the subpage protection feature.

Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 virt/kvm/kvmi.c     | 46 +++++++++++++++++++++++++++++++++++++--------
 virt/kvm/kvmi_int.h |  1 +
 2 files changed, 39 insertions(+), 8 deletions(-)

diff --git a/virt/kvm/kvmi.c b/virt/kvm/kvmi.c
index 4a9a4430a460..e18dfffa25ac 100644
--- a/virt/kvm/kvmi.c
+++ b/virt/kvm/kvmi.c
@@ -32,6 +32,7 @@ static void kvmi_track_flush_slot(struct kvm *kvm, struct kvm_memory_slot *slot,
 static const u8 full_access  =	KVMI_PAGE_ACCESS_R |
 				KVMI_PAGE_ACCESS_W |
 				KVMI_PAGE_ACCESS_X;
+static const u32 default_write_access_bitmap;
 
 void *kvmi_msg_alloc(void)
 {
@@ -57,23 +58,32 @@ static struct kvmi_mem_access *__kvmi_get_gfn_access(struct kvmi *ikvm,
 	return radix_tree_lookup(&ikvm->access_tree, gfn);
 }
 
+/*
+ * TODO: intercept any SPP change made on pages present in our radix tree.
+ *
+ * bitmap must have the same value as the corresponding SPPT entry.
+ */
 static int kvmi_get_gfn_access(struct kvmi *ikvm, const gfn_t gfn,
-			       u8 *access)
+			       u8 *access, u32 *write_bitmap)
 {
 	struct kvmi_mem_access *m;
 
+	*write_bitmap = default_write_access_bitmap;
 	*access = full_access;
 
 	read_lock(&ikvm->access_tree_lock);
 	m = __kvmi_get_gfn_access(ikvm, gfn);
-	if (m)
+	if (m) {
 		*access = m->access;
+		*write_bitmap = m->write_bitmap;
+	}
 	read_unlock(&ikvm->access_tree_lock);
 
 	return m ? 0 : -1;
 }
 
-static int kvmi_set_gfn_access(struct kvm *kvm, gfn_t gfn, u8 access)
+static int kvmi_set_gfn_access(struct kvm *kvm, gfn_t gfn, u8 access,
+			       u32 write_bitmap)
 {
 	struct kvmi_mem_access *m;
 	struct kvmi_mem_access *__m;
@@ -87,6 +97,7 @@ static int kvmi_set_gfn_access(struct kvm *kvm, gfn_t gfn, u8 access)
 
 	m->gfn = gfn;
 	m->access = access;
+	m->write_bitmap = write_bitmap;
 
 	if (radix_tree_preload(GFP_KERNEL)) {
 		err = -KVM_ENOMEM;
@@ -100,6 +111,7 @@ static int kvmi_set_gfn_access(struct kvm *kvm, gfn_t gfn, u8 access)
 	__m = __kvmi_get_gfn_access(ikvm, gfn);
 	if (__m) {
 		__m->access = access;
+		__m->write_bitmap = write_bitmap;
 		kvmi_arch_update_page_tracking(kvm, NULL, __m);
 		if (access == full_access) {
 			radix_tree_delete(&ikvm->access_tree, gfn);
@@ -124,12 +136,22 @@ static int kvmi_set_gfn_access(struct kvm *kvm, gfn_t gfn, u8 access)
 	return err;
 }
 
+static bool spp_access_allowed(gpa_t gpa, unsigned long bitmap)
+{
+	u32 off = (gpa & ~PAGE_MASK);
+	u32 spp = off / 128;
+
+	return test_bit(spp, &bitmap);
+}
+
 static bool kvmi_restricted_access(struct kvmi *ikvm, gpa_t gpa, u8 access)
 {
+	u32 allowed_bitmap;
 	u8 allowed_access;
 	int err;
 
-	err = kvmi_get_gfn_access(ikvm, gpa_to_gfn(gpa), &allowed_access);
+	err = kvmi_get_gfn_access(ikvm, gpa_to_gfn(gpa), &allowed_access,
+				  &allowed_bitmap);
 
 	if (err)
 		return false;
@@ -138,8 +160,14 @@ static bool kvmi_restricted_access(struct kvmi *ikvm, gpa_t gpa, u8 access)
 	 * We want to be notified only for violations involving access
 	 * bits that we've specifically cleared
 	 */
-	if ((~allowed_access) & access)
+	if ((~allowed_access) & access) {
+		bool write_access = (access & KVMI_PAGE_ACCESS_W);
+
+		if (write_access && spp_access_allowed(gpa, allowed_bitmap))
+			return false;
+
 		return true;
+	}
 
 	return false;
 }
@@ -1126,8 +1154,9 @@ void kvmi_handle_requests(struct kvm_vcpu *vcpu)
 int kvmi_cmd_get_page_access(struct kvmi *ikvm, u64 gpa, u8 *access)
 {
 	gfn_t gfn = gpa_to_gfn(gpa);
+	u32 ignored_write_bitmap;
 
-	kvmi_get_gfn_access(ikvm, gfn, access);
+	kvmi_get_gfn_access(ikvm, gfn, access, &ignored_write_bitmap);
 
 	return 0;
 }
@@ -1136,10 +1165,11 @@ int kvmi_cmd_set_page_access(struct kvmi *ikvm, u64 gpa, u8 access)
 {
 	gfn_t gfn = gpa_to_gfn(gpa);
 	u8 ignored_access;
+	u32 write_bitmap;
 
-	kvmi_get_gfn_access(ikvm, gfn, &ignored_access);
+	kvmi_get_gfn_access(ikvm, gfn, &ignored_access, &write_bitmap);
 
-	return kvmi_set_gfn_access(ikvm->kvm, gfn, access);
+	return kvmi_set_gfn_access(ikvm->kvm, gfn, access, write_bitmap);
 }
 
 int kvmi_cmd_control_events(struct kvm_vcpu *vcpu, unsigned int event_id,
diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
index 3f0c7a03b4a1..d9a10a3b7082 100644
--- a/virt/kvm/kvmi_int.h
+++ b/virt/kvm/kvmi_int.h
@@ -141,6 +141,7 @@ struct kvmi {
 struct kvmi_mem_access {
 	gfn_t gfn;
 	u8 access;
+	u32 write_bitmap;
 	struct kvmi_arch_mem_access arch;
 };
 

