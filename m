Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DABA0C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 836A82089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 836A82089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5534F6B0279; Fri,  9 Aug 2019 12:01:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A1EC6B027B; Fri,  9 Aug 2019 12:01:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 267986B027C; Fri,  9 Aug 2019 12:01:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id CC6E36B0279
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:05 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id p13so46735080wru.17
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=JfimiJGSRZ74FoKM+QfROHdJ/FvId7S7A6jJ2ymcvPc=;
        b=IntPekZ8eyO+cD1K4SlFcXEwnJlfZBmMrxqjczTYPrXnZomL0cDKcPqI7DQJt0gDGd
         aGoeDdchO35pxNi7+L6ev5WjLgfI+fInQkjk3lCamsD1lxz6+l1sKm5Y7evOdn68O4RI
         SuBIDru8XRvOwjOTF6TrMADBGV1oDrgIxNyhtIyYq/j7a/4OitdeCc5/MqvvhBVOav7n
         tL4k8Q0ijtbqwoMcRWOJxgrrTRKvvDPLr8Rf5B6gRV+pTQ0WmV6OTHPETyG4u4A5VQp/
         9yxCgYPJTZXnrJRIh+fjSAMmg3qdAkXrymcWH0RCLBpqXrGr+P8Sf19sTWR8txF6d7EQ
         Vw3g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAWkhhEQxW1x36wyWVIE675noMipokZq0J1a/d0LOZamt8dQfY3n
	hXWZpg9vAYxv3FhJbLGmNojlWt1/C7K4Un121vWc9i5Dfvcm/pvkeUKDGqh6rvzjXG69tMuv8eu
	tJpQ5LwofpAuDOJZnn0dJvq2yitOj9Etbbp+0dQk6jjXLqyuVOy6GWk5pPo2l6rp2GA==
X-Received: by 2002:a5d:4a45:: with SMTP id v5mr17068983wrs.108.1565366465432;
        Fri, 09 Aug 2019 09:01:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz/1cgJAT0TpA2rge7wZiHVAAsXRH00hiF6HHWLa3qCeurjlFC24P7wmLjuXUECUjhLE1Lt
X-Received: by 2002:a5d:4a45:: with SMTP id v5mr17068889wrs.108.1565366464480;
        Fri, 09 Aug 2019 09:01:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366464; cv=none;
        d=google.com; s=arc-20160816;
        b=0YpZc75GAA81EgfVi4A20Zd7cVHgfrNcquBygJFFWwui275co5w5/UafkOi+TlwhK3
         SK1mzA9jiJMRaOpnC+Q7b8Zv7aYrmjQbo2dX+Jm9vwmfjcBz+KGGphcbxHR3S4WnP4iU
         G6If1pDQlsQInjxwqupicgHzdlR6dTFR84ijQG8i7bV6gCAM6AKolZZNnVB5YzEGrmBZ
         /q0ufdpPa4TzUoT/4nRFq/hWi0Fm48vEeJ3ZpX2r2FCZbo6dtxbXdd/aLX2xYx3AoBj+
         oT6mDzaE4dJjuwVEovGMqEV9yLMIFnl2qr9uoTIWipqOcSphbcTZVNjmoArIS+j6Ipi1
         z28A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=JfimiJGSRZ74FoKM+QfROHdJ/FvId7S7A6jJ2ymcvPc=;
        b=onfviubmnjoC11vmby8fDrVg6SKES2eTuCPXgNWB+n9SsDtfzBQoFCZB5PmeKfb2nk
         9LxhFmzRfwJE6wTAqnMZkFJoV6BisdwHZ2I72Wg/jUPtYZLnDkZ3HAf7UNhYaA3XsYde
         vZvbHM0Y1FDUQwntmzVwTMSSRtT3a4Ebh8QK/f4whCD4q/703VSCSOv5Ru07kzrDSNnw
         PajTp6gq8HZpM6lZVGoSs3Mn/kE9337Wp0RtdclXvDVLwMkSAOA6ajlIj63SqrK6KmBB
         XuKjxaJq0DQ5BrnV9NDhvoCY5FUPO03SLetm5ztSs0C++Ae4+ehL6ayH0CekWFu3p9Aj
         MJ2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id d8si82301285wrr.138.2019.08.09.09.01.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id DE002305D3E1;
	Fri,  9 Aug 2019 19:01:03 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id C1A4A305B7A0;
	Fri,  9 Aug 2019 19:01:01 +0300 (EEST)
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
	Sean Christopherson <sean.j.christopherson@intel.com>
Subject: [RFC PATCH v6 28/92] kvm: x86: consult the page tracking from kvm_mmu_get_page() and __direct_map()
Date: Fri,  9 Aug 2019 18:59:43 +0300
Message-Id: <20190809160047.8319-29-alazar@bitdefender.com>
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

KVM doesn't normally need to keep track that closely to page access bits,
however for the introspection subsystem this is essential.

Suggested-by: Paolo Bonzini <pbonzini@redhat.com>
Link: https://marc.info/?l=kvm&m=149804987417131&w=2
CC: Sean Christopherson <sean.j.christopherson@intel.com>
Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/mmu.c | 21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 9eaf6cc776a9..810e3e5bd575 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -2491,6 +2491,20 @@ static void clear_sp_write_flooding_count(u64 *spte)
 	__clear_sp_write_flooding_count(sp);
 }
 
+static unsigned int kvm_mmu_page_track_acc(struct kvm_vcpu *vcpu, gfn_t gfn,
+					   unsigned int acc)
+{
+	if (kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_PREREAD))
+		acc &= ~ACC_USER_MASK;
+	if (kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_PREWRITE) ||
+	    kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_WRITE))
+		acc &= ~ACC_WRITE_MASK;
+	if (kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_PREEXEC))
+		acc &= ~ACC_EXEC_MASK;
+
+	return acc;
+}
+
 static struct kvm_mmu_page *kvm_mmu_get_page(struct kvm_vcpu *vcpu,
 					     gfn_t gfn,
 					     gva_t gaddr,
@@ -2511,7 +2525,7 @@ static struct kvm_mmu_page *kvm_mmu_get_page(struct kvm_vcpu *vcpu,
 	role.direct = direct;
 	if (role.direct)
 		role.cr4_pae = 0;
-	role.access = access;
+	role.access = kvm_mmu_page_track_acc(vcpu, gfn, access);
 	if (!vcpu->arch.mmu->direct_map
 	    && vcpu->arch.mmu->root_level <= PT32_ROOT_LEVEL) {
 		quadrant = gaddr >> (PAGE_SHIFT + (PT64_PT_BITS * level));
@@ -3234,7 +3248,10 @@ static int __direct_map(struct kvm_vcpu *vcpu, int write, int map_writable,
 
 	for_each_shadow_entry(vcpu, (u64)gfn << PAGE_SHIFT, iterator) {
 		if (iterator.level == level) {
-			emulate = mmu_set_spte(vcpu, iterator.sptep, ACC_ALL,
+			unsigned int acc = kvm_mmu_page_track_acc(vcpu, gfn,
+								  ACC_ALL);
+
+			emulate = mmu_set_spte(vcpu, iterator.sptep, acc,
 					       write, level, gfn, pfn, prefault,
 					       map_writable);
 			direct_pte_prefetch(vcpu, iterator.sptep);

