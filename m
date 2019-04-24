Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5954C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 20:24:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D17320835
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 20:24:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="00CRCUef"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D17320835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0ED976B0006; Wed, 24 Apr 2019 16:24:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 076146B0007; Wed, 24 Apr 2019 16:24:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7FDF6B0008; Wed, 24 Apr 2019 16:24:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id B7C666B0006
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 16:24:29 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id s64so8096158oia.15
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 13:24:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=V9mJ7ZcGzEPuIiUC1HRKB7NtqsbiOoETZ948+wVXfwg=;
        b=uSzamMSX1CA66V/Y6K/wUfDDbQWYTAItZnxDXcwDbS0HVSgTYvLFoLQ1h5/BDTUHyL
         zkNQ45yxL/qznBT3ZCBQ3Dg33G/uKX+onhuu6SIR3wHA3rfGSI/Mb/WF1fcp8F3UN2pq
         2Zq/PC/6YPJkYATg03Zj6GQFgG/ZJAAtafZJLOTnIWEJ6G6+XGPJCl3Dmjt8ZOQupqmw
         FmqhWbYmeSg2lg9kYzO8QTkfJ95j2WO3haG7wuy6c+mAn2R8e+5FjnvXT82n5wo1p4w9
         rp8BLyEi5vTZTJrBCILqHrmvycQxyaNyy/K4k6ky3KmQK4zmJ1Z7/WCV8e1KqsRDkJkO
         CW/Q==
X-Gm-Message-State: APjAAAXyve1FlX+3l/Th797eeM06ne+eY7Htx2vgHCtVv5wHNIVS0jwf
	UEsPbo/6ThEfSWNMNpDnRr9TzkswvIyNVxCHjS6xVX+bNBZCT2KmWfwMOZOWwWFl1EPGG6cMP/g
	8JnZT6h4+9w9Jp7bch0XQAL2jJMpTUeuyH7tkausHKLxrrRLNeg/nZvCxrtgAQA6C1A==
X-Received: by 2002:a9d:3287:: with SMTP id u7mr18843388otb.218.1556137469120;
        Wed, 24 Apr 2019 13:24:29 -0700 (PDT)
X-Received: by 2002:a9d:3287:: with SMTP id u7mr18843350otb.218.1556137468395;
        Wed, 24 Apr 2019 13:24:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556137468; cv=none;
        d=google.com; s=arc-20160816;
        b=WoT9R75pVhisRGNF+FNQqlxqYmBYCrijnL3MjJGANFoaxEmJfk0dQiepnn9lkpU5UY
         /28ks/K1D7wTioy6YjvSAksNKaF5AY1Hqu4YJ/uTdeXdGHeuhmUEyWyGCp/fhRFvZe3p
         KYjNE+3PgjpxVA/tWN7xIIs0cOcoQSf/uSAtLdPG+DaVAgiZ/fSxjoY8ax1vtQ1BhfRx
         oe/n2ERC5kVH4A+5Z8OmumajQbkgir1lXJSVaVglkyfYiy8ODgZEu8cwyA6SvT1eBcgZ
         Q840S6Zyb4yDfzQMdx/CQEA+fBGxqroUZTXOGwNkby/xYz0f06n+feiZS+1E8QISaovk
         4PIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=V9mJ7ZcGzEPuIiUC1HRKB7NtqsbiOoETZ948+wVXfwg=;
        b=fosgnsYe9SYkHrN0zLUzLXJymnzSrdwXTXqHtmUaXIFHcCd7ey1xP73nyIn2FgEJfx
         zVHOHOd+hTb4brKGlwUvPV3bon39TsE0a10JvlkhID9FuJ6ja48m1PO8fM/OKhU3cLFj
         hMfxt5FQrKLgMQwydkX2mdLpYZmJthRkKJt6K5kDUVTuiU0LKs/QFwx06uX9VbS0xg7c
         b5HulQudR6s5xRYz2Q+oKnSTkOdHHM0b5tk4k/2w3WKGPe/xv7uS31gUZS/Pu1UTykKQ
         MGItHeakbpBeHFGSoMIQ9zUcY5nUGVRA11JSbqfrnYa5xV65zqki7ach0dEtyV5DAEp1
         MoIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=00CRCUef;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q25sor9066009ota.155.2019.04.24.13.24.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Apr 2019 13:24:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=00CRCUef;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=V9mJ7ZcGzEPuIiUC1HRKB7NtqsbiOoETZ948+wVXfwg=;
        b=00CRCUefWmcpWNFvNuRE22UhLpVVOxwlDmyYk25bhx+MNzVYmV0gVmEeozgQghsvXs
         OWUBfFB2O0gjeiziE78S9xL4YKAWu/vxUxq28dKiKNcUUNwb4hAfCMxOpxrCTWVXZ78g
         pAnguyDkbrAIXiJw6WF5dnURnye+tHG2icimvleqEoCKyVXhCjYHMj5HhA5Zt1FZGBxL
         AsRy9oPqXup16ZId51KBceNDLIUmx/8WS+TqkkhoifZOVNdG6nUkBYZT8FjRYgTVQihX
         TCcd7V6iDS8d1/NpPX3bcccjvp99ieu8Sm0dwuaIT/Wnxzo2P2UYGz4SkZ/LEALEXEnp
         G75w==
X-Google-Smtp-Source: APXvYqwJaPdMxlIj5r34OJcX00ZztCO3rYI542la7P6JV0ApO/iQ7QlA3YhYHPcMpamE+isS0xRpt3EDRs8eLy96o+Q=
X-Received: by 2002:a9d:19ed:: with SMTP id k100mr2578516otk.214.1556137468007;
 Wed, 24 Apr 2019 13:24:28 -0700 (PDT)
MIME-Version: 1.0
References: <20190423203843.2898-1-pasha.tatashin@soleen.com>
 <7f7499bd-8d48-945b-6d69-60685a02c8da@arm.com> <CA+CK2bCD11x64pJj5gSnsu5jsUqJyU6o+=J4K8oYAsHqz9ULqQ@mail.gmail.com>
 <CA+CK2bB5ahqLrekkTUSdzTE2BPSPbB9nk6nKs+LjTap2oF8X-w@mail.gmail.com>
In-Reply-To: <CA+CK2bB5ahqLrekkTUSdzTE2BPSPbB9nk6nKs+LjTap2oF8X-w@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 24 Apr 2019 13:24:16 -0700
Message-ID: <CAPcyv4gdo5GcS8cbvLQr0Ez09z32VyrbVouW2GVV5UJf8R3HWw@mail.gmail.com>
Subject: Re: [PATCH] arm64: configurable sparsemem section size
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, James Morris <jmorris@namei.org>, 
	Sasha Levin <sashal@kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Keith Busch <keith.busch@intel.com>, 
	Vishal L Verma <vishal.l.verma@intel.com>, Dave Jiang <dave.jiang@intel.com>, 
	Ross Zwisler <zwisler@kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>, 
	"Huang, Ying" <ying.huang@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, 
	Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, rppt@linux.vnet.ibm.com, 
	Ard Biesheuvel <ard.biesheuvel@linaro.org>, andrew.murray@arm.com, james.morse@arm.com, 
	Marc Zyngier <marc.zyngier@arm.com>, sboyd@kernel.org, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 12:54 PM Pavel Tatashin
<pasha.tatashin@soleen.com> wrote:
>
> <resending> from original email
>
> On Wed, Apr 24, 2019 at 3:48 PM Pavel Tatashin
> <patatash@linux.microsoft.com> wrote:
> >
> > On Wed, Apr 24, 2019 at 5:07 AM Anshuman Khandual
> > <anshuman.khandual@arm.com> wrote:
> > >
> > > On 04/24/2019 02:08 AM, Pavel Tatashin wrote:
> > > > sparsemem section size determines the maximum size and alignment that
> > > > is allowed to offline/online memory block. The bigger the size the less
> > > > the clutter in /sys/devices/system/memory/*. On the other hand, however,
> > > > there is less flexability in what granules of memory can be added and
> > > > removed.
> > >
> > > Is there any scenario where less than a 1GB needs to be added on arm64 ?
> >
> > Yes, DAX hotplug loses 1G of memory without allowing smaller sections.
> > Machines on which we are going to be using this functionality have 8G
> > of System RAM, therefore losing 1G is a big problem.
> >
> > For details about using scenario see this cover letter:
> > https://lore.kernel.org/lkml/20190421014429.31206-1-pasha.tatashin@soleen.com/
> >
> > >
> > > >
> > > > Recently, it was enabled in Linux to hotadd persistent memory that
> > > > can be either real NV device, or reserved from regular System RAM
> > > > and has identity of devdax.
> > >
> > > devdax (even ZONE_DEVICE) support has not been enabled on arm64 yet.
> >
> > Correct, I use your patches to enable ZONE_DEVICE, and  thus devdax on ARM64:
> > https://lore.kernel.org/lkml/1554265806-11501-1-git-send-email-anshuman.khandual@arm.com/
> >
> > >
> > > >
> > > > The problem is that because ARM64's section size is 1G, and devdax must
> > > > have 2M label section, the first 1G is always missed when device is
> > > > attached, because it is not 1G aligned.
> > >
> > > devdax has to be 2M aligned ? Does Linux enforce that right now ?
> >
> > Unfortunately, there is no way around this. Part of the memory can be
> > reserved as persistent memory via device tree.
> >         memory@40000000 {
> >                 device_type = "memory";
> >                 reg = < 0x00000000 0x40000000
> >                         0x00000002 0x00000000 >;
> >         };
> >
> >         pmem@1c0000000 {
> >                 compatible = "pmem-region";
> >                 reg = <0x00000001 0xc0000000
> >                        0x00000000 0x80000000>;
> >                 volatile;
> >                 numa-node-id = <0>;
> >         };
> >
> > So, while pmem is section aligned, as it should be, the dax device is
> > going to be pmem start address + label size, which is 2M. The actual
> > DAX device starts at:
> > 0x1c0000000 + 2M.
> >
> > Because section size is 1G, the hotplug will able to add only memory
> > starting from
> > 0x1c0000000 + 1G

This is yet another example of where we need to break down the section
alignment requirement for arch_add_memory().

https://lore.kernel.org/lkml/155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com/

