Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BB45C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 14:34:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36642216C4
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 14:34:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36642216C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C43B86B0286; Fri, 10 May 2019 10:34:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF3CF6B02A8; Fri, 10 May 2019 10:34:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE2CD6B02A9; Fri, 10 May 2019 10:34:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 781446B0286
	for <linux-mm@kvack.org>; Fri, 10 May 2019 10:34:20 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e14so4163581pgg.12
        for <linux-mm@kvack.org>; Fri, 10 May 2019 07:34:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:organization:user-agent;
        bh=TNP1HUuoUO6FWSzrorUm/vSKAzgB8akARFc1HKNmoZg=;
        b=XbvymhzqWHE3B7IPS9RpOdaXfn4wUd5o3XXXIsCpatAmdZToJ7eCTh13fyKiZ1OvX9
         AO9U/bHo9phf2pIO0K8e0cbLSpiNsLEcj4hyCmo6aFAxyCITZLaz7VDeyI0Uz09x2o9Z
         3x78/aznLZaXDsAK3JtRz0PqKw1Em9jEIr0uGxLpH3nOvZr2Hah8aqm5i04udn04dfU9
         k1b+GUdsvVScXTeSJWorKUXcOENVarpTKeuJZj41ddKZlt/kH2JQIann3t/VyYVu+NgT
         dpAZfaqD6T78QwwUFHwEaOsbalwz0KpSWSz1PTdHeizHAMqugc9yx1tGuz+Lxou9UKvP
         Rz7Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of andriy.shevchenko@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=andriy.shevchenko@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWfMhxJnSA8tW3qNNgJvcHEeXoM9Kih5f4CMCgtL2B+ufaGDOcY
	6SKH5h1Ct/KsnQfVUr1W1e5nIQQRbJ50Sk2/gogn4ed7Y9zqL1bC34lnP9FbqTPn2SDVIjXaspd
	qHyb/FTQ+PEerNg7JWBqOa6RTLTefLK8g9ByanaTXNRQKocLSivmF56C0YY4Cl8BV9w==
X-Received: by 2002:a62:470e:: with SMTP id u14mr14610288pfa.31.1557498860157;
        Fri, 10 May 2019 07:34:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+VIkxK0J5O4ev8NoSd1gG0DjgXLMpvUH77oaG5Q25y2Fx+/haDvMbdYw1lWRTW3Zw/VCy
X-Received: by 2002:a62:470e:: with SMTP id u14mr14609905pfa.31.1557498857640;
        Fri, 10 May 2019 07:34:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557498857; cv=none;
        d=google.com; s=arc-20160816;
        b=hhmXmDwrduBCSY9pRCqqGP3CK5aK3DxZ1n5muiwc/cXV+SA477pio1L53q9pBLqX4l
         l8lJovf9OfKv0CO4eup4s6UmbZxepmCOENdDRMO25nyQJy49K+3La1Regcnmitex75iL
         gSsi9X9lZcnDzyyiTOmiMFCgftybMwlKsOEw+OPvL3t1n3d//KZNNliZooZ34kqr8ER3
         xpDeSBVSzUo3WJEOqpbHxGgeLkuxa1drnb3GH2ft5R3k1DDEoEh3OUqwGBCc1LdIZjrr
         2rL4kg5GleyQ2LsZ0x9AoSk5kasYRvDslTyHJ4aQiVg/IaTuZs6wWlp/pX2AQV1HAiDX
         Kj9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:organization:in-reply-to:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=TNP1HUuoUO6FWSzrorUm/vSKAzgB8akARFc1HKNmoZg=;
        b=VUAsy21+pIpNmw1iOKUZQC87Ar/DH6xCrNGIjfsLhm5EsHaAOBcC3xXMMOcGPNzSo2
         Sqo7/+3g0wJicTlTpwJImfZaTrtNJoAhYEsQfkBAOVNoB0Ng5ahVG5rHs+lqK1HEUbcs
         24j9AzW6vpTyHyKKms4e1EJaO/x4TZmz0volazEoWaDeCg3a98BghN/c7UVNnHadTVe/
         jo7yK0lmwIWO+k5BsPd9SrPSnpgbHudngpbIj6GeMylg0PFwNA56YFHDqhHNcxft9+4b
         CY6fFHQBZUK622oQKNSAvTNMsS7Ddm8gZm1/KDkeXteOQojcH6Hu/6QQHgLw9IDrNt/R
         JgaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of andriy.shevchenko@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=andriy.shevchenko@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 31si7501041pli.242.2019.05.10.07.34.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 07:34:17 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of andriy.shevchenko@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of andriy.shevchenko@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=andriy.shevchenko@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 May 2019 07:34:16 -0700
X-ExtLoop1: 1
Received: from smile.fi.intel.com (HELO smile) ([10.237.72.86])
  by orsmga002.jf.intel.com with ESMTP; 10 May 2019 07:34:08 -0700
Received: from andy by smile with local (Exim 4.92)
	(envelope-from <andriy.shevchenko@linux.intel.com>)
	id 1hP6b9-0004Sg-Pc; Fri, 10 May 2019 17:34:07 +0300
Date: Fri, 10 May 2019 17:34:07 +0300
From: "andriy.shevchenko@linux.intel.com" <andriy.shevchenko@linux.intel.com>
To: "Ardelean, Alexandru" <alexandru.Ardelean@analog.com>
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
	"intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>,
	"linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	"linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>,
	"devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
	"linux-integrity@vger.kernel.org" <linux-integrity@vger.kernel.org>,
	"linux-fbdev@vger.kernel.org" <linux-fbdev@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-rpi-kernel@lists.infradead.org" <linux-rpi-kernel@lists.infradead.org>,
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"alsa-devel@alsa-project.org" <alsa-devel@alsa-project.org>,
	"linux-rockchip@lists.infradead.org" <linux-rockchip@lists.infradead.org>,
	"linux-clk@vger.kernel.org" <linux-clk@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>,
	"linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>
Subject: Re: [PATCH 03/16] lib,treewide: add new match_string() helper/macro
Message-ID: <20190510143407.GA9224@smile.fi.intel.com>
References: <20190508112842.11654-1-alexandru.ardelean@analog.com>
 <20190508112842.11654-5-alexandru.ardelean@analog.com>
 <20190508131128.GL9224@smile.fi.intel.com>
 <20190508131856.GB10138@kroah.com>
 <b2440bc9485456a7a90a488c528997587b22088b.camel@analog.com>
 <4df165bc4247e60aa4952fd55cb0c77e60712767.camel@analog.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4df165bc4247e60aa4952fd55cb0c77e60712767.camel@analog.com>
Organization: Intel Finland Oy - BIC 0357606-4 - Westendinkatu 7, 02160 Espoo
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 10, 2019 at 09:15:27AM +0000, Ardelean, Alexandru wrote:
> On Wed, 2019-05-08 at 16:22 +0300, Alexandru Ardelean wrote:
> > On Wed, 2019-05-08 at 15:18 +0200, Greg KH wrote:
> > > On Wed, May 08, 2019 at 04:11:28PM +0300, Andy Shevchenko wrote:
> > > > On Wed, May 08, 2019 at 02:28:29PM +0300, Alexandru Ardelean wrote:

> > > > Can you split include/linux/ change from the rest?
> > > 
> > > That would break the build, why do you want it split out?  This makes
> > > sense all as a single patch to me.
> > > 
> > 
> > Not really.
> > It would be just be the new match_string() helper/macro in a new commit.
> > And the conversions of the simple users of match_string() (the ones using
> > ARRAY_SIZE()) in another commit.
> > 
> 
> I should have asked in my previous reply.
> Leave this as-is or re-formulate in 2 patches ?

Depends on on what you would like to spend your time: collecting Acks for all
pieces in treewide patch or send new API first followed up by per driver /
module update in next cycle.

I also have no strong preference.
And I think it's good to add Heikki Krogerus to Cc list for both patch series,
since he is the author of sysfs variant and may have something to comment on
the rest.

-- 
With Best Regards,
Andy Shevchenko


