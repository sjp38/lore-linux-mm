Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 161D7C10F0B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 13:15:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3B312084C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 13:15:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3B312084C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6898B6B000C; Wed,  3 Apr 2019 09:15:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 639EB6B000D; Wed,  3 Apr 2019 09:15:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 501BA6B000E; Wed,  3 Apr 2019 09:15:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 028A36B000C
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 09:15:09 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n12so7535538edo.5
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 06:15:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=PXuYbWzZ6z3LrZGjiPp7kFNWaMc4SndBFSr1Q3Ctm8U=;
        b=J9qNQwc9TaSi0uy7Op+fUW3II2wXE2Jbozts21UoL+47ZJSJCW7zc1cPcMeIjmKIS6
         OR0fzaCXc5Y8UVQz5dsWt9hQnlarG/nq5Vsr8eJ+77rRk73DLhreOxwc9BNFir8KAf9j
         WaOd1BGQgv5zWrvXpd2rRhscXooalLJdg/Vb8OhGuJ1PVWrD5YQb/BH5G2Nu4352Phh9
         jvQIR1XpWqGwVUOVwT8pmz46Fuqt8NXxyMXAQvnQ4dPTJiZAMjbgmw1zIY0Bm/VmpT4L
         jiCLmzRYd5rnDMGu4YNMUOLRsiJ8XH+oCRXA3Yl+JdH/zV7agygN33A+FA5L6jf64y2l
         uKAw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWWRRcJ/+nH4kiK1bVFAXZ9qH9858voZ9y0Fzd4A09pFuMXpGjO
	BU3UHfaai8AgqFbiGuZQRvGlJjq/fBlbavQCrCH0mBjCXvKobUBMfvZyGufMQkxdk2fqB4ovWTz
	PXn1Ulh5/Ctsc3dJwh/yT6+3h/MU6xcXGe4JxC/I1srjc7t9vVhhNpGTBGdhJh/cMMg==
X-Received: by 2002:aa7:d954:: with SMTP id l20mr49386226eds.156.1554297308583;
        Wed, 03 Apr 2019 06:15:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwC7siRuR92dugQNLAy7f2CS2ogU2LncB9W/x0FM5PA94gAjO6/2mrs/M89wvgA7h/rPEmL
X-Received: by 2002:aa7:d954:: with SMTP id l20mr49386181eds.156.1554297307793;
        Wed, 03 Apr 2019 06:15:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554297307; cv=none;
        d=google.com; s=arc-20160816;
        b=ng0RmAR87cBCg/oY33ga7LeF1C0KcuRToinoCsFbIz8EXYbaoq1jkwZTGfvkWQEiPf
         KABRJS+WzsknHM760R2td9ee4/P79RpHQAszDN3RYgAqieM4RNb2j28DkU046Ybemzic
         /KoSGvUHGECMhrQw1bsYZ446dyKVz5rq+i0CbRu3qUYcAy75wVN3w3X6Jo5Ha69RJoW9
         AckJOPeq57WPcUQVvWU0n2MYyFAiaTuj4isZkocBCwprSrn+OLzEqiOYuP3qm4l7wwwH
         b0jZk9ol8ZPw5piZvVbnIdSDDYratwDo4CyHzBIEHndeBoWaUy8OvvIfeBS2tB7skrsK
         89mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=PXuYbWzZ6z3LrZGjiPp7kFNWaMc4SndBFSr1Q3Ctm8U=;
        b=aqHUrXzLipCF6Qwfl2hkxtTDxYoWEndBXZ2gHDD7Gj39ePyEpyS6AcC0DoJXhgYAxi
         rJ/OVKkScx9jspKYvm0li/oT/rcTA7b0qg6PdQAjNs1k3vOdRqeZyyGbd4yYc8ggNZUG
         H2ujF8Jn0UqzVlupIuRYPIuZ+ZVXpLVFaJQqWnxGue+YYR0JvS21ZYDUy0229FfRRgFu
         PdZi59aQE3NswJEPtuX/+8GSIFlhg56z6x+k4Qa0bb0zc9mvbj26WUi0CiGN+mYu/43h
         BxLfKEEGsqLI3O4U1ezsYAFLMcNUoVJ1d+TMyzYZZ38gtZedp6BG2kSzo2DZfNNMZsF9
         c+Bg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y15si2017348edm.325.2019.04.03.06.15.07
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 06:15:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C1C92A78;
	Wed,  3 Apr 2019 06:15:06 -0700 (PDT)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 407743F59C;
	Wed,  3 Apr 2019 06:15:03 -0700 (PDT)
Subject: Re: [PATCH 2/6] arm64/mm: Enable memory hot remove
To: Robin Murphy <robin.murphy@arm.com>,
 Anshuman Khandual <anshuman.khandual@arm.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 akpm@linux-foundation.org, will.deacon@arm.com, catalin.marinas@arm.com
Cc: mark.rutland@arm.com, mhocko@suse.com, david@redhat.com,
 logang@deltatee.com, cai@lca.pw, pasha.tatashin@oracle.com,
 james.morse@arm.com, cpandya@codeaurora.org, arunks@codeaurora.org,
 dan.j.williams@intel.com, mgorman@techsingularity.net, osalvador@suse.de
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-3-git-send-email-anshuman.khandual@arm.com>
 <ed4ceac4-b92c-47f4-33b0-ed1d0833b40d@arm.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <e191ddcb-271c-57f3-091f-eacaac2e86e0@arm.com>
Date: Wed, 3 Apr 2019 14:15:01 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <ed4ceac4-b92c-47f4-33b0-ed1d0833b40d@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/04/2019 13:37, Robin Murphy wrote:
> [ +Steve ]
> 
> Hi Anshuman,
> 
> On 03/04/2019 05:30, Anshuman Khandual wrote:

<snip>

>> diff --git a/arch/arm64/include/asm/pgtable.h
>> b/arch/arm64/include/asm/pgtable.h
>> index de70c1e..858098e 100644
>> --- a/arch/arm64/include/asm/pgtable.h
>> +++ b/arch/arm64/include/asm/pgtable.h
>> @@ -355,6 +355,18 @@ static inline int pmd_protnone(pmd_t pmd)
>>   }
>>   #endif
>>   +#if (CONFIG_PGTABLE_LEVELS > 2)
>> +#define pmd_large(pmd)    (pmd_val(pmd) && !(pmd_val(pmd) &
>> PMD_TABLE_BIT))
>> +#else
>> +#define pmd_large(pmd) 0
>> +#endif
>> +
>> +#if (CONFIG_PGTABLE_LEVELS > 3)
>> +#define pud_large(pud)    (pud_val(pud) && !(pud_val(pud) &
>> PUD_TABLE_BIT))
>> +#else
>> +#define pud_large(pmd) 0
>> +#endif
> 
> These seem rather different from the versions that Steve is proposing in
> the generic pagewalk series - can you reach an agreement on which
> implementation is preferred?

Indeed this doesn't match the version in my series although is quite
similar.

My desire is that p?d_large represents the hardware architectural
definition of large page/huge page/section (pick your naming). Although
now I look more closely this is actually broken in my series (I'll fix
that up and send a new version shortly) - p?d_sect() is similarly
conditional.

Is there a good reason not to use the existing p?d_sect() macros
available on arm64?

I'm also surprised by the CONFIG_PGTABLE_LEVEL conditions as they don't
match the existing conditions for p?d_sect(). Might be worth double
checking it actually does what you expect.

Steve

