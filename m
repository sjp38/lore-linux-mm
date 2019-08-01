Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7757EC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:13:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39375206A3
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:13:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39375206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7AE58E0003; Thu,  1 Aug 2019 02:13:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B041F8E0001; Thu,  1 Aug 2019 02:13:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A1A168E0003; Thu,  1 Aug 2019 02:13:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 58BDD8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 02:13:16 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m23so43979315edr.7
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 23:13:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=qlktEyeZ2w7X7wycnMX2xdJYbzoOJsNcHk5RSYkTpPo=;
        b=m8sP3k/BKaEhAEfyQWgZf7L33N0CDxeROjoP/mJacQpzmkl4NgNlF1HnEuSpjouz1Q
         qQrT0KVQBY/8/T/MaRk2Y86DhjtxQGpYJCqnUhsMRGVb9se+oIcKwNGP83nYVUNGVqJP
         lJiW3zGrmz1PQPq3pLhfDt4GwvEvjWF27GAM9YhpX7kEI6uhgdtsiWMF39oV1OMaFrUZ
         gRkWXygsQ40TQ/R+GLzXhuvNrEsLHmBT+v6TqhrLtn0prIvrxUWPy5fOEB/FMggPBQ23
         QsoWRc2HqI4pux7oAX46AYACvwlT5HIw7IeJ9ris1eLLL7EFjxR7eIjXDJ+ngqmM+xzX
         2RXQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUugeMQYpT7MB3lxkkh27H0OsKichQYtijVSi+cQ68lGjZnOaSJ
	KD2bWFfRhsF1oeANSZtGu3QHo4LJihzUl9RmyOnP8HO0Qb06gdsxzXgcLp6HenWTI+pqNQLK2uw
	uLAivB6W4UQX0LvmMLy6c0Vbd5HJwB847caS5DogaRE38Xm01MVAb1KkmKfsSkfqN8A==
X-Received: by 2002:a05:6402:3c6:: with SMTP id t6mr29812032edw.172.1564639995866;
        Wed, 31 Jul 2019 23:13:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2JMAKpjkhHSMglTgRm6/1qHponCKPoajwGm+rlukWH6xHHsokI4yCyPZUOpOyEnNgO/eA
X-Received: by 2002:a05:6402:3c6:: with SMTP id t6mr29811999edw.172.1564639995251;
        Wed, 31 Jul 2019 23:13:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564639995; cv=none;
        d=google.com; s=arc-20160816;
        b=L+VrB0fiy3ZKa8hH9yaS59NHSt/tKeRnEBWI5B0Vg084wEVyYCW3daJt90+MdJCFXA
         j5g0U25yZSmvHrbLfz3lUGiFoDANmVSoF3xDJQkmAttB8kM4uDqiHITivq5clVrhtjpV
         UJOoS/88G3i9WPhaiUQ+AnTjtnywiwlXQkLczdfgodqJvbPGIcFJ+rVOKEQUDgjmwtxG
         OnbdlWGLfELEbP+4gKy9O8sJxbkIFnhYNqHBOvBW89JrUxamWWS6Ny3lSfqSvMHtVBIW
         y1xM+Ce0A21r7DJgvTIM5SJMiyvhlMV/tpXmF89oCCj1qpgKC9VGKEqYOSK6l0iwc6fG
         mLng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=qlktEyeZ2w7X7wycnMX2xdJYbzoOJsNcHk5RSYkTpPo=;
        b=VlAtW8OonoEW2zxZ3y/n9yjoFvgf4ZNSmG1pjoMUWnQ7rUKSlPjwiiRkfubjUt9C2+
         hkNXsS0QmMTBCQJi/vZ2HCInFZB7lC+Zq4rYoAUlb9EtWzFFPHi9Pkp0hMLPv4/nZETg
         Q05qzXkgH+MXT2+wC8u2cpa6LObzoYNVMBmUmqAuSASRwIzQMGBvWAiv3k41uAYptpYs
         +p+CCSbr9sv6nBwDZfW5Dp0W+YCZs6pE/cKeBsmc4yl0R16lpAmPiYzYKi3ZaX3lthRQ
         63GXGnhfi6j1UtVUBEVAz5MEEAeCajaSyTgMw5rWS0hcGwHVlY+yVZcLFt+GMA9Z9dE4
         RExg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id v17si22311922edm.4.2019.07.31.23.13.14
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 23:13:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 10555337;
	Wed, 31 Jul 2019 23:13:14 -0700 (PDT)
Received: from [10.163.1.81] (unknown [10.163.1.81])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E7AE53F694;
	Wed, 31 Jul 2019 23:15:06 -0700 (PDT)
Subject: Re: [PATCH v9 10/21] mm: Add generic p?d_leaf() macros
To: Mark Rutland <mark.rutland@arm.com>
Cc: Steven Price <steven.price@arm.com>, linux-mm@kvack.org,
 Andy Lutomirski <luto@kernel.org>, Ard Biesheuvel
 <ard.biesheuvel@linaro.org>, Arnd Bergmann <arnd@arndb.de>,
 Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>,
 James Morse <james.morse@arm.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
 Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>,
 x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 "Liang, Kan" <kan.liang@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>
References: <20190722154210.42799-1-steven.price@arm.com>
 <20190722154210.42799-11-steven.price@arm.com>
 <20190723094113.GA8085@lakrids.cambridge.arm.com>
 <ce4e21f2-020f-6677-d79c-5432e3061d6e@arm.com>
 <20190729125013.GA33794@lakrids.cambridge.arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <d427ccad-e64f-82f4-588b-816376e3cadb@arm.com>
Date: Thu, 1 Aug 2019 11:43:38 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190729125013.GA33794@lakrids.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 07/29/2019 06:20 PM, Mark Rutland wrote:
> On Sun, Jul 28, 2019 at 05:14:31PM +0530, Anshuman Khandual wrote:
>> On 07/23/2019 03:11 PM, Mark Rutland wrote:
>>> It might also be worth pointing out the reasons for this naming, e.g.
>>> p?d_large() aren't currently generic, and this name minimizes potential
>>> confusion between p?d_{large,huge}().
>>
>> Agreed. But these fallback also need to first check non-availability of large
>> pages. 
> 
> We're deliberately not making the p?d_large() helpers generic, so this
> shouldn't fall back on those.

I meant non-availability of large page support in the MMU HW not just the
presence of p?d_large() helpers.

