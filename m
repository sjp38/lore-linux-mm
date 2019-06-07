Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C34DBC468BC
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:46:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78AE2208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:46:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="VWI7VCl5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78AE2208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 272206B026F; Fri,  7 Jun 2019 16:46:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 224026B0270; Fri,  7 Jun 2019 16:46:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0EAD56B0271; Fri,  7 Jun 2019 16:46:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id CDDB26B026F
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 16:46:54 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d7so2280236pfq.15
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 13:46:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:content-transfer-encoding:from
         :mime-version:subject:date:message-id:references:cc:in-reply-to:to;
        bh=XukHmQruicw8IlfF6jJ6jVCYF0PSAeCd61ALsjzTSpY=;
        b=sfZLskkWUma5Al1o8RFbznhFwl5qAppWRyv3ZqMoHDK0etISmvLVzZu30PO0y/HZr5
         MTpb99mqOawrtChAIg7g523eUtgcbj/RP/N0ZJvKYgL4OFFT3zvd3drS1/FqVnUIzAKd
         1N/fhYxqT22pLWAG9rwUm5ssk3GFCTpLnKVbPiE0twUd4+kv4w/DpcCjGemDhSbT3WN/
         /pdYtPd9BSTRVNMo1O1h392/4+5PDMd0Bknct2WsMzQCTL86VC32tIxo3kut66ulp1U0
         iuuAD3coJA/YV87rS98Ju99hJ0zy0mQKbkpjz4w4RAJ1TlT3SsKx72xPu2WPftW1Iap2
         GMYQ==
X-Gm-Message-State: APjAAAXqsolLqFXdO14JVtWCJXyrJgUDOchQb5gcA6X5brp8eGMOpVI3
	HQ6JZVASY7bJKTEBqG1XmzR+BnQOSivz1z0GgnuzGQX053ZjK27gRSsv+/1yQ5KL1m08EAUQkKF
	KfIytkQt8eqAFERLpRRN4Wp+jItifUHTR0HQ5PBUHJ6Q68vRRRSgLn7K+TwZyovp89A==
X-Received: by 2002:a17:902:8609:: with SMTP id f9mr54065303plo.252.1559940414433;
        Fri, 07 Jun 2019 13:46:54 -0700 (PDT)
X-Received: by 2002:a17:902:8609:: with SMTP id f9mr54065278plo.252.1559940413652;
        Fri, 07 Jun 2019 13:46:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559940413; cv=none;
        d=google.com; s=arc-20160816;
        b=OSN2D3I5GEUgtC6V8MSNu6DK+P1n593df7RErnVbYnFl2nQrKEQta087qk7T9vQkBG
         tO2Hs5H6uzD7O06azmFp/ZOOt1Gze2LN3s2Eo0xF5908TmnulfymT1KYEceuehXz8/rB
         p/lQjGu5rwI/do7pxHfBP4biZ2TOpGTO6mRS/QkFe4puOTcvmWv/zVkhEEZPIjMAXFfP
         EQkQhT5Lvzc8BcBJlmsg3M/CfOoqSj4mHs0Jhifzq41oekCbP2vp6vXPF5m2Lh70sX9d
         8raIvWxSmq1XeMHObuN0KnDlpQzzHnS7hXuuZDDEcMMNh6C9hjcqxLy80j/NudzmNyNK
         QbYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:in-reply-to:cc:references:message-id:date:subject:mime-version
         :from:content-transfer-encoding:dkim-signature;
        bh=XukHmQruicw8IlfF6jJ6jVCYF0PSAeCd61ALsjzTSpY=;
        b=Y2Az8Ig44H2YCxfwnCyG3XKIZsE3naef6YhT4y7nraFOW1JOQmRMO2kBfCpBOKm/6S
         yLDmqU0K23nUgL7Y8ytPeQBT9GLBGIi3KswfDBwr/6lHEb731FeoHuukAmRpDOzlLgeu
         +K7s9BoBpSBb/uCeAUm24fMuN9aJLNmDR2qAhP6Zzj1qDPmin+IoIJ5kYNg/+ZN1qDC/
         Xeld+niS21yG1lZ4Ryy6vuwj2+OwJMiEY+793JfDec4COUMzsFwpJEq5jLBLnsf8DNGN
         ZcF4lCxd9AjU39UzNHRZeI613ADhJbmzYGH36EgETafvGtzg8AR/KMLjeAEbw8b5/58n
         7v1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=VWI7VCl5;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a19sor3197197pfn.54.2019.06.07.13.46.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 13:46:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=VWI7VCl5;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=content-transfer-encoding:from:mime-version:subject:date:message-id
         :references:cc:in-reply-to:to;
        bh=XukHmQruicw8IlfF6jJ6jVCYF0PSAeCd61ALsjzTSpY=;
        b=VWI7VCl5285LdP7wOr87pA6+IQYIq/ZxhBxJbF1/nckLiWb00yMLQlkMSFh4MCmFIq
         /dqJBvYXqKj4YcUgfT3KURvRXmso7VPKa0tgm8V0RDBhXkf0XYt6MYFS8iutMKKpfXs1
         J2m1rqQfTl0vttXXt7TvR91asPuMao/Avd04hxQKWY3DGbO6e9kqdOSNRzrBeSbR421E
         Rf9Al37d+zkA1bJ2NtyUgJkERotLKfbY8cpTiNFxW3h5PvRE0rml/0f46+ey+IgUyxqM
         XOCqZ7ORzhd+wlc9aCrEgSryqbXOT4+W665Z56TP/EMr2yUjbSDUZKj9n9UphV69nzc1
         Elxw==
X-Google-Smtp-Source: APXvYqxhFk60QtRVzTldpmH+7yv8QONLVQH+CovTP9/QHWOvUlZZE4M5xtzQoodB8aOtHfr02eU7Pw==
X-Received: by 2002:aa7:808d:: with SMTP id v13mr60783415pff.198.1559940413359;
        Fri, 07 Jun 2019 13:46:53 -0700 (PDT)
Received: from ?IPv6:2600:1012:b018:c314:403f:c95d:60d3:b732? ([2600:1012:b018:c314:403f:c95d:60d3:b732])
        by smtp.gmail.com with ESMTPSA id 14sm3068901pgp.37.2019.06.07.13.46.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 13:46:52 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
From: Andy Lutomirski <luto@amacapital.net>
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup function
Date: Fri, 7 Jun 2019 13:43:15 -0700
Message-Id: <25281DB3-FCE4-40C2-BADB-B3B05C5F8DD3@amacapital.net>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com> <20190606200926.4029-4-yu-cheng.yu@intel.com> <20190607080832.GT3419@hirez.programming.kicks-ass.net> <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com> <20190607174336.GM3436@hirez.programming.kicks-ass.net> <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com> <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net> <7e0b97bf1fbe6ff20653a8e4e147c6285cc5552d.camel@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>,
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
In-Reply-To: <7e0b97bf1fbe6ff20653a8e4e147c6285cc5552d.camel@intel.com>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
X-Mailer: iPhone Mail (16F203)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 7, 2019, at 12:49 PM, Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>=20
> On Fri, 2019-06-07 at 11:29 -0700, Andy Lutomirski wrote:
>>> On Jun 7, 2019, at 10:59 AM, Dave Hansen <dave.hansen@intel.com> wrote:
>>>=20
>>>> On 6/7/19 10:43 AM, Peter Zijlstra wrote:
>>>> I've no idea what the kernel should do; since you failed to answer the
>>>> question what happens when you point this to garbage.
>>>>=20
>>>> Does it then fault or what?
>>>=20
>>> Yeah, I think you'll fault with a rather mysterious CR2 value since
>>> you'll go look at the instruction that faulted and not see any
>>> references to the CR2 value.
>>>=20
>>> I think this new MSR probably needs to get included in oops output when
>>> CET is enabled.
>>=20
>> This shouldn=E2=80=99t be able to OOPS because it only happens at CPL 3, r=
ight?  We
>> should put it into core dumps, though.
>>=20
>>>=20
>>> Why don't we require that a VMA be in place for the entire bitmap?
>>> Don't we need a "get" prctl function too in case something like a JIT is=

>>> running and needs to find the location of this bitmap to set bits itself=
?
>>>=20
>>> Or, do we just go whole-hog and have the kernel manage the bitmap
>>> itself. Our interface here could be:
>>>=20
>>>   prctl(PR_MARK_CODE_AS_LEGACY, start, size);
>>>=20
>>> and then have the kernel allocate and set the bitmap for those code
>>> locations.
>>=20
>> Given that the format depends on the VA size, this might be a good idea. =
 I
>> bet we can reuse the special mapping infrastructure for this =E2=80=94 th=
e VMA could
>> be a MAP_PRIVATE special mapping named [cet_legacy_bitmap] or similar, an=
d we
>> can even make special rules to core dump it intelligently if needed.  And=
 we
>> can make mremap() on it work correctly if anyone (CRIU?) cares.
>>=20
>> Hmm.  Can we be creative and skip populating it with zeros?  The CPU shou=
ld
>> only ever touch a page if we miss an ENDBR on it, so, in normal operation=
, we
>> don=E2=80=99t need anything to be there.  We could try to prevent anyone f=
rom
>> *reading* it outside of ENDBR tracking if we want to avoid people acciden=
tally
>> wasting lots of memory by forcing it to be fully populated when the read i=
t.
>>=20
>> The one downside is this forces it to be per-mm, but that seems like a
>> generally reasonable model anyway.
>>=20
>> This also gives us an excellent opportunity to make it read-only as seen f=
rom
>> userspace to prevent exploits from just poking it full of ones before
>> redirecting execution.
>=20
> GLIBC sets bits only for legacy code, and then makes the bitmap read-only.=
  That
> avoids most issues:

How does glibc know the linear address space size?  We don=E2=80=99t want LA=
64 to break old binaries because the address calculation changed.

