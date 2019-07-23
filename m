Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DEFFC76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:11:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 157A72184E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:11:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 157A72184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58CED8E0006; Tue, 23 Jul 2019 13:11:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53D738E0002; Tue, 23 Jul 2019 13:11:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42E1B8E0006; Tue, 23 Jul 2019 13:11:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0B7C58E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:11:32 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id u21so26602477pfn.15
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:11:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=8VDFgnACVlFfEpbXvpf0r9q5CHZiuYzANCPHwtF+rYc=;
        b=iyTF8PI9HGVmFSm0XLpWqhD/n/C/Wr+7lEbBXNUFTKt/UCQSFL9PY2zgS74P9BYWP6
         xnQiGLitChPWYAqdYM73AjRuLv9aS7K7AYcK2+ZAqvY1+ef3yoEzCXYAkGSSMONI5Sll
         z8kQg+YmqAV71c2S1NDzLi1eMruVi2K/N71MfxiTbUEDKVsXkwzY/0I/iyJvZG381MQu
         klF+7W7QjMt63tOaY9hknh0ugcXJFRxXKK87eNTIKZOGDLgPYcUkM2QvpGNxtUmFnKeU
         x+ET8M+3QulWk3WAUkSBax0j2CisXfMxWFM9w9es7I/nKkDrURY5l/esLAa6s4xbJHt1
         YPCQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXAJ30EG3oImqEj2Xs6eTvj7wxFfj73MHgfi8zIRLmOCzVULXpM
	9psfh4e83wISKYXlYpThrlvgjKCRvqMIuMwNIBvay1csFMl8kAXRUDkprCBzIpYTC0mgR+bUYit
	wliRynNiCFiySF8vWMrpoD9sbOuE9BoLztdCN7uP5qg7dw1ENv60eQx0f1gU9i58B8Q==
X-Received: by 2002:a17:90a:a410:: with SMTP id y16mr84011356pjp.62.1563901891568;
        Tue, 23 Jul 2019 10:11:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrMmBt25phU1cVN2LvrsSeUBwM0ZIOBK+T7WiA8fjIugVhOaUVIyFebGzUlh5lzuvnXqUb
X-Received: by 2002:a17:90a:a410:: with SMTP id y16mr84011304pjp.62.1563901890790;
        Tue, 23 Jul 2019 10:11:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563901890; cv=none;
        d=google.com; s=arc-20160816;
        b=sqMwaJ51/ULYq12pbVVAg6XMzTZvZSHQfdfD92FRchFhgN37d4bap1K6f76QMv890K
         qu4dpeEJF1O/9Ve/TKjN6yLP/lkPZo+pw5h3MfTz9lcWUaj6B3WJpoJmcFGA8Si4khbI
         yRsRQT1ov9JZhNoTwYegcOV6c+UgftNv0fwTvGxT8NxftPrAYEF+1EabnkXK0PzM3WS2
         zEzVDt+ykYVSWVPDEFBTWGIcR4krkp5YJ2cBL028vnxAw1+fOFRCKvOm6mt+rbuqZ6Y2
         sOR2MDadYzNWnSe8igHtGyzBdnfPsCBdLJ4/ZlsH5o2OEqJS56XcQFoS6L1fHIS2m4R1
         RywQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=8VDFgnACVlFfEpbXvpf0r9q5CHZiuYzANCPHwtF+rYc=;
        b=KtyWUf5NIvyhf+rLOFZL7Y9F9WawfU4JTP99ckMEvbWZZxnptxPIYQZiHjRZRWggU8
         vsQl25kcvfQ1Tve5LZrXyu16mX0lMsXSvtr6xLxL0ybYHQg4QZXs6WHZeY3Ijp2lJ5ei
         GxO9/NHdIqbGSgp/ajAT0vUZ8AfFWLAS1x8DtYB0e0B2uMSKRQMiv/sLmst6GlZwff7o
         QRaiUBQ1+M7+dPWtFObRFoSLNfoor8pVqHL+7HAPG91vuZwLw+e2HZnjcuTRMn76KgvB
         EUcCm5zU3FThTMnFlcqWeIFSB33x79syz+1vCWh0Uz+O5M280PbEXLheYD4UAUaUyW2E
         yXrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id k21si12635017pls.202.2019.07.23.10.11.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 10:11:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 Jul 2019 10:11:30 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,299,1559545200"; 
   d="scan'208";a="368453183"
Received: from orsmsx102.amr.corp.intel.com ([10.22.225.129])
  by fmsmga005.fm.intel.com with ESMTP; 23 Jul 2019 10:11:29 -0700
Received: from orsmsx114.amr.corp.intel.com ([169.254.8.96]) by
 ORSMSX102.amr.corp.intel.com ([169.254.3.142]) with mapi id 14.03.0439.000;
 Tue, 23 Jul 2019 10:11:29 -0700
From: "Prakhya, Sai Praneeth" <sai.praneeth.prakhya@intel.com>
To: Dave Young <dyoung@redhat.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-efi@vger.kernel.org"
	<linux-efi@vger.kernel.org>, "mingo@kernel.org" <mingo@kernel.org>,
	"bp@alien8.de" <bp@alien8.de>, "peterz@infradead.org" <peterz@infradead.org>,
	"ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "rppt@linux.ibm.com"
	<rppt@linux.ibm.com>, "pj@sgi.com" <pj@sgi.com>
Subject: RE: Why does memblock only refer to E820 table and not EFI Memory
 Map?
Thread-Topic: Why does memblock only refer to E820 table and not EFI Memory
 Map?
Thread-Index: AQHVQS4PLLsbbSADyUqVsMzHOrg1zabYbfVg
Date: Tue, 23 Jul 2019 17:11:28 +0000
Message-ID: <FFF73D592F13FD46B8700F0A279B802F4F94B2C6@ORSMSX114.amr.corp.intel.com>
References: <cfee410c5dd4b359ee395ad075f31133387def70.camel@intel.com>
 <20190723080949.GB9859@dhcp-128-65.nay.redhat.com>
In-Reply-To: <20190723080949.GB9859@dhcp-128-65.nay.redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiNTIyYzdhNDYtMTZkNS00ODNiLThiNWYtNTEzZWM1MzU1ODExIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiTzFiaHJsZmc1bVdHYTlUTXVzRXpieEhjSWRjMXBxbmNpNGl5Q01BSTl6d1lKcjJuWlFkVzJTZWNIT1hGdm13TSJ9
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.600.7
dlp-reaction: no-action
x-originating-ip: [10.22.254.138]
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> > On x86 platforms, there are two sources through which kernel learns
> > about physical memory in the system namely E820 table and EFI Memory
> > Map. Each table describes which regions of system memory is usable by
> > kernel and which regions should be preserved (i.e. reserved regions
> > that typically have BIOS code/data) so that no other component in the
> > system could read/write to these regions. I think they are duplicating
> > the information and hence I have couple of questions regarding these
> >
> > 1. I see that only E820 table is being consumed by kernel [1] (i.e.
> > memblock subsystem in kernel) to distinguish between "usable" vs "reser=
ved"
> regions.
> > Assume someone has called memblock_alloc(), the memblock subsystem
> > would service the caller by allocating memory from "usable" regions
> > and it knows this *only* from E820 table [2] (it does not check if EFI
> > Memory Map also says that this region is usable as well). So, why
> > isn't the kernel taking EFI Memory Map into consideration? (I see that
> > it does happen only when "add_efi_memmap" kernel command line arg is
> > passed i.e. passing this argument updates E820 table based on EFI
> > Memory Map) [3]. The problem I see with memblock not taking EFI Memory
> > Map into consideration is that, we are ignoring the main purpose for wh=
ich EFI
> Memory Map exists.
>=20
> https://blog.fpmurphy.com/2012/08/uefi-memory-v-e820-memory.html
> Probably above blog can explain some background.

Thanks a lot! Dave. The link was helpful, it did explain that Linus and HPA=
 were=20
not very happy with EFI and things were going good with E820 and hence it w=
as given=20
more preference compared to EFI.

But sadly, I am not 100% convinced yet :( (just my thoughts)
This decision was made a decade ago when EFI wasn't stable. Now that UEFI i=
s the defacto=20
on most of the x86 platforms (and since I believe UEFI is getting better) I=
 am still unable to=20
digest that kernel throws away EFI Memory Map (unless explicitly asked by "=
add_efi_memap")

Regards,
Sai

