Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22615C28EB4
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 13:51:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9A4F2070B
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 13:51:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9A4F2070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E6726B0277; Thu,  6 Jun 2019 09:51:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 596CD6B0278; Thu,  6 Jun 2019 09:51:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45F2E6B0279; Thu,  6 Jun 2019 09:51:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E7DB26B0277
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 09:51:12 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y24so3889808edb.1
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 06:51:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YTXcHfuxfFCwnytrNH3j9F0V2Hxj5nbQz1TReCN7thc=;
        b=XwGiCWuBxuktQa/zz9+J/aCTsMDY5/48TINzpdyCJ8Qj2X4ziW4EODMRNkUyzhy2Sz
         cunTn5nMZVtAN2KG0gcANqu1BYJJ9LmS7BkKYDQ2atBIMgE6Yqf8kgWQvpxZtf+Lka8G
         1rPmFkIi9SFkDqW+5dMY2kyf1NJoIWnrV4A39dNDSXiX8NM1D6gPFXdXTxHc/e2Y80vk
         +sjRkSmiY6N2zZrSmVgFc0DRO4y1duMg6L86ToVni5raN7JP1LvQgt4SshRFM86zJBDB
         dlB27pZHkHlj22WZzklwL+C7kWUO/WZwOwMk1H/D/GfdNU/glSw4phtXW8DaiynA7v2G
         egMw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAVYE7k6nhWuzRHX1cMDdDJpiqlggkvsYlqPKesHTnQq+cdU0h5Y
	9gYXNwoNXhWjCV42k3SiRayRSG+2D9qr6dauGxFD/l+fZ0C/0FYkNAH95xeLu2156t6QA1/6dki
	Y/l1u+ceBQdl62DkhrUKZo7nzsIto5iJxzIxzdY2V41sYyJ5RLGIfAkqWVMDE8OU/cw==
X-Received: by 2002:a17:906:d053:: with SMTP id bo19mr40493589ejb.86.1559829072367;
        Thu, 06 Jun 2019 06:51:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIvNeRbBEskVprtWQHLPdj6mUJScSbQ8sEvZTsoQOYNZH2FBt8gZwN4vTmnKiGOIfh8yNx
X-Received: by 2002:a17:906:d053:: with SMTP id bo19mr40493519ejb.86.1559829071543;
        Thu, 06 Jun 2019 06:51:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559829071; cv=none;
        d=google.com; s=arc-20160816;
        b=uhQNt4anNYVDj8r7mYfBFNi5GIp9b31qsIsdfar1oSIq8x0l5FlWbGpcKYLkUZOP0x
         8Et1fplHiyqZKuwMtHNjWEoRBJMGIsUjYt/IbCXEmsFA2idsPMDM+UJsN+wckS319bgw
         S3g0I/BuXyc430+2Hv3L1Nem+U9vpmldBOGndk5327K4H8JnaokGY5ZyGoxlzsey44bu
         PlSIVeUjnNLYFf9KaJdDmFs+g6PiuYM3S7fChMcX+vcOGw1IjgqxICDkqcTuQZ7NGgHC
         8Wh4+d8s/vH2284LaK9iBQlOraDv8fAU1ZtjzbBTNaj/sTW80m3qTfilRmtj7MIRRfPY
         Gz2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YTXcHfuxfFCwnytrNH3j9F0V2Hxj5nbQz1TReCN7thc=;
        b=AV7rI2dTZjbHzllJd+tvWeVRg6B4MvnH5AoMoe75dqrlqR3wS+DoPD9n2dfdOf3Zhk
         lBJ3yLjLIKUTVP/j9uscypDG7+aFsEFKBnxFGWJHMv1x+inILrbY4WAMa9UN60U7Uu9W
         AH/Md2rDuEMz7cTGmW9oeo2GxkC6tkOmOtutKLrFWOxZZ/mSPaDVAqG04DRo63/trQTT
         amcSXlcFhY3KoodHqofQSMJ6JXdqNsQgCphdqfvYKU3o59c68QvxBwrvWkW3KV6dUlvx
         3g+kxAfG39QBdoypnFb9S614rs60Pt5LkoU7c5A9yka9uNV2JXtzXCnoHgB4F8NnXsDa
         XuRg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g34si1823545edb.182.2019.06.06.06.51.11
        for <linux-mm@kvack.org>;
        Thu, 06 Jun 2019 06:51:11 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 68F47374;
	Thu,  6 Jun 2019 06:51:10 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E2D753F5AF;
	Thu,  6 Jun 2019 06:51:08 -0700 (PDT)
Date: Thu, 6 Jun 2019 14:51:06 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	Toshi Kani <toshi.kani@hpe.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Will Deacon <will.deacon@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH V4] mm/ioremap: Check virtual address alignment while
 creating huge mappings
Message-ID: <20190606135106.GE56860@arrakis.emea.arm.com>
References: <a893db51-c89a-b061-d308-2a3a1f6cc0eb@arm.com>
 <1557887716-17918-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1557887716-17918-1-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 15, 2019 at 08:05:16AM +0530, Anshuman Khandual wrote:
> Virtual address alignment is essential in ensuring correct clearing for all
> intermediate level pgtable entries and freeing associated pgtable pages. An
> unaligned address can end up randomly freeing pgtable page that potentially
> still contains valid mappings. Hence also check it's alignment along with
> existing phys_addr check.
> 
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> Cc: Toshi Kani <toshi.kani@hpe.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Chintan Pandya <cpandya@codeaurora.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Catalin Marinas <catalin.marinas@arm.com>

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

I guess Andrew can pick this up, otherwise I can queue it through arm64
(there are no arm64 dependencies on this).

Thanks.

-- 
Catalin

