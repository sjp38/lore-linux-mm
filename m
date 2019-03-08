Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85393C10F09
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 10:50:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E52820811
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 10:50:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E52820811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CED878E0004; Fri,  8 Mar 2019 05:50:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9CC38E0002; Fri,  8 Mar 2019 05:50:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8D6E8E0004; Fri,  8 Mar 2019 05:50:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 612FC8E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 05:50:50 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id 29so9449524eds.12
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 02:50:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=c6pJuJ9m7n5maxDjLZxoTobn6+wPVSNFn3HzLPDjgO4=;
        b=by7/WRhab/xxY4ORWFGCTrEohk60HEnkonwYEGJ5IWdQEYw6YAT22iOceAIj9nx4La
         dVqtV7950lm0kTp4nTlnxBuvHvYiw3P50v/nMfzn4HeIEX+UfS8rxBnBoc1asu3P7O8e
         gEbNaznPTvAuqB8PkvbFD5fc/C2/Mly4MIbv1vIoetWNL8TXgFKtH9BBf3vwSRASr0yn
         +y2ysB3QvUhNmUWrmBRMCEIUg1aCl+CbrCMv+S7v0kYGF0rX9g2vC1LVm89hBcL5EK1t
         XBXsK4ybkrXKgKunmqpCFvRLGVpGjhPjzApnn3/fJjsYnDpejOmj3N9UHCqhFmLFLIyX
         t+sA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWALiAD0nBbR9RpgkvkrDUEetjw6XbX2EN82N+0iWtqmcobx6XJ
	KMAsSsidpBl4GQ3likPhIpjTizz4z+ToL83HuQo/3/5IGG57lV8m3oBv8KGWt2u5rlsQ89mxH+3
	7blpGggAWNHN+s8zKIanU/3oT6m0/ckowjg8C24SHvBRk3BjWJF/ZO3ACRUNF+hm5gQ==
X-Received: by 2002:a17:906:860e:: with SMTP id o14mr11445903ejx.202.1552042249959;
        Fri, 08 Mar 2019 02:50:49 -0800 (PST)
X-Google-Smtp-Source: APXvYqyyfMqYoCdkx7ECu0dkGvt0vURVUIaUlZqNJakg6eoQCtAkasjt5bQ3bWYeIIl6tUAjLi9Z
X-Received: by 2002:a17:906:860e:: with SMTP id o14mr11445850ejx.202.1552042248850;
        Fri, 08 Mar 2019 02:50:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552042248; cv=none;
        d=google.com; s=arc-20160816;
        b=Vo2WMlNVvVGvzLjOmKZsDx0E9wF2aj1Npq5mkMTif5mTI411mu4mXr5YM8+3zfm21S
         lxOkX7d4qoapo1SfUkOR1q9JbniJ5WngzSTzDqQvkmPnMT1SbLb+a2pL8qOTxMeCURP3
         URb8OLPy/vexZlzP5vRUVi7gnAvnKus+v3DsFhLTd28uMamw/UfPTWOGqj4YtYtfE31y
         5w9bLwqoNiAIuNafE48UbuLoOuV4eBuHZ/q0dwr+p5VwQbWmXZRSZ0C6gDYTgIfNB8YG
         4sPlnPM900na5sWIlL/L36BpHYzrGiRQ8xIlbj7OIPXyC4QY5dvWEaMdk/3cwT5Aen4X
         Ig6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=c6pJuJ9m7n5maxDjLZxoTobn6+wPVSNFn3HzLPDjgO4=;
        b=D/tHyKMWrlPiWzdu954zGpf1McnLFgMu8K4fvFHhDrwronaNtMczP3ynVwSOntoMxe
         NeJPwvUq+v82Iyvmrds4BfSMTKAHyh8HSAJFBKHy5LfPBWjFtxBtNSL96onwTCQMNV/W
         j8/Plp6a0PmwwXJwNH3NIvLp+cDEvq8l+gUXeT97f0HDYzGyVzLe4qxsx+NptpWSEZ+w
         E1VoryIeo63M0JwZ60UHPlgYc53zVFZNcVXb+e0SFxP24uRVO7caZqvH0MjfokyDfmuh
         FdxHEgAdxdHwL1stRECf7TX0TDF0qUtD4MLpYBCBwCl/46ru46GNwu/UU0F4K+saZYUN
         qOjg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r24si724264eda.437.2019.03.08.02.50.48
        for <linux-mm@kvack.org>;
        Fri, 08 Mar 2019 02:50:48 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B3132A78;
	Fri,  8 Mar 2019 02:50:47 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id CB00E3F706;
	Fri,  8 Mar 2019 02:50:43 -0800 (PST)
Subject: Re: [PATCH v4 04/19] powerpc: mm: Add p?d_large() definitions
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>, Peter Zijlstra
 <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <will.deacon@arm.com>, linux-mm@kvack.org, Paul Mackerras
 <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>,
 "Liang, Kan" <kan.liang@linux.intel.com>,
 Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org,
 Ingo Molnar <mingo@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>,
 Arnd Bergmann <arnd@arndb.de>, kvm-ppc@vger.kernel.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>,
 Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-kernel@vger.kernel.org,
 James Morse <james.morse@arm.com>, linuxppc-dev@lists.ozlabs.org
References: <20190306155031.4291-1-steven.price@arm.com>
 <20190306155031.4291-5-steven.price@arm.com>
 <20190308083744.GA6592@rapoport-lnx>
From: Steven Price <steven.price@arm.com>
Message-ID: <a2103947-4551-6f6d-4082-0dca4efd1d06@arm.com>
Date: Fri, 8 Mar 2019 10:50:42 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190308083744.GA6592@rapoport-lnx>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/03/2019 08:37, Mike Rapoport wrote:
> On Wed, Mar 06, 2019 at 03:50:16PM +0000, Steven Price wrote:
>> walk_page_range() is going to be allowed to walk page tables other than
>> those of user space. For this it needs to know when it has reached a
>> 'leaf' entry in the page tables. This information is provided by the
>> p?d_large() functions/macros.
>>
>> For powerpc pmd_large() was already implemented, so hoist it out of the
>> CONFIG_TRANSPARENT_HUGEPAGE condition and implement the other levels.
>>
>> Also since we now have a pmd_large always implemented we can drop the
>> pmd_is_leaf() function.
>>
>> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> CC: Paul Mackerras <paulus@samba.org>
>> CC: Michael Ellerman <mpe@ellerman.id.au>
>> CC: linuxppc-dev@lists.ozlabs.org
>> CC: kvm-ppc@vger.kernel.org
>> Signed-off-by: Steven Price <steven.price@arm.com>
>> ---
>>  arch/powerpc/include/asm/book3s/64/pgtable.h | 30 ++++++++++++++------
> 
> There is one more definition of pmd_large() in
> arch/powerpc/include/asm/pgtable.h

True. That is a #define so will work correctly (it will override the
generic version). Since it is only a dummy definition (always returns 0)
it could be removed, but that would need to be in a separate patch after
the asm-generic versions have been added to avoid breaking bisection.

Steve

