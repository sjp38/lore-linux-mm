Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEEF2C73C41
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 13:34:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57F382080C
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 13:34:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="WCdvs4TX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57F382080C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B89C68E004F; Tue,  9 Jul 2019 09:34:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3A358E0032; Tue,  9 Jul 2019 09:34:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A29218E004F; Tue,  9 Jul 2019 09:34:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 84C058E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 09:34:12 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id h3so23113180iob.20
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 06:34:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=qhZ9K+aj4bVR1kRvCDHu8fuOy09gt6Svugsy5dV+WVg=;
        b=rXx83HSM+2bbRJpY4SnujROHsKWeFGnaXcKqah1lvIvj4zqvNNR1ZIJ8fSolHRwggT
         couBqVY7o8I1U8lgkoLbG97QT2GmOGtWLtGv+4lwmPGMiFbfqwzz/tCzKRJWafpZILhX
         tf7dF8fiAT4LeRY/WClXVIBOJV7ZRHHozwTeniu1QRme6HWx03NU8VCvQ4V9tEKfa6RB
         lM8TEVOd0Ry0XMZXfBUQnu1pl6OgaFNuUGWAvLGnCmV7Y0EosCp7vBZJfdGtA763IqjD
         W9bumvo9QIb87PQFHzzrT5Jqd6A7CyixRlqvLCrBFz0qnDmZ3SCVzE1jR20fRZbVLAMa
         71Xw==
X-Gm-Message-State: APjAAAWqwqt+qEwMRyFnw46x9e+AxF/N1uv6Q/GZUAfo5y/Yy8EhxnTK
	P+M/kroBQj4dQWszaP0KWeOXDwxPi8fwLAKuzYNFp11TVoqxMmPtxbnc1F5YdqE4W49ovhU5bo7
	hRN+IIfR8XRS4iANqLcIqu+oiIbMWIRx+HW49HEf/2bCcpothwdmQ4x+LS0j7R8tOgg==
X-Received: by 2002:a5d:9550:: with SMTP id a16mr9100393ios.106.1562679252235;
        Tue, 09 Jul 2019 06:34:12 -0700 (PDT)
X-Received: by 2002:a5d:9550:: with SMTP id a16mr9100291ios.106.1562679251097;
        Tue, 09 Jul 2019 06:34:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562679251; cv=none;
        d=google.com; s=arc-20160816;
        b=B+IUuY/SWnbuX4WKXAFG9FSGWabUTmPIURXkUzp2zOCnBtGOMfD6TKZ0bXn0VZ/aaT
         +NxExeBDiUtZPZ972oFJ3C39eB47jIyj9uw1tCVbkbE0GkaGoMac0pmN26U0UM5yGwIj
         I+oGyMxYb3OiK1ljGvIATz86o3EPAelTyg51HGVzKQSDOitYZJZzil0u4Khklw/Vbe2d
         MWQlCLFtaS+WA2hsX5Q96FMJZtyftis4wy8IzpsD0gwzWUMvgVYWjhPUcI93Nmfly6BE
         C0DQnYcVd1gMkYQVb02DqbmaSZHuC1xfzpvHvcAIUd7peVLMt9SEgax2qK4m/EE25Ilz
         LAVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=qhZ9K+aj4bVR1kRvCDHu8fuOy09gt6Svugsy5dV+WVg=;
        b=0xxRtckhOJS6T6An8HXUicweIkBKFc7g9ckaopHkiAG2yQu8UYRkQI+tgmKxBOfj5w
         8F1sBWzQiyXOk+v3aqxLPe2V2iC9tLNysUsqildGI/UYJiRzphrL5uY0jEhAoYrO+sVl
         LRi+jKI+iPEfPJ8K2U8lG8XQpDXxTr/Rf1ZMN8xUwyycLElxyCBN52jlVMt4ew8s0OCx
         gPcs1X498bnLQrEX4a+WnkC39k76wa9zJhBbMxm594lmaTa5O19gnWYq95YXzO+hVmSp
         Uu/5+xZVxYsWG1qvWcM4JZPfeNVXEaHMoI2Z8TqHWUy97sfj3+4etyEvYdHGY6dJ/ED5
         ivgA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=WCdvs4TX;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h17sor14156948ior.61.2019.07.09.06.34.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jul 2019 06:34:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=WCdvs4TX;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=qhZ9K+aj4bVR1kRvCDHu8fuOy09gt6Svugsy5dV+WVg=;
        b=WCdvs4TXN+9GIYowkSuMdFEQ4syQGfEZq2fbK0yY5/dxQ6VxHf5j0VW5zBrHDuTpRH
         8yrWc2pxIhaGaPSisqSDiwG+lDG1fmjDlEVHOwRDxGCfaSDw2MR4bLNGfDtaNXNDFZQr
         79/X1Zn29OVo72pzTbe9DS0hT4MaiOMHN44t5xG/CiQs9VFOd0aZZxXqOHZDUD/dTAB3
         Fhp7n2gtRcxGFN62nscplP3PVRYe//8U0jn3LXtCfYi1s7RijU7lUsgwpLPCHRZeq8//
         eLLQi5KsnejJ7IvX4qJdTI/lxpQN/TUlaUYQfwZHYHWIcwis6oZNTHDkZJ28dVpuhAes
         iWxw==
X-Google-Smtp-Source: APXvYqxmHmnwWROql5oN9WLxdlfrbin5EaMmtC8sSO2qSh0Jq8A4W+GrRNHF9eWjGyICCT/oZwMp6g==
X-Received: by 2002:a6b:fd10:: with SMTP id c16mr23902581ioi.217.1562679250687;
        Tue, 09 Jul 2019 06:34:10 -0700 (PDT)
Received: from ?IPv6:2601:281:200:3b79:d6e:1b00:ea8e:79ea? ([2601:281:200:3b79:d6e:1b00:ea8e:79ea])
        by smtp.gmail.com with ESMTPSA id v3sm11452430iom.53.2019.07.09.06.34.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 06:34:09 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 2/2] x86/numa: instance all parsed numa node
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16F203)
In-Reply-To: <CAFgQCTui7D6_FQ_v_ijj6k_=+TQzQ3PaGvzxd6p+XEGjQ2S6jw@mail.gmail.com>
Date: Tue, 9 Jul 2019 07:34:08 -0600
Cc: Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org,
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
Message-Id: <4AF3459B-28F2-425F-8E4B-40311DEF30C6@amacapital.net>
References: <1562300143-11671-1-git-send-email-kernelfans@gmail.com> <1562300143-11671-2-git-send-email-kernelfans@gmail.com> <alpine.DEB.2.21.1907072133310.3648@nanos.tec.linutronix.de> <CAFgQCTvwS+yEkAmCJnsCfnr0JS01OFtBnDg4cr41_GqU79A4Gg@mail.gmail.com> <alpine.DEB.2.21.1907081125300.3648@nanos.tec.linutronix.de> <CAFgQCTvAOeerLHQvgvFXy_kLs=H=CuUFjYE+UAN+vhPCG+s=pQ@mail.gmail.com> <alpine.DEB.2.21.1907090810490.1961@nanos.tec.linutronix.de> <CAFgQCTui7D6_FQ_v_ijj6k_=+TQzQ3PaGvzxd6p+XEGjQ2S6jw@mail.gmail.com>
To: Pingfan Liu <kernelfans@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jul 9, 2019, at 1:24 AM, Pingfan Liu <kernelfans@gmail.com> wrote:
>=20
>> On Tue, Jul 9, 2019 at 2:12 PM Thomas Gleixner <tglx@linutronix.de> wrote=
:
>>=20
>>> On Tue, 9 Jul 2019, Pingfan Liu wrote:
>>>> On Mon, Jul 8, 2019 at 5:35 PM Thomas Gleixner <tglx@linutronix.de> wro=
te:
>>>> It can and it does.
>>>>=20
>>>> That's the whole point why we bring up all CPUs in the 'nosmt' case and=

>>>> shut the siblings down again after setting CR4.MCE. Actually that's in f=
act
>>>> a 'let's hope no MCE hits before that happened' approach, but that's al=
l we
>>>> can do.
>>>>=20
>>>> If we don't do that then the MCE broadcast can hit a CPU which has some=

>>>> firmware initialized state. The result can be a full system lockup, tri=
ple
>>>> fault etc.
>>>>=20
>>>> So when the MCE hits a CPU which is still in the crashed kernel lala st=
ate,
>>>> then all hell breaks lose.
>>> Thank you for the comprehensive explain. With your guide, now, I have
>>> a full understanding of the issue.
>>>=20
>>> But when I tried to add something to enable CR4.MCE in
>>> crash_nmi_callback(), I realized that it is undo-able in some case (if
>>> crashed, we will not ask an offline smt cpu to online), also it is
>>> needless. "kexec -l/-p" takes the advantage of the cpu state in the
>>> first kernel, where all logical cpu has CR4.MCE=3D1.
>>>=20
>>> So kexec is exempt from this bug if the first kernel already do it.
>>=20
>> No. If the MCE broadcast is handled by a CPU which is stuck in the old
>> kernel stop loop, then it will execute on the old kernel and eventually r=
un
>> into the memory corruption which crashed the old one.
>>=20
> Yes, you are right. Stuck cpu may execute the old do_machine_check()
> code. But I just found out that we have
> do_machine_check()->__mc_check_crashing_cpu() to against this case.
>=20
> And I think the MCE issue with nr_cpus is not closely related with
> this series, can
> be a separated issue. I had question whether Andy will take it, if
> not, I am glad to do it.
>=20
>=20

Go for it. I=E2=80=99m not familiar enough with the SMP boot stuff that I wo=
uld be able to do it any faster than you. I=E2=80=99ll gladly help review it=
.=

