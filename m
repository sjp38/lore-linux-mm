Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEB54C606C8
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:53:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57ECC2166E
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:53:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="uLTRVMnw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57ECC2166E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8A2C8E002D; Mon,  8 Jul 2019 13:53:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E3ACB8E0027; Mon,  8 Jul 2019 13:53:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D02698E002D; Mon,  8 Jul 2019 13:53:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id A6FB08E0027
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 13:53:48 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id f143so2142065oig.22
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 10:53:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=lXiKTKdJjWmmOzImQjobEzNMyxTZp+pVBtxXzpoWeww=;
        b=joG8GPuTuw/UxsSGgqLVDfz/BfeNUeD/IPC3yulpxYMB1le7TGuc770yoUiTcllQ5N
         Xb/MsYY5aWj5gkuu5sUU3hBvOrSoz2QHQzDthPUQk7bmmRlYTc81V4z/63Xc5jYZf7Pu
         qg1L2g1ArqGVGhJMNFiwr6EoCvWaQMMuMYY8Ts+eAUHBmRSm3gIcA4/Iu2Cz4nRgzmO0
         wUQLhuxr+qKh2u56aMTvRhzLNFpmDxAl8mEJqi0iCBpdU2H946+U7HmUXX3+nGOmqBPQ
         kvcSgUD1KpsjNbNcFPkLb7E7h2uPllkPZMusUHVT43rYYONxPK5R1n5IbQpSpaFWMJje
         0oTw==
X-Gm-Message-State: APjAAAXTEwtjsf0vI5PvYNxjL2wijp4atwXl+deZ0x5eeQVk1a7bzN+P
	4ZKTWzTaAmx6WvOnQXFqfdt6kbE+KGr+eZWUXqsRqNMRuqHJ9MEY5vnUdArlHLAdai4bnsQyc4+
	PfHFgPUyQ+6BkcC17uq745RgJBhYlZe6SiCdtoVD8Sr+zvD55IVlwqhNuEJMYnWpO9g==
X-Received: by 2002:a05:6830:160c:: with SMTP id g12mr15984070otr.231.1562608428355;
        Mon, 08 Jul 2019 10:53:48 -0700 (PDT)
X-Received: by 2002:a05:6830:160c:: with SMTP id g12mr15984030otr.231.1562608427548;
        Mon, 08 Jul 2019 10:53:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562608427; cv=none;
        d=google.com; s=arc-20160816;
        b=tI4v/FMy1NUrV/jPbOTifeh7+mWLpstNHvwH0AZ5nZuQGP9iAR5gQCTt0Bl0CstRAg
         +tGEBCJQ66J9mbODZYheJm4pPu4zXI4jH1hsDfALekCiGoHkcL8y42qUeqItKfqcpGRg
         Q9Wwvu6s60pJ4Uo8yCsKw8zF290yrdPZO0BoHbGE3ngTeRP8vBkLjJnVGYgGEsRnRR0y
         0ZoRrLdVSpr54utIfKQG5SO0VWCZ6BUGqj3itJBfzmcOEo3/qno1ZguK5+OoJBqVF4LI
         jzp2DJKGmGI0ArnDmCLpZBLDWHF6rTgb80ED1kL9OrqcOfW9DOCQlHtY3J5yQVpF1Vqj
         dYtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=lXiKTKdJjWmmOzImQjobEzNMyxTZp+pVBtxXzpoWeww=;
        b=bw9dIkVpNgD/K0cE6Siyk+EbOkgvFetymCl0uoA+m2aTaylXsc79tlxF8kHuuRbMGi
         Wa+UelR4Mg1nXAcse58U8GXEiLPczOUinBZ2iu6FIkipqdPQI4ngKaLhPNeZ5856+KWM
         VtVcSMLaZOVUaUhTQUy2fR/YlfFTgWZyCCtMIW2+iGUMWvLD2FXe84XihJ5GjHJdUqGf
         l7gUceqXFKjo7Ciy3rbqJHb/ZN8/jQp4rxla2D48iHgCzX8PzyWtNvv0Bf1QZyz/VGXY
         E/CWWO4kHgxAO4noRx8rOm+q0MgMgfZdO8hWCFxPiEi0GFQ6FYT3tg6kfg2eOl9N/GY+
         eAkw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=uLTRVMnw;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z15sor2335669oih.86.2019.07.08.10.53.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 10:53:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=uLTRVMnw;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=lXiKTKdJjWmmOzImQjobEzNMyxTZp+pVBtxXzpoWeww=;
        b=uLTRVMnwZk2CQeK9NsMFG1T9iWX1eSDoHS52IKhuMBtnYB3nQ3/1U2OgUyvsCPlk/Z
         EI8XXNstp3Csyaez2ROx4EOJlIGjd4tLOiG39IIH4zN0JAF0ASLPuPL1/W+mqBTpwnth
         zWRqS6ERIPoyrbh8jQQpFpKPRXnz/4aD5kdG9by96/LhODAMI6Mxk/AH2AqgurMlqdki
         nz7x8/yM0VDMkAU6LHEmZIVB4scPSyYernwK/ISAIid4JoI9iImKz+AlTdEnJ2IZFdPU
         xaAWERIrsE1QK0rzzOmLtVBOMYVgiW0mStrMsDaag2fIp7PmU5kJZRgN+vR6txaTd6Sa
         MR7A==
X-Google-Smtp-Source: APXvYqyRQs8Zurema9OPScys70HeRqXuIM5mRR8jYgjiMjLpGk6uWmJ4fTXAwl6qAFTgqVuGEPjL1g==
X-Received: by 2002:aca:5a04:: with SMTP id o4mr10598811oib.36.1562608427065;
        Mon, 08 Jul 2019 10:53:47 -0700 (PDT)
Received: from ?IPv6:2600:100e:b04d:1b:ad89:e9a5:8c48:d7f4? ([2600:100e:b04d:1b:ad89:e9a5:8c48:d7f4])
        by smtp.gmail.com with ESMTPSA id 103sm6061298otu.33.2019.07.08.10.53.45
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 10:53:46 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 2/2] x86/numa: instance all parsed numa node
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16F203)
In-Reply-To: <alpine.DEB.2.21.1907081125300.3648@nanos.tec.linutronix.de>
Date: Mon, 8 Jul 2019 11:53:30 -0600
Cc: Pingfan Liu <kernelfans@gmail.com>, x86@kernel.org,
 Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>,
 Mike Rapoport <rppt@linux.ibm.com>, Tony Luck <tony.luck@intel.com>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 "H. Peter Anvin" <hpa@zytor.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>,
 Pavel Tatashin <pavel.tatashin@microsoft.com>,
 Mel Gorman <mgorman@techsingularity.net>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Michael Ellerman <mpe@ellerman.id.au>,
 Stephen Rothwell <sfr@canb.auug.org.au>, Qian Cai <cai@lca.pw>,
 Barret Rhoden <brho@google.com>, Bjorn Helgaas <bhelgaas@google.com>,
 David Rientjes <rientjes@google.com>, linux-mm@kvack.org,
 LKML <linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <18D4CC9F-BC2C-4C82-873E-364CD1795EFB@amacapital.net>
References: <1562300143-11671-1-git-send-email-kernelfans@gmail.com> <1562300143-11671-2-git-send-email-kernelfans@gmail.com> <alpine.DEB.2.21.1907072133310.3648@nanos.tec.linutronix.de> <CAFgQCTvwS+yEkAmCJnsCfnr0JS01OFtBnDg4cr41_GqU79A4Gg@mail.gmail.com> <alpine.DEB.2.21.1907081125300.3648@nanos.tec.linutronix.de>
To: Thomas Gleixner <tglx@linutronix.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jul 8, 2019, at 3:35 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
>=20
>> On Mon, 8 Jul 2019, Pingfan Liu wrote:
>>> On Mon, Jul 8, 2019 at 3:44 AM Thomas Gleixner <tglx@linutronix.de> wrot=
e:
>>>=20
>>>> On Fri, 5 Jul 2019, Pingfan Liu wrote:
>>>>=20
>>>> I hit a bug on an AMD machine, with kexec -l nr_cpus=3D4 option. nr_cpu=
s option
>>>> is used to speed up kdump process, so it is not a rare case.
>>>=20
>>> But fundamentally wrong, really.
>>>=20
>>> The rest of the CPUs are in a half baken state and any broadcast event,
>>> e.g. MCE or a stray IPI, will result in a undiagnosable crash.
>> Very appreciate if you can pay more word on it? I tried to figure out
>> your point, but fail.
>>=20
>> For "a half baked state", I think you concern about LAPIC state, and I
>> expand this point like the following:
>=20
> It's not only the APIC state. It's the state of the CPUs in general.
>=20
>> For IPI: when capture kernel BSP is up, the rest cpus are still loop
>> inside crash_nmi_callback(), so there is no way to eject new IPI from
>> these cpu. Also we disable_local_APIC(), which effectively prevent the
>> LAPIC from responding to IPI, except NMI/INIT/SIPI, which will not
>> occur in crash case.
>=20
> Fair enough for the IPI case.
>=20
>> For MCE, I am not sure whether it can broadcast or not between cpus,
>> but as my understanding, it can not. Then is it a problem?
>=20
> It can and it does.
>=20
> That's the whole point why we bring up all CPUs in the 'nosmt' case and
> shut the siblings down again after setting CR4.MCE. Actually that's in fac=
t
> a 'let's hope no MCE hits before that happened' approach, but that's all w=
e
> can do.
>=20
> If we don't do that then the MCE broadcast can hit a CPU which has some
> firmware initialized state. The result can be a full system lockup, triple=

> fault etc.
>=20
> So when the MCE hits a CPU which is still in the crashed kernel lala state=
,
> then all hell breaks lose.
>=20
>> =46rom another view point, is there any difference between nr_cpus=3D1 an=
d
>> nr_cpus> 1 in crashing case? If stray IPI raises issue to nr_cpus>1,
>> it does for nr_cpus=3D1.
>=20
> Anything less than the actual number of present CPUs is problematic except=

> you use the 'let's hope nothing happens' approach. We could add an option
> to stop the bringup at the early online state similar to what we do for
> 'nosmt'.
>=20
>=20

How about we change nr_cpus to do that instead so we never have to have this=
 conversation again?

