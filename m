Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EDA6C10F07
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:11:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0ED4C218FD
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:11:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0ED4C218FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 862F08E0039; Wed, 20 Feb 2019 17:11:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E9C68E0002; Wed, 20 Feb 2019 17:11:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6650B8E0039; Wed, 20 Feb 2019 17:11:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1888E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 17:11:12 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id a5so16589687pfn.2
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 14:11:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=CUeTeWHrvHBzFPfUDJt4R4+bRNHBXwsUrDyFp0j0tOs=;
        b=dDky6qdgCa7IetnaBDyIII8t4WWe+1NxU6M7tLh08gx0QIwV5BxC3y3CJZ6gKsNaPz
         X64ciAGyZZx3hFy4cl5Hsi2OBq7J/DfoU6N49l1MS9qV/EclEiLZQEhQ1qvDVeuW/IO9
         EHMqo4hlGNQKWTKANoVEVgDq4Vf0itSTK9ltYoN6JzoUz6kRxF6DkC+0kaiSLseT8z/n
         quxUZfjLsK/YR67xjmHCXiOlARAS8RJtgkHUNIyp1VmHBAll1Yzg2wl6ddlszALaWuGD
         KMf6m4ElyiLxClE5TW540OmpaFuBKrnDZMi5hE/+8amsOB9b5s/8BlzDN0E8KKFyA3/r
         B8tQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYEwXAHxNaSxgdcAk6s5vkZqtDq1Jgfthu2JFKZlFgHCehFHToF
	ktjYIPEO54YnaQSgpLp6ehynRPdocatO4cp3xTOp7y4xYbBI0Lh/rIgahuosGDdMP8NHUL8wBMh
	Cep66drzibMBA4Hz2kCt2Cze2cxRzVcQs5BIllyo2Q0QHnwrWydA1r53VttX2tzFpYw==
X-Received: by 2002:a17:902:7d89:: with SMTP id a9mr22669216plm.33.1550700671610;
        Wed, 20 Feb 2019 14:11:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYuvbGADm+eI2dadRXV88C+4/HD96MwDKDjNorGQuJSxum2uPSEWiGQmwvBD12Oxa2FB7Pw
X-Received: by 2002:a17:902:7d89:: with SMTP id a9mr22669160plm.33.1550700670819;
        Wed, 20 Feb 2019 14:11:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550700670; cv=none;
        d=google.com; s=arc-20160816;
        b=eFan4B1MnLLjFXtWJolRRCZpPKytGABsK4U27bx1fSxBrcrhWVFLW5ClE+9fWtt+b9
         Dy0leLLEjY+0lUoWCRi3sbVa0UNMyRC4patiw1FINckzi/IbZUCgtrtpCWqop8VmO7xm
         lWjYCrQSKr7/9/0vjLWao0N38Zj7U/j7lgDP5RlPXRXywOuPmTcvF9SuIC+rpPWF6yvx
         tlM83vwVwkoae/pt/cZd+U8+tU0A+G2m7M42YIHrYBqLPGHFnALt4Un3piHMOMwP4fQk
         e3AWfGJVqd3x6kTq/VeVikWakx9J8MjNcpEfRdMWo5r8GH977lmQkPM4Akfnb3Qy+6jk
         /WaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=CUeTeWHrvHBzFPfUDJt4R4+bRNHBXwsUrDyFp0j0tOs=;
        b=LrJS+FG7MdWyorxVwaM57NlfsB3HoLaomP30zgLqHbUBSd5DmbxRlmbW/ebRkGqP3k
         FRKVFjjhVM+OIfk7yUjdoZDyoyybDtqor93StEvoJz60a3B6X5lBQVtp09UNG3Dtih3m
         oGdJoZehMBhje8LGe+cLifhVlPRQtbuLsXZSRbrIVGY+jcf8GUZzwpzW3gABf6R6zDfP
         fQ9l/x4EekDbqeKuzN6DD0jwehM4ZqiL7fh/Dk7gwBTaYsNX+PiNxcLGq2Ys5NgEFWRN
         SdcFEI/VT5wc27J02baJksqhRa/J345uFDbfC12Ba4n8b8on+yHfgTR0PAyu2+I+29Nm
         GsDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a143si20505239pfd.24.2019.02.20.14.11.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 14:11:10 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Feb 2019 14:11:10 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,392,1544515200"; 
   d="scan'208";a="135880677"
Received: from ray.jf.intel.com (HELO [10.7.201.20]) ([10.7.201.20])
  by orsmga002.jf.intel.com with ESMTP; 20 Feb 2019 14:11:09 -0800
Subject: Re: [PATCHv6 07/10] acpi/hmat: Register processor domain to its
 memory
To: "Rafael J. Wysocki" <rafael@kernel.org>,
 Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
 Linux Memory Management List <linux-mm@kvack.org>,
 Linux API <linux-api@vger.kernel.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Dan Williams <dan.j.williams@intel.com>
References: <20190214171017.9362-1-keith.busch@intel.com>
 <20190214171017.9362-8-keith.busch@intel.com>
 <CAJZ5v0gjv0DZvYMTPBLnUmMtu8=g0zFd4x-cpP11Kzv+6XCwUw@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <9ab5d6ba-4cb6-a6f1-894d-d79b77c8bc21@intel.com>
Date: Wed, 20 Feb 2019 14:11:10 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAJZ5v0gjv0DZvYMTPBLnUmMtu8=g0zFd4x-cpP11Kzv+6XCwUw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/20/19 2:02 PM, Rafael J. Wysocki wrote:
>> diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
>> index c9637e2e7514..08e972ead159 100644
>> --- a/drivers/acpi/hmat/Kconfig
>> +++ b/drivers/acpi/hmat/Kconfig
>> @@ -2,6 +2,7 @@
>>  config ACPI_HMAT
>>         bool "ACPI Heterogeneous Memory Attribute Table Support"
>>         depends on ACPI_NUMA
>> +       select HMEM_REPORTING
> If you want to do this here, I'm not sure that defining HMEM_REPORTING
> as a user-selectable option is a good idea.  In particular, I don't
> really think that setting ACPI_HMAT without it makes a lot of sense.
> Apart from this, the patch looks reasonable to me.

I guess the question is whether we would want to allow folks to consume
the HMAT inside the kernel while not reporting it out via
HMEM_REPORTING.  We have some in-kernel users of the HMAT lined up like
mitigations for memory-side caches.

It's certainly possible that folks would want to consume those
mitigations without anything in sysfs.  They might not even want or need
NUMA support itself, for instance.

So, what should we do?

config HMEM_REPORTING
	bool # no user-visible prompt
	default y if ACPI_HMAT

So folks can override in their .config, but they don't see a prompt?

