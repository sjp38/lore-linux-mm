Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EF36C76186
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 06:19:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E8C621743
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 06:19:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="RZN+6hkY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E8C621743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10A426B0006; Wed, 17 Jul 2019 02:19:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BBC26B0008; Wed, 17 Jul 2019 02:19:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEC678E0001; Wed, 17 Jul 2019 02:19:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B1ED46B0006
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 02:19:46 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id z14so7094373pgr.22
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 23:19:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=o9OnSlZJU5DUUCjEct8az2tBr1Fx/bIZ5665+npBK6E=;
        b=Se1f1VLz4haxdgTgLFl+TLWRlRX3m8virQMDwVtaAoB6kWZdXNXo6peW/IMO+6SioF
         0bMPWTExPqHL00ENlEa9Z8M7Zn3Evwx6znLAbMVSC+Nohjl83caGp4UNYpLJ+rdsKIhP
         8m5evSSjC/QmMfXVo9/fGe19E+4324qtenU2D4jW+vGBBb91N1JktSFaKrifwoeZURHd
         bIiI27yDmu36NyEecTAsF+sSKu8D2flOwpAQ31XK4CcqQIWcEAuVB+9d/XxyVknWIgpH
         7/OE0M/CQViyRVU/NHvnkbMwVvQ3HnX2m9i8ZgrRzabP+g3+96/kIEa08lzoKlwmKZHB
         eCFg==
X-Gm-Message-State: APjAAAX2XjAsgme7G/rYgcJ9PMDrbnbIe6sn1kkAdvcdOI/83PQJ3QsE
	E2JXjMZBAMWJ/psO1WYrmbXPLGepDM2IXheWDIqlsLpydIRhj6uoU3gY3xWFvRQfVmdoqntZYMt
	I8eRJynnf1HSqQCicGEISG92itZsgxpz7cgxLFBTUSTPG1lB/7S0aMWGfgLg5a4D4uw==
X-Received: by 2002:a17:902:6a87:: with SMTP id n7mr40452102plk.336.1563344386338;
        Tue, 16 Jul 2019 23:19:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwnZvtwVu5otRN0wafV1puxwHeGqCvQcjyXiu8yR0Ow7S8wmFMOR9n+pbLmNE2yGqApkxTJ
X-Received: by 2002:a17:902:6a87:: with SMTP id n7mr40452049plk.336.1563344385703;
        Tue, 16 Jul 2019 23:19:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563344385; cv=none;
        d=google.com; s=arc-20160816;
        b=oegY8RJ1u426Gz1iCAOXsghnJBGFR/GsD5kPvqCHiMsiAnuatwzopcLSMfksr+l1hY
         smQEzJaWxzVR8fsIxqUIZge0Kq7Tq1YDxAI1H08HH3gAKafXmY4Rii99elPuxde4TMCI
         Gm+mWMRob/OfjGPZrU5zAFBZBwVaNVwU1EcEb93stWTqGkhFcALq/tq0Ns9r/w1+hOM6
         BeD3ubSUcOBpMz4C7O8EViNUY428EYM+c3/+o/Cz4t3ZZ8q7e91OPI1Pwoeh9a2xuRM/
         rlkhtsTzotbxnCyZGBpshzBRy5BSkndC6cJOT8HPOFPvdl/EKWENYG25u+d3NRhKgMOP
         P/qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=o9OnSlZJU5DUUCjEct8az2tBr1Fx/bIZ5665+npBK6E=;
        b=StX9OWFGG+2aJ2ff4xCnXT1WDZ9yYPb3o3vGfFMQALAsVgqtl3yfZgdpmhsSYwFtiU
         wjG6yUvI4uzdv9Xe8kI/DhDuouY00Wtq4dmYEm9Al0/qcW6OGX8vOb8BVDhv/F5GB1rk
         3H9Pe7vNL66Qqzb+LO6HjzpfdIfgihgpMThwb3GOF80+YHyMl25Dq0ldUn+Us+um2iFW
         HHS5yT37JrkMqbSI7pF7YCMDcE078lYHb/tgrGnane4gwU+j5pQtXOe+hwGFtN7UJKvG
         OGliNvqFexmpN+R7aoFOU2saspBaVs+guIg3S6ovQimgcvN0wku3GXhzkCg9W3WtZymg
         m3Uw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RZN+6hkY;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b20si20570905pls.24.2019.07.16.23.19.45
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 16 Jul 2019 23:19:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RZN+6hkY;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=o9OnSlZJU5DUUCjEct8az2tBr1Fx/bIZ5665+npBK6E=; b=RZN+6hkYNj53BCOuGJCII7CTy
	4UP0nDFKHWBfBLP60hguy5Cccg/HS5uW+WBamn3keHex3uSblsfTqp/vgYdbxQgJygTaMedfhoYUI
	+MfE8bpoa4voUC9FwnPrYXuSMFpTNjBGgvZChZaM29s312FbxnXBlBIU3L4ziP7x4fonUeTudxLbD
	JFV8ZTPulU5KD102qXFqqeFMKpKGgxZ7zr65/CSgBCtWteOLA7g4OjTlLVZrqbDWNgc5W2yLDndTQ
	O8QO1XeaqDETBPXDnLRo0JFqvNBz4PHvfzQkYgeTt8M2uTKxDLA3b4XCUzqqLmyglTrWXFS3mrpiu
	TtiQN4IbA==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=dragon.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hndHz-0005Xd-OA; Wed, 17 Jul 2019 06:19:43 +0000
Subject: Re: mmotm 2019-07-16-17-14 uploaded
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz,
 linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org
References: <20190717001534.83sL1%akpm@linux-foundation.org>
 <8165e113-6da1-c4c0-69eb-37b2d63ceed9@infradead.org>
 <20190717143830.7f7c3097@canb.auug.org.au>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <a9d0f937-ef61-1d25-f539-96a20b7f8037@infradead.org>
Date: Tue, 16 Jul 2019 23:19:40 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190717143830.7f7c3097@canb.auug.org.au>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/16/19 9:38 PM, Stephen Rothwell wrote:
> Hi Randy,
> 
> On Tue, 16 Jul 2019 20:50:11 -0700 Randy Dunlap <rdunlap@infradead.org> wrote:
>>
>> drivers/gpu/drm/amd/amdgpu/Kconfig contains this (from linux-next.patch):
>>
>> --- a/drivers/gpu/drm/amd/amdgpu/Kconfig~linux-next
>> +++ a/drivers/gpu/drm/amd/amdgpu/Kconfig
>> @@ -27,7 +27,12 @@ config DRM_AMDGPU_CIK
>>  config DRM_AMDGPU_USERPTR
>>  	bool "Always enable userptr write support"
>>  	depends on DRM_AMDGPU
>> +<<<<<<< HEAD
>>  	depends on HMM_MIRROR
>> +=======
>> +	depends on ARCH_HAS_HMM
>> +	select HMM_MIRROR
>> +>>>>>>> linux-next/akpm-base  
>>  	help
>>  	  This option selects CONFIG_HMM and CONFIG_HMM_MIRROR if it
>>  	  isn't already selected to enabled full userptr support.
>>
>> which causes a lot of problems.
> 
> Luckily, I don't apply that patch (I instead merge the actual
> linux-next tree at that point) so this does not affect the linux-next
> included version of mmotm.
> 

for the record:  drivers/gpio/Makefile:

<<<<<<< HEAD
obj-$(CONFIG_GPIO_BD70528)              += gpio-bd70528.o
=======
obj-$(CONFIG_GPIO_BD70528)              += gpio-bd70528.o
>>>>>>> linux-next/akpm-base



-- 
~Randy

