Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AFA2C04AB7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:55:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 183AC20881
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:55:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="Sqp9nGAl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 183AC20881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A93406B0008; Tue, 14 May 2019 17:55:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1C3B6B000A; Tue, 14 May 2019 17:55:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90BD26B000C; Tue, 14 May 2019 17:55:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 544536B0008
	for <linux-mm@kvack.org>; Tue, 14 May 2019 17:55:22 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id g11so375134plt.23
        for <linux-mm@kvack.org>; Tue, 14 May 2019 14:55:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=zGsQ7lgpHhpTbszYslBdzxyDCXSizX6+VVJQr1o6b6I=;
        b=j4OV58iTblssdL+tevHxRrKEZALEi3xL36tie2vDaIzRrufuUEPd4LIwTnY5GVS7wo
         x5Ify1STnyjyWgqbCjX5pxwtlGYieEbuomKJB6lV/Kl2e/RCozhmDT24a9hQEedpSMWS
         BoKvmtrtV0L36+wBqLsyLAnio0qAL3CAvOMfBw6Lcn3Z/MSNR3xHx4ErmwrgdCnMwxPg
         hj7hZZTNRM6nwFNKxzCNeKRco04hH5/gxnrTXYC/QFGjpddewtcOSknwEe1JVBRNuz9O
         cT5aXmJI9U08LQeJMBVsgl/0UwnpiDSb0z6B6YbY7YP/7QWFo4wN/4wl6UkDbGiz8HWg
         af+w==
X-Gm-Message-State: APjAAAW9vbULjK9/ytUYXqNQPeyHdtr52J98+7F/oAOdoSQcPeoM3eEr
	H0vphRrMySetSqIuE1tndm/WJIL3tr3RTBSzQtMjqd0yJBXcIjjTX3DAv9ItbTGWprTSeo0kzUl
	LDktAeis1y2o0kpK4NrwxO7JoY2R28cA+st1NMZ1pPB87XXG2DXEgNufugajMXqRYnA==
X-Received: by 2002:a63:4a66:: with SMTP id j38mr21347947pgl.199.1557870921995;
        Tue, 14 May 2019 14:55:21 -0700 (PDT)
X-Received: by 2002:a63:4a66:: with SMTP id j38mr21347902pgl.199.1557870921241;
        Tue, 14 May 2019 14:55:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557870921; cv=none;
        d=google.com; s=arc-20160816;
        b=nHdQ/fSxmVBrgYUTsQwc6KJ4+GaQG20IzhbIXY/ErZjuPzwgeiKHY4vzFUzFxJn9GK
         S0Y5IgSRZj6gEVvAbYIVP5/NisR3bFWZM9tHhAFLhL7zkCvwL4/o8ryMf6ZDwolRTlnx
         LwNlrZglsEtIMAJSAUecjuTL1JYXuVNKbShEJrD0u+D1k5pGYTHH0STTsV9z7MvfksfC
         W/wmXKnrTwRQtJUHEASF2/0YjexNTynLrfh30GNDYM3WxS+qzml52xzTfUSTO3rFoHJL
         K3FGVv75SCmdDF/yr//WFAEanA59PgQZoP7SaoCsPXVNb/iT6lllBcict4ynPbq08+8x
         fZvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=zGsQ7lgpHhpTbszYslBdzxyDCXSizX6+VVJQr1o6b6I=;
        b=p+gFbPNMGcWBJxyJ9cs4KbLPqMDJqG7zepQQ30qTbtgWxpZ5rjeWg/RjwEh7ST/vrW
         zio0z0UVJvJtC+xRO33s4KRAsWzbbbS4kJUNYA0bt0bQNfnpCTfK1az+55gW/voyQjBT
         zHNsWPHZTLME06fL+bVupKQXNmnTzrQ89SHR4qwXS4qcBbARUGNmVAXmJEFJPMe/PsTq
         uqa5Lo5bLw2cN/8htj1KZ+V1p2dQxS/KuPXcBUiEQPwPjXbDx/0Cipu/ayn+ULHZdLP3
         m7Yk5d7rkNllSE7VxdxAbCA+aaG8uVU27MYjVWYewFHjx8VCewXzPn5/kyLoRjQ1X+TM
         h4hA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=Sqp9nGAl;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y31sor13642pgk.29.2019.05.14.14.55.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 14:55:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=Sqp9nGAl;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=zGsQ7lgpHhpTbszYslBdzxyDCXSizX6+VVJQr1o6b6I=;
        b=Sqp9nGAlWQZ5vX1dxWHDTDuxZAQ8qZWMKHz3Jl8zJhU4HCd4U5LRW6+WrNk+FFVT4m
         hghwxry4xwaDl/HQX8VpDYEsXxjpIc+C5kovvhxiwYCqXTRQef29CxCNWFm1bW5znOQt
         K7SZARGMC8Rt7RfHAn3RpY8sM6daSCeeLH7swaooopzfa3ObMdZ6EWj/nj1LpViuniyi
         4bbhnkKWhoastGyfdBE/DJkoP1Rh8R0rld6KSf2YfFl4gdmjFXNecFeWf9TzQuYX9kSC
         yl5u8Qe4FV0TiiOwcMABkeTC1I2KGOOO/tJlPkFrFplmiajsczCkdhcwsEb9HLfHGJbp
         bZGw==
X-Google-Smtp-Source: APXvYqw24l2gqEGsaEZKg5LYXhvlKPM4W+qe2urWfGhhgYhWFa149ACdSpb4zow/e83hwlMY5jdZGg==
X-Received: by 2002:a63:2bc8:: with SMTP id r191mr39777166pgr.72.1557870920728;
        Tue, 14 May 2019 14:55:20 -0700 (PDT)
Received: from ?IPv6:2601:646:c200:1ef2:bde9:fbad:7d91:52eb? ([2601:646:c200:1ef2:bde9:fbad:7d91:52eb])
        by smtp.gmail.com with ESMTPSA id d15sm116637pfm.186.2019.05.14.14.55.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 14:55:19 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC KVM 18/27] kvm/isolation: function to copy page table entries for percpu buffer
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16E227)
In-Reply-To: <20190514210603.GD1977@linux.intel.com>
Date: Tue, 14 May 2019 14:55:18 -0700
Cc: Andy Lutomirski <luto@kernel.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Alexandre Chartre <alexandre.chartre@oracle.com>,
 Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, kvm list <kvm@vger.kernel.org>,
 X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, jan.setjeeilers@oracle.com,
 Liran Alon <liran.alon@oracle.com>, Jonathan Adams <jwadams@google.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <A1EB80C0-2D88-4DC0-A898-3BED50A4F5A8@amacapital.net>
References: <CALCETrWUKZv=wdcnYjLrHDakamMBrJv48wp2XBxZsEmzuearRQ@mail.gmail.com> <20190514070941.GE2589@hirez.programming.kicks-ass.net> <b8487de1-83a8-2761-f4a6-26c583eba083@oracle.com> <B447B6E8-8CEF-46FF-9967-DFB2E00E55DB@amacapital.net> <4e7d52d7-d4d2-3008-b967-c40676ed15d2@oracle.com> <CALCETrXtwksWniEjiWKgZWZAyYLDipuq+sQ449OvDKehJ3D-fg@mail.gmail.com> <e5fedad9-4607-0aa4-297e-398c0e34ae2b@oracle.com> <20190514170522.GW2623@hirez.programming.kicks-ass.net> <20190514180936.GA1977@linux.intel.com> <CALCETrVzbBLokip5n0KEyG6irH6aoEWqyNODTy8embpXhB1GQg@mail.gmail.com> <20190514210603.GD1977@linux.intel.com>
To: Sean Christopherson <sean.j.christopherson@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On May 14, 2019, at 2:06 PM, Sean Christopherson <sean.j.christopherson@in=
tel.com> wrote:
>=20
>> On Tue, May 14, 2019 at 01:33:21PM -0700, Andy Lutomirski wrote:
>> On Tue, May 14, 2019 at 11:09 AM Sean Christopherson
>> <sean.j.christopherson@intel.com> wrote:
>>> For IRQs it's somewhat feasible, but not for NMIs since NMIs are unblock=
ed
>>> on VMX immediately after VM-Exit, i.e. there's no way to prevent an NMI
>>> from occuring while KVM's page tables are loaded.
>>>=20
>>> Back to Andy's question about enabling IRQs, the answer is "it depends".=

>>> Exits due to INTR, NMI and #MC are considered high priority and are
>>> serviced before re-enabling IRQs and preemption[1].  All other exits are=

>>> handled after IRQs and preemption are re-enabled.
>>>=20
>>> A decent number of exit handlers are quite short, e.g. CPUID, most RDMSR=

>>> and WRMSR, any event-related exit, etc...  But many exit handlers requir=
e
>>> significantly longer flows, e.g. EPT violations (page faults) and anythi=
ng
>>> that requires extensive emulation, e.g. nested VMX.  In short, leaving
>>> IRQs disabled across all exits is not practical.
>>>=20
>>> Before going down the path of figuring out how to handle the corner case=
s
>>> regarding kvm_mm, I think it makes sense to pinpoint exactly what exits
>>> are a) in the hot path for the use case (configuration) and b) can be
>>> handled fast enough that they can run with IRQs disabled.  Generating th=
at
>>> list might allow us to tightly bound the contents of kvm_mm and sidestep=

>>> many of the corner cases, i.e. select VM-Exits are handle with IRQs
>>> disabled using KVM's mm, while "slow" VM-Exits go through the full conte=
xt
>>> switch.
>>=20
>> I suspect that the context switch is a bit of a red herring.  A
>> PCID-don't-flush CR3 write is IIRC under 300 cycles.  Sure, it's slow,
>> but it's probably minor compared to the full cost of the vm exit.  The
>> pain point is kicking the sibling thread.
>=20
> Speaking of PCIDs, a separate mm for KVM would mean consuming another
> ASID, which isn't good.

I=E2=80=99m not sure we care. We have many logical address spaces (two per m=
m plus a few more).  We have 4096 PCIDs, but we only use ten or so.  And we h=
ave some undocumented number of *physical* ASIDs with some undocumented mech=
anism by which PCID maps to a physical ASID.

I don=E2=80=99t suppose you know how many physical ASIDs we have?  And how i=
t interacts with the VPID stuff?

