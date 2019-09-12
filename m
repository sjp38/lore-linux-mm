Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06F6AC4CEC5
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 11:00:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF15E20678
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 11:00:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="XU1ehr7B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF15E20678
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A6526B0003; Thu, 12 Sep 2019 07:00:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4576B6B0005; Thu, 12 Sep 2019 07:00:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 345196B0006; Thu, 12 Sep 2019 07:00:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0189.hostedemail.com [216.40.44.189])
	by kanga.kvack.org (Postfix) with ESMTP id 142B26B0003
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 07:00:18 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id B77DA1A4BC
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 11:00:17 +0000 (UTC)
X-FDA: 75925974474.30.month88_27994ff6b857
X-HE-Tag: month88_27994ff6b857
X-Filterd-Recvd-Size: 5172
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com [209.85.208.65])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 11:00:16 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id p2so22340109edx.11
        for <linux-mm@kvack.org>; Thu, 12 Sep 2019 04:00:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=i4n3cs5YIwHpBBnCvQbY3FnLMZHpwOIQycs63oVDiSc=;
        b=XU1ehr7BQ2UPg1KBuVQ5nl6L4OIYSyENUTpJxtu0PcESlZD1JDIDF/kfEGLVTwGTPP
         MxBuxnwufiCItM0eu2f6PGyyjzV27Q2cNWmrCI/fGkWv00JgM+mdZSN1lgpv2XIZF9yD
         Ti1WM/t84cLxXEP8DSXzi5NQKs0TYyJ79hQa7AZv9JgQdH0hTuNKnH8BEAiZ+ewccLLa
         vvU+d/v7/7I+eQ9LvIytn9jJr+WOd1sRRaRjF83QEr00IfWCJU2SCQ/EcoyWOdAh3E8X
         tFKZsg92QCTLtpzpNowjR1vbUr8LIL24WrcjhMNVcplThOrveFyd6bS7Oehx93UQGF8r
         wpAw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=i4n3cs5YIwHpBBnCvQbY3FnLMZHpwOIQycs63oVDiSc=;
        b=B5fIPJCRTm0g5PpkFu57hbb0o004ry3JubuhtxJJBgdfMYjlC/n4NZAqlDZuZOu84l
         jwXLUxOJbuvT0+wwIhI38lRu1tO0Vy5nOo1BZJJsh9lZaLlm0K5uNcfEQY+Y0zvo/Zcg
         Bco2BoZl/Xi5u3Z6kK0a6NOPJroq5mVwRrUO30bWpOW9ENjXDXXTb2BgqIODm7gwwNcT
         3ZPuK9ynaE3mUFuNGxm4IJVbf16ZyVRSOBFQmxjnxK5+cpRoYVp8AHDEJzOyULUFtyjr
         a09WFqyJtj6Ek5cpFwsMi8Y0g1h+TadED+3YCnVjh+ntMpBgMMSkOA45nCMoC6CS9de6
         RY/g==
X-Gm-Message-State: APjAAAXFknm1kddPltYJKkfI3fVTH/Lht3gmB8DiwFctihuxH6/Kxmnn
	j7fz9acR/C+mFhfIAjsIx49G7Q==
X-Google-Smtp-Source: APXvYqzn86bOsg/hOamx0ZM4X4jdcRXf0RIV/TYjmuJGR8c1qTMEHrx7GcnktNsAZCbZ5Sfr2/boLg==
X-Received: by 2002:a50:d084:: with SMTP id v4mr42151595edd.48.1568286015703;
        Thu, 12 Sep 2019 04:00:15 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id 60sm4730030edg.10.2019.09.12.04.00.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Sep 2019 04:00:14 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 379ED100B4A; Thu, 12 Sep 2019 14:00:16 +0300 (+03)
Date: Thu, 12 Sep 2019 14:00:16 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Mark Brown <broonie@kernel.org>,
	Steven Price <Steven.Price@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Kees Cook <keescook@chromium.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Matthew Wilcox <willy@infradead.org>,
	Sri Krishna chowdary <schowdary@nvidia.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Russell King - ARM Linux <linux@armlinux.org.uk>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Paul Mackerras <paulus@samba.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vineet Gupta <vgupta@synopsys.com>, James Hogan <jhogan@kernel.org>,
	Paul Burton <paul.burton@mips.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Gerald Schaefer <gerald.schaefer@de.ibm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	linux-snps-arc@lists.infradead.org, linux-mips@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	x86@kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH V2 2/2] mm/pgtable/debug: Add test validating
 architecture page table helpers
Message-ID: <20190912110016.srrydg2krplscbgq@box>
References: <1568268173-31302-1-git-send-email-anshuman.khandual@arm.com>
 <1568268173-31302-3-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1568268173-31302-3-git-send-email-anshuman.khandual@arm.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 12, 2019 at 11:32:53AM +0530, Anshuman Khandual wrote:
> +MODULE_LICENSE("GPL v2");
> +MODULE_AUTHOR("Anshuman Khandual <anshuman.khandual@arm.com>");
> +MODULE_DESCRIPTION("Test architecture page table helpers");

It's not module. Why?

BTW, I think we should make all code here __init (or it's variants) so it
can be discarded on boot. It has not use after that.

-- 
 Kirill A. Shutemov

