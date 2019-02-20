Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 694B6C10F07
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:44:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F7D32089F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:44:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F7D32089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF3748E0042; Wed, 20 Feb 2019 17:44:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA2F98E0002; Wed, 20 Feb 2019 17:44:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB9BC8E0042; Wed, 20 Feb 2019 17:44:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A8058E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 17:44:22 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 202so17885793pgb.6
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 14:44:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ADSnTAmMBLbb+CaaBT5R+wPVABqgRHBEqnFu1otGO/0=;
        b=IzsD7NoZnrPUQ5Ji4sRyHVA8s99wCRmptTE1OBCUivBB6sjRWxE+sundC9YbYq0sQP
         NOeBJ1x0+QjFtP+cmEh4MbP5C8WVg3VuZv52OtDbYgn6J6X1u/uW7c5iLrZSa3zi9g3T
         spvvqapXJAIuqh/rFWSZdlfa1rzpz5AYD9a5U7g8KDI8NlwFJVDdQZoglHywQJlby+fH
         +kXprl035gmpFvuvQ5JAYWDUGiF29VrKA/4ZJpeFLPUnkfE0xXNjJi9t81Js+wrOYceM
         1x9gkzPnU9KTg+pn9NlGei/OfzxxghaUZtCaeIlhshQa+9VVwwXUmb3kAJGXqVhho4jK
         iVaA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaZU/YP6wBn/oHg51dJ7GaQjArQ2RSzF0sbioD6ZQUb++TFM096
	QY6Uyp3TGTnjVHO/7efT12BhbQvVZZxDK9g6F35MUC+Y+fxsPBBswsDIWX1TbVUwk24hU6O8kSH
	4l7nfcSPtsIycsfDsWmhaAsZ1vJ6kAWhQpkv6rs4YlnfvIvJoZAPwL5F6fRPheAOBpA==
X-Received: by 2002:a62:61c4:: with SMTP id v187mr12846575pfb.133.1550702661967;
        Wed, 20 Feb 2019 14:44:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia2pWagOM14NxsJxKLAFykDf0AZBSlzEFgccJagyt28G2q+fwNyH7uIlhfkS0nJ4E8CI7xA
X-Received: by 2002:a62:61c4:: with SMTP id v187mr12846540pfb.133.1550702661217;
        Wed, 20 Feb 2019 14:44:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550702661; cv=none;
        d=google.com; s=arc-20160816;
        b=cmUPFXly7AeojowtqVAl2Wjb/OJHGYDQa7l+SxEyj+P443uOI/JcGRz1lwfEVk6NYM
         HvouOiTHCO+JYUD/S+1o5xXT5Zv8TdIXLZYCt5zKJx3gUjVyhf7gx9Vm36/jyasUBt4c
         GPN3Cbk6sDordYnZg2yLZXV2wQJloA6az1UiTaIJe/50KmLeK0zj0YD1gouklzBIgDwP
         AKRXKB2FgqdEVBYvciQI7gVyBawj8KPOH6qC19GmQ28NBNZEfT6xHv2/esMFt5WK+zkY
         oULkmndqHtPVYKYhhW8XAWrCq724UVX3r04uNiOFfPk/5nn31g8C9kQztphSgaRIsQMU
         l3Fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ADSnTAmMBLbb+CaaBT5R+wPVABqgRHBEqnFu1otGO/0=;
        b=IfmLsjnIUNbiU24vQ9C/ji1/oJXYCbxbDFF0EnsG4guQ44/ncxqMsDSLJyahufZzdI
         rTmY7via0KXjurYzccsChAk986HbFLOhG/k8NPlS+53i5xjqkOaXidV+/4vOWaWT+fhk
         huQM4GdccXJYB9Nfl07WE7sEJx5FJFhMbpbP9fIofUBffUALzrSMPBxE/UzxEkJd/uRx
         uSwiJPBnaYGvmnfhr8y2jsV6dGMwhszKwEKT0GSq/MYcAfQnGwpWl5kP3MQgF7eVtgXp
         RJ7N1ATMpy5yC41AvtWswboVMzFgG5pbCV7jaQ/cD9IvxpXEjMK2ZYNA4deFENO9pMZJ
         hrYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id f6si18362106pgo.58.2019.02.20.14.44.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 14:44:21 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Feb 2019 14:44:20 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,392,1544515200"; 
   d="scan'208";a="145942736"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by fmsmga004.fm.intel.com with ESMTP; 20 Feb 2019 14:44:20 -0800
Date: Wed, 20 Feb 2019 15:44:19 -0700
From: Keith Busch <keith.busch@intel.com>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Linux API <linux-api@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCHv6 07/10] acpi/hmat: Register processor domain to its
 memory
Message-ID: <20190220224419.GC5478@localhost.localdomain>
References: <20190214171017.9362-1-keith.busch@intel.com>
 <20190214171017.9362-8-keith.busch@intel.com>
 <CAJZ5v0gjv0DZvYMTPBLnUmMtu8=g0zFd4x-cpP11Kzv+6XCwUw@mail.gmail.com>
 <9ab5d6ba-4cb6-a6f1-894d-d79b77c8bc21@intel.com>
 <CAJZ5v0izS-MBcC3ZsRKK59zWcJOMQ672sRuv_GCVrsYR36Wa8w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJZ5v0izS-MBcC3ZsRKK59zWcJOMQ672sRuv_GCVrsYR36Wa8w@mail.gmail.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 11:21:45PM +0100, Rafael J. Wysocki wrote:
> On Wed, Feb 20, 2019 at 11:11 PM Dave Hansen <dave.hansen@intel.com> wrote:
> > On 2/20/19 2:02 PM, Rafael J. Wysocki wrote:
> > >> diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
> > >> index c9637e2e7514..08e972ead159 100644
> > >> --- a/drivers/acpi/hmat/Kconfig
> > >> +++ b/drivers/acpi/hmat/Kconfig
> > >> @@ -2,6 +2,7 @@
> > >>  config ACPI_HMAT
> > >>         bool "ACPI Heterogeneous Memory Attribute Table Support"
> > >>         depends on ACPI_NUMA
> > >> +       select HMEM_REPORTING
> > > If you want to do this here, I'm not sure that defining HMEM_REPORTING
> > > as a user-selectable option is a good idea.  In particular, I don't
> > > really think that setting ACPI_HMAT without it makes a lot of sense.
> > > Apart from this, the patch looks reasonable to me.
> >
> > I guess the question is whether we would want to allow folks to consume
> > the HMAT inside the kernel while not reporting it out via
> > HMEM_REPORTING.  We have some in-kernel users of the HMAT lined up like
> > mitigations for memory-side caches.
> >
> > It's certainly possible that folks would want to consume those
> > mitigations without anything in sysfs.  They might not even want or need
> > NUMA support itself, for instance.
> >
> > So, what should we do?
> >
> > config HMEM_REPORTING
> >         bool # no user-visible prompt
> >         default y if ACPI_HMAT
> >
> > So folks can override in their .config, but they don't see a prompt?
> 
> Maybe it would be better to make HMEM_REPORTING do "select ACPI_HMAT if ACPI".
> 
> The mitigations could then do that too if they depend on HMAT and
> ACPI_HMAT need not be user-visible at all.

That sounds okay, though it would create unreachable code if !ACPI since
that's the only user for the new reporting interfaces.

