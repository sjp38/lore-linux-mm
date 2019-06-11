Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EC22C43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 10:37:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA2BB2080A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 10:37:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA2BB2080A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AD796B0005; Tue, 11 Jun 2019 06:37:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 537136B0006; Tue, 11 Jun 2019 06:37:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3FEF96B0007; Tue, 11 Jun 2019 06:37:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E519A6B0005
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 06:37:31 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l26so20099844eda.2
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 03:37:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=J7aI4DCclPauOifFWjS/4bykYE9Ya/AxtZK2Gucs6p8=;
        b=QC3ZtUvpOwGtzCOR+KezP/K5RzX78iU7NfYsSyiMSfl2UBm3xGs82nsLGFx2VuJg5R
         lmp4UXZMWa1Z5x6Y299XwznhRTcTsSZACkXEz+onVSiMyfgYbMdOGddbU6oZnBYOJiOJ
         5PSoTwsnlfeROIW9JxZtzH/V4I955tbYwC4CGXqc/MNsZWncdsKWGnJiY9THXMGutMkt
         OD9UIvOGx5jGPHjC6qZhhY4YZBuDOvedGFkhY82XCP2zDSw1BMTJJAWWElJuBuN8k/bf
         OXyLrn6ln4YkQBAegIQdGWz8WAZJpNz18swNjVetvEX8C1TM5OEPq0yu7hCK4m6jnZMO
         fW5Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAXdJE6NFljcoIzZph71GNqvdeI2KLNKEApYmZHLc1O4NTjOzqIM
	jIKzhY00bS1Xno+koMb/heqexx0y5UeTM0sG2KTjnKMGVlXheTJpfhwfpX+mZzQHafVmuWLCr+o
	a+PhxT6onJhDPXuc6lMORXe8mikVN2kxsKDzIKZzC3fV2BFK4/fMfpQkIp3EfFN++bg==
X-Received: by 2002:a50:ee89:: with SMTP id f9mr51407198edr.293.1560249451517;
        Tue, 11 Jun 2019 03:37:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5OAdjug9fi7Urdjkr+hj6xy5HbT3qLXJ8I3s6KQlO1EADu+a9DRV5JitaqHZIz/ZGY4DY
X-Received: by 2002:a50:ee89:: with SMTP id f9mr51407146edr.293.1560249450757;
        Tue, 11 Jun 2019 03:37:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560249450; cv=none;
        d=google.com; s=arc-20160816;
        b=aZvnZkaOKJzqiNeOIrNosjaXSiwx2jltcdcYHsjraN0zvbg+0nhmNa5aQ12Bz3wroj
         Mcf5K/y5jFsE4ELI4xtY8hx6eTBeySOVunBx6ZJRg7aF2SxKaVJSr1axNeFYKXYggigP
         l1cXAsALrHonH1AanswlSKVh/tzV8q568yKudb3ofEsUCEHejIJ49gQMdwZXg9xIFvuT
         IF9Af/68nbZMdZ8qoYCsEWnT34pYfw38oHKtbhYJEoX0YtquPL5VEkFsPeGkZvMtQrZt
         31x4Htw0z+Izgg1XAs0g4OCtT3C9bux+bdowyDG9Dkk0eQ+0ZSTyMu09YV7eoSWFJ3ai
         ne+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=J7aI4DCclPauOifFWjS/4bykYE9Ya/AxtZK2Gucs6p8=;
        b=TBKhI6/aCE9hRsyH3jF3/r2LB9Nf8MjPxCANVMM7MEjseuDk9ghG+3TVvINSwChYYE
         8uTD6d5RnKim5ZHXyuocAPNKESdlQ4Ql9BgRxFZuAnOPk9npWGlECygekIOBXJMpvTfX
         ArfdbWxnrSCgZPO6dWBZ0HAAXh05tueK6/Q8roU2YDgfw4hUPaPmxV+toxKUjFyc5B2W
         xv0fXKWLvmlvYfLDrS7plfEe+Y0iqmziPNH0+X5j2iGqI+7JgOAPbrDSUu7qzIXt9M04
         csmWmpK9V8zNxPb1RjowVp/gBZ4wU51vaiW8OfjRwWH3n8DL3DwzQeH1zSL9mG47eSNb
         vLiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 7si141717ejx.310.2019.06.11.03.37.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 03:37:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BB1C8AD12;
	Tue, 11 Jun 2019 10:37:29 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 1C7AE1E3E26; Tue, 11 Jun 2019 12:37:29 +0200 (CEST)
Date: Tue, 11 Jun 2019 12:37:29 +0200
From: Jan Kara <jack@suse.cz>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: dan.j.williams@intel.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org,
	linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH v3 3/6] mm/nvdimm: Add page size and struct page size to
 pfn superblock
Message-ID: <20190611103729.GA27635@quack2.suse.cz>
References: <20190604091357.32213-1-aneesh.kumar@linux.ibm.com>
 <20190604091357.32213-3-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190604091357.32213-3-aneesh.kumar@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 04-06-19 14:43:54, Aneesh Kumar K.V wrote:
> This is needed so that we don't wrongly initialize a namespace
> which doesn't have enough space reserved for holding struct pages
> with the current kernel.
> 
> We also increment PFN_MIN_VERSION to make sure that older kernel
> won't initialize namespace created with newer kernel.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
...
> diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
> index 00c57805cad3..e01eee9efafe 100644
> --- a/drivers/nvdimm/pfn_devs.c
> +++ b/drivers/nvdimm/pfn_devs.c
> @@ -467,6 +467,15 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
>  	if (__le16_to_cpu(pfn_sb->version_minor) < 2)
>  		pfn_sb->align = 0;
>  
> +	if (__le16_to_cpu(pfn_sb->version_minor) < 3) {
> +		/*
> +		 * For a large part we use PAGE_SIZE. But we
> +		 * do have some accounting code using SZ_4K.
> +		 */
> +		pfn_sb->page_struct_size = cpu_to_le16(64);
> +		pfn_sb->page_size = cpu_to_le32(SZ_4K);
> +	}
> +
>  	switch (le32_to_cpu(pfn_sb->mode)) {
>  	case PFN_MODE_RAM:
>  	case PFN_MODE_PMEM:

As we discussed with Aneesh privately, this actually means that existing
NVDIMM namespaces on PPC64 will stop working due to these defaults for old
superblocks. I don't think that's a good thing as upgrading kernels is
going to be nightmare due to this on PPC64. So I believe we should make
defaults for old superblocks such that working setups keep working without
sysadmin having to touch anything.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

