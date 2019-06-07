Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5123C468BD
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 17:05:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0F802089E
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 17:05:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="K15lDwrH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0F802089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B6FD6B000E; Fri,  7 Jun 2019 13:05:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3669F6B0266; Fri,  7 Jun 2019 13:05:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 256036B0269; Fri,  7 Jun 2019 13:05:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E0AAC6B000E
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 13:05:19 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d7so1898615pfq.15
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 10:05:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=DgtSX/H6NfPgrhihV60ypaHNzH2XLKDDtBMwkkXJEQM=;
        b=M21jaFToOO5zqdjEfMKQ3VOCfcEe25iqHLnjGIMDB9vX5lD5PCIQH+B5mjfG3YigVE
         M89FXMBKAdiTn0EwHhC+rZLQswd/OUaM0QtJtHWuhEyZX/mdw+y9xp+m1Gf28LS17Qv7
         Z1C50aaiv/R5mpEAwA5SCAb0ho7zsqdTiLXP0C5uoinJARjMDRGJgQg3TAeiTCiohe8k
         EBEeiRKjhz79c/RDXMIlNfZIMNOt9aRkG7/Eeco6cj0b0wMivhGmyfNi+qCyhmQPyBAp
         t31t0E4Si3nvRY28vR3zxIhLgXXl369y693r8QZgRURSQ49Gw2qTrWeMg1VZx5gnN+oz
         zWjA==
X-Gm-Message-State: APjAAAUTnjbRYu1zBiBgttetjWuJI0O20rF4GbapK3Ltu8rp7otHcY+p
	IPsb0WjbNtAxgNUZOyf5+45M1YU7+DEBatKCaEjOKRvPB8Mch/OIFdmZqNaLMIhUJtiXwb+NGIn
	PDlPvy3nVItZC6TAY4RidMsgRFXT528j+Vjq/6AvrFM6zuL0Mv+7f+ph/UQbfp1Qi9A==
X-Received: by 2002:a17:90a:1911:: with SMTP id 17mr6927587pjg.113.1559927119585;
        Fri, 07 Jun 2019 10:05:19 -0700 (PDT)
X-Received: by 2002:a17:90a:1911:: with SMTP id 17mr6927488pjg.113.1559927118746;
        Fri, 07 Jun 2019 10:05:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559927118; cv=none;
        d=google.com; s=arc-20160816;
        b=RLq5dNQKr6tEkByO1+K8ewhqD0BBgf5gk1UbFVa9o5IHOLQqyg7xOpmWuFD7WXk+wi
         Zt3D7QEYsEo9w4EOdzCtqZ34ZqYBMZnTc9w5qMJlwmYz1NNvCNOgoymsFpSdu/SQHEWI
         FhsgJeNctJRwslQ8+rKrGcMHKIoLE9Di5X0oNBErTkCAPVQPnjwsUVfksujtawexsv8s
         Tw1Uk14VlQAeLmuU16Mj+F5aYq3bELgHFSy+YL9yjISZIop9zeeDILDlFnpdAPwOSu2g
         /2VxV5JnjB1xjyQqYrHmCk5VBZrMiLJQCp9wJm1xlXJnQUKwPVzcCpnXdHJpRFkqbZcV
         ZWaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=DgtSX/H6NfPgrhihV60ypaHNzH2XLKDDtBMwkkXJEQM=;
        b=u6YLMTSkrU9hT4twV7DWuTtJDamhdL1oGbKCNWMmabiwInMCBQY2Ledy7/rQhjvd4B
         u2KpUAa/wYGPoI+4Ttge1lFJ2xpHXDnWw4cTo0s1TF9da49P86JOq/NTz4AbXEBlWyfL
         2YZccHhsTlxHzn7M/YzxFHkIBkFmlYwWy0iLgsYYuH+TLcsRy39ybjqXFZKBXYGg24EK
         d/9uxn9YX8oQ0AtlI/J/jBsBLpY5yL+SEn6OQk7weMONgIFZi1LlVWGj/WT9Jm2flaNu
         hiJRNZboirADTexZlL5KhsP9qb3CUUExYYT6FuhYONjCPDIvOXxNV7s2er+pQ2Yy7dXn
         4j1w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=K15lDwrH;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x5sor3312981pjp.9.2019.06.07.10.05.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 10:05:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=K15lDwrH;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=DgtSX/H6NfPgrhihV60ypaHNzH2XLKDDtBMwkkXJEQM=;
        b=K15lDwrHU+QByMLUcGsPxdOnNlJhavwl5vzG6kxYPkx7YmYvZeW1ck5JO0OoObB5Xa
         bYOzIyKVQ7hz1tKrFJw+d10DsxIcYUogKFKziY6bC49Z4sqMZGz+GKrut1kqgjD9iqnD
         Iy7yuXdRlEQo1JJypK02SCFJ3fiU6aXucnVYHIUhOl0FC0rrAuLNGfNaBUSjjY0SJP0O
         g+9/YMoWXJmfYyZUowSn5eE6XZng5m+uDKaxwLeh1WtwbitTB4KCIgvTiJtDprK4A3Nl
         yGxKspKE+tdnIrdwE1lKLqeXOSavRevLlFIkM3wUJcLjFBoUe06Q+MLv/g4yKH03/nvj
         qypA==
X-Google-Smtp-Source: APXvYqxpIAgK6uMLd/KqHPohBW13L8/VruBdBF59jsPIJ7TQYnlh4WNEPsdSIs+GfxOtnM3FSmF/iQ==
X-Received: by 2002:a17:90a:24e4:: with SMTP id i91mr7053557pje.9.1559927117889;
        Fri, 07 Jun 2019 10:05:17 -0700 (PDT)
Received: from ?IPv6:2600:1012:b044:6f30:60ea:7662:8055:2cca? ([2600:1012:b044:6f30:60ea:7662:8055:2cca])
        by smtp.gmail.com with ESMTPSA id b2sm2609638pgk.50.2019.06.07.10.05.15
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 10:05:15 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup function
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16F203)
In-Reply-To: <ac8827d7b516f4b58e1df20f45b94998d36c418c.camel@intel.com>
Date: Fri, 7 Jun 2019 10:05:13 -0700
Cc: Peter Zijlstra <peterz@infradead.org>, x86@kernel.org,
 "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
 Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>,
 Cyrill Gorcunov <gorcunov@gmail.com>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Eugene Syromiatnikov <esyr@redhat.com>,
 Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>,
 Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>,
 Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>,
 Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
 Pavel Machek <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>,
 "Ravi V. Shankar" <ravi.v.shankar@intel.com>,
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
 Dave Martin <Dave.Martin@arm.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <A495EEB4-F05F-4AB3-831A-0F15B912A7EC@amacapital.net>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com> <20190606200926.4029-4-yu-cheng.yu@intel.com> <20190607080832.GT3419@hirez.programming.kicks-ass.net> <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com> <76B7B1AE-3AEA-4162-B539-990EF3CCE2C2@amacapital.net> <ac8827d7b516f4b58e1df20f45b94998d36c418c.camel@intel.com>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>




> On Jun 7, 2019, at 9:45 AM, Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>=20
> On Fri, 2019-06-07 at 09:35 -0700, Andy Lutomirski wrote:
>>> On Jun 7, 2019, at 9:23 AM, Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>>>=20
>>>>> On Fri, 2019-06-07 at 10:08 +0200, Peter Zijlstra wrote:
>>>>> On Thu, Jun 06, 2019 at 01:09:15PM -0700, Yu-cheng Yu wrote:
>>>>> Indirect Branch Tracking (IBT) provides an optional legacy code bitmap=

>>>>> that allows execution of legacy, non-IBT compatible library by an
>>>>> IBT-enabled application.  When set, each bit in the bitmap indicates
>>>>> one page of legacy code.
>>>>>=20
>>>>> The bitmap is allocated and setup from the application.
>>>>> +int cet_setup_ibt_bitmap(unsigned long bitmap, unsigned long size)
>>>>> +{
>>>>> +    u64 r;
>>>>> +
>>>>> +    if (!current->thread.cet.ibt_enabled)
>>>>> +        return -EINVAL;
>>>>> +
>>>>> +    if (!PAGE_ALIGNED(bitmap) || (size > TASK_SIZE_MAX))
>>>>> +        return -EINVAL;
>>>>> +
>>>>> +    current->thread.cet.ibt_bitmap_addr =3D bitmap;
>>>>> +    current->thread.cet.ibt_bitmap_size =3D size;
>>>>> +
>>>>> +    /*
>>>>> +     * Turn on IBT legacy bitmap.
>>>>> +     */
>>>>> +    modify_fpu_regs_begin();
>>>>> +    rdmsrl(MSR_IA32_U_CET, r);
>>>>> +    r |=3D (MSR_IA32_CET_LEG_IW_EN | bitmap);
>>>>> +    wrmsrl(MSR_IA32_U_CET, r);
>>>>> +    modify_fpu_regs_end();
>>>>> +
>>>>> +    return 0;
>>>>> +}
>>>>=20
>>>> So you just program a random user supplied address into the hardware.
>>>> What happens if there's not actually anything at that address or the
>>>> user munmap()s the data after doing this?
>>>=20
>>> This function checks the bitmap's alignment and size, and anything else i=
s
>>> the
>>> app's responsibility.  What else do you think the kernel should check?
>>>=20
>>=20
>> One might reasonably wonder why this state is privileged in the first pla=
ce
>> and, given that, why we=E2=80=99re allowing it to be written like this.
>>=20
>> Arguably we should have another prctl to lock these values (until exec) a=
s a
>> gardening measure.
>=20
> We can prevent the bitmap from being set more than once.  I will test it.
>=20

I think it would be better to make locking an explicit opt-in.=

