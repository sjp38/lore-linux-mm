Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A366C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 14:02:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CFBAF206DF
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 14:02:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CFBAF206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 229016B0003; Thu,  2 May 2019 10:02:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DAAC6B0006; Thu,  2 May 2019 10:02:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A24A6B0007; Thu,  2 May 2019 10:02:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B16EF6B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 10:02:48 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n52so1121170edd.2
        for <linux-mm@kvack.org>; Thu, 02 May 2019 07:02:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ryxTUN+PNMNV832LFiFOXNczQfJgZPRMopwKUfGXY5w=;
        b=Eo0LFrP9oaMawNn5uhG6EgoGAzfqCwodG8uGe2N9ueXH59cncmY+f42H2pdnBMAurc
         VRk0003waLW1OyIieZRVk/BPMyOtXb6EDwkqFTzKgmBriJlFpC21JBvMIbk5xXsf2HcN
         KoebIzZJa/pBPRV9oVggjdinIj7+1PUJxnSDFxt1avTU50XmVLqwaCf09eRQ5l9R4SJk
         veNI290dlSZHD5fCrYTLTaqxSKFo/ZUlt92C+gTs5aYAl0UOcwi5wVpgPBJ8BsuBczFu
         F6Is03wFTUzGyAvT9IBKFo76j09DZ/5EvDbbZuxhGRA6ln/JXb2UiG95ad71hsPAJn0b
         l0GQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVOLAXotLb+tinKjqeJsfHRsooAJQL2XmbNtV1erBPPULVZV0L2
	3lXs2qU4Z2wNI7FcJ8oA7T9t+aw/IHq1ZutcHSs1z+GSe92H7DnHX8Rddkh02qJKZmebgtLyOSj
	8BcJtGHE3snoq6dHUfz+YE2Cw/R85CC7z3lxD9j2fSjhd4TzwZeDBDSacBrbbFrCVtQ==
X-Received: by 2002:a50:9765:: with SMTP id d34mr2710521edb.195.1556805768203;
        Thu, 02 May 2019 07:02:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsfg0zsGArDxns0IfrBC8SPhJgRqiFvtYHxalBly3GJXOqfbzuHESpQnP1/FPf0dPIhRNI
X-Received: by 2002:a50:9765:: with SMTP id d34mr2710452edb.195.1556805767348;
        Thu, 02 May 2019 07:02:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556805767; cv=none;
        d=google.com; s=arc-20160816;
        b=l/5bJjBvsbwsW1X3u012xRhEkNTfdLRNj5OfVgb6t9SX2d5Rsj0HiFY2JsuJnTsGUh
         +kWkkftUzyur3plin/Pn03cHhvvm6XqBIIbDQbm5D38WUPO44xh/PFvvaccRrdmAMSgQ
         ioZ2R85jX/MQMfqcR9p4aKcRscY3yUvHUCMIBbPuUn6TSlIMHjzi6NSM2bnJ1Wb82bhD
         k5W5YGd/oHdehJBkD4eCZS7TtJYWBw99B9nkIDHzWy6+RQTpUm4HLdgDlJcuOtePW1Yc
         xO03kFoIv33lozbCsZHIZ2S2pfAC7X4b9Edr0cIKG1KbazBLUdfUkX2qZ51xTokEesBi
         MnUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ryxTUN+PNMNV832LFiFOXNczQfJgZPRMopwKUfGXY5w=;
        b=y+vP/jkz1OwwMDXJRsdVGPTSuOg5tsdMmE86UpLebA52u7LJhij8lJpQnQ1U9lxsPW
         dnthsG5l6skM/cTrcTE++j1vRE5pc+arVz0NyauPHotg31J6sES0BKpqQxXcAC8wn9Hx
         6tTgSy06QuEZ4ePvD06lAXx9Ffaio04wttRY2F+POImApc4nJXt/RubmhoYORdevOp7U
         fMpnVYCtkuxgrIhmCcqrUWNr5LqQ3Rveei/UhP7jmmMCbfpdQ+hTAF3ris7NgmBVvD0z
         BgJLDeKcayqsczhaeQK5X99UyxdrlpvQIcbMtwLK/PZ/iCx90wbBjn+XVVK6WTVTvmhS
         Hp4g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w16si156589edd.176.2019.05.02.07.02.46
        for <linux-mm@kvack.org>;
        Thu, 02 May 2019 07:02:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1B9DC374;
	Thu,  2 May 2019 07:02:46 -0700 (PDT)
Received: from [10.163.1.85] (unknown [10.163.1.85])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 600E63F220;
	Thu,  2 May 2019 07:02:37 -0700 (PDT)
Subject: Re: [PATCH] mm/pgtable: Drop pgtable_t variable from pte_fn_t
 functions
To: Matthew Wilcox <willy@infradead.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.com>,
 Logan Gunthorpe <logang@deltatee.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Dan Williams <dan.j.williams@intel.com>, jglisse@redhat.com,
 Mike Rapoport <rppt@linux.vnet.ibm.com>, x86@kernel.org,
 linux-efi@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org,
 intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
 schwidefsky@de.ibm.com
References: <1556803126-26596-1-git-send-email-anshuman.khandual@arm.com>
 <20190502134623.GA18948@bombadil.infradead.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <03be69c4-9a63-041c-49fc-249b2bf1d58a@arm.com>
Date: Thu, 2 May 2019 19:32:42 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190502134623.GA18948@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 05/02/2019 07:16 PM, Matthew Wilcox wrote:
> On Thu, May 02, 2019 at 06:48:46PM +0530, Anshuman Khandual wrote:
>> Drop the pgtable_t variable from all implementation for pte_fn_t as none of
>> them use it. apply_to_pte_range() should stop computing it as well. Should
>> help us save some cycles.
> You didn't add Martin Schwidefsky for some reason.  He introduced

scripts/get_maintainer.pl did not list the email but anyways I should have
added it from git blame. Thanks for adding his email to the thread.
 

