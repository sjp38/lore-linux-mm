Return-Path: <SRS0=GuKW=WG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8464C32751
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 11:13:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71A8B20B7C
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 11:13:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71A8B20B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C8006B000A; Sat, 10 Aug 2019 07:13:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 177EE6B000C; Sat, 10 Aug 2019 07:13:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 065F56B000D; Sat, 10 Aug 2019 07:13:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id AE4846B000A
	for <linux-mm@kvack.org>; Sat, 10 Aug 2019 07:13:12 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id b14so47862757wrn.8
        for <linux-mm@kvack.org>; Sat, 10 Aug 2019 04:13:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9PgkYtV/DVfBRc6+ic8I0RA2JUBuXEG/Xsv/SYYN+qM=;
        b=EzTVkYnp8aODZk9LnGEPhVtkNQOFl1ODnEkyU+1SoVlPg4SRnElfpz1AxIKVww9R/W
         KsBBFaGwbRIWLGjoDn9GyMahJY7e7pT/RM1S1ZnpQm9GTp4pTn0HfgfohO7RhPA0Wt0B
         hLcPet1fqIWfX+ga8mwg6tDwOcar88O/IfqsJOH0M5OMUbwof94sD3+JxHgjJ62V9jXE
         eTpU4gUrnMA0ZXSaebgj+MtawBh673tYKhZ46Fj7seXUFdBeXWHl2aJHcbeOystBQ3Fo
         XKJ+4sGt0Fp4nkG6EreLqISmgumT/rYdDgDIN0SRP91Q6ub86HHuKFvqlqUI4zafT6t1
         7hAQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWchcUyi3751Zl3cKPjON4m03N3o4Qj9S7qiDiHy23SLpNZKp9c
	SJY7PTjEYWN7qbY7rjxijY78YGMyT7yYzmJpvE5zEurkbJihvLwYZRjsJlRDJ+dv11fR88+R3hj
	G2ZhZf2XR9nMRAaVDdwW5El0nvXSULTuCWj0l5U+Jvu70xH8cpdHSnpFod1Gz+ops1w==
X-Received: by 2002:a1c:9a95:: with SMTP id c143mr2934654wme.2.1565435592303;
        Sat, 10 Aug 2019 04:13:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaRbJBcjBE0iGIDnNZt6iAnjB0ixymIVT38axuMd7Kef5LKF/Na4OruHvHXsXzmYmF1Rr8
X-Received: by 2002:a1c:9a95:: with SMTP id c143mr2934598wme.2.1565435591577;
        Sat, 10 Aug 2019 04:13:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565435591; cv=none;
        d=google.com; s=arc-20160816;
        b=RR9tP/GcQMSy+0yDriirGK52hMEUBxuxFf/65vA8nTir17fvB996dBtJUnawtcCxo5
         qntENmVZv6OdqoeFkeQcmiHRQDhtPuT1KvebWu1Q42UvaZOKXoWNDmeDNShHn1gigFMb
         Ox8sNA2j5UAqNb+B2GCZPrLuTaVdE/I2trpdmpLdBmq2WrwB4ezDKqAGGAcBaVe4p3zp
         yyaWt2t5b4uvjSajHHzHildxBJub6Gph2VAXI8GAGbhLMyPl1UnVwDdOZ690WqHO4suH
         JNlsG2338yoTnBs+a+0uefDaPw0Q7T3LVSiCN0PJzr+whsMARLTwlSPUmQgOHdhVh9/j
         X5RA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9PgkYtV/DVfBRc6+ic8I0RA2JUBuXEG/Xsv/SYYN+qM=;
        b=XWzCpT7mFz7B9Z8CDVJotCrS8ws06fkw47j8D4G3JPAAZQ4ugumV3F8B2sU+SSYNlG
         KoZ7NlU7FDV6KR0OLGFY7D/t+vCs7MJfnFJY1qST/4RG8p0OYOik9TnCrv77QyPytI8O
         X+J7rjRQDB6reudlQFFOcH233icL5ZueFsSjLhXw/IGQDhQHFX853DKuqrhlfZTJFHOG
         TJwwn0emIJCRF++poqHHWeU0qR+kIWuX+r4igM41CHGsGU1XXEr7x7+Vwimvi7QkVNYF
         vpSwFhjj+XcI6lQXW05DbED1bKwySQjRN0Oq1rxrldEL8CV3+tuLwxPRk7wawsYxVtZR
         16Bw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 92si3376127wrd.420.2019.08.10.04.13.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Aug 2019 04:13:11 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 2801368BFE; Sat, 10 Aug 2019 13:13:09 +0200 (CEST)
Date: Sat, 10 Aug 2019 13:13:08 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org,
	Jason Gunthorpe <jgg@mellanox.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>
Subject: Re: [PATCH] nouveau/hmm: map pages after migration
Message-ID: <20190810111308.GB26349@lst.de>
References: <20190807150214.3629-1-rcampbell@nvidia.com> <20190808070701.GC29382@lst.de> <0b96a8d8-86b5-3ce0-db95-669963c1f8a7@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0b96a8d8-86b5-3ce0-db95-669963c1f8a7@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 02:29:34PM -0700, Ralph Campbell wrote:
>>>   {
>>>   	struct nouveau_fence *fence;
>>>   	unsigned long addr = args->start, nr_dma = 0, i;
>>>     	for (i = 0; addr < args->end; i++) {
>>>   		args->dst[i] = nouveau_dmem_migrate_copy_one(drm, args->vma,
>>> -				addr, args->src[i], &dma_addrs[nr_dma]);
>>> +				args->src[i], &dma_addrs[nr_dma], &pfns[i]);
>>
>> Nit: I find the &pfns[i] way to pass the argument a little weird to read.
>> Why not "pfns + i"?
>
> OK, will do in v2.
> Should I convert to "dma_addrs + nr_dma" too?

I'll fix it up for v3 of the migrate_vma series.  This is a leftover
from passing an args structure.

On something vaguely related to this patch:

You use the NVIF_VMM_PFNMAP_V0_V* defines from nvif/if000c.h, which are
a little odd as we only ever set these bits, but they also don't seem
to appear to be in values that are directly fed to the hardware.

On the other hand mmu/vmm.h defines a set of NVIF_VMM_PFNMAP_V0_*
constants with similar names and identical values, and those are used
in mmu/vmmgp100.c and what appears to finally do the low-level dma
mapping and talking to the hardware.  Are these two sets of constants
supposed to be the same?  Are the actual hardware values or just a
driver internal interface?

