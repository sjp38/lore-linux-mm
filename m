Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EF94C468BD
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 16:35:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A76320825
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 16:35:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="Z1ujcUSO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A76320825
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 022F86B026F; Fri,  7 Jun 2019 12:35:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEE296B0270; Fri,  7 Jun 2019 12:35:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D68E56B0271; Fri,  7 Jun 2019 12:35:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9871C6B026F
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 12:35:31 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id g11so1686968plt.23
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 09:35:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=0wvMqjnLfHeibHfnd5Vo60J3T+kOUBskArwKAN9PGMQ=;
        b=FMXIUfPEGEPeX7GOwIWCKB+vsTRJUYogjcYIZSu6MB9E4Rh4BiL8R32FDn0Y69vIfb
         SejCFWIwSK4PC7QABniT0zysGbePhHdghvz9OTWv5JQMFOWwZaOnE6BxfpKYhYNNAcWD
         vXt711CobgzA0C2U2kYDfN0oCKZ9/6sm0m6iFPE21lZif1JoGQS0OHYLcRVaGQDt4bv6
         Li4VP5PENau1mtme2NdkP4oGr4ZPwN+TDBiNY9kFuOWHs+MSbvPF82xLfVQZEuiIK1RX
         zGbeJ+7gOGs969sxwcauIVP8BdigbWd+GqbPURWFtv+0R0HkeiVsfMwUcabNgxqJtrer
         UXgA==
X-Gm-Message-State: APjAAAVwWQU2tNfshsvBay1RRF3HMqCANx7TJ9D6OY+DD9B1MH5qSbjE
	DM1xljV9mMgHOpdGJyArFJDCLB9WGlYXJRShg+jEpbUE7JSUPau6yCUFzeHLmtPDhX9pGclD9hz
	NuhqGXNpI2oPm908ngOgmoflSCUsFs7i2qNIfr/7wHt4Quen0STOqvbbR1tldy2qCHQ==
X-Received: by 2002:a63:c744:: with SMTP id v4mr3653866pgg.370.1559925331140;
        Fri, 07 Jun 2019 09:35:31 -0700 (PDT)
X-Received: by 2002:a63:c744:: with SMTP id v4mr3653795pgg.370.1559925330465;
        Fri, 07 Jun 2019 09:35:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559925330; cv=none;
        d=google.com; s=arc-20160816;
        b=dAJpDDoLhHQTxhv7irMefjtmHhd3hwMnv+wpkAg4wqbnzcrjuHzkKdHcMLSk+yp5Td
         UgWD76xZRYdSaSjGFav9HwHdN5wNYApq2vK2YqBVKKJKj6pcFDlKETySrpQ0sL5a/UWM
         kM6ynTY56SdlZI7u70dlbOyAYM2cE2DThKF/PZdFlIRdUX+6boCLmFDOJDztdsHhdoMl
         fFwSOzuB+8XcA4hRqo4OnhJ7ooASqasknhkSwL3QtzsFrHed8t7ywku9IIMrQD6nXh7/
         QhXFjKylEEWRhYu9hXI3nc6XL5E1IRtyKuJl5VGXwBwoxEZqgFvz2hh8Ie2XCroESQEm
         v/qQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=0wvMqjnLfHeibHfnd5Vo60J3T+kOUBskArwKAN9PGMQ=;
        b=kp1cc+8kMINkQ9nFl/FyUGP6J6uhKJxApgsPWXVHGltDDP8NJNF5BAhoe+MVyVEQih
         OMCYCtXmwOj2ROqD2DGcrL3AJOX1zku/bvArVnt6kdBsrAesTfyC7jb5TlVRzrad83WW
         LueTfxBOFFIZkXD6sXH71WYgsaUkIQwbWw8b5xJK9dXUEsMwAcmDZ82DpYXZI6VCKhV/
         xj4Q0pPO1ZeaPuNb0vxILodXcyyLiPiQKhBXqFIZCWyhZ4JtQAh2vCKd4DS4inPqWK59
         Xm0PMlqDqqKFVM/YfQRxrIRI3pUmjMG0F7f40/aVzXUd0FZvcf+PqH1sASQZkIln8sHM
         MHfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=Z1ujcUSO;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t22sor3160552plr.42.2019.06.07.09.35.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 09:35:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=Z1ujcUSO;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=0wvMqjnLfHeibHfnd5Vo60J3T+kOUBskArwKAN9PGMQ=;
        b=Z1ujcUSObY84r0pQw1gBEgavn3UDkEJ73l7OoeuHJ7dTxxtAWA5cFzGd2tv+bDLXFZ
         ZUSH8lkopmuRZXxnqwLbFKFylazXfmK1Yd06ZaFH3sphoqD6YxdLCXKJjTeZ/46olgLw
         cLkrGYT/rNrgSGRUpMNUrvuX5u7UwSAvEWwn4hAgbhrWtbQEXPMkYf5cSf3rXHCCI2yO
         oxKvbLtHVB4ymsJqzauKbObHwXVJGq0nRHyzLloNX1EQW9P9evaYW8zYcNjTEP4aI/WM
         V69MI12MFr6S0MbwLenZ5QYptjGPavTIFQ1xi2XagjAAyleNVcloUFwKXdfWiK7WVJUO
         LbUg==
X-Google-Smtp-Source: APXvYqxYfU9YVziUJO0vNHvuNseZrHbxK2V0LHuxNzSafUXNPN+YeoYV3SImF7zgnh5F5HqBc8Gomg==
X-Received: by 2002:a17:902:7e0f:: with SMTP id b15mr48583188plm.237.1559925330160;
        Fri, 07 Jun 2019 09:35:30 -0700 (PDT)
Received: from ?IPv6:2600:1012:b044:6f30:60ea:7662:8055:2cca? ([2600:1012:b044:6f30:60ea:7662:8055:2cca])
        by smtp.gmail.com with ESMTPSA id f2sm2240019pgs.83.2019.06.07.09.35.28
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 09:35:29 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup function
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16F203)
In-Reply-To: <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
Date: Fri, 7 Jun 2019 09:35:27 -0700
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
Message-Id: <76B7B1AE-3AEA-4162-B539-990EF3CCE2C2@amacapital.net>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com> <20190606200926.4029-4-yu-cheng.yu@intel.com> <20190607080832.GT3419@hirez.programming.kicks-ass.net> <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 7, 2019, at 9:23 AM, Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>=20
>> On Fri, 2019-06-07 at 10:08 +0200, Peter Zijlstra wrote:
>>> On Thu, Jun 06, 2019 at 01:09:15PM -0700, Yu-cheng Yu wrote:
>>> Indirect Branch Tracking (IBT) provides an optional legacy code bitmap
>>> that allows execution of legacy, non-IBT compatible library by an
>>> IBT-enabled application.  When set, each bit in the bitmap indicates
>>> one page of legacy code.
>>>=20
>>> The bitmap is allocated and setup from the application.
>>> +int cet_setup_ibt_bitmap(unsigned long bitmap, unsigned long size)
>>> +{
>>> +    u64 r;
>>> +
>>> +    if (!current->thread.cet.ibt_enabled)
>>> +        return -EINVAL;
>>> +
>>> +    if (!PAGE_ALIGNED(bitmap) || (size > TASK_SIZE_MAX))
>>> +        return -EINVAL;
>>> +
>>> +    current->thread.cet.ibt_bitmap_addr =3D bitmap;
>>> +    current->thread.cet.ibt_bitmap_size =3D size;
>>> +
>>> +    /*
>>> +     * Turn on IBT legacy bitmap.
>>> +     */
>>> +    modify_fpu_regs_begin();
>>> +    rdmsrl(MSR_IA32_U_CET, r);
>>> +    r |=3D (MSR_IA32_CET_LEG_IW_EN | bitmap);
>>> +    wrmsrl(MSR_IA32_U_CET, r);
>>> +    modify_fpu_regs_end();
>>> +
>>> +    return 0;
>>> +}
>>=20
>> So you just program a random user supplied address into the hardware.
>> What happens if there's not actually anything at that address or the
>> user munmap()s the data after doing this?
>=20
> This function checks the bitmap's alignment and size, and anything else is=
 the
> app's responsibility.  What else do you think the kernel should check?
>=20

One might reasonably wonder why this state is privileged in the first place a=
nd, given that, why we=E2=80=99re allowing it to be written like this.

Arguably we should have another prctl to lock these values (until exec) as a=
 gardening measure.=

