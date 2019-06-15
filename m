Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A5E4C31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 15:30:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7F122183F
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 15:30:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="L1UiC6nR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7F122183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CB6B6B0003; Sat, 15 Jun 2019 11:30:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57B778E0002; Sat, 15 Jun 2019 11:30:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46A428E0001; Sat, 15 Jun 2019 11:30:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0D9BA6B0003
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 11:30:13 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id y9so3404101plp.12
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 08:30:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=/jcKk2/19vs459JoYUsaRTHxKiAzDVN8TgUMdkzJK98=;
        b=Q+IcUicghUVO0uCUZ02MZjQzbFzwDQ90gkUXoUORSG9m9sLI0dmBoOYThn5Z1NqD8n
         dLJKZGR/QAQzf6WQkWeEEB1HmAKAs62jPYApyek2ae5RQbj4kUA2IDd0QYQaiME+X1Sg
         rXx8T33UeyFa8LWervC0xWHqXz+eP7y7vz4Y6T1sMt7dRzzNj0uqE1nMCdMv3vr3P9t6
         n6Vl6sU1vt21H5577FA2fCr6wOsd4cqZ2kTGd9KAKkYHY5tIX4BqdvcwPjUKA6POWUGb
         MvSfBa8fV9r75UPQOSE2KhxwUBjuyw01hVpsZIfdSXdA1FCZ1BG3vtO0ePaM6Za1ONZ1
         fPlA==
X-Gm-Message-State: APjAAAUJySgl1Rnbh4SR0+wa0+r7Uk0Wbl5VZN8nuZiLJEI6VbqV4cSb
	Yh+VL+o8XCj8QYkSNhUR27eIGfK58T+xxxs/hVowzrWNUnPaj/n1cb8IyAMltdl2oFBIM53OTdv
	XMXgnfWPED+OFK08uoNK669zgwlg4IL27MicnXZjkQQZNOzdiTlCWQknNSZvUiqjfBg==
X-Received: by 2002:a17:90a:29c5:: with SMTP id h63mr16083929pjd.83.1560612612466;
        Sat, 15 Jun 2019 08:30:12 -0700 (PDT)
X-Received: by 2002:a17:90a:29c5:: with SMTP id h63mr16083864pjd.83.1560612611420;
        Sat, 15 Jun 2019 08:30:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560612611; cv=none;
        d=google.com; s=arc-20160816;
        b=Zc0w5oCrOfwYWhEInOprNEIMpUpPR6daNVpeveLoOQ3mNE+O4w9DCPXSAoyv0am7Ld
         rDdJFoSU/ovUPvmRytF0d4+rYqI5SZ8ZLl8FK9ureu2d14lZg0FQsaluIGNPTap+9Ys7
         9ekozY67N/mHpR6QwIYBFnvlLzij4DQJlT3KWugfFR8jvol+ddKPw1xTdel7MTfUt53v
         SmLrB2aw1E64n5X0sTHB3hD8YVd4lGU8883SFzL0Fke0gwS1O8WjCu2+Lmhski6oFk6R
         7LOKslPOmTVTR5qFdpNKwOFV1ab9z0f1EG1tdRoHc1S2Eg4D5gKESjyMjfaR2DZEuM/T
         t8xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=/jcKk2/19vs459JoYUsaRTHxKiAzDVN8TgUMdkzJK98=;
        b=B1ueWkSDOqX8pxfc86IwMqIX+s3x05opX1Ix2T8Itm/NWDipyjGxKf7MST68z76Kb7
         TQolkju0vF9zIV29HFQxYnh9Zoj0eNho82wLrbi5DNRaRb2p4KY+oHDdXFEX8RZTzDF0
         hVif+au1shAhJg0tLy/kv1fUKHeQeezZ5UphOGl3V1yo55fX7eobwvNXwRUkGKdcfqxF
         HKDYWnGglDtn2uxvVWHuIxRQpX5qh8d97sXjoPI17OYRjlD/qO+SebHQKru6QvIjxpLW
         OmX4FViOg9gVDD3XSxgw/CXqYFj173jcStDSDA+5gWWyi4yoBCdCHkmhySnzBXL/w3Ph
         wsag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=L1UiC6nR;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e4sor7729430plk.30.2019.06.15.08.30.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 15 Jun 2019 08:30:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=L1UiC6nR;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=/jcKk2/19vs459JoYUsaRTHxKiAzDVN8TgUMdkzJK98=;
        b=L1UiC6nRuC3WJJyU4c429mSMn+pt8bbs3SLZ3/ixeDlvWes+s1uY9J4EILqskN4rXb
         fcFioaFdINs25jtQGQF5qZ2rz4p5MOv7Y/AYkenKBgA3ZKQ0mFZ+llpN/qByte1CrNMD
         c5cTCshV0XRXLeLNGARAUHukmOrufQ04fPKFD0HjybCZiZw/SImj09huQbCbm8aCrUMr
         TU5YUAeHmbjni7zoyDuZEyuUQoa3Qp3fG/qd+979UGnjN8hSVuXm/kcVhSlWZN4WAPU0
         fjyhF3NeYYZyQjjTCZ6u0skIxl3jWLS+jEUDnprxySkwYzDUXrg5LZMv4R2K14mjW4Hv
         MV+w==
X-Google-Smtp-Source: APXvYqxMtmluM9P/M5dWN/Lor2GlhEt5GnTEIv5uBTV8Q2z4c6iDoqESId4Kmw0F8ERpcyEBPtKqlg==
X-Received: by 2002:a17:902:ab83:: with SMTP id f3mr8554100plr.122.1560612610934;
        Sat, 15 Jun 2019 08:30:10 -0700 (PDT)
Received: from ?IPv6:2600:1010:b01c:6f69:f4c4:438f:f883:452a? ([2600:1010:b01c:6f69:f4c4:438f:f883:452a])
        by smtp.gmail.com with ESMTPSA id g8sm7859239pgd.29.2019.06.15.08.30.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jun 2019 08:30:09 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup function
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16F203)
In-Reply-To: <5d7012f6-7ab9-fd3d-4a11-294258e48fb5@intel.com>
Date: Sat, 15 Jun 2019 08:30:08 -0700
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>,
 Peter Zijlstra <peterz@infradead.org>, x86@kernel.org,
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
Message-Id: <E68459DD-53D3-42A6-B120-180203791E24@amacapital.net>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com> <7e0b97bf1fbe6ff20653a8e4e147c6285cc5552d.camel@intel.com>
 <25281DB3-FCE4-40C2-BADB-B3B05C5F8DD3@amacapital.net> <e26f7d09376740a5f7e8360fac4805488b2c0a4f.camel@intel.com>
 <3f19582d-78b1-5849-ffd0-53e8ca747c0d@intel.com> <5aa98999b1343f34828414b74261201886ec4591.camel@intel.com>
 <0665416d-9999-b394-df17-f2a5e1408130@intel.com> <5c8727dde9653402eea97bfdd030c479d1e8dd99.camel@intel.com>
 <ac9a20a6-170a-694e-beeb-605a17195034@intel.com> <328275c9b43c06809c9937c83d25126a6e3efcbd.camel@intel.com>
 <92e56b28-0cd4-e3f4-867b-639d9b98b86c@intel.com> <1b961c71d30e31ecb22da2c5401b1a81cb802d86.camel@intel.com>
 <ea5e333f-8cd6-8396-635f-a9dc580d5364@intel.com> <cf0d1470e95e0a8b88742651d06601a53d6655c1.camel@intel.com>
 <5ddf59e2-c701-3741-eaa1-f63ee741ea55@intel.com> <b5a915602020a6ce26ea1254f7f60e239c91bc9f.camel@intel.com>
 <598edca7-c36a-a236-3b72-08b2194eb609@intel.com> <359e6f64d646d5305c52f393db5296c469630d11.camel@intel.com>
 <5d7012f6-7ab9-fd3d-4a11-294258e48fb5@intel.com>
To: Dave Hansen <dave.hansen@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 14, 2019, at 3:06 PM, Dave Hansen <dave.hansen@intel.com> wrote:
>=20
>> On 6/14/19 2:34 PM, Yu-cheng Yu wrote:
>> On Fri, 2019-06-14 at 13:57 -0700, Dave Hansen wrote:
>>>> I have a related question:
>>>>=20
>>>> Do we allow the application to read the bitmap, or any fault from the
>>>> application on bitmap pages?
>>>=20
>>> We have to allow apps to read it.  Otherwise they can't execute
>>> instructions.
>>=20
>> What I meant was, if an app executes some legacy code that results in bit=
map
>> lookup, but the bitmap page is not yet populated, and if we then populate=
 that
>> page with all-zero, a #CP should follow.  So do we even populate that zer=
o page
>> at all?
>>=20
>> I think we should; a #CP is more obvious to the user at least.
>=20
> Please make an effort to un-Intel-ificate your messages as much as
> possible.  I'd really prefer that folks say "missing end branch fault"
> rather than #CP.  I had to Google "#CP".
>=20
> I *think* you are saying that:  The *only* lookups to this bitmap are on
> "missing end branch" conditions.  Normal, proper-functioning code
> execution that has ENDBR instructions in it will never even look at the
> bitmap.  The only case when we reference the bitmap locations is when
> the processor is about do do a "missing end branch fault" so that it can
> be suppressed.  Any population with the zero page would be done when
> code had already encountered a "missing end branch" condition, and
> populating with a zero-filled page will guarantee that a "missing end
> branch fault" will result.  You're arguing that we should just figure
> this out at fault time and not ever reach the "missing end branch fault"
> at all.
>=20
> Is that right?
>=20
> If so, that's an architecture subtlety that I missed until now and which
> went entirely unmentioned in the changelog and discussion up to this
> point.  Let's make sure that nobody else has to walk that path by
> improving our changelog, please.
>=20
> In any case, I don't think this is worth special-casing our zero-fill
> code, FWIW.  It's not performance critical and not worth the complexity.
> If apps want to handle the signals and abuse this to fill space up with
> boring page table contents, they're welcome to.  There are much easier
> ways to consume a lot of memory.

Isn=E2=80=99t it a special case either way?  Either we look at CR2 and popul=
ate a page, or we look at CR2 and the =E2=80=9Ctracker=E2=80=9D state and se=
nd a different signal.  Admittedly the former is very common in the kernel.

>=20
>>> We don't have to allow them to (popuating) fault on it.  But, if we
>>> don't, we need some kind of kernel interface to avoid the faults.
>>=20
>> The plan is:
>>=20
>> * Move STACK_TOP (and vdso) down to give space to the bitmap.
>=20
> Even for apps with 57-bit address spaces?
>=20
>> * Reserve the bitmap space from (mm->start_stack + PAGE_SIZE) to cover a c=
ode
>> size of TASK_SIZE_LOW, which is (TASK_SIZE_LOW / PAGE_SIZE / 8).
>=20
> The bitmap size is determined by CR4.LA57, not the app.  If you place
> the bitmap here, won't references to it for high addresses go into the
> high address space?
>=20
> Specifically, on a CR4.LA57=3D0 system, we have 48 bits of address space,
> so 128TB for apps.  You are proposing sticking the bitmap above the
> stack which is near the top of that 128TB address space.  But on a
> 5-level paging system with CR4.LA57=3D1, there could be valid data at
> 129GB.  Is there something keeping that data from being mistaken for
> being part of the bitmap?
>=20

I think we need to make the vma be full sized =E2=80=94 it should cover the e=
ntire range that the CPU might access. If that means it spans the 48-bit bou=
ndary, so be it.

> Also, if you're limiting it to TASK_SIZE_LOW, please don't forget that
> this is yet another thing that probably won't work with the vsyscall
> page.  Please make sure you consider it and mention it in your next post.

Why not?  The vsyscall page is at a negative address.

>=20
>> * Mmap the space only when the app issues the first mark-legacy prctl.  T=
his
>> avoids the core-dump issue for most apps and the accounting problem that
>> MAP_NORESERVE probably won't solve

What happens if there=E2=80=99s another VMA there by the time you map it?=

