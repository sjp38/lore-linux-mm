Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94C8FC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 09:14:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5DD8021773
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 09:14:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5DD8021773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 074566B026B; Fri, 29 Mar 2019 05:14:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 023BC6B026C; Fri, 29 Mar 2019 05:14:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7C546B026D; Fri, 29 Mar 2019 05:14:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9B5DF6B026B
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 05:14:20 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f2so758661edv.15
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 02:14:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=d0sRPJoN3uS1PVhjRZCnCC6DKFre0lznn/goE84eThc=;
        b=lzT857PqvFQlpuZd1maUXDzKGSUvI4/ERaDjHOYBT4/5psxuwN71ieeWDZll9vcqKW
         LV4YcqeSRf15ZvOhCIVvTB5I6fN/iSMhZM2Qj6P6BkRgx+2sPIn/uZd/Bv9s0KzgmEND
         3nRDBUFKdGZ95nkXqbpSJWGwRfupBPAhAnqnBS0258dH4/l4P3B8mip2TVJ5hO1tFs2U
         fWZ8QUyQNhOBG197AgHOpGquBJL7THhyqRDd7Uil2T4NiRQOG8VEMCENeFj3oD9pNTfm
         2RMTvRXJinXekZ5OLhMLrXmCHf4D9G9mOKVWg8C02W8pVgbOmu6IQyoRSBNHZTIw2tuL
         xWmg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXSahSjA3ZreG/aVfyTOZLslRzQ0BM+EiU0Q7iKgScj/ir7Yvdj
	NbuPCzcBmGOvYtvRkKjIEofD78DXwqFAo5G7I76/4OmK/v4gq6yCGvpfKviddOZlgMV/sJgjPJ+
	iJ0MvQ/ULv+QAO3j3ekWCwlxmCtGUKWLSn0uSvK/l+LjEpe5/F3PS9HjdewTdUls=
X-Received: by 2002:a17:906:d69:: with SMTP id s9mr26632058ejh.205.1553850860173;
        Fri, 29 Mar 2019 02:14:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzayMqQGkH/IKElIynXuk4k8FU/KFnT2Zoxs6unrw3CVuQSE2pK96dK3om6B/HcZEKKTs7T
X-Received: by 2002:a17:906:d69:: with SMTP id s9mr26632035ejh.205.1553850859373;
        Fri, 29 Mar 2019 02:14:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553850859; cv=none;
        d=google.com; s=arc-20160816;
        b=b74yQRBMC6gb2gjSVPRV4R6tiowcC636aO6PdAxYW753KEJcH8J8+G/uYPO8WSolTP
         7flqaAYPyITZ6nBsg97R1eigVQpAXpP4vUU5s43l4n4fr1KpiuCV0o2eGDacLasCorOJ
         N9zNOSyrzMpd3D6vYMHWKiGhHFjnjkpLin8fVHg2fOo2gORnNXwIxhccGyLBF9S2UN8v
         SLtHdAZ/u66lwCY9av131FJ5WujciQqCQLW+C2IcFHfRii5xe3gXjgzvxIl7TgYSwJs3
         Ni61bVn0huvaMEYnJplJkexc/TyJ9kYpbkHP0lsKXnb1dok66OnC5TOVQRpOaT++Pbcc
         hRIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=d0sRPJoN3uS1PVhjRZCnCC6DKFre0lznn/goE84eThc=;
        b=afdDX50hQADCE9bSsXLdBgGPexYA1lINk01nJnWPy4Js7hTU9d78weOS+/KUV8F2EK
         yxTicD6uiMlgKPu0VnKLpxy3ZDKBtGQuTsZjf+B8omZrpTE81gsskIGB3yIfty9xdMDm
         QliVXlkxxZl6TsvlxhzkcoCb9oUwtlpGp6lFETuQlfupY+mBtY/ah3x1wmFz0cm/ualU
         wxba0dO25vjXPLEIH985u4aCqTlbcYJn0LT5Kslo9mtj5jVvrVVrk6Xzif8s2JI15Gc4
         HhLAx2P9utQGM94NHfrlYT2rIJFDZ81Kt/I9q8uBWB5Ke5w5bXh88YGK705y8fy4ra91
         UAag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r25si724749edb.15.2019.03.29.02.14.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 02:14:19 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 01631AE60;
	Fri, 29 Mar 2019 09:14:19 +0000 (UTC)
Date: Fri, 29 Mar 2019 10:14:18 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rafael@kernel.org,
	akpm@linux-foundation.org, osalvador@suse.de, rppt@linux.ibm.com,
	willy@infradead.org, fanc.fnst@cn.fujitsu.com
Subject: Re: [PATCH v3 1/2] mm/sparse: Clean up the obsolete code comment
Message-ID: <20190329091418.GE28616@dhcp22.suse.cz>
References: <20190329082915.19763-1-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190329082915.19763-1-bhe@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 29-03-19 16:29:14, Baoquan He wrote:
> The code comment above sparse_add_one_section() is obsolete and
> incorrect, clean it up and write new one.
> 
> Signed-off-by: Baoquan He <bhe@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> v2->v3:
>   Normalize the code comment to use '/**' at 1st line of doc
>   above function.
> v1-v2:
>   Add comments to explain what the returned value means for
>   each error code.
>  mm/sparse.c | 17 +++++++++++++----
>  1 file changed, 13 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 69904aa6165b..363f9d31b511 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -684,10 +684,19 @@ static void free_map_bootmem(struct page *memmap)
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
>  #endif /* CONFIG_SPARSEMEM_VMEMMAP */
>  
> -/*
> - * returns the number of sections whose mem_maps were properly
> - * set.  If this is <=0, then that means that the passed-in
> - * map was not consumed and must be freed.
> +/**
> + * sparse_add_one_section - add a memory section
> + * @nid: The node to add section on
> + * @start_pfn: start pfn of the memory range
> + * @altmap: device page map
> + *
> + * This is only intended for hotplug.
> + *
> + * Returns:
> + *   0 on success.
> + *   Other error code on failure:
> + *     - -EEXIST - section has been present.
> + *     - -ENOMEM - out of memory.
>   */
>  int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>  				     struct vmem_altmap *altmap)
> -- 
> 2.17.2
> 

-- 
Michal Hocko
SUSE Labs

