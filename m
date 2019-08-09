Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51545C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:45:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2128621743
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:45:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2128621743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B487F6B0005; Fri,  9 Aug 2019 05:45:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF9046B0008; Fri,  9 Aug 2019 05:45:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E7E86B000A; Fri,  9 Aug 2019 05:45:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 529F56B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 05:45:56 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r21so59974703edc.6
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 02:45:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=u+yMsGsz3qYZrzgBsVFmvJg3hEL2voIKGyVKr14Ljqc=;
        b=jTij21JI1QlZAmzONwnGQMnygDy8uoSnLepRiSU6DHpu2U9FXmQxMxa+fxk3TsF4YD
         8FoTXsx641Emq1s8fKLrZwJXQdPc0jD9NSiCcz4Kv4YyfHNl0+GXglrmTc3ZyNWX158F
         FuXXs9EBtK6yngbZZjrVjwUwLuoN1NBu/amOtCA5lCmmYYmo8UgPKbEWWIiZ4/6lztVb
         MJaVEQgh50Q0afMoCLmSQIfdUw1KTbYH4l9GzO/1bH23KLcWukAk82hPtQc/eh69HGGT
         XRJLyORT4ZufO3Q7bYZp8iMb8uysKRiZYVumthWBupLUFZPefH3MUV2GIpYyPvSfVYVe
         Ghdw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAV9Mq+LnguCfnDiQwPBb62PpiDHNLciy+wCUorb8Fz/iKL2+GgT
	wWiZN8qiXYiFGFm70XHKATTas5SDIGPMfiTVbyrCbbV+s2g4ghijVTaZ4qP5CyYUcbsAaRyWF+Q
	Kj7Iu9LaHF3shsURzkASZAh+lUsODSKQhgDYA53xlJyeW1U5EKXtUlFHkhL+S6eY=
X-Received: by 2002:a17:906:2557:: with SMTP id j23mr17249465ejb.228.1565343955904;
        Fri, 09 Aug 2019 02:45:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzAxVRki9mzCz+xYhIyn6CRhkT/Pq5uPw21NJ91dILG/P2KgL98uxh+yASKSLkVGYM7TxQA
X-Received: by 2002:a17:906:2557:: with SMTP id j23mr17249430ejb.228.1565343955137;
        Fri, 09 Aug 2019 02:45:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565343955; cv=none;
        d=google.com; s=arc-20160816;
        b=RavUG61/4uGep10yvNNtzssIzNPYQumx9N5NfDzchgUB+ONOmlHkaQKQO4aCKwzQLo
         d2nhvnmKsB5gTe5f+QmvR8Qdwge/adENbfO++ExyP/XNn9SZ3yldCIIKoyEf6UrKzcee
         jkbqjSB1EEs1hfjVOiUZQMqC1rJoU8ZiPAPA0HqbSfwM06hLVsZ3MhEE2v7cKEErczXL
         PTmpCOSIejRZgIqfcJiX6p2nVELbVleM7WvKJaF6/BWy0Yz7+gOBTY0o+hP/brtcolyN
         RIhb7G9gh5LPA3QVODMVIPqEMBxOV7+aBktfQIrhKtuYM1ev15pYn2rtsCwDrsnMqwSF
         NJNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=u+yMsGsz3qYZrzgBsVFmvJg3hEL2voIKGyVKr14Ljqc=;
        b=QCcF0Ti9uir7hXUxInmeI8WTiPSqBjZEOq0KeNhK7NuDUnSQA568frrksu48681F8x
         j0mesnUUJsfeV6BBiMzXrxYNrGpvInbJdUdlpNk93dCMAUrVp7GjjyjrujJIcDfFcGqw
         mRNP1LZQrqmDwGfPVOY/YIaP83xMw+D1v+c25oM96uCCJ7+LXSOF3ja0Wen6j/oPl2Zl
         2hS7xxBSfkJLV0ETxXgZBPHng4Si11C1481uM421nnWqf3m1i6tRA5kMlvRyk73rWrFl
         05EpiiucsRgwwQ48ajbWfJKSb1c/jor6yaMr3Ozwqxc2w1kWiHrm35y3TB/CMzfhqUn7
         kuUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id o18si34488648ejm.191.2019.08.09.02.45.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 09 Aug 2019 02:45:55 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 81.250.144.103
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 732B46000D;
	Fri,  9 Aug 2019 09:45:51 +0000 (UTC)
Subject: Re: [PATCH v6 11/14] mips: Adjust brk randomization offset to fit
 generic version
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Albert Ou <aou@eecs.berkeley.edu>, Kees Cook <keescook@chromium.org>,
 linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>,
 Palmer Dabbelt <palmer@sifive.com>, Will Deacon <will.deacon@arm.com>,
 Russell King <linux@armlinux.org.uk>, Ralf Baechle <ralf@linux-mips.org>,
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 Luis Chamberlain <mcgrof@kernel.org>, Paul Burton <paul.burton@mips.com>,
 Paul Walmsley <paul.walmsley@sifive.com>, James Hogan <jhogan@kernel.org>,
 linux-riscv@lists.infradead.org, linux-mips@vger.kernel.org,
 Christoph Hellwig <hch@lst.de>, linux-arm-kernel@lists.infradead.org,
 Alexander Viro <viro@zeniv.linux.org.uk>
References: <20190808061756.19712-1-alex@ghiti.fr>
 <20190808061756.19712-12-alex@ghiti.fr>
 <68ec5cf6-6ba3-68ab-aa01-668b701c642f@cogentembedded.com>
From: Alexandre Ghiti <alex@ghiti.fr>
Message-ID: <7b7e256d-5106-3022-9ded-0af4193b6b8b@ghiti.fr>
Date: Fri, 9 Aug 2019 11:45:51 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <68ec5cf6-6ba3-68ab-aa01-668b701c642f@cogentembedded.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: fr
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/8/19 11:19 AM, Sergei Shtylyov wrote:
> Hello!
>
> On 08.08.2019 9:17, Alexandre Ghiti wrote:
>
>> This commit simply bumps up to 32MB and 1GB the random offset
>> of brk, compared to 8MB and 256MB, for 32bit and 64bit respectively.
>>
>> Suggested-by: Kees Cook <keescook@chromium.org>
>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
>> Acked-by: Paul Burton <paul.burton@mips.com>
>> Reviewed-by: Kees Cook <keescook@chromium.org>
>> Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
>> ---
>>   arch/mips/mm/mmap.c | 7 ++++---
>>   1 file changed, 4 insertions(+), 3 deletions(-)
>>
>> diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
>> index a7e84b2e71d7..ff6ab87e9c56 100644
>> --- a/arch/mips/mm/mmap.c
>> +++ b/arch/mips/mm/mmap.c
> [...]
>> @@ -189,11 +190,11 @@ static inline unsigned long brk_rnd(void)
>>       unsigned long rnd = get_random_long();
>>         rnd = rnd << PAGE_SHIFT;
>> -    /* 8MB for 32bit, 256MB for 64bit */
>> +    /* 32MB for 32bit, 1GB for 64bit */
>>       if (TASK_IS_32BIT_ADDR)
>> -        rnd = rnd & 0x7ffffful;
>> +        rnd = rnd & (SZ_32M - 1);
>>       else
>> -        rnd = rnd & 0xffffffful;
>> +        rnd = rnd & (SZ_1G - 1);
>
>    Why not make these 'rnd &= SZ_* - 1', while at it anyways?


You're right, I could have. Again, this code gets removed afterwards, so 
I think it's ok
to leave it as is.

Anyway, thanks for your remarks Sergei !

Alex


>
> [...]
>
> MBR, Sergei
>
> _______________________________________________
> linux-riscv mailing list
> linux-riscv@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-riscv

