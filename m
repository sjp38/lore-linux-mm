Return-Path: <SRS0=4n/l=R3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F077EC43381
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 21:19:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9086220811
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 21:19:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9086220811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AE696B0003; Sun, 24 Mar 2019 17:19:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15E8C6B0005; Sun, 24 Mar 2019 17:19:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 025D76B0007; Sun, 24 Mar 2019 17:19:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B4D346B0003
	for <linux-mm@kvack.org>; Sun, 24 Mar 2019 17:19:41 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g125so7786574pfb.1
        for <linux-mm@kvack.org>; Sun, 24 Mar 2019 14:19:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:organization:user-agent;
        bh=2q8VJPxEOugiFas2XT18kXD4oIc28SiyDHzakhCWu9M=;
        b=q13ypu6FU5uO46JXIdshNxKhuVVNnWcZzAyhC2n9/UfZ87XlUp28rdYEbVMUkebBM0
         fWZ+Iy9CbOA5vYkmae77GCV/CJFFCKl84Mf2M8otb+j5WHQGyR8TBfXDcmMEz+T4AryP
         9mBnl+Om65E5rDnowa/HIv/ojKVEoYxQYM5PyWP02hPovMEVL8K+H8Lfic58KbJzDpjz
         FIhDofKKt16wmCz6P8Gd8xUjtssKPABrXLvDStbCBE57mzAZSCZhcdVu2Yv4Fw2quxes
         RV2LPF0GK1PnKuIdnmDXSVmoSxJ3gxo+icfLJA06B8HCJrqBI+9sfSyy8hZirlTkPjwE
         SXzQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of andriy.shevchenko@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=andriy.shevchenko@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV4/ph8gxJFJKtf2EN/ameu6Mc0uBgs/0RHnNMcf73le70+5Rht
	HMpkRwNlVQtFGTP7RB8Ih1nnGKUwgZyBpx8aZbN1PONmKc/MzmQR8nk3Z4E6Pj9vO0iAQn6omsy
	1kQUYPryJlmIPH2Hsadz+Xjwn6/p+yApIGBiiISSbAvJgcogWiR9DZ0k9qWqF7ekR9A==
X-Received: by 2002:a63:1060:: with SMTP id 32mr20119925pgq.126.1553462381395;
        Sun, 24 Mar 2019 14:19:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFvpfmm8tQpU78BVvj8vF2dDOgYpx6dIHdGSdwTuRVyueIqJ1MN+SkECUecPwbquEWZcz8
X-Received: by 2002:a63:1060:: with SMTP id 32mr20119873pgq.126.1553462380654;
        Sun, 24 Mar 2019 14:19:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553462380; cv=none;
        d=google.com; s=arc-20160816;
        b=WfCb/yDdG26vjPhfH+TCMS5ypKXYWH9rotWnw+pGKpCvAAM9o545bK4G071MoJ3mc2
         oPVMoEoxkENAvZgN5/DyzhIijKletr8acAWGL0AgjDC8PJjpZLsYYja8NjnmwX9dQe9S
         HQU0ws08vMB/sFEZW8Ks37Hw8pypGaWgz+/B+hDnKOxfEHsz7mcO8NMD4hBz3D6wI86W
         LbJ4Bshyjzal1Wte0ZcM62zH7zgx2qE5svifAasqoo9G1kjZvcD9i/Q7qJ6DImm6pPYn
         sOvXZN+7bAq/wy6e+6M5qIn6s0MCgVR2EZJNInnmNOKWGgLnBvgMEnO297BHi53nDalz
         t3+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:organization:in-reply-to:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=2q8VJPxEOugiFas2XT18kXD4oIc28SiyDHzakhCWu9M=;
        b=OCM6qRKOezyp4XcE5XZvA5H8p2sboiFHJRCfaRo4W85qOh+W6NK393wsIbyQN5AVwB
         bYl88ceJTZKZV08WtAUe6SZ0TTXEkA+FD7hxWTEe5oYNG50v51uGs98tdxevULattmUc
         6PHqtenDDWf6OaciGRtpViPQAe8hAFYbo20v2+V12rODZ37aWc4sJ1ac3tGzxtkkqXly
         BSSXwt/u9R/3UAq21Z04jMagBmO1jQNbVnophTj0Ox0I2k7TAY04IBwasGcWifYqX9dm
         35LWE+N1lWwoYfvSxyjKo7wZ0aB79Z/mHS3IL5OiMtl2B/smJPmTrmfzPPS9RvQenfai
         uDnw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of andriy.shevchenko@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=andriy.shevchenko@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id f3si11673289pgs.557.2019.03.24.14.19.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Mar 2019 14:19:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of andriy.shevchenko@linux.intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of andriy.shevchenko@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=andriy.shevchenko@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Mar 2019 14:19:39 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,256,1549958400"; 
   d="scan'208";a="129807518"
Received: from smile.fi.intel.com (HELO smile) ([10.237.72.86])
  by orsmga006.jf.intel.com with ESMTP; 24 Mar 2019 14:19:34 -0700
Received: from andy by smile with local (Exim 4.92)
	(envelope-from <andriy.shevchenko@linux.intel.com>)
	id 1h8AWi-0006Gz-Fh; Sun, 24 Mar 2019 23:19:32 +0200
Date: Sun, 24 Mar 2019 23:19:32 +0200
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Sakari Ailus <sakari.ailus@linux.intel.com>
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
Message-ID: <20190324211932.GK9224@smile.fi.intel.com>
References: <20190322132108.25501-1-sakari.ailus@linux.intel.com>
 <CAMuHMdVmqqjVx7As9AAywYxYXG=grijF5rF77OBn6TUjM9+xKw@mail.gmail.com>
 <20190322135350.2btpno7vspvewxvk@paasikivi.fi.intel.com>
 <20190322170550.GX9224@smile.fi.intel.com>
 <20190324211008.lypghym3gqcp62th@mara.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190324211008.lypghym3gqcp62th@mara.localdomain>
Organization: Intel Finland Oy - BIC 0357606-4 - Westendinkatu 7, 02160 Espoo
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 24, 2019 at 11:10:08PM +0200, Sakari Ailus wrote:
> On Fri, Mar 22, 2019 at 07:05:50PM +0200, Andy Shevchenko wrote:
> > On Fri, Mar 22, 2019 at 03:53:50PM +0200, Sakari Ailus wrote:
> > 
> > > Porting a patch
> > > forward should have no issues either as checkpatch.pl has been complaining
> > > of the use of %pf and %pF for a while now.
> > 
> > And that's exactly the reason why I think instead of removing warning on
> > checkpatch, it makes sense to convert to an error for a while. People are
> > tending read documentation on internet and thus might have outdated one. And
> > yes, the compiler doesn't tell a thing about it.
> > 
> > P.S. Though, if majority of people will tell that I'm wrong, then it's okay to
> > remove.
> 
> I wonder if you wrote this before seeing my other patchset.

Yes, I wrote it before seeing another series.

> What I think could be done is to warn of plain %pf (without following "w")
> in checkpatch.pl, and %pf that is not followed by "w" in the kernel.
> Although we didn't have such checks to begin with. The case is still a
> little bit different as %pf used to be a valid conversion specifier whereas
> %pO likely has never existed.
> 
> So, how about adding such checks in the other set? I can retain %p[fF] check
> here, too, if you like.

Consistency tells me that the warning->error transformation in checkpatch.pl
belongs this series.


-- 
With Best Regards,
Andy Shevchenko


