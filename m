Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79831C76192
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 22:07:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 271732173B
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 22:07:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="UxyLjO/r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 271732173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D037E6B000A; Tue, 16 Jul 2019 18:07:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDAA28E0003; Tue, 16 Jul 2019 18:07:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF06C8E0001; Tue, 16 Jul 2019 18:07:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 932416B000A
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 18:07:14 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id v49so12486508otb.6
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 15:07:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=am3zTTAioUL0WnBW6RccNxphyDc3aO0XKt7PXXLcHQ8=;
        b=DKPMKGqpx1Nt3oljCUwH51FnzcFxfNm9CpUw0W5u9ilVFZa70wzMecbCaQ87kQn4N5
         iWtKmyNWyn2Lz9sgXS0EOfiVzdNNeAdIlwFrY9SZEYJJjhz/T0hyFSiPI+6nMFfP7AOR
         GWXkthXncES7/OJC+ohhnEvX8Bje+9UVtmcy5ZXxbOmm2aMVpedMx7eCAb3wPyEQ7KT7
         KRqX/aOT50EkW2cVxFpI9zUBD/1P6x8Mt/zOVNqlXssr07dPhtk6CJqcAzDWoLeFXW3I
         HJVvBxyUN81IEe43QVMSodGuNVM3tlH1ptfJXpfCXPcbLV+XNpjPIlMtcH5z+Oq2PmTt
         y76w==
X-Gm-Message-State: APjAAAU4VaqggAn3Db5hDQZgnMa2MWzqyqlQh+xXDMOWGnbJbGe/lvWs
	yjAfw6sK+1O9KCGQVEhfxnKurBY86XptcKKqAljQlWk/i0SIe9k0cALvAlh+iD+SuTLbl9TgoSP
	HV7PVsHmDx94Tj2UVCfBcWzZxpJloLK439rgef5Q4oZ+5bmW7RWMBrhkYni63a3KV6w==
X-Received: by 2002:aca:4a4e:: with SMTP id x75mr17419737oia.154.1563314834192;
        Tue, 16 Jul 2019 15:07:14 -0700 (PDT)
X-Received: by 2002:aca:4a4e:: with SMTP id x75mr17419718oia.154.1563314833644;
        Tue, 16 Jul 2019 15:07:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563314833; cv=none;
        d=google.com; s=arc-20160816;
        b=Wwnl0Ix8XhHEb9qCPAloQzXuyyfHvxk3RxwovmRKTBbk02YUahVAtOQO2ZIwwa/4p1
         N07pdqa4BmGhh2h4EfM/nj+uHvC8CTndGgupMSk0KBWZDoP/DPDXC+yR/+hHVJU2TByH
         vL054DjsDLhjbbZxnJn+eR+z4ytcnDzN8AfyIb3rBGRfOeb6HQpksV/kbBQN9YrKlwxn
         oX2htez9g1ZRE2EHOM5UkFmuOA2Y8wqmeU1fFRErMMbuN3JLD6BKpdMHt2p49hs5P8V6
         kyDFMG4EcAmiZqUbw81eML6oOVb7+tOHru84kOkUTfGpbhU5L6oHcwF2l9TreWoOW6vR
         W57g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=am3zTTAioUL0WnBW6RccNxphyDc3aO0XKt7PXXLcHQ8=;
        b=KY8IwED3ScA6zafC5u73hU08xI3PCAoflfRQly0UB8Uex78IhYyo/+go0y+f6SUsTr
         h/n7NmUe2qlgjVzCf6KxQpyuqvRqQaEOnjS9OVbIlxnyY0Xpb5zirYXDU+vRWOwTtrsx
         TCKNSVLSktA+UgnwRckO5lCrcx5wq1SqhJT/6TEqeqqXjZycSdinvrVA6xdFCuk9yalA
         Bii3bDRHlxYba/MfH7RTlxVp6qdZDPsPb8sR6XB+joSnJ7mlhfrpMZUCPQHI2gUj+SVj
         AyG64jMGfzAK2KBkmLtaJmUTLd8gaE98D4jFoKrj0RqYQdSS5K2vr05pXMa7NGOkTjG5
         NC/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="UxyLjO/r";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i4sor11570253ota.11.2019.07.16.15.07.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 15:07:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="UxyLjO/r";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=am3zTTAioUL0WnBW6RccNxphyDc3aO0XKt7PXXLcHQ8=;
        b=UxyLjO/rW4wV+XGw3XGomgV83T/DKFlBystntsKgmvFkWmCwMpj/GM1V9lthCAaawH
         nN2CpACN8q+A0EP0pjJ/NzdCHbXnhaPvZxcvgTlK5YKUYE8G3wjU8E5R1cpJPvUJEQGK
         T4wUbFt57KyYzIMCQBzzack4HRvbwTcdYv4wyQjEL2gbyUfTvZzUKVB2lfDGb2utJmTr
         yLHu8JQguEmIFgxF3sZpQoANON1BeFbk735OqwlbGJ/BX1TOIxUymC6rtPDCUgjiv1WS
         dSq5YbkzLmAfcbuH2eOUWFXsy483B0KKD5VTIvPVEjEL0gqBIpNLA1bJ3QF1ImtcdbIf
         uiIw==
X-Google-Smtp-Source: APXvYqwh13LvFILQ4sc7Xet21Uj0uBONLPMpu0RdYeM/DiLsx/zxVJRrL7wQuzP6kM+SbvQZXwKMI1JwlYV3FYaciZA=
X-Received: by 2002:a9d:7a8b:: with SMTP id l11mr18339062otn.247.1563314833269;
 Tue, 16 Jul 2019 15:07:13 -0700 (PDT)
MIME-Version: 1.0
References: <20190613045903.4922-1-namit@vmware.com> <CAPcyv4hpWg5DWRhazS-ftyghiZP-J_M-7Vd5tiUd5UKONOib8g@mail.gmail.com>
 <9387A285-B768-4B58-B91B-61B70D964E6E@vmware.com> <CAPcyv4hstt+0teXPtAq2nwFQaNb9TujgetgWPVMOnYH8JwqGeA@mail.gmail.com>
 <19C3DCA0-823E-46CB-A758-D5F82C5FA3C8@vmware.com> <20190716150047.3c13945decc052c077e9ee1e@linux-foundation.org>
In-Reply-To: <20190716150047.3c13945decc052c077e9ee1e@linux-foundation.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 16 Jul 2019 15:07:01 -0700
Message-ID: <CAPcyv4iqNHBy-_WbH9XBg5hSqxa=qnkc88EW5=g=-5845jNzsg@mail.gmail.com>
Subject: Re: [PATCH 0/3] resource: find_next_iomem_res() improvements
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nadav Amit <namit@vmware.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Borislav Petkov <bp@suse.de>, Toshi Kani <toshi.kani@hpe.com>, Peter Zijlstra <peterz@infradead.org>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Bjorn Helgaas <bhelgaas@google.com>, 
	Ingo Molnar <mingo@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 16, 2019 at 3:01 PM Andrew Morton <akpm@linux-foundation.org> w=
rote:
>
> On Tue, 18 Jun 2019 21:56:43 +0000 Nadav Amit <namit@vmware.com> wrote:
>
> > > ...and is constant for the life of the device and all subsequent mapp=
ings.
> > >
> > >> Perhaps you want to cache the cachability-mode in vma->vm_page_prot =
(which I
> > >> see being done in quite a few cases), but I don=E2=80=99t know the c=
ode well enough
> > >> to be certain that every vma should have a single protection and tha=
t it
> > >> should not change afterwards.
> > >
> > > No, I'm thinking this would naturally fit as a property hanging off a
> > > 'struct dax_device', and then create a version of vmf_insert_mixed()
> > > and vmf_insert_pfn_pmd() that bypass track_pfn_insert() to insert tha=
t
> > > saved value.
> >
> > Thanks for the detailed explanation. I=E2=80=99ll give it a try (the mo=
ment I find
> > some free time). I still think that patch 2/3 is beneficial, but based =
on
> > your feedback, patch 3/3 should be dropped.
>
> It has been a while.  What should we do with
>
> resource-fix-locking-in-find_next_iomem_res.patch

This one looks obviously correct to me, you can add:

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

> resource-avoid-unnecessary-lookups-in-find_next_iomem_res.patch

This one is a good bug report that we need to go fix pgprot lookups
for dax, but I don't think we need to increase the trickiness of the
core resource lookup code in the meantime.

