Return-Path: <SRS0=4n/l=R3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD271C10F11
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 21:10:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7714420880
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 21:10:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7714420880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F236C6B0003; Sun, 24 Mar 2019 17:10:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED2906B0005; Sun, 24 Mar 2019 17:10:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE8686B0007; Sun, 24 Mar 2019 17:10:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A92536B0003
	for <linux-mm@kvack.org>; Sun, 24 Mar 2019 17:10:19 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g83so7753296pfd.3
        for <linux-mm@kvack.org>; Sun, 24 Mar 2019 14:10:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZrajNULdIlZUieh1ZvljV4SK9KDMYoddYp/UioHM/7A=;
        b=MG1oP1ORD2ugsABLkKG/Qa0ItsSdh2VMnRaSb4UF+OPgMBX0qjBz9bFMZh9zHDdN4z
         fqwfJVf47pRx/+3jLCdMkuXaeemb7N/1SNP1U+IBR9cRHAAnvU+NP4HAw8AX8YrqANv9
         pgT0JP+/oTpdPZT3ernFj3gg5aTrNfsrNH1xPwoE5sWOp3vNrXWxABTVGDQeB/ueUaqW
         3rqqlxbShYYiTNC9UrgeeIL5rX+EgEW9ftSJk/QnBhPNnO6kWoVMvmwxgFU9y1lE80/S
         5/wDew9zPKuhuc76MFre4xuk2TKlSIKGzIaThw+aoGj3js3VM5wLfdEy03EfgnVs4AoR
         N0KA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of sakari.ailus@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=sakari.ailus@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXRSBVOu4ANwzpFJGwQ2AzT4SNNGv/kXMryKjTQbKYqq2CtHXH9
	97eIm4Un3w9FU9ql5Jg/3+8xyjIElTfDTBSL+JvbwYLLRPhdb0+3SgX0PEFdUAxRmgtGJd6ogsT
	mDj0sPqw9SeJYwjNU/QxoBJKdHhvazdfNOFsO3dRHUU3D/ZxVYhcDm0eXNDcKrGrdxg==
X-Received: by 2002:a63:94:: with SMTP id 142mr20034920pga.277.1553461819300;
        Sun, 24 Mar 2019 14:10:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpH8ZmvCcy3dRO/Przre9OIk+to+7AkmAYrexPfJlDxVDwHNYDUOZNVCH0PaSwhQ/2Wf1T
X-Received: by 2002:a63:94:: with SMTP id 142mr20034847pga.277.1553461818134;
        Sun, 24 Mar 2019 14:10:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553461818; cv=none;
        d=google.com; s=arc-20160816;
        b=iDkjdE4CXIofiWIr4At7JYDl/mvG4P/xSrlmMiVpbuNhmh7mECpCBFQu2FBJM2Fxui
         4xBlxikCVaTJny/TiBCmzb18w0SMaZBnf4s/CRvzvMuaFvh7QsUae2u+OtzmTBLZ5ipP
         Z0s7vLI/xssRVuinv2vJpYuMUSENZCLr+4flUEcU0CV8l4GJqUV5Yr/RKhY561cYgmY8
         LYB6fR/JvVYNtZgXo4yI9Iju8Yi07R/+civBbKNusIwKSd4RD2W81Yk+4fwBGVSUPNqr
         2qrLwfCLyWJ0x4IIzc5TQCP0dIL+5koLWBnLVAmu/2Tkrq9lF4npFHKH0RnSEsk/Hgim
         IDpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZrajNULdIlZUieh1ZvljV4SK9KDMYoddYp/UioHM/7A=;
        b=XHSi1fpS4ryLVBiBoauUWGrf7xVR8bsOsljrTzQNDF72sVDwjoIWqcS+RF2yqSv2jr
         pHrIZdAjctumSKgo44fXIzyQxFlL0VFGyIqqq+MwjjPCkL9vho99HyyR3VoWuX+e1pZi
         qyj6YamfF+xZ5r4p79z4ejPGk1+iRfQ2Goqpz7RAPcXKTDD91r0Bv+O3WpRogoFdiABS
         WY5bP7IOO7obF6BHK2MwaQyDsZnrfI1Xhv1HdVvc2qMnRQXTiqM96116xnliiaDvFst6
         cf4qFeXZWY7Ve4bqaJnj4yYLASVuYvKtBZB90MKsnBQ3YVg8lspZxajwwiFm1dbrPwmW
         amfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of sakari.ailus@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=sakari.ailus@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id k7si10817796pgi.451.2019.03.24.14.10.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Mar 2019 14:10:17 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of sakari.ailus@linux.intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of sakari.ailus@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=sakari.ailus@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Mar 2019 14:10:17 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,256,1549958400"; 
   d="scan'208";a="331600917"
Received: from pnass-mobl.ger.corp.intel.com (HELO mara.localdomain) ([10.249.136.221])
  by fmsmga005.fm.intel.com with ESMTP; 24 Mar 2019 14:10:11 -0700
Received: from sailus by mara.localdomain with local (Exim 4.89)
	(envelope-from <sakari.ailus@linux.intel.com>)
	id 1h8ANd-0000IX-8x; Sun, 24 Mar 2019 23:10:09 +0200
Date: Sun, 24 Mar 2019 23:10:08 +0200
From: Sakari Ailus <sakari.ailus@linux.intel.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Petr Mladek <pmladek@suse.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	scsi <linux-scsi@vger.kernel.org>,
	Linux PM list <linux-pm@vger.kernel.org>,
	Linux MMC List <linux-mmc@vger.kernel.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	linux-um@lists.infradead.org,
	linux-f2fs-devel@lists.sourceforge.net, linux-block@vger.kernel.org,
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-btrfs <linux-btrfs@vger.kernel.org>,
	linux-pci <linux-pci@vger.kernel.org>,
	sparclinux <sparclinux@vger.kernel.org>,
	xen-devel@lists.xenproject.org,
	ceph-devel <ceph-devel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Lars Ellenberg <drbd-dev@lists.linbit.com>
Subject: Re: [PATCH 0/2] Remove support for deprecated %pf and %pF in vsprintf
Message-ID: <20190324211008.lypghym3gqcp62th@mara.localdomain>
References: <20190322132108.25501-1-sakari.ailus@linux.intel.com>
 <CAMuHMdVmqqjVx7As9AAywYxYXG=grijF5rF77OBn6TUjM9+xKw@mail.gmail.com>
 <20190322135350.2btpno7vspvewxvk@paasikivi.fi.intel.com>
 <20190322170550.GX9224@smile.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190322170550.GX9224@smile.fi.intel.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andy,

On Fri, Mar 22, 2019 at 07:05:50PM +0200, Andy Shevchenko wrote:
> On Fri, Mar 22, 2019 at 03:53:50PM +0200, Sakari Ailus wrote:
> 
> > Porting a patch
> > forward should have no issues either as checkpatch.pl has been complaining
> > of the use of %pf and %pF for a while now.
> 
> And that's exactly the reason why I think instead of removing warning on
> checkpatch, it makes sense to convert to an error for a while. People are
> tending read documentation on internet and thus might have outdated one. And
> yes, the compiler doesn't tell a thing about it.
> 
> P.S. Though, if majority of people will tell that I'm wrong, then it's okay to
> remove.

I wonder if you wrote this before seeing my other patchset.

For others as the background, it adds %pfw to print fwnode node names.
Assuming this would be merged, %pfw could be in use relatively soon. With
the current patchset, %pf prints nothing just as %pO ("F" missing).

What I think could be done is to warn of plain %pf (without following "w")
in checkpatch.pl, and %pf that is not followed by "w" in the kernel.
Although we didn't have such checks to begin with. The case is still a
little bit different as %pf used to be a valid conversion specifier whereas
%pO likely has never existed.

So, how about adding such checks in the other set? I can retain %p[fF] check
here, too, if you like.

-- 
Kind regards,

Sakari Ailus
sakari.ailus@linux.intel.com

