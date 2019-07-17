Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B405C76192
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 03:50:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AB92208C0
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 03:50:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="swMFO0oK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AB92208C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A7A8F6B0003; Tue, 16 Jul 2019 23:50:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2AF56B0005; Tue, 16 Jul 2019 23:50:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 919078E0001; Tue, 16 Jul 2019 23:50:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5872E6B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 23:50:17 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y66so13648804pfb.21
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 20:50:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=LRyB1JKPo1g9viozQbn+8G4YzmKA4nqslPwu0uoBl1E=;
        b=lp3TysBFngn35CcE1pN2qstAliZE88TXAyPZnXf8yq278SZdVqxGgP1TndaysubiYY
         cPrK1wILy0zTJ0jNZJHkqdwRiK0BT57MNMSLP1BLUkJVh06fNEDtiUkm2IN65fDwLpGK
         Fr+kJC5iDuLdwmCFFt6U6n9MeubQ9Dh6V+BqdouMJQQ5eMsNniSFTlQkiGrut4ey6wYf
         IOQvb5w8N6MAR9kG3C+dZFhVYCswqXB8B5u6mNDeDMojVkNMVbAsxVXPqsTkPaJ7+Sdn
         M67ZySicO2G0RstZD6sjmmNnhm4Kw/xhECloBe+W6SNWmk9aQXZegNsdyVbA49hgbPDU
         kybQ==
X-Gm-Message-State: APjAAAUnXLIg63KgLzKJwuNCJMp0f1EhEu2IyihVTySioRsQ1keQeo4X
	vYZNnZlQRteVGEUs5XOZESFvQZNWOl2T7gUdpWWfDTLpcuo4oUlIx3EMnrVz9r2XavHUjdjpkon
	kmPY4sFXM6nTU22S1bXH0Acqc2OfHr4/1kiC30Oh9bs3V61PmpQ6dEnekPoEz0zcxcQ==
X-Received: by 2002:a17:902:ac85:: with SMTP id h5mr40716561plr.198.1563335416819;
        Tue, 16 Jul 2019 20:50:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwqi+TB9x53Z9gknnnSK1P1Lil7PHVf4nOnjhYO2C9JLTXHPlzEXQiUyG3o0MGU7LHZtCNO
X-Received: by 2002:a17:902:ac85:: with SMTP id h5mr40716476plr.198.1563335416011;
        Tue, 16 Jul 2019 20:50:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563335416; cv=none;
        d=google.com; s=arc-20160816;
        b=Fp8AXiURJLjmPxXMooyRCc7+y6BkXhRq/BQ2NZ18dLCDH77Mf4aCyLv80sIS+S1WIY
         T79o8KZsHQTY3iP3jh/ZqP49yT747PT4aeHL4RUHp5ps34Ur/TtOd2hLwKs+n+3Aupoy
         QVXOp0tcBkZdzUYIJjm8WyGl0LheJYC8z9dMw0RNbU5HMde7Z9gpbXIeLJYVvu97eQuy
         cH8/aywHWyrfczkY/Il2zWv7M0+NJU3RrVTqY8eEvMc0wBAXN1GwZrfiEYq88t+yAdog
         6TkJ4WkUSqJKh77DaRPaivcbNrH9OknxuGJ8v3eTi7Y9YXlEUy4rhoUSjxg89MZWMkTH
         W6yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject
         :dkim-signature;
        bh=LRyB1JKPo1g9viozQbn+8G4YzmKA4nqslPwu0uoBl1E=;
        b=psq6oXqL8Af4VMkG2+cJbRkCrwngS6mKUgCf6oQ+6KpvVXoKHTeHHTIEBe5JPOPwpd
         MCnJ4wD8no41n7OOowrX1GZ98Y7UqsyVZ2WLC8ziWO06T8zUraRSigpecAE2l1ou5pwR
         31RAKyoz3coeohKC7dWJ/iJONk7QNqoWq3hgM9OvEBPrU1nwDpasr7IfXs90jspQNjRt
         dAMXl8uNW75OvxuZ5QLNRS2uWX3AXsZM26jc3ESXKSdlzaVBbrkLxy0hHUdaUdj7Msg+
         Gm4hnWGjgWdaiihTYxMebT+YinJ6eCS09fbesn8HK4fHq8QUuS6UtMQdIH6wNpwSHZ65
         dy6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=swMFO0oK;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k11si23920477pfi.3.2019.07.16.20.50.15
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 16 Jul 2019 20:50:15 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=swMFO0oK;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:To:
	Subject:Sender:Reply-To:Cc:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=LRyB1JKPo1g9viozQbn+8G4YzmKA4nqslPwu0uoBl1E=; b=swMFO0oK0G+l+YUUlFZXG0x6y
	cKnODAhceBjMyRkEWsnSyoMTW8b6HsRXZO2blKLfhvtoX7Uc6r+tgXFU+wbZYn1WHxjYymZ5HOwDM
	0qMq+aj5fOUmxHMdimh3JCFhu0oZtLwoVEAuTfFchx1BnpL5sPfwtu0lbHDXche91qHIGWvFYtoCd
	lpUZj0XRztKsPIB6+QwXKBvVZcAj0t1iJFOIbkk0rka0l2HRnTzKD7loQlUQxv28OgdK28u8txI7h
	lkDAyFnpqJTyXRZ7rXJ555r2TKmdVnOK2Vje34oiDBTh03FKATcyXBhMWmJaWX4oAUWVgl/5ezm1L
	5Paiqsa9g==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=[192.168.1.17])
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hnaxK-0003P0-QH; Wed, 17 Jul 2019 03:50:14 +0000
Subject: Re: mmotm 2019-07-16-17-14 uploaded
To: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz,
 sfr@canb.auug.org.au, linux-next@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org
References: <20190717001534.83sL1%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <8165e113-6da1-c4c0-69eb-37b2d63ceed9@infradead.org>
Date: Tue, 16 Jul 2019 20:50:11 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190717001534.83sL1%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/16/19 5:15 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2019-07-16-17-14 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.

drivers/gpu/drm/amd/amdgpu/Kconfig contains this (from linux-next.patch):

--- a/drivers/gpu/drm/amd/amdgpu/Kconfig~linux-next
+++ a/drivers/gpu/drm/amd/amdgpu/Kconfig
@@ -27,7 +27,12 @@ config DRM_AMDGPU_CIK
 config DRM_AMDGPU_USERPTR
 	bool "Always enable userptr write support"
 	depends on DRM_AMDGPU
+<<<<<<< HEAD
 	depends on HMM_MIRROR
+=======
+	depends on ARCH_HAS_HMM
+	select HMM_MIRROR
+>>>>>>> linux-next/akpm-base
 	help
 	  This option selects CONFIG_HMM and CONFIG_HMM_MIRROR if it
 	  isn't already selected to enabled full userptr support.

which causes a lot of problems.


-- 
~Randy

