Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AC6FC28D18
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 02:40:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C67E207E0
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 02:40:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C67E207E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D0ECD6B0270; Wed,  5 Jun 2019 22:40:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBFF76B0271; Wed,  5 Jun 2019 22:40:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BADE86B0272; Wed,  5 Jun 2019 22:40:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 687966B0270
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 22:40:25 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c1so1399429edi.20
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 19:40:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=XUZzPgmaQ73JVWAQLmis86n+9NkZ52/nNl0fHYGNknk=;
        b=T0HsMpKC25KVOVzIL0YBiV7Z3NCfxHTgUHNRsmRFEDmEeVumb10pkiuem73C66UcM2
         pqbsJ1HlI3AVQuDe5jRY7A0ByB72wMh2BC58bM3nZ7NOLysnimozpyb6nNYctsCDSEQ1
         1F62z1CVDxaT6U+Q5ut1j5oGphPWbPmhs4+gfy5ynJkUutnkvShBr/3Ua2CqqC85R/ZV
         PnAtbvd7lxVujEuCS0vvwfM/EzsgiHsCkBvCZhhP6L7G0p61NFAKf4EtTxG4PMHHg/Qx
         PhsoVPh8w+PMR/7flxZFAmiF+oLIncVJPGWm6wx4s4AZzqMQEn6v5eACrRixjSHnAuV1
         jGcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWCPPISAKjpLAzrTfGZVyiqXByanjJi21LCZmx27eqEPMclpSfk
	E55qCebl+s2ipWdNNMOULKVXca9xJtXVSmeLnIUO+/vkgyapQbxQ6KJc+3dwXZKR8oki6EspYsK
	XEfvxGW7v0Jvtp0KIXNHjXiRLvSgcRGZuSDX0R9B7b3J0wKsNQXTEthsrIj4N48/dNg==
X-Received: by 2002:a50:ad98:: with SMTP id a24mr46428943edd.235.1559788824939;
        Wed, 05 Jun 2019 19:40:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzogt7WSKx3JzyCGDCDw7HDpjkCEdbBmcl8Q8m3uYmBRKsG6ww9tLpIEGcN+WYWmTT10I55
X-Received: by 2002:a50:ad98:: with SMTP id a24mr46428888edd.235.1559788824332;
        Wed, 05 Jun 2019 19:40:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559788824; cv=none;
        d=google.com; s=arc-20160816;
        b=S4v4q227G86/ivnxG4Wx1zt2JGoKo3MATDVblJtJbD/yXKJL+FF3TByzxgHF/sh/t7
         YcmEhxu0oWzAsWO5TfCH7gqFMtgk455fm/LJLmG8qsyQDTEBcOzKub9QVpGmx569anh+
         6KtwUOTmC54u5fcxwKvz4KWv3L5DwQqIgj3oeNULV9uWVOovp1ovI+aUTXFkruvMK5/9
         qrvgSmACW+o/p4v5F4/8Hbb4UXxdEe0+6qutfgCIT5WH+ES84Ce7/Ldc2WYRDynegh6K
         MC0ulCNA1u9oyKbUhfDDvpRGCz1dMEIXD6dHDrGoFAfjtxuV5pPuCs1X5xAO2nfJHVZR
         AKbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=XUZzPgmaQ73JVWAQLmis86n+9NkZ52/nNl0fHYGNknk=;
        b=LhV1Ol7QqViZ+0FqFm0v9HqrF4E/inQld8r+2cO0I3dJPDnRQ2JjHqV+3XSF0waXLU
         43QPaWnaFnRrCTgvwtCiJKPtQg+YLGFGEfcWXaMs8IhFv05aNbiDW6UNNyQ+VBmTX5KK
         6vLaL3eHr0Iq8k0qzC3nm/AoLuSpGtXWGJLzU2DINSINSHhhBVHtnNen0sf/qclJTCgL
         6BbDKdheOp3EpT4safxXJmipsLOF0E7MlWd9yQpv0hJey0oqE0CqjL4i+ZCy24yd0kg/
         fQsyXv4LLX3aqVTHXG8aApa4fVMGW/op3t8Fnc9Sgdrsw0MbzWfADUGZRYmhK/tAraa3
         PMyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o15si377837ejm.144.2019.06.05.19.40.23
        for <linux-mm@kvack.org>;
        Wed, 05 Jun 2019 19:40:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B927480D;
	Wed,  5 Jun 2019 19:40:22 -0700 (PDT)
Received: from [10.162.43.122] (p8cg001049571a15.blr.arm.com [10.162.43.122])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 881D23F690;
	Wed,  5 Jun 2019 19:40:12 -0700 (PDT)
Subject: Re: [RFC V2] mm: Generalize notify_page_fault()
To: Matthew Wilcox <willy@infradead.org>,
 Michael Ellerman <mpe@ellerman.id.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 Mark Rutland <mark.rutland@arm.com>,
 Christophe Leroy <christophe.leroy@c-s.fr>,
 Stephen Rothwell <sfr@canb.auug.org.au>,
 Andrey Konovalov <andreyknvl@google.com>, Paul Mackerras <paulus@samba.org>,
 Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>,
 Fenghua Yu <fenghua.yu@intel.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>,
 "David S. Miller" <davem@davemloft.net>, Thomas Gleixner
 <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>,
 Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>,
 Dave Hansen <dave.hansen@linux.intel.com>
References: <1559630046-12940-1-git-send-email-anshuman.khandual@arm.com>
 <87sgsomg91.fsf@concordia.ellerman.id.au>
 <20190605112328.GB2025@bombadil.infradead.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <bc89341a-a2b6-bd34-d342-b46f6e902a7c@arm.com>
Date: Thu, 6 Jun 2019 08:10:28 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190605112328.GB2025@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/05/2019 04:53 PM, Matthew Wilcox wrote:
> On Wed, Jun 05, 2019 at 09:19:22PM +1000, Michael Ellerman wrote:
>> Anshuman Khandual <anshuman.khandual@arm.com> writes:
>>> Similar notify_page_fault() definitions are being used by architectures
>>> duplicating much of the same code. This attempts to unify them into a
>>> single implementation, generalize it and then move it to a common place.
>>> kprobes_built_in() can detect CONFIG_KPROBES, hence notify_page_fault()
>>> need not be wrapped again within CONFIG_KPROBES. Trap number argument can
>>> now contain upto an 'unsigned int' accommodating all possible platforms.
>> ...
>>
>> You've changed several of the architectures from something like above,
>> where it disables preemption around the call into the below:
>>
>>
>> Which skips everything if we're preemptible. Is that an equivalent
>> change? If so can you please explain why in more detail.
> 
> See the discussion in v1 of this patch, which you were cc'd on.
> 
> I agree the description here completely fails to mention why the change.
> It should mention commit a980c0ef9f6d8c.

I will update the commit message to include an explanation for this new
preempt behavior in the generic definition.

