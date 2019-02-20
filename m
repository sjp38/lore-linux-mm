Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F25D8C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:51:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACFD02146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:51:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACFD02146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C2FB8E0043; Wed, 20 Feb 2019 17:51:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 498B98E0002; Wed, 20 Feb 2019 17:51:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3AF9D8E0043; Wed, 20 Feb 2019 17:51:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 130D98E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 17:51:04 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id x8so5097224otg.17
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 14:51:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=MXnskfauBnUogXYJgY5dNHOIdo9j55TU67g9oo5oqhM=;
        b=C5Pou5OzCF0IAChjSeiN8kGOxqHrznx1whd2cEYB3CPd1R2Y0OXFLm7Zzq3VwoFE2r
         bT6tQ2F7VOMbKy6pMz/ewDgjv1uygoZO34JIt6tGL2ETc449YjQOhKZqftaVHL1GCw2n
         llToQWn47RrFETZ56faJUbAdaKadZpdy6GSYI4FTja2+Fmqheoo9M8ynHZez1IaZvzu5
         WQgAxuOpzQyhksjJ9c5N3hiIrEb9tAvEd3L124zQ/+qyR5dPpaZcnKkLRQFCFOQk+uS6
         sOrw6UxX9y97k+tNAhgPZDRumHTkQGmOTN0uwLv42K7cLBzo6bDsGJGaun7ae9CgQH6i
         mOng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAubqXxBiY3fCkUL9ACelMXqZWRpK9XnaC1VqyaZlXsSVizl/S2qO
	310M/QOa1fknTHKWZ19sUbmv1na4uhPwCg+JOEJ8naRsfUeiZToxMmNPqo5Ab1gPvSY2Gp7r5Jp
	759pS3bmKS5bT5aWdAfR/uri9iHBx/94I8dHtdB+2NNOCFPxsgaGjfRhdSB0fi/gJbhM6PfR+/p
	GoqljaDLAmVqSMEq5NA8nUkOYCPrP2bzJrb3zr4SrMlN8SyPF9vSmfJuZ+r8CeZb7w3i8Y53gGI
	1tyg5ZZgOVhfICgskiKNKrOcJoO7FUWjnSIIkwVSTIHiVoNLmkZxHJdcpKue4V+QaUqOGj7BL1W
	7U38T66Lm5+o07Qil7iHgKVNqOIVZP7AAaiHnxKPLNZ1DEgyxhwN+fV4i1Mxp5jBviuS8nUe6g=
	=
X-Received: by 2002:aca:af90:: with SMTP id y138mr7107110oie.35.1550703063855;
        Wed, 20 Feb 2019 14:51:03 -0800 (PST)
X-Received: by 2002:aca:af90:: with SMTP id y138mr7107089oie.35.1550703063185;
        Wed, 20 Feb 2019 14:51:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550703063; cv=none;
        d=google.com; s=arc-20160816;
        b=oXc9RbJMytMDumUAuYyy34zrb/2pNIbLbSPekB79qOgp89/eGNRJA/yftPBbuobe32
         1kMqUhrJ9lnCpz/zcK1WxAUZk0YJzIGtgRg0svyYIN92APx/+6MSen7/ZHNbEdj3H2oN
         pNskE8pOMK5t9Ptw3jQ0Har8N10mZfH9SXV6vIFTKmu2HbieQLyvwFLI65PXZ0JPdM5C
         CqonyR81tj0D27QaUt75qL4fym/wla//CNqOeZhhBR4+2QYv/oKX0mbzBBR88tkZRjdH
         Ujilyf0BnPDTSc0zFaflXQsGmlmnmGyOuw0SN4JxRFFJIDUyzQBUOvu3KgpSYJMYgM8W
         nkeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=MXnskfauBnUogXYJgY5dNHOIdo9j55TU67g9oo5oqhM=;
        b=wbMGbqA2u7oFdlqKCwc9teWpWE0DJjRnOsL4jK1BmQK6/levncbk0luAcnGXPA5+f+
         NYEX8Ftd9fgDhurbv1dvNthIz2PQ0N1XkU9w1cryZqsvzPpuCe7/tVHjyTi9T9zS52Pr
         xoTyVtQM/RZ76e+v9JmzEVKp69sy6Yd1XeiuI1CmAEdATNWKW6fUslDoqfWZ1setk+GC
         rnCMAPXHiowWsX1A15BiTK1FtRrCZw0ADKSkGeAhNaipyrSFEC+Rp/Bg70cOnRMduNDu
         YY1CUHdv4+uTnh4XIZXNga7iGOLI8V44/P3AaRWmSUbO/BxTSaXth9mKPKcYK7XhosEn
         Zxfg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s23sor11034273oih.39.2019.02.20.14.51.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 14:51:03 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IZRPgC4J+d8RrkM9iH9F5Zs+AMlNX5W8aBgKvrqXeUzhgCN/MVSc89/TZNlgaCEVUeLZkRcCiMgaC2iQSwbJBk=
X-Received: by 2002:aca:ed0f:: with SMTP id l15mr7586917oih.76.1550703062784;
 Wed, 20 Feb 2019 14:51:02 -0800 (PST)
MIME-Version: 1.0
References: <20190214171017.9362-1-keith.busch@intel.com> <20190214171017.9362-8-keith.busch@intel.com>
 <CAJZ5v0gjv0DZvYMTPBLnUmMtu8=g0zFd4x-cpP11Kzv+6XCwUw@mail.gmail.com>
 <9ab5d6ba-4cb6-a6f1-894d-d79b77c8bc21@intel.com> <CAJZ5v0izS-MBcC3ZsRKK59zWcJOMQ672sRuv_GCVrsYR36Wa8w@mail.gmail.com>
 <20190220224419.GC5478@localhost.localdomain>
In-Reply-To: <20190220224419.GC5478@localhost.localdomain>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Wed, 20 Feb 2019 23:50:52 +0100
Message-ID: <CAJZ5v0ji4ReBFf_L14kNbt-eAg79mdQYkYNC8MqbM=4kQa4Agg@mail.gmail.com>
Subject: Re: [PATCHv6 07/10] acpi/hmat: Register processor domain to its memory
To: Keith Busch <keith.busch@intel.com>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 11:44 PM Keith Busch <keith.busch@intel.com> wrote:
>
> On Wed, Feb 20, 2019 at 11:21:45PM +0100, Rafael J. Wysocki wrote:
> > On Wed, Feb 20, 2019 at 11:11 PM Dave Hansen <dave.hansen@intel.com> wrote:
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
> > Maybe it would be better to make HMEM_REPORTING do "select ACPI_HMAT if ACPI".
> >
> > The mitigations could then do that too if they depend on HMAT and
> > ACPI_HMAT need not be user-visible at all.
>
> That sounds okay, though it would create unreachable code if !ACPI since
> that's the only user for the new reporting interfaces.

Until there are other users of it, you can make HMEM_REPORTING depend
on ACPI_NUMA and select ACPI_HMAT.

