Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54ADEC48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 12:37:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC9E7208CA
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 12:37:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC9E7208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FCB16B0003; Tue, 25 Jun 2019 08:37:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 687028E0003; Tue, 25 Jun 2019 08:37:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 526D18E0002; Tue, 25 Jun 2019 08:37:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 034F36B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 08:37:45 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y3so25388793edm.21
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 05:37:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=+awiAtyi0j8rU6+lM7CN0w7Zhy2l93UJ2WXz8nSBSO0=;
        b=C1QN4Q6iTHRfcWP2FIIAjia1W9nr7ZXb9CAi+74bCZjiu5SWiYiztsHIWKsTybeIjg
         JhmjM3Mn04si8X5X2OsHOHB/W2W/59+7IRdlu+d13eH3xePTX89wbb56dsXu9+9+dr5c
         RclRYY+JC+C6uBQwoW7r0YtTrBV/wwyVEJrQeqST6EimfeGq3MGfBTOSmXcOL21yj32L
         ldIYMs4HfwteODlnyKSWF496tafktohFUg++87tVFfmGMg0ze+CMRHSDny53gj6o+HiS
         foLSvmikcXgAfaY8R8P89StZPgdqWqr2WEdE/aD8GCKf7Csx3arzWSy8WqyZLA1rrbza
         dY7g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
X-Gm-Message-State: APjAAAUcLw67toLPCeSBBeAujXTIj4Q/hUMI6hV8m+kpKfOMw8ZJlee/
	xTSfObSU8kldrA703X1JyLRaR/7nmvtfbhkYceqpG4J8rqsOa2mIfdUgOz8AcQzo5DiEhhosRYo
	42Wect3KQM5Qn5onkP7XqsMwXOmnvyIKAIflweBjqG9FRegFJcq1LUuWhf/tv9d/8jg==
X-Received: by 2002:a17:906:308a:: with SMTP id 10mr23771173ejv.124.1561466264534;
        Tue, 25 Jun 2019 05:37:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1tDi2iyEkEQ+Ep6ll8y5CYGexy7wnXa0uTB65uN/0COWlUcyHTSFLBRwD6UjFzLvl/WF5
X-Received: by 2002:a17:906:308a:: with SMTP id 10mr23771116ejv.124.1561466263778;
        Tue, 25 Jun 2019 05:37:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561466263; cv=none;
        d=google.com; s=arc-20160816;
        b=VFWVBfRgurYu4TtG3E4WV4CrHfnbp+NeuHitBKT4g2CP8KXgQqfmuHf82ZFYtBOokJ
         hEnyNqwT8XDSmlGxuzlfQzMxc/yKHftnZMC8HImezEF0vBFwmp16wPQKLE+OlyV+dk+S
         QbREiUSrWxxj/3/BakYaloCvZGR6E9jSKO5lR3Y5DSp+C2diPryyGoNebTYcaE8QexnZ
         3Qtnp9jBgfrKj1vrXoBMZvCcXr9fgQImeu0+czvkOi9BWFQ3H1w/mLL8+I3lOBdnX/5t
         qUm8eI62BZpRvprxljNvtBQzaiH49zd/Kb0LpGgQT5wV+TPZ1HUEeFlMp97gRSojHYjr
         Rinw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=+awiAtyi0j8rU6+lM7CN0w7Zhy2l93UJ2WXz8nSBSO0=;
        b=mGilIzBGpT4cyb3WrNIp8NMTA72MWYP1HYDF51bENfU2W3kJTuqbHVuJs6MBP/boOD
         6T98jybxpnx0IMmallH6rEgpmhTZr8RNUZmj5jH4w0Ik8fgHDhsCTCegroICabgMUGl+
         QP7RPCDlDsuLCLQ7UX88EHTmUTlYPkmaFPKVZUYRy1emROAri8DRh5Jfw6aM8hwJFbDu
         EdOupXSW6rtmyuq/E7LeE0eBV4K9Rrp2sbHricwLdCb4D978UDecZqkQ+Nh1VaN+v4L3
         giFpud6QEM7XjSAxr9StqGOMqt0MzLBw7TK6kIDeXvryizbffM064UETlvF4RAR76Zdo
         mSEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id d33si349572edb.194.2019.06.25.05.37.43
        for <linux-mm@kvack.org>;
        Tue, 25 Jun 2019 05:37:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id BC02B2B;
	Tue, 25 Jun 2019 05:37:42 -0700 (PDT)
Received: from [70.10.37.10] (unknown [10.37.10.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id DBE593F71E;
	Tue, 25 Jun 2019 05:37:39 -0700 (PDT)
Subject: Re: RISC-V nommu support v2
To: Palmer Dabbelt <palmer@sifive.com>
Cc: Christoph Hellwig <hch@lst.de>, Paul Walmsley <paul.walmsley@sifive.com>,
 Damien Le Moal <Damien.LeMoal@wdc.com>, linux-riscv@lists.infradead.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <mhng-6f11ed95-e3f3-41dc-93c5-1576928b373b@palmer-si-x1e>
From: Vladimir Murzin <vladimir.murzin@arm.com>
Message-ID: <4b2ce641-1412-0e71-82be-07e3f0a6328a@arm.com>
Date: Tue, 25 Jun 2019 13:37:38 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <mhng-6f11ed95-e3f3-41dc-93c5-1576928b373b@palmer-si-x1e>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/25/19 8:31 AM, Palmer Dabbelt wrote:
> On Mon, 24 Jun 2019 06:08:50 PDT (-0700), vladimir.murzin@arm.com wrote:
>> On 6/24/19 12:54 PM, Christoph Hellwig wrote:
>>> On Mon, Jun 24, 2019 at 12:47:07PM +0100, Vladimir Murzin wrote:
>>>> Since you are using binfmt_flat which is kind of 32-bit only I was expecting to see
>>>> CONFIG_COMPAT (or something similar to that, like ILP32) enabled, yet I could not
>>>> find it.
>>>
>>> There is no such thing in RISC-V.  I don't know of any 64-bit RISC-V
>>> cpu that can actually run 32-bit RISC-V code, although in theory that
>>> is possible.  There also is nothing like the x86 x32 or mips n32 mode
>>> available either for now.
>>>
>>> But it turns out that with a few fixes to binfmt_flat it can run 64-bit
>>> binaries just fine.  I sent that series out a while ago, and IIRC you
>>> actually commented on it.
>>>
>>
>> True, yet my observation was that elf2flt utility assumes that address
>> space cannot exceed 32-bit (for header and absolute relocations). So,
>> from my limited point of view straightforward way to guarantee that would
>> be to build incoming elf in 32-bit mode (it is why I mentioned COMPAT/ILP32).
>>
>> Also one of your patches expressed somewhat related idea
>>
>> "binfmt_flat isn't the right binary format for huge executables to
>> start with"
>>
>> Since you said there is no support for compat/ilp32, probably I'm missing some
>> toolchain magic?
>>
>> Cheers
>> Vladimir
> To:          Christoph Hellwig <hch@lst.de>
> CC:          vladimir.murzin@arm.com
> CC:          Christoph Hellwig <hch@lst.de>
> CC:          Paul Walmsley <paul.walmsley@sifive.com>
> CC:          Damien Le Moal <Damien.LeMoal@wdc.com>
> CC:          linux-riscv@lists.infradead.org
> CC:          linux-mm@kvack.org
> CC:          linux-kernel@vger.kernel.org
> Subject:     Re: RISC-V nommu support v2
> In-Reply-To: <20190624131633.GB10746@lst.de>
> 
> On Mon, 24 Jun 2019 06:16:33 PDT (-0700), Christoph Hellwig wrote:
>> On Mon, Jun 24, 2019 at 02:08:50PM +0100, Vladimir Murzin wrote:
>>> True, yet my observation was that elf2flt utility assumes that address
>>> space cannot exceed 32-bit (for header and absolute relocations). So,
>>> from my limited point of view straightforward way to guarantee that would
>>> be to build incoming elf in 32-bit mode (it is why I mentioned COMPAT/ILP32).
>>>
>>> Also one of your patches expressed somewhat related idea
>>>
>>> "binfmt_flat isn't the right binary format for huge executables to
>>> start with"
>>>
>>> Since you said there is no support for compat/ilp32, probably I'm missing some
>>> toolchain magic?
>>
>> There is no magic except for the tiny elf2flt patch, which for
>> now is just in the buildroot repo pointed to in the cover letter
>> (and which I plan to upstream once the kernel support has landed
>> in Linus' tree).  We only support 32-bit code and data address spaces,
>> but we otherwise use the normal RISC-V ABI, that is 64-bit longs and
>> pointers.
> 
> The medlow code model on RISC-V essentially enforces this -- technically it
> enforces a 32-bit region centered around address 0, but it's not that hard to
> stay away from negative addresses.  That said, as long as elf2flt gives you an
> error it should be fine because all medlow is going to do is give you a
> different looking error message.
> 

Thanks for explanation!

Vladimir

