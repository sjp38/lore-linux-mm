Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01CCDC43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 05:33:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C33EC2084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 05:33:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C33EC2084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 578F16B026D; Fri, 26 Apr 2019 01:33:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5017D6B026E; Fri, 26 Apr 2019 01:33:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A3AE6B026F; Fri, 26 Apr 2019 01:33:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DF66A6B026D
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 01:33:39 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m57so928357edc.7
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 22:33:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fiyROoKbPqBHPWL9Ror7UG8X3l3uq/7N3aRkoVxuRE0=;
        b=Smgeo/1eCDi13C5r7kjdjfJA2Ki4nf7a0RbLyREUaugyXUJL0uUXEDVwLQd9U/ec+S
         eRzTFb3d2p40vvTnnaYnGAi/BPDl/FuXbz3XIeht5C6cQuF5Ox2UmRvjdtK3HND4ih9o
         io5F4TWeVrIaAokP6L41ZqWvfhsuP+2u+ipYW2q8CQQQx8obcwPBhm0K6pA3hHo7pcqm
         fi/ME6EFOQnd+WfJHyO0OnIDfIYmDRMhzCsc/zkBho/srnqsGHitUJexPdRPC1Zd6bmi
         864J75qUPJchDZRgYU3Saj41HTSFthrQvFibDJS7ANHVFZY1GGNIeVyi5cfPNnjd4FHW
         S8Bw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXRfVEieOyngM7UChm/4MDAv38xwR/MkDazDwMfSVCE/IJBgpU0
	JIsDBwrREIEsvzRMEH4OCwZdLwkZ7YVkCL/GmRkFvzOP3jJp2QPXRyjAE2VLcD8vNbmA5PRUR/i
	fh6Yf48pZFAAoNnRziDsqFAIO9yWjB7D68EU89tl9VbQCBIu4AFCApn2ghlpfOHU=
X-Received: by 2002:a17:906:1f53:: with SMTP id d19mr587019ejk.12.1556256819469;
        Thu, 25 Apr 2019 22:33:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxiItXbC88aLQmJVqofwMZfJrek6uK/zz29MrhP4zhXu7tcM+3MM0G2eICUrVHqBzt8kr6T
X-Received: by 2002:a17:906:1f53:: with SMTP id d19mr586982ejk.12.1556256818679;
        Thu, 25 Apr 2019 22:33:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556256818; cv=none;
        d=google.com; s=arc-20160816;
        b=XBuVcRU8MhZLcH3uf0kHOR8QDaIuIT8VVHdLo/ROwErlthr/kGYMUPFU77sOGgKtr5
         Ns7RwuYDL2oXt1Pj/9kK2xbe/kH+I3Q6Pah3hrGX63ybzoM5oQWyx2WXMHEc46hYDMX4
         wqphQFTvUPQBRvzLyi6MSrEGlv5pu0+3e+wQJotbxbMuEdlPc+RyjLfZKrTPMXtls5II
         CkrUSTk3RK6nEJPZmzQF1RHCImzhRQZ6a4UNBvgdq+dcX+s8+dV5O19Oy7xw7QllF313
         IvBqBRc+Z7vXVdKVvKyz/poBILT0wGbiMace1J/oOAPtCu5U1lScKd6sMiuCk5OUqOcb
         D8pA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fiyROoKbPqBHPWL9Ror7UG8X3l3uq/7N3aRkoVxuRE0=;
        b=XyPDEnyUhy9yspoHDbiylnhTun1plfa48IdFwVq9FhID2uozOt5pSngOr572oYLX07
         /+EB3Ni9GTWUx4+B5DEQywYpA5mqjXEeWdvVezck8Yre3ZgbcNBHIUtQXQ0nIpQauQeI
         f8opW8aivc5nPvWJFa1N5G8xzcJajrVUttgNAjID60d4mXDSUnFlBy/Y+k6D8iMdMS6S
         WSt729PDBsK/OA+GdnlWjk9N4+7atRCC/R71KMVf988qZ+rRpW3o4AfpFXASeAnKUmNN
         T+TwXOcZj5Jio8c/FClDngaRyUotB3CT8pb+2XAJcd2XPQKSusHWHYAPl3lWqYQxPrcg
         SkNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c18si1276947edc.21.2019.04.25.22.33.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 22:33:38 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EB6C6AD64;
	Fri, 26 Apr 2019 05:33:37 +0000 (UTC)
Date: Fri, 26 Apr 2019 07:33:35 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Will Deacon <will.deacon@arm.com>, James Morris <jmorris@namei.org>,
	Sasha Levin <sashal@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Keith Busch <keith.busch@intel.com>,
	Vishal L Verma <vishal.l.verma@intel.com>,
	Dave Jiang <dave.jiang@intel.com>,
	Ross Zwisler <zwisler@kernel.org>,
	Tom Lendacky <thomas.lendacky@amd.com>,
	"Huang, Ying" <ying.huang@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>,
	Takashi Iwai <tiwai@suse.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Catalin Marinas <catalin.marinas@arm.com>, rppt@linux.vnet.ibm.com,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>, andrew.murray@arm.com,
	james.morse@arm.com, Marc Zyngier <marc.zyngier@arm.com>,
	sboyd@kernel.org, Linux ARM <linux-arm-kernel@lists.infradead.org>
Subject: Re: [PATCH] arm64: configurable sparsemem section size
Message-ID: <20190426053335.GD12337@dhcp22.suse.cz>
References: <20190423203843.2898-1-pasha.tatashin@soleen.com>
 <20190425152550.GY12751@dhcp22.suse.cz>
 <20190425153138.GC25193@fuggles.cambridge.arm.com>
 <20190425154156.GZ12751@dhcp22.suse.cz>
 <CA+CK2bDLkSTdrYx+zth9=EJxigQR1-nMt52avt7-NpguAWwoVw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+CK2bDLkSTdrYx+zth9=EJxigQR1-nMt52avt7-NpguAWwoVw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-04-19 13:57:25, Pavel Tatashin wrote:
> > > I gave *vague* memories of running out of bits in the page flags if we
> > > changed this, but that was a while back. If that's no longer the case,
> > > then I'm open to changing the value, but I really don't want to expose
> > > it as a Kconfig option as proposed in this patch. People won't have a
> > > clue what to set and it doesn't help at all with the single-Image effort.
> >
> > Ohh, I absolutely agree about the config option part JFTR. 1GB section
> > loos quite excessive. I am not really sure a standard arm64 memory
> > layout looks though.
> 
> I am now looking to use Dan's patches "mm: Sub-section memory hotplug
> support" to solve this problem. I think this patch can be ignored.

Even if the subsection memory hotplug is going to be used then the
underlying question remains. If there is no real reason to use large
memsections then it would be better to use smaller ones.
-- 
Michal Hocko
SUSE Labs

