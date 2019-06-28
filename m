Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96820C5B579
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 03:46:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66CD0208CB
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 03:46:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66CD0208CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E582D8E0003; Thu, 27 Jun 2019 23:46:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E073D8E0002; Thu, 27 Jun 2019 23:46:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF6938E0003; Thu, 27 Jun 2019 23:46:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7FFDB8E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 23:46:13 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i44so7539482eda.3
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 20:46:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ju8OuMo6rKWWMo8SB9IJ5VSwe5x4wFBzk9/4asH/CuI=;
        b=TteSNNA987MQb1Ub3LrtY/hrmpsw2rututIszMKytkOwLiuCvQb/eDOgvBOba/NJsm
         qw4P5PEHX3DKLkih4rqUl1qW1gzCiTzNFgA0+KcnCfNxaxkojtctjovjmZFd4QYMrvqN
         4XbGCHakakMeyoahyTePQeNrVaS9Yfvhw8gjP+k5LBjJ2o5uDBKUs5uU4g+h7y3UYvU+
         CaPrMKw3s4GXB8aTXtS9robeJXoHH8SXedLJoSDHzjLvK+w68jEXORJvFKdZdaDLj8g/
         YhC5BbYS5x6GlzemAQHhtFxEBMc6mPYlUoIUk6/i/FLJgeLlpzVhjgUaceuzvhosIEGy
         C9og==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXSGvrNQB50RfPa/8IbAV8bBisktG2LjwHqP8QZlbQcJ1GaKuOG
	8xoYZvj2NXFh4YbBaWgi0J0WvIxCwIMUxrjRJbNqar0f8ahJBHispSqTWAW1k2bz+ZiZ9U8F14O
	1sRL0Zukl3YA3wTYpwyN5DFxGBe4uJV3VMbQvDgIOtPixE19J4TUmkU/4XqCAkH9LKw==
X-Received: by 2002:a17:906:1e04:: with SMTP id g4mr6552543ejj.48.1561693573020;
        Thu, 27 Jun 2019 20:46:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzSOIbIqvPs4kY7r+mwPs4bEqGgCRg9z30oXKL419LKgrZmjp4YCs0n1SRic4NTiaNkIFm
X-Received: by 2002:a17:906:1e04:: with SMTP id g4mr6552493ejj.48.1561693571964;
        Thu, 27 Jun 2019 20:46:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561693571; cv=none;
        d=google.com; s=arc-20160816;
        b=T880ohI+QCoH/2IpCI1v2h5gBQw6AOuht1mQ9wYNqQ7WTAQO1sWTQmZIOR+CX0f2Zs
         zGWMKSYSDW2/PNSvMU/6qNjqVNoESa76w0fXHxNpEuwolo808QmL7uUSyu0lQoJjjg4t
         EEVO+WIb+BdSM7dD1n0x5z9vNZSAMIPYtQKwcL/J0B19DSHgIJshTyLCfALRJLxvXWGG
         so0+VcF8JrnL1w06gt1zza5owFgGaDlcDilzKMNLNR+ZvKZ0jUjPANzUUqolDU567sa2
         xXgagTNpdFQqJBch/k2N5EiMW+OwuqRyPXypftVanV82PNROarPp2zrWv2iuHtfU1nZq
         zGyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ju8OuMo6rKWWMo8SB9IJ5VSwe5x4wFBzk9/4asH/CuI=;
        b=kPNOjygmBORF2gQR9E5FZEaMfV/6IzjWrWbgulWotNsgIVcK5oLlyI+r2PVO3B4vYw
         gmATIOWWHvWBinfDjCcSs76y+6s+T7ocUSNzf2H8Xw/1Rml0yAumzR7B9PXCCalhMEe9
         KWEohQs9CeowjKmbYHH8ZXv3F2F5XDmAl+pov5qMvlo+toT4fIfZXj57fh4/3mLhMrVM
         dJYeZt+PISy9GoMJa0zLX0skY55O2yxqmDDy/LwzH+rHM5pl2+HYZDpMsQj9tggCNQpn
         0elMjFZXZUoEsEEwaN9RzPzgFMPSmi+EOHujuAZBz6pYhNaXv0kU9acJdsZbzlLdGO3/
         G8dA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id g34si962003edb.182.2019.06.27.20.46.11
        for <linux-mm@kvack.org>;
        Thu, 27 Jun 2019 20:46:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EEEA72B;
	Thu, 27 Jun 2019 20:46:10 -0700 (PDT)
Received: from [10.162.40.144] (p8cg001049571a15.blr.arm.com [10.162.40.144])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 965093F706;
	Thu, 27 Jun 2019 20:46:08 -0700 (PDT)
Subject: Re: [RFC 1/2] arm64/mm: Change THP helpers to comply with generic MM
 semantics
To: Zi Yan <ziy@nvidia.com>
Cc: linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will@kernel.org>, Mark Rutland <mark.rutland@arm.com>,
 Marc Zyngier <marc.zyngier@arm.com>, Suzuki Poulose
 <suzuki.poulose@arm.com>, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org
References: <1561639696-16361-1-git-send-email-anshuman.khandual@arm.com>
 <1561639696-16361-2-git-send-email-anshuman.khandual@arm.com>
 <7F685152-7C6C-4E99-99DF-03DDD03D6094@nvidia.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <5c490be8-5ac1-0a3a-32cf-d4e692fc59b5@arm.com>
Date: Fri, 28 Jun 2019 09:16:35 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <7F685152-7C6C-4E99-99DF-03DDD03D6094@nvidia.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/27/2019 09:01 PM, Zi Yan wrote:
> On 27 Jun 2019, at 8:48, Anshuman Khandual wrote:
> 
>> pmd_present() and pmd_trans_huge() are expected to behave in the following
>> manner during various phases of a given PMD. It is derived from a previous
>> detailed discussion on this topic [1] and present THP documentation [2].
>>
>> pmd_present(pmd):
>>
>> - Returns true if pmd refers to system RAM with a valid pmd_page(pmd)
>> - Returns false if pmd does not refer to system RAM - Invalid pmd_page(pmd)
>>
>> pmd_trans_huge(pmd):
>>
>> - Returns true if pmd refers to system RAM and is a trans huge mapping
>>
>> -------------------------------------------------------------------------
>> |	PMD states	|	pmd_present	|	pmd_trans_huge	|
>> -------------------------------------------------------------------------
>> |	Mapped		|	Yes		|	Yes		|
>> -------------------------------------------------------------------------
>> |	Splitting	|	Yes		|	Yes		|
>> -------------------------------------------------------------------------
>> |	Migration/Swap	|	No		|	No		|
>> -------------------------------------------------------------------------
>>
>> The problem:
>>
>> PMD is first invalidated with pmdp_invalidate() before it's splitting. This
>> invalidation clears PMD_SECT_VALID as below.
>>
>> PMD Split -> pmdp_invalidate() -> pmd_mknotpresent -> Clears PMD_SECT_VALID
>>
>> Once PMD_SECT_VALID gets cleared, it results in pmd_present() return false
>> on the PMD entry. It will need another bit apart from PMD_SECT_VALID to re-
>> affirm pmd_present() as true during the THP split process. To comply with
>> above mentioned semantics, pmd_trans_huge() should also check pmd_present()
>> first before testing presence of an actual transparent huge mapping.
>>
>> The solution:
>>
>> Ideally PMD_TYPE_SECT should have been used here instead. But it shares the
>> bit position with PMD_SECT_VALID which is used for THP invalidation. Hence
>> it will not be there for pmd_present() check after pmdp_invalidate().
>>
>> PTE_SPECIAL never gets used for PMD mapping i.e there is no pmd_special().
>> Hence this bit can be set on the PMD entry during invalidation which can
>> help in making pmd_present() return true and in recognizing the fact that
>> it still points to memory.
>>
>> This bit is transient. During the split is process it will be overridden
>> by a page table page representing the normal pages in place of erstwhile
>> huge page. Other pmdp_invalidate() callers always write a fresh PMD value
>> on the entry overriding this transient PTE_SPECIAL making it safe. In the
>> past former pmd_[mk]splitting() functions used PTE_SPECIAL.
>>
>> [1]: https://lkml.org/lkml/2018/10/17/231
> 
> Just want to point out that lkml.org link might not be stable.
> This one would be better: https://lore.kernel.org/linux-mm/20181017020930.GN30832@redhat.com/

Sure will update the link in the commit. Thanks !

