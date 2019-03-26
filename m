Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64FD2C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:29:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1956F20856
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:29:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1956F20856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B29A6B0005; Tue, 26 Mar 2019 05:29:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 960B96B0006; Tue, 26 Mar 2019 05:29:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84EAA6B0007; Tue, 26 Mar 2019 05:29:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F0BA6B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:29:39 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id t4so5013006eds.1
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 02:29:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lH5qwi4GhJyW14P2vIASOtr07lMl4jOZhjbsGLXQkns=;
        b=gaT7ESjTjv4KEniUwegjD+MP0/EqXE4O2DdiMo/n/cZr6G6P/6Bjh/HLAvQ1Y93QtK
         ETv830pyoWVNeQYzq4VEtr6dYSzI/Jinh6eeyKTh1fgG/UCffI/5yWQLFdvhvTuIqW8Q
         5reiBeVHEMnabf8jKIfCYbaRUzPnmMXj6/PBYes3/lv50U6b6XgFijFXO5xfK4VMy4qR
         8/YTNXf/5s3oCDM9CdN2+gv/odoH3tLfTLi6NQCyxcoPbC3T7y4HGSM1/Bx2gfN461f5
         JpU8cavfYDsEox0G3vyhl5GRvD5j1iAGh62RArFNFldwbUT0v+LYo+vaPSKgeo7BUZXM
         BgYA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUfYakV4J4j+r6LgWvZc4ETnA7x8jaMZHs7GkBc5CHko4kBnI65
	jSOgwekTQ+34AO9MNOLwCpVEzVJOtGs9po/V6Fa28ns7dtYi3ke5vcSfhku5ZOIgjMQT5Qo3W7y
	Jwt9VBeeaTQVF7SP9szNHq+fMBdCkE53lnJf/uzod8Xohre3gRViH+DkstKFVjvw=
X-Received: by 2002:a50:b113:: with SMTP id k19mr19898474edd.31.1553592578702;
        Tue, 26 Mar 2019 02:29:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzTayNjp5JgZTGyFB9FLYRhDgDVCdwnaC/JYMVxx9OHNjY50cGIQOATQawxDgmqrJmJX/jb
X-Received: by 2002:a50:b113:: with SMTP id k19mr19898430edd.31.1553592577920;
        Tue, 26 Mar 2019 02:29:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553592577; cv=none;
        d=google.com; s=arc-20160816;
        b=HKGq2HLYm1lpuex7kiiAl4KtxchZUKChsbcQ0xWhbsefAA244fjDQmzuDmtpivsWUf
         Ttv/89O52noe33PsBrcdTSFmPJ1v5omp7aefHpMGrHw5OG54upY2rzlflKdYreKMqx40
         dLOLISUPJaIIMKWQ+uMHbbeRFjovEOcX2/3PnRuoIk0avDJuh3Q0paOhe+kHDqmjEWk5
         WFmf0Q1MFICOQQ1C8UZkHNBiHNWMycXjYufPKLLEpsAVuHODkx08b+qzq3JckqnbeINX
         CwpF9Fkv9/7Jk2Uql/yMCJUaD6ARNUjBdf/GG7Gni486oHO+1vxdX/TA6HeWhNHZqhGx
         RKCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lH5qwi4GhJyW14P2vIASOtr07lMl4jOZhjbsGLXQkns=;
        b=jXAqBZBeNp0xI21FfCsxqZxxbz2DbLb7sMH4vBcUe7EHLbBk7jpV+wGeDaIkDFrD3O
         AvQO/P+ISUfDyzhZkBuIm0Ddj+4c+wyscF2TbwceoNX5OIy3Rm0kP6zAePPYcSE/75Rz
         BSeiZ6WBaOZiCwRctxXWknbFuA6gNzqx+8tN0qk0G2uyCvFwrA5INxvLB+5sVjayo/sM
         MFhhCJ6gNGcxOswMRYG4tund2u8A6FtjFNKZFWrS/7OggxyV1HUsptxIMDKIA69RjT38
         TNd4hLqqfWrOTweYTCw4/OeKkUVf7aBNABNZTHwRyxXx7kJAkY1VcHpyLnbGPGYdMzL9
         z0aQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y3si596770eje.81.2019.03.26.02.29.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 02:29:37 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 63BC9AC8C;
	Tue, 26 Mar 2019 09:29:37 +0000 (UTC)
Date: Tue, 26 Mar 2019 10:29:36 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, rppt@linux.ibm.com, osalvador@suse.de,
	willy@infradead.org, william.kucharski@oracle.com
Subject: Re: [PATCH v2 2/4] mm/sparse: Optimize sparse_add_one_section()
Message-ID: <20190326092936.GK28406@dhcp22.suse.cz>
References: <20190326090227.3059-1-bhe@redhat.com>
 <20190326090227.3059-3-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326090227.3059-3-bhe@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-03-19 17:02:25, Baoquan He wrote:
> Reorder the allocation of usemap and memmap since usemap allocation
> is much simpler and easier. Otherwise hard work is done to make
> memmap ready, then have to rollback just because of usemap allocation
> failure.

Is this really worth it? I can see that !VMEMMAP is doing memmap size
allocation which would be 2MB aka costly allocation but we do not do
__GFP_RETRY_MAYFAIL so the allocator backs off early.

> And also check if section is present earlier. Then don't bother to
> allocate usemap and memmap if yes.

Moving the check up makes some sense.

> Signed-off-by: Baoquan He <bhe@redhat.com>

The patch is not incorrect but I am wondering whether it is really worth
it for the current code base. Is it fixing anything real or it is a mere
code shuffling to please an eye?

> ---
> v1->v2:
>   Do section existence checking earlier to further optimize code.
> 
>  mm/sparse.c | 29 +++++++++++------------------
>  1 file changed, 11 insertions(+), 18 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index b2111f996aa6..f4f34d69131e 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -714,20 +714,18 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>  	ret = sparse_index_init(section_nr, nid);
>  	if (ret < 0 && ret != -EEXIST)
>  		return ret;
> -	ret = 0;
> -	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
> -	if (!memmap)
> -		return -ENOMEM;
> -	usemap = __kmalloc_section_usemap();
> -	if (!usemap) {
> -		__kfree_section_memmap(memmap, altmap);
> -		return -ENOMEM;
> -	}
>  
>  	ms = __pfn_to_section(start_pfn);
> -	if (ms->section_mem_map & SECTION_MARKED_PRESENT) {
> -		ret = -EEXIST;
> -		goto out;
> +	if (ms->section_mem_map & SECTION_MARKED_PRESENT)
> +		return -EEXIST;
> +
> +	usemap = __kmalloc_section_usemap();
> +	if (!usemap)
> +		return -ENOMEM;
> +	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
> +	if (!memmap) {
> +		kfree(usemap);
> +		return  -ENOMEM;
>  	}
>  
>  	/*
> @@ -739,12 +737,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>  	section_mark_present(ms);
>  	sparse_init_one_section(ms, section_nr, memmap, usemap);
>  
> -out:
> -	if (ret < 0) {
> -		kfree(usemap);
> -		__kfree_section_memmap(memmap, altmap);
> -	}
> -	return ret;
> +	return 0;
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -- 
> 2.17.2
> 

-- 
Michal Hocko
SUSE Labs

