Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFB0FC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:21:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A7D152146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:21:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="PhmVANGN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A7D152146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B1C68E003E; Wed, 20 Feb 2019 17:21:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 461968E0002; Wed, 20 Feb 2019 17:21:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 329E88E003E; Wed, 20 Feb 2019 17:21:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 043D78E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 17:21:00 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id w20so8572139otk.16
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 14:21:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=wYHmGSae92E6kyyzNFPvzSyptP9jjYpuFxHzK9ePRvA=;
        b=fn4F0jamadZngGsdne5mA10zaA0AiQ+fJ4kiSx4plhakerW9I6M2QjD9bEjcaO4ndU
         nQQV3ov8/NGys+DORmRh0/cdOHFwh3QtKjgtGm629JXTfK/mM4aHV28KIaSx8Kx6JgiU
         FhfDquxZRT8TD2HYGsF9IJIL2E7hQo6VCHYuPx9Py3puEa2uBeepznAEQq0Dg0mLBGpN
         NBxlQ8xHgp7HEHw5sdPo9XdNdoG2RPrkbmPnYvhXp90M3cFVXDN8HyKviu5RPUPOt3ah
         SyfNycFV1TRChLQeBDy3JCoY7RwEQiX1awpM+5bvvvuRtjMhWPXP/VvG5L7CTaThVZ0K
         ymaQ==
X-Gm-Message-State: AHQUAuYT9w5G6Z2Lc7ABwVp63DU+Y2KIK8EnSqPgSO/6qU5eHIkkR2sk
	29tqQSb+vS4/UUS7HEJdlpFR1qxtaafwrFSdhGldleQmcG/+ZtZ09s2agMnurh2aCO5lueAoYqN
	ekwzSVdh2m5u1XwQtv7R+78OKJ2jsijfiYIHngueV7AQp/evk0IePaMsFi5ZzDI7jOrwayLm7Qt
	yCYGGMviY9oeJnn1hmiQ+ucjQFMKJk9aGsTBAuiTvTF5CtlXD5USRfUl1u5JP9gzAV12YQpnYx8
	RUfM04PunJ3aQeeoWLIA1RJGJyLobqvhxcGFuPLrqr0rS/gSEcUd9k59/w5tkZUKpBYjsIqrsVK
	MFOapDwAfZ2w+M/Pdy1KDeNoXmX051zOciYAC1SlkDQq3Env6JkuewBxRlcmcxGU9kkbSX/2Gxn
	p
X-Received: by 2002:aca:c682:: with SMTP id w124mr7601399oif.117.1550701259804;
        Wed, 20 Feb 2019 14:20:59 -0800 (PST)
X-Received: by 2002:aca:c682:: with SMTP id w124mr7601375oif.117.1550701259259;
        Wed, 20 Feb 2019 14:20:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550701259; cv=none;
        d=google.com; s=arc-20160816;
        b=aOhRpTGiwU8E8k3GrDe6hH/eitXnoLDIKC0QX1GIUop0+SBXANmbM0iL2JILStTQFU
         7ELBUF4J0cB458ulBH18ajHHa/XnTujTXi7sTI+d6a/TmMYqcb5/leBx7G3kPyxtPp41
         IP5CDXXttMqww0CjoHDOdKJAH/W4TBrKmq+6Th+5oiFWybyKpgQp8YCUvOIHy8H+13QP
         lmVdhvQtuBgCKLL40NTW+MUiaDxh6z+qLsD1BosVejc3uuoI7BJqJilH6Be0p44eRcLe
         6hrsuWJMItDUW7CXo1/9svhzsplNrB+0jmJXUG0RC0XlgaFkcHwrItmOmlxjan6sdxbx
         JZlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=wYHmGSae92E6kyyzNFPvzSyptP9jjYpuFxHzK9ePRvA=;
        b=MgbluBwf8RWrOhDIaOjrkZw8I7DZFoSUbPK/FiaMQWYktlCbugVxqsGJkf8coi0epH
         TDxBSwxZWqPPcAK2LYqPCNOj1gCMFWYDTwYs6LVcLl+SIrClon/bdfIlq19spM20wMmP
         XXkooWHHiRlX87WtLnz5H1cIMN/BV7KDTnV93/L4YsCvg9GqmOtO04H8eNAN0FxCaOWh
         0oQN0ppL9PJV62yADkHoDlOmL5/PXrxgGT7aZ+MhB9CbwKiuWmVHr2lx5LJWyJhCYgQK
         u0UvcWGrfOo5RQjydBW5SHsymlEYmoQShT+gD3QQR6TaSZStz4Ts2DAlSaYXq0SoTsV5
         EK0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=PhmVANGN;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m14sor9687872oic.64.2019.02.20.14.20.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 14:20:59 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=PhmVANGN;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=wYHmGSae92E6kyyzNFPvzSyptP9jjYpuFxHzK9ePRvA=;
        b=PhmVANGN9uxCFQvamQEsZzQyEDEeKKmsALmHaXY1uWKPkjBV6WDF1GHKhgmRPZiDke
         ss10F4tqpeTvXOgd7/x4gycVfztCap2Jn5xfoRZ0xgSSn+oUYK2/TWsl+eVcBml9a8cj
         mXi0wRnYTTNqXoYJKAtpbECOhxGmuJ6JCJAQmsp5my1hMDNSgFnMp12t8fXmx/hv97sQ
         OvUEdl1yUvzUL4xhCU/Zy9ZwQ/yFaHG16kucz3FiVr5xdOfNCxisU4zrvWoNiuklesb6
         qWyaqed/Akdfu80y7Jg1m/+PR23iTxspbkCxqREqk/eJcS1aziyzrYtjwDTLdQ107RiV
         dumA==
X-Google-Smtp-Source: AHgI3Ia4KkP74uHBWXReoJuMyNqr85iF47p1Ij1i/ERE9QXCthX6/HpkumPtCQLmuidBS13nCSnPKArKkthePEG7S04=
X-Received: by 2002:aca:c3cb:: with SMTP id t194mr7146924oif.70.1550701258989;
 Wed, 20 Feb 2019 14:20:58 -0800 (PST)
MIME-Version: 1.0
References: <20190214171017.9362-1-keith.busch@intel.com> <20190214171017.9362-8-keith.busch@intel.com>
 <CAJZ5v0gjv0DZvYMTPBLnUmMtu8=g0zFd4x-cpP11Kzv+6XCwUw@mail.gmail.com>
 <9ab5d6ba-4cb6-a6f1-894d-d79b77c8bc21@intel.com> <CAPcyv4iP032bqAgCZ8czRXkJ_gXz0H1EVC+ypf6NhKQ65aKczg@mail.gmail.com>
 <CAJZ5v0hwyXnsLmCKNJvzOvcG-HD1UmuWNGFvoB02=2Ks1hE0bA@mail.gmail.com>
In-Reply-To: <CAJZ5v0hwyXnsLmCKNJvzOvcG-HD1UmuWNGFvoB02=2Ks1hE0bA@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 20 Feb 2019 14:20:48 -0800
Message-ID: <CAPcyv4iz4XYrHeQBR5f9W7T+0PcTvP0w70OsWuvbbChKtq0RUg@mail.gmail.com>
Subject: Re: [PATCHv6 07/10] acpi/hmat: Register processor domain to its memory
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Keith Busch <keith.busch@intel.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 2:17 PM Rafael J. Wysocki <rafael@kernel.org> wrote:
>
> On Wed, Feb 20, 2019 at 11:14 PM Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > On Wed, Feb 20, 2019 at 2:11 PM Dave Hansen <dave.hansen@intel.com> wrote:
> > >
> > > On 2/20/19 2:02 PM, Rafael J. Wysocki wrote:
> > > >> diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
> > > >> index c9637e2e7514..08e972ead159 100644
> > > >> --- a/drivers/acpi/hmat/Kconfig
> > > >> +++ b/drivers/acpi/hmat/Kconfig
> > > >> @@ -2,6 +2,7 @@
> > > >>  config ACPI_HMAT
> > > >>         bool "ACPI Heterogeneous Memory Attribute Table Support"
> > > >>         depends on ACPI_NUMA
> > > >> +       select HMEM_REPORTING
> > > > If you want to do this here, I'm not sure that defining HMEM_REPORTING
> > > > as a user-selectable option is a good idea.  In particular, I don't
> > > > really think that setting ACPI_HMAT without it makes a lot of sense.
> > > > Apart from this, the patch looks reasonable to me.
> > >
> > > I guess the question is whether we would want to allow folks to consume
> > > the HMAT inside the kernel while not reporting it out via
> > > HMEM_REPORTING.  We have some in-kernel users of the HMAT lined up like
> > > mitigations for memory-side caches.
> > >
> > > It's certainly possible that folks would want to consume those
> > > mitigations without anything in sysfs.  They might not even want or need
> > > NUMA support itself, for instance.
> > >
> > > So, what should we do?
> > >
> > > config HMEM_REPORTING
> > >         bool # no user-visible prompt
> > >         default y if ACPI_HMAT
> > >
> > > So folks can override in their .config, but they don't see a prompt?
> >
> > I would add an "&& ACPI_NUMA" to that default as well.
>
> But ACPI_HMAT depends on ACPI_NUMA already, or am I missing anything?

Oh, my mistake, sorry.

