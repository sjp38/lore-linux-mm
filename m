Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4AE3C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:04:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AC6120C01
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:04:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AC6120C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85A696B02A1; Fri,  9 Aug 2019 12:01:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 832516B02A2; Fri,  9 Aug 2019 12:01:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7227F6B02A3; Fri,  9 Aug 2019 12:01:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 228516B02A1
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:36 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id e8so46643177wrw.15
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=B2WFK2Dlo/fgsqRY4K4qibZoDI+2o7XZ7zCpHfdvmkU=;
        b=h8AEtS/s1plFhyiduNYiS7lMTBboNiDTfRamM9UTcp5pwWYsH9Q0mErbKAuSx/B5B4
         joVb/doShwICau0KwccZchoWQe89VC9qX0Q5SelX0zxaHafokFiTNdPX4E2hE78q79wK
         SNxLwT2Tj5s8yQR9rGEIG92GSCzf+6zcDdH/nR0hwT8svzqdAe6GqA2K+O1Vsyo8rvCQ
         HqoWANwnXLivis6FqO+YC3yzSGkSh6qiAAtE/AX4cTebmSlKZZJi7AznunRmg4Y8rDhj
         DF3PTafX4zzmiXJbbrB5lN94ca/H2S4x+mOB6U+bwAD8FRC/58VBg/e3rZB2W0EFXHoU
         zyfA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAWotVcKty8a+hZ2vXO1mXc50BbWCTnWRtNg9mA07VpghJD+bHlc
	ZVJMf9Ee45rNEbcIzgh/hojC5126P/NcOvGNdN/JoPOlv/MfEEWWlXJSUBIieOpoxOJaFVJJ27i
	5HHi/3GTOpb9q+JlhXJgQ+fsFwLYvEX5Fv6Ozu8MnOokfMDjKo+KZ8BVgleJc7OwR2A==
X-Received: by 2002:a05:600c:40e:: with SMTP id q14mr4426022wmb.83.1565366495673;
        Fri, 09 Aug 2019 09:01:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjL3PYD43XS5mpryOgQz/tct6UymPImOB8/VW8tpeYbOGvvoypv2zAaEtfta9be5QYMXG4
X-Received: by 2002:a05:600c:40e:: with SMTP id q14mr4425893wmb.83.1565366494172;
        Fri, 09 Aug 2019 09:01:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366494; cv=none;
        d=google.com; s=arc-20160816;
        b=V+FuXeWn94q/njW5gRCDct5GF0ai8LW69q3KqvGzRhOdDp4Qi3POYbg3ugorY+IK4P
         hL+VmpqPtfncdOx4DpvcL9w9wYUoWlg+MK4ah7WOs8a9T8i/VhoxA0weapw3nMOWnU2x
         3Z+strwtSafhX9H7tAez2mYpAFr1bnVzfHoie3Em8rNk0LXENqQQ0Y/9zbnFLd2JKdwb
         8iBcHLArA9HNEklp1KsZdH1i2lBXGyoJUkSrSRISftrdAu1yoLZ2lrixjVOjKACqbJ5p
         lYVedATatL+TPTgaIC73pxEX0vlLm3gXEVJEIncGYOW+UrDdAKRGLBzgIO1j5cYHLUni
         vqlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=B2WFK2Dlo/fgsqRY4K4qibZoDI+2o7XZ7zCpHfdvmkU=;
        b=f5fP0UJ0BPhJjyKUbHZsMhJHA1B3qZ4+qU9A3disvAW7ngdtMSBbPIjM3WlE76zCz+
         86QabMgzB+4RV8YNhHKrbJk3J/4iMChBF2ioLYoKr7qKLOGeFx0BmganEPMps0NJidsX
         1AGUj8dmbSUSxlQar9Yd1B3iFfoVfF9y/BxZkbOufrQRWDjph/c8uBjZXkupDSzpJXC/
         eBB4i+JTxibiVbvouloL/hcEtdcPWCozA6WNrm6rm//94z+0dDFvWV5TG9U94BX613Gd
         62j7AZbiBje1koYLIkRuZmyEvzBlI6M6JJJP6ySie+X4sPPK7f9uA5+ZxNG/RF1jHKKy
         rdGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id d16si85094583wrr.5.2019.08.09.09.01.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 9AD6B305D358;
	Fri,  9 Aug 2019 19:01:33 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 5FCC4305B7A1;
	Fri,  9 Aug 2019 19:01:32 +0300 (EEST)
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
Subject: [RFC PATCH v6 70/92] kvm: x86: filter out access rights only when tracked by the introspection tool
Date: Fri,  9 Aug 2019 19:00:25 +0300
Message-Id: <20190809160047.8319-71-alazar@bitdefender.com>
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

It should complete the commit fd34a9518173 ("kvm: x86: consult the page tracking from kvm_mmu_get_page() and __direct_map()")

Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/mmu.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 65b6acba82da..fd64cf1115da 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -2660,6 +2660,9 @@ static void clear_sp_write_flooding_count(u64 *spte)
 static unsigned int kvm_mmu_page_track_acc(struct kvm_vcpu *vcpu, gfn_t gfn,
 					   unsigned int acc)
 {
+	if (!kvmi_tracked_gfn(vcpu, gfn))
+		return acc;
+
 	if (kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_PREREAD))
 		acc &= ~ACC_USER_MASK;
 	if (kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_PREWRITE) ||

