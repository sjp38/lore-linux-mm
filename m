Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C779FC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 15:24:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86E322087E
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 15:24:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86E322087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2363A6B0003; Mon, 25 Mar 2019 11:24:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BC8F6B0006; Mon, 25 Mar 2019 11:24:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05E986B0007; Mon, 25 Mar 2019 11:24:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id BCC4E6B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 11:24:19 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id x5so135069pll.2
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 08:24:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:organization:user-agent;
        bh=PYqWwZRXS90/KtcfyWd4Hrl4+0U8zHEgnn26LOTIWnU=;
        b=OXyc31Rx55SiEkuDkI3tXwstnOWOr55o+Jjjig+rPh8UTmwx9iTVdbnonsWxWCiDpJ
         386qP85QBCZU8W5+LoTqeLbsLZm5XHEP9Umq6UCfLOFNEA+IuozxoW4oKKqi/c+k6qTF
         QJrzJgGSZQLwurvmCbKG2zhHFhE0Mw9tUnMprhD6U21noVQGIOJ5uwfCYbHnxH0mQh9V
         WG+kgCFaOjogw1UlbRFFSBbYOpvUvRpuA2PF30iMUOzAWjc3LtEuJrbMFNjdTg185aFS
         if5I3hUhOVXPx0uLHgLhvzkW2UqVGVGUfx0bgEoZHiq5bp5SwLG6gjxEPZfslHvv9M1N
         1ecg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of andriy.shevchenko@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=andriy.shevchenko@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXpgqwveJH6bQmZ1BwNrIjWmlZc5KQBpKscWt9nPuQrKIHco1OH
	Wab/hgO22pHY0ekMmEvP3C6ruC6aHVC8CeIUAtRlwa1PUf6hd0d+xP+ChDRJauxC4Reg9IUhcj4
	ZoJYcUz4Z1lLn7tVIqZAp2o/xSM3+5a5COJ3rjnhBFDDkRehYTRH3n6lumfJt6wZKFA==
X-Received: by 2002:a63:2f44:: with SMTP id v65mr23614515pgv.141.1553527459402;
        Mon, 25 Mar 2019 08:24:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIjhivBbh679kd5yVCLJZPpD6I9F2+YQbTqD6NS9QsRirgepZZdRiOuRC8QNnvRxXeJHgk
X-Received: by 2002:a63:2f44:: with SMTP id v65mr23614445pgv.141.1553527458557;
        Mon, 25 Mar 2019 08:24:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553527458; cv=none;
        d=google.com; s=arc-20160816;
        b=l55vPOvFWHq8Jk21RY3RBM94VXL1cJRF5sO9xSKM0pgk2YvTACdJWFdQNq/Mm5H5aR
         WZazmddCpS/NuVQw3nj7Q9/6nBrDO8U7Vyo/2Yo9mkVKzZfQKQSh6oHfESZsRtCk276N
         zNvecj7BWvVD7N/7kbTkAyqSA2dxp30xa6JQY4AyjHQNFUqtqnaz2UKOM7FCdvNepv09
         QuVxQ+5Mp0cyvYb8q0L+c1pFURlt131aVLk4+J1qz1k3vKid+GD1CJ6Y5TWxDy0ha91w
         PnHjpm7mVcHupqELOv3M4nqHAgv+ZsQAoN6sjvPxLygJkEAUPVP5O9cTeCXJSn+WCi1l
         DxEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:organization:in-reply-to:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=PYqWwZRXS90/KtcfyWd4Hrl4+0U8zHEgnn26LOTIWnU=;
        b=uxNwyRFkM3XyJcHTB3RMPel2+q5Jon7Uo1r0a76MLOBysH7Y5PY3xKrwXmbGMt1YbA
         3svNiDk725fKo3//ESCi1o48UiFOKg2/Z2/AeKvd9+l3vXb7n0vbpGftD6QCSwAYp1dk
         BSj5tCf/k6HW5J+tKfbXhOEgMbPxf2WlTA8o/can+v9sAXTpT6ddxXlG3Jli1StUZUY0
         uUfMlC8239ikx8gxP5rIdfQgrPa3xYbomQ3WW6OsedLkMjcli/bpDHXU4RJD/kyYQBml
         qiniboZ7mfMQTWldIX4Y6OyjRGBGP2BEqxGWEmV1AYRNaUBVAoEE59XtHO8qUIN2w7mH
         YjnA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of andriy.shevchenko@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=andriy.shevchenko@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id q7si7743264pls.259.2019.03.25.08.24.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 08:24:18 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of andriy.shevchenko@linux.intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of andriy.shevchenko@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=andriy.shevchenko@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Mar 2019 08:24:17 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,269,1549958400"; 
   d="scan'208";a="128504383"
Received: from smile.fi.intel.com (HELO smile) ([10.237.72.86])
  by orsmga008.jf.intel.com with ESMTP; 25 Mar 2019 08:24:11 -0700
Received: from andy by smile with local (Exim 4.92)
	(envelope-from <andriy.shevchenko@linux.intel.com>)
	id 1h8RSL-0007EQ-PF; Mon, 25 Mar 2019 17:24:09 +0200
Date: Mon, 25 Mar 2019 17:24:09 +0200
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
Message-ID: <20190325152409.GF9224@smile.fi.intel.com>
References: <20190322132108.25501-1-sakari.ailus@linux.intel.com>
 <CAMuHMdVmqqjVx7As9AAywYxYXG=grijF5rF77OBn6TUjM9+xKw@mail.gmail.com>
 <20190322135350.2btpno7vspvewxvk@paasikivi.fi.intel.com>
 <20190322170550.GX9224@smile.fi.intel.com>
 <20190324211008.lypghym3gqcp62th@mara.localdomain>
 <20190324211932.GK9224@smile.fi.intel.com>
 <20190325151259.2w22y4ijqilrbaxj@kekkonen.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190325151259.2w22y4ijqilrbaxj@kekkonen.localdomain>
Organization: Intel Finland Oy - BIC 0357606-4 - Westendinkatu 7, 02160 Espoo
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001619, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 05:13:00PM +0200, Sakari Ailus wrote:

> All other invalid pointer conversion specifiers currently result into a
> warning only. I see that as an orthogonal change to this set. I found
> another issue in checkpatch.pl that may require some discussion; would you
> be ok with addressing this in another set?

If it looks better that way, I have no objection.

-- 
With Best Regards,
Andy Shevchenko


