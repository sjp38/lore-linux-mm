Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79E62C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:04:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 275512089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:04:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 275512089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 579C66B02A6; Fri,  9 Aug 2019 12:01:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B0556B02A7; Fri,  9 Aug 2019 12:01:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C51E6B02A4; Fri,  9 Aug 2019 12:01:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id C0E1F6B02A6
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:40 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id 21so1448924wmj.4
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RzFkrhKfm+lKtxE/RoAbtV1ZTRsRTVwEzIiTzlNXEhI=;
        b=cm9fbojZJQkVbkon5JDa4ZV2Z1Z5XKjgN5HY8C3qDiSGT4jkvmS47mTtMBZZN0tWx1
         KrNGX7Oxkrf2So5fu1CY11ZRODOZUwwTanz7uv9Izx76kvjncHzQN8zrPK6siD0m6p4D
         O22wEn4hTJrJy/Ig8oPYjewmqJY+GJ6Sb9ms5cEQPBGv0WaAIyN8pEqwaMf+NS8qryP+
         l13JwEMDSVH1xzY8ZWBVsCBSwjx/zLsRVh2xNUPprojR+ExPawWv8uQ/Tm8PwX3UdlMI
         9Aa0euJExgP7gyjNfS6RJzxZWMvs0l5MLTdLKio4BKvH6Ro/oYK9luxVvjvmE0PXwQzF
         lb7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAV0/sl5FrRW5oBftQDk9Y6bhIvQ5O3UvpTmiZjovqd3HXRXjxG7
	/7MTH4t6Yp6fb56yKV8pXsYZ7mKYxqUbRmeHYS6uKwvNYNVAY68lf9hu7JxFYMJ/SVit7zwNg8x
	5nhB7d0KOktSWsMlO6pl+SKt9aLmP6R9d70HpZ1NFR5p/4+d7kvszOpt4yJ1+RyZ9Hw==
X-Received: by 2002:a5d:4108:: with SMTP id l8mr750279wrp.113.1565366500410;
        Fri, 09 Aug 2019 09:01:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzItPj5CNi1an2QNO5v8piKTo68ttsIkHFmSqX5uD6kCXS8YqdLgTa6/8H68DY2oucDrUvb
X-Received: by 2002:a5d:4108:: with SMTP id l8mr750201wrp.113.1565366499580;
        Fri, 09 Aug 2019 09:01:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366499; cv=none;
        d=google.com; s=arc-20160816;
        b=HvD6pZ6Zp5n1fWR6aJqU/fN/OMXYuOrJvRBTkhCSDBq2e7I1ppoZcMP3xhyzFmNXPg
         VkeggK8xS1vlgRHqIHIuabngiMfTAJfVrWpMntCel6S2oK22qOe5VZmlBe8Pf45j+Erc
         FIff6Z2Nug/FGacYwHqTCLqE0Y45tEginHjF3vDHco6h3y6XmFbDKDih++S37/JmEfPD
         xMg83NnPLgp8bspyuQLNJrdomosALpEmVpWhAKrxl6hXIxzWJ6f6DZPd/xQ7MqybxB/y
         /dhUp0n0tD5wQ51HOY8b8YsCnNpNRYol6MIkVkcjbvkqXTACT+5Zu7k/bnUj7i2WwG1E
         o6AA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=RzFkrhKfm+lKtxE/RoAbtV1ZTRsRTVwEzIiTzlNXEhI=;
        b=e0ios/PRc++B1eYpzKKx9DudNFoFoE9LQgvGKk75B03j36/BuVw1DTgxCzX4X1uQzB
         vkvuykwSy+v4pfn4vFtTNq/NeGRlu1o5bGh43eL0QcauiGjr67vUtuLgZA7k+fFiizqw
         SCY17o6p608ZXG+3H4h58/bdTU3mU8HhAjVQbsokFP1/a5m/50En/zBeJnXjJFtpMevJ
         Y3Tkpjgt3YBEra4+2xE1E8RTwqXOFfbu992aq318Y0hAI1sIJEEx77wdRKGJridhQR34
         2PGU2jUOsTFBJ+prLJybIMHHuOgrOjRQTOc35rWbsNvY4lWgV9tSTbYhlY3ZjcnhwmnX
         WPNg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id u17si4288815wmm.76.2019.08.09.09.01.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 06666305D35E;
	Fri,  9 Aug 2019 19:01:39 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id A7168305B7A4;
	Fri,  9 Aug 2019 19:01:38 +0300 (EEST)
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
Subject: [RFC PATCH v6 76/92] kvm: x86: disable EPT A/D bits if introspection is present
Date: Fri,  9 Aug 2019 19:00:31 +0300
Message-Id: <20190809160047.8319-77-alazar@bitdefender.com>
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

Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/vmx/vmx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/kvm/vmx/vmx.c b/arch/x86/kvm/vmx/vmx.c
index dc648ba47df3..152c58b63f69 100644
--- a/arch/x86/kvm/vmx/vmx.c
+++ b/arch/x86/kvm/vmx/vmx.c
@@ -7718,7 +7718,7 @@ static __init int hardware_setup(void)
 	    !cpu_has_vmx_invept_global())
 		enable_ept = 0;
 
-	if (!cpu_has_vmx_ept_ad_bits() || !enable_ept)
+	if (!cpu_has_vmx_ept_ad_bits() || !enable_ept || kvmi_is_present())
 		enable_ept_ad_bits = 0;
 
 	if (!cpu_has_vmx_unrestricted_guest() || !enable_ept)

