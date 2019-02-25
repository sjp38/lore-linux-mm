Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70A59C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 16:51:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3877E20C01
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 16:51:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3877E20C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE14D8E0010; Mon, 25 Feb 2019 11:51:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B90A08E000E; Mon, 25 Feb 2019 11:51:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A7F7A8E0010; Mon, 25 Feb 2019 11:51:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 656118E000E
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 11:51:11 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id d3so7377051pgv.23
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 08:51:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=jfEoQJT/Fn8gB9Ej7ChqP19uBo96vax3O9WfrvyIdT8=;
        b=NMRwoZMoDPcETR3tYmXon+xAkV3BhiWKCaIwKgEywnN3XLBNcs1FhCQmL6jHjhwu+R
         dAd9y7fF02rlnk1rj0TNosdkdhNG1pYMvMLzyMPWkqmXG3EkpkZppmbWdd2ZJkDeFK8a
         0iIwLO9/3c1gWmrmDefjGK+Ka281BeLWpblQInunGrle95XRxxdUIcCNopNM7w9Su44J
         rPy0elUkLt1t8eFFHtEakp5whcODuWgz6zTfYpaLeoi+LOmIkPskSPW21KMkmNMx47fu
         +CwwWBECwzSPdRkhVemuPMbVAL2V9nS/xQBDv/GbbsZeL0yEdvhkbSYr84EGwJdBG+Hx
         1kaA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubOtWGbNPFgxORhqPLOqIfLE4IYW0NLwy1CfVDwb1DrP1oiteqK
	Dtm7fxym6ThihKh1kLFd2JdPMqJoLDsHAH2vu019Ub0H90QPGPlDo/MHsvJJ58Ae9CmPXkpQars
	0AKoEoz/cTbwptEnivfxX+jc/JcfNvkS8k9AlGwgCzmnpEOmsDCg4jMig9bRLcKCSeQ==
X-Received: by 2002:a63:e451:: with SMTP id i17mr19924215pgk.413.1551113471076;
        Mon, 25 Feb 2019 08:51:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbQM3DapQpftInKMue0xl+WXXAMMD2hJd9D0FwgvWp9YA9rHH9XsI2rOW9k/dPBElqeOGS0
X-Received: by 2002:a63:e451:: with SMTP id i17mr19924162pgk.413.1551113470119;
        Mon, 25 Feb 2019 08:51:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551113470; cv=none;
        d=google.com; s=arc-20160816;
        b=BwGDz8Jgcncd3RAYN5zMyNkANJcqBnywrCb+9/8fS0FMoEqO37Pnmyc0qk3dpxAVXj
         HUsCmq4BSR4aF2YQrrESBnd/Jh0zJvrUcXvcHk/0ySsTRliALkhUYNkUyJYNFq06wpWh
         5DcmflVeiWI6SxtGEZ2T0ONFLADHqTOPI2bjzDMRWpfoyV6Kvdobxge7yO4l66KYV7eU
         cZGPtWA9OOCt36MrOBhdzh5KzT6L2nrs7d5eieGqbsl7N68iIw6Ho53voASwmwDmuzSZ
         bjKHBkiJPGT40Yz+EV2lNRrF6NYWp5GTx7f7zEKiqupaIQC/RFmIpKYRwbLaBHozmr5I
         I68Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=jfEoQJT/Fn8gB9Ej7ChqP19uBo96vax3O9WfrvyIdT8=;
        b=MEBznC542aUu83n/tZph09Bv57wEaQOw2a7KEctniF0Xltlvsauuf6E8w05b5b8VVQ
         g4DIsPNE2BuXwqQEGndaK8ae0BGaCTBVkKzywMnnb6PPB+ZQifEqxLHY2sNv3KVrexOG
         0xWaRUOlp/8cWZbeiXXEFXYOvcnH6Em9C3qlnTvyTUKESItlaW93GIxnAoFtwvHXFNJz
         oejVbulJKtosWlvcxqEOSCSzBmsa1z5vXsP8grrpfb71MI6yLDnwzag1rLxOSvdq7Ys2
         B0+YUYS/p0ZEtcN7pSeAHkp9x2gKGBADMMW7/UdBHC3LQUY3+5fTWLQGpZiv03S0yEjH
         pj8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id e2si10409767pgm.568.2019.02.25.08.51.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 08:51:10 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Feb 2019 08:51:09 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,411,1544515200"; 
   d="scan'208";a="323239250"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by fmsmga005.fm.intel.com with ESMTP; 25 Feb 2019 08:51:08 -0800
Date: Mon, 25 Feb 2019 09:51:18 -0700
From: Keith Busch <keith.busch@intel.com>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Linux API <linux-api@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCHv6 07/10] acpi/hmat: Register processor domain to its
 memory
Message-ID: <20190225165118.GK10237@localhost.localdomain>
References: <20190214171017.9362-1-keith.busch@intel.com>
 <20190214171017.9362-8-keith.busch@intel.com>
 <CAJZ5v0gjv0DZvYMTPBLnUmMtu8=g0zFd4x-cpP11Kzv+6XCwUw@mail.gmail.com>
 <20190222184831.GF10237@localhost.localdomain>
 <CAJZ5v0hfQ5HWT0kfaOxSbpJvdqotsMWVBCZ6wiL4Tnuy+O5O7Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJZ5v0hfQ5HWT0kfaOxSbpJvdqotsMWVBCZ6wiL4Tnuy+O5O7Q@mail.gmail.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 24, 2019 at 08:59:45PM +0100, Rafael J. Wysocki wrote:
> On Fri, Feb 22, 2019 at 7:48 PM Keith Busch <keith.busch@intel.com> wrote:
> > If I do it the other way around, that's going to make HMEM_REPORTING
> > complicated if a non-ACPI implementation wants to report HMEM
> > properties.
> 
> But the mitigations that Dave was talking about get in the way, don't they?
> 
> Say there is another Kconfig option,CACHE_MITIGATIONS, to enable them.
> Then you want ACPI_HMAT to be set when that it set and you also want
> ACPI_HMAT to be set when HMEM_REPORTING and ACPI_NUMA are both set.
> 
> OTOH, you may not want HMEM_REPORTING to be set when CACHE_MITIGATIONS
> is set, but that causes ACPI_HMAT to be set and which means that
> ACPI_HMAT alone will not be sufficient to determine the
> HMEM_REPORTING value.

I can't think of when we'd want to suppress reporting these attributes
to user space, but I can split HMAT enabling so it doesn't depend on
HMEM_REPORTING just in case there really is an in-kernel user that
definitely does not want the same attributes exported.

> Now, if you prompt for HMEM_REPORTING and make it depend on ACPI_NUMA,
> then ACPI_HMAT can be selected by that (regardless of the
> CACHE_MITIGATIONS value).
> 
> And if someone wants to use HMEM_REPORTING without ACPI_NUMA, it can
> be made depend on whatever new option is there for that non-ACPI
> mechanism.
> 
> There might be a problem if someone wanted to enable the alternative
> way of HMEM_REPORTING if ACPI_NUMA was set (in which case HMAT would
> have to be ignored even if it was present), but in that case there
> would need to be an explicit way to choose between HMAT and non-HMAT
> anyway.
> 
> In any case, I prefer providers to be selected by consumers and not
> the other way around, in case there are multiple consumers for one
> provider.

Well, the HMEM_REPORTING fundamentally has no dependency on any of these
things and I've put some effort into making this part provider agnostic.
I will change it if this concern is gating acceptance, but I don't
think it's as intuitive for generic interfaces to be the selector for
implementation specific providers.

