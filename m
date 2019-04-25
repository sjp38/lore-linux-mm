Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35F9DC4321A
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:31:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59535215EA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:31:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59535215EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DA656B000D; Thu, 25 Apr 2019 11:31:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 888E76B0010; Thu, 25 Apr 2019 11:31:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 777A66B0266; Thu, 25 Apr 2019 11:31:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 20FAA6B000D
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 11:31:48 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o8so11822233edh.12
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 08:31:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0n5bDWrXJ+kLKddpIgwG4vwMM1+teLWtBbzY9CTThTw=;
        b=otoQolTrsjf10GbD8Fgs33iYdnB8dhBKTgHTcbO1h7PU/lSy4bgR7ppLDYQGvIcDAq
         kkjOzgNdOQ1tk+7OfaORVaK7qxav7CxpbdTDsHVjWftF3UXwFM/LcRX1P6EF49+oZGSn
         pc7IyWGMKqciJUibjaTlUiC7F0XLmmHdxQvy2ii+VerLTU41bhrsDxkecpKrPfTamPWz
         dJth2+P/VMNU0Jfmqtk8X26yOPhz0KwkfoN1wZc24uDm2MkENpIde0ijI3xzaYbBblTe
         V+hYHzsQJ07XWxVQZV1yHF6T120jLLe/+mUAAQxvYiIZWPmnq7k7g0WT8K7Wd5YHMnI/
         2kdA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: APjAAAXk4ggQLLVwbFy2hfxTQs//+5J0QlJgCwmmYjp/yq3iVsQHwHRr
	eurpMtXNiA4Vsq5JzM3828FwrClphzbQIz6VyNYEatlkohK2B0E+kG8bwJ/N7FYX212DJRz3b9E
	orEi/CT2YfKreRXUcitZ+17fYnzPWqXPZdcMxe1e0FaV7k378EkOZrqhqMIFYWOmwow==
X-Received: by 2002:a17:906:3d31:: with SMTP id l17mr19997564ejf.67.1556206307634;
        Thu, 25 Apr 2019 08:31:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZkKMiZAqirwKAWQTvfJ1z9m3FEgShV5UbfUzcNKfemVTorp6Yvz0iYn3CDQXZQBZuc9JP
X-Received: by 2002:a17:906:3d31:: with SMTP id l17mr19997521ejf.67.1556206306801;
        Thu, 25 Apr 2019 08:31:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556206306; cv=none;
        d=google.com; s=arc-20160816;
        b=vN7RUsiJmlq/lx6fiT8i2icd3iTeklCjSqveSDqmrZAItlr8RmnUGNR/Lf0cpOb+Zo
         N/6IXFRR2so4+uIXBP5aj+Z2Snqhno2n9mx06iq0sJNoEJNxYstjld858vjWefu7YLVE
         Gvp+HBx7SYupCUH3js8PlsDDkx0ivXNW5qeEYYNpVSD7JKTJqX/UpsUNuJZ1e+koLICn
         Io3NCE6HQFx+9PMZM3108FO8oHgURMpfaRuFaKjHJ4tfW6rwNH82n+lyQzmikDCC9g19
         5sWfZVRf0SZWV9IOoHsLdp5O34skND0fyu6PJPDVHdSvX45LG7fD0K3pqnKFbSUqx4a4
         Vy2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0n5bDWrXJ+kLKddpIgwG4vwMM1+teLWtBbzY9CTThTw=;
        b=Fn1fXBOoM+GlwORAvqb4PX+UPItvfaL6xK5CcIJGfI9QUQqQTzsA7zAUPRHpYP2G9m
         a9mg0M8nbutCOUj21BKK5nhkAd37SQ8Xb5PafgqjMh2wv3CZkdCwSZGm89qTKpouG2yV
         q1W9y7MCdST23CJ01dhjmBRizBn6qMhxs389KrysCzYDaWxQZm25/u2Ebm36ssugkNCQ
         bpUq2sdCBiXar8jwhP7egHai7+6PyEBXJId5V8Y2bMNB+bLfeopUGdsqdQA45fk3mTmB
         sMChGzX5SzpuNw+8LnnHTRmefs8nE7dN4TQok9CKLJXJozgncCZVbi3IECy9e1qGd22p
         ACOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h15si149478edf.325.2019.04.25.08.31.46
        for <linux-mm@kvack.org>;
        Thu, 25 Apr 2019 08:31:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B20D4A78;
	Thu, 25 Apr 2019 08:31:45 -0700 (PDT)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id CAC243F557;
	Thu, 25 Apr 2019 08:31:40 -0700 (PDT)
Date: Thu, 25 Apr 2019 16:31:38 +0100
From: Will Deacon <will.deacon@arm.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>, jmorris@namei.org,
	sashal@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-nvdimm@lists.01.org, akpm@linux-foundation.org,
	dave.hansen@linux.intel.com, dan.j.williams@intel.com,
	keith.busch@intel.com, vishal.l.verma@intel.com,
	dave.jiang@intel.com, zwisler@kernel.org, thomas.lendacky@amd.com,
	ying.huang@intel.com, fengguang.wu@intel.com, bp@suse.de,
	bhelgaas@google.com, baiyaowei@cmss.chinamobile.com, tiwai@suse.de,
	jglisse@redhat.com, catalin.marinas@arm.com,
	rppt@linux.vnet.ibm.com, ard.biesheuvel@linaro.org,
	andrew.murray@arm.com, james.morse@arm.com, marc.zyngier@arm.com,
	sboyd@kernel.org, linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH] arm64: configurable sparsemem section size
Message-ID: <20190425153138.GC25193@fuggles.cambridge.arm.com>
References: <20190423203843.2898-1-pasha.tatashin@soleen.com>
 <20190425152550.GY12751@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190425152550.GY12751@dhcp22.suse.cz>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 05:25:50PM +0200, Michal Hocko wrote:
> On Tue 23-04-19 16:38:43, Pavel Tatashin wrote:
> > sparsemem section size determines the maximum size and alignment that
> > is allowed to offline/online memory block. The bigger the size the less
> > the clutter in /sys/devices/system/memory/*. On the other hand, however,
> > there is less flexability in what granules of memory can be added and
> > removed.
> > 
> > Recently, it was enabled in Linux to hotadd persistent memory that
> > can be either real NV device, or reserved from regular System RAM
> > and has identity of devdax.
> > 
> > The problem is that because ARM64's section size is 1G, and devdax must
> > have 2M label section, the first 1G is always missed when device is
> > attached, because it is not 1G aligned.
> > 
> > Allow, better flexibility by making section size configurable.
> 
> Is there any inherent reason (64k page size?) that enforces such a large
> memsection?

I gave *vague* memories of running out of bits in the page flags if we
changed this, but that was a while back. If that's no longer the case,
then I'm open to changing the value, but I really don't want to expose
it as a Kconfig option as proposed in this patch. People won't have a
clue what to set and it doesn't help at all with the single-Image effort.

Will

