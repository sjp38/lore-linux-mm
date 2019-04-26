Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFB3DC43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 15:07:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B7E620675
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 15:07:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="lL2n9vt8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B7E620675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EEDFC6B0005; Fri, 26 Apr 2019 11:07:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E75C76B000C; Fri, 26 Apr 2019 11:07:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D15916B000D; Fri, 26 Apr 2019 11:07:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 93F506B0005
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 11:07:31 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e14so2244556pgg.12
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 08:07:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=IiTlllJV7T8Ybav7NUjeUyZVUhhnS7kZRU1PPhbGkJM=;
        b=jtvQg9980EJoXXZ0TmOn2H4bIOW74yLFD3pKMmqbZkrB5Djm25FzoQ4PTSnuAYgw0O
         sIIqVICIyZSqXyfFywPGSFIGJeXj16fzco7UzQpwh2QrSAn00CEG2Dldh7nuFUoCK+B/
         xXLcKbJxi1SxK0/VTmCTJM3J5vo4OebQ6h+1+3EGITGcEcq6xBFJ8eKbQT7FsAaEoYrL
         ZmiSBlAVLDqdD8fe7FE6U+xDz0fCx+YDkkjGSgvKp83+SvwvbUlL3HF+ypNCCBENZckH
         Ok/TGGEowXw+SosuKKtKomWe2UP0QkfthNeGVlYuSfknLHVdIO7ftKqMVljYbQxhEE6k
         q2FQ==
X-Gm-Message-State: APjAAAWLm7QzQRlPY6AdVmn2d0p3vmnIGd7n+GI3nwj6qZl55/yTLK+d
	LN1t4U2rgDkYIatkDrxZ8BOI6IukIz/bToa0bYixbdhz8PPa7Ur1AiAt/et68MKqztrX0Vig/Nc
	f5FJdWZRmg83pl04HrFVelqvMWa94A9Ad+4Gv9aI3xzVX/ZhI/I92ZuW9R1cbAQsFIQ==
X-Received: by 2002:a62:70c6:: with SMTP id l189mr47596490pfc.139.1556291250956;
        Fri, 26 Apr 2019 08:07:30 -0700 (PDT)
X-Received: by 2002:a62:70c6:: with SMTP id l189mr47596409pfc.139.1556291250129;
        Fri, 26 Apr 2019 08:07:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556291250; cv=none;
        d=google.com; s=arc-20160816;
        b=OsmS2aWOqQufJv6rKCSImBMnTYMdCeSFhk1Z5Bqku9xzxqnMY+EROQ1q/j4SBIhr9l
         y6fUPrOzpjSKtqIC6aGjyiYFcnY1Z+NW3D/xLBRF23+giLSsBD4VQtUXv26JHZOqiWn7
         PHEY3Dkn0d1pYJx8Eptle3pvt5ETRoz90y/b0RB1hPwUQKatobvFCi5NmnHkGgpQxwif
         dZTCK1zTec8uKjHrUd8zspnhqLBlXFWp1yBvHXzudo2zJPPdhdIWV0tYNkE8QU/OYsJK
         FKNACzZsqKJDziAu+3GGeLsgEBzDIfSf4eXbOD3tgcAdpYJmuitUJUg+fdsMnaTppgW8
         W6Jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=IiTlllJV7T8Ybav7NUjeUyZVUhhnS7kZRU1PPhbGkJM=;
        b=sywySr9UG7xkjBh9HKd6gwxEHoZlquCI+84t6O5qwMGuAc+5GH7A2pE+pyI+VE/Uq0
         tMFhmarlVU3eVDshOlPDJCDf/SPRI4RPGdCYF6wWWSaWy7HdrlLz8fiyhPrC/7gXXAYy
         C1IgDbYNowaBYV0VgQEG6mqxoBmPD4ZsXNCK3rJJN0v0GwWp1oInfoaktayGfz7kiNuf
         7fNK+MqJYd1AovewFPDtBo20SkS7JEy0EIo/cixO735dqlLdk+NQfKIHbKx2vdr0rioc
         pPPoiEziDjMF+HhBydeFR5dzRmF9z7vfpjvr1+SIblQ0uL1fyxjb51jbif462Bw2OjeT
         HlTA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=lL2n9vt8;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w5sor24908418plq.1.2019.04.26.08.07.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 08:07:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=lL2n9vt8;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=IiTlllJV7T8Ybav7NUjeUyZVUhhnS7kZRU1PPhbGkJM=;
        b=lL2n9vt8GnIPUDFoTEJvf33Y5pQF3uo+rWu5qEgbH4HLxkSLx9jcc9TgyzRHksCYAj
         fmqBt8KcPRhmOtkK37ubeAfoG6y85dhMIr00G8/l5QKNCrHl+uAHYqZa3tqrKJGN/hNF
         zMa3B964tLPhi0oSvuAu+2gT3es4gkyza8ZHVSBXBM3/lziiDPPsEq1fEoXGTlrl9ymn
         HW+jVq0eHkWEj5PWkmH+nzUBebi0aQ1DIrGkI35HSVEbH8s6MoxMjQlUwrNbge+pBTwd
         EISfz9afMMiyAm8SlpyJVhLYaLgXSI/p17RwVC/21KPAGuwHhTZG4PtV9zb52apojoWM
         ss8A==
X-Google-Smtp-Source: APXvYqxw6s47f9ZtAEqXzz4CE/DWzlsYAbZ43O38HXxSazAc+xuzWMJmNzZfd0ZmQluLX4nGUmluqQ==
X-Received: by 2002:a17:902:7b8e:: with SMTP id w14mr28880635pll.202.1556291249630;
        Fri, 26 Apr 2019 08:07:29 -0700 (PDT)
Received: from ?IPv6:2601:646:c200:1ef2:dd4b:950:9d5a:d566? ([2601:646:c200:1ef2:dd4b:950:9d5a:d566])
        by smtp.gmail.com with ESMTPSA id l15sm11072795pgb.71.2019.04.26.08.07.28
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 08:07:28 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC PATCH 2/7] x86/sci: add core implementation for system call isolation
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16E227)
In-Reply-To: <1556290658.2833.28.camel@HansenPartnership.com>
Date: Fri, 26 Apr 2019 08:07:27 -0700
Cc: Dave Hansen <dave.hansen@intel.com>,
 Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
 Alexandre Chartre <alexandre.chartre@oracle.com>,
 Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
 Jonathan Adams <jwadams@google.com>, Kees Cook <keescook@chromium.org>,
 Paul Turner <pjt@google.com>, Peter Zijlstra <peterz@infradead.org>,
 Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org,
 linux-security-module@vger.kernel.org, x86@kernel.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <54090243-E4C7-4C66-8025-AFE0DF5DF337@amacapital.net>
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com> <1556228754-12996-3-git-send-email-rppt@linux.ibm.com> <627d9321-466f-c4ed-c658-6b8567648dc6@intel.com> <1556290658.2833.28.camel@HansenPartnership.com>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Apr 26, 2019, at 7:57 AM, James Bottomley <James.Bottomley@hansenpartne=
rship.com> wrote:
>=20
>> On Fri, 2019-04-26 at 07:46 -0700, Dave Hansen wrote:
>>> On 4/25/19 2:45 PM, Mike Rapoport wrote:
>>> After the isolated system call finishes, the mappings created
>>> during its execution are cleared.
>>=20
>> Yikes.  I guess that stops someone from calling write() a bunch of
>> times on every filesystem using every block device driver and all the
>> DM code to get a lot of code/data faulted in.  But, it also means not
>> even long-running processes will ever have a chance of behaving
>> anything close to normally.
>>=20
>> Is this something you think can be rectified or is there something
>> fundamental that would keep SCI page tables from being cached across
>> different invocations of the same syscall?
>=20
> There is some work being done to look at pre-populating the isolated
> address space with the expected execution footprint of the system call,
> yes.  It lessens the ROP gadget protection slightly because you might
> find a gadget in the pre-populated code, but it solves a lot of the
> overhead problem.
>=20

I=E2=80=99m not even remotely a ROP expert, but: what stops a ROP payload fr=
om using all the =E2=80=9Cfault-in=E2=80=9D gadgets that exist =E2=80=94 any=
 function that can return on an error without doing to much will fault in th=
e whole page containing the function.

To improve this, we would want some thing that would try to check whether th=
e caller is actually supposed to call the callee, which is more or less the h=
ard part of CFI.  So can=E2=80=99t we just do CFI and call it a day?

On top of that, a robust, maintainable implementation of this thing seems ve=
ry complicated =E2=80=94 for example, what happens if vfree() gets called?

