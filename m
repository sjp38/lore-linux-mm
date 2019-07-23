Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A936C76188
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 07:06:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6030206B8
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 07:06:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6030206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88C866B0005; Tue, 23 Jul 2019 03:06:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8161D6B0007; Tue, 23 Jul 2019 03:06:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7536B8E0001; Tue, 23 Jul 2019 03:06:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2ABA46B0005
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 03:06:45 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y24so27702059edb.1
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 00:06:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=znLS0Flfr7bAoDo+PUGRaAiv2se/eRKzKSOxZeMt00o=;
        b=Ic00Ttqi1cFfGGJ5RnTCNcHcn4CP2M2BLTT5P6hdGviLWqbXdYqqDfxuHGYkyEz1XE
         2uOpHsmRPYtLSzUUA6JTCwE+hymC/QZ74viMKibgYRzzbHxyXc6En+pn7fksuIThh5a1
         udiP/l9wuplzqAGJA6VCHzyuGhNeVtDAbeHpL/A51nGKdezezLiZOtmvzgMUJpdNIQJA
         7ucuJ/RIgs6j0YOX2SrxIAJNzo4fB8Bbmy2GSDDOsrGuKcqlYcWjzCCjYjPvQLujvTG6
         qfYqqJ1Qa49Hxqeb3JkRfvqBeS+B2UXUHcTYLtWRb+uqZbgxB3xnoOs4xRRhUCT7V0ac
         evjg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVfzACmFTGp8mYC6XWiBbGy8ynnNoPgO0tzYc2WIS83TOPqgh0r
	CVkgMTFcPMN30AoNNyPwFwP9BKcdO3SuEgpu3pJ+7jj4zFImwL1l5SkgAU90gO9d6g6aKvk7iv4
	A/h5DIq9Jv4taYBIUm/TPA+8TyJJFtQDKZn72aV08EhzPjB1/F/fdILY2xo0i8ag=
X-Received: by 2002:a50:89a6:: with SMTP id g35mr66260683edg.145.1563865604751;
        Tue, 23 Jul 2019 00:06:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0TuEdgAeCvFQnzsyp5eyjEL+YzUj6YDWvnEzouF1mg0eiivi7zCw8RlecguMz8sgZ3vGa
X-Received: by 2002:a50:89a6:: with SMTP id g35mr66260652edg.145.1563865604136;
        Tue, 23 Jul 2019 00:06:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563865604; cv=none;
        d=google.com; s=arc-20160816;
        b=RsxBv5DQd0hKW1U3vMenfNbOj1dI8gbfeS6mXTZ1ZAaVOQ3mLmq5nyH7ijC0CzmKLj
         gtu0s/GsuP+LTprR6nID0v3zZE3c8/765kcjmuNDLP4pwqheXNMQzCYop/oEJX8++vSd
         MrC2p08LqcTrh+dsZ6J4PXpdlAkTpJjzE8Q+bmkgJDXTpsX1I8e995QlV92I8B8xLrCp
         DhR5LElKYFxqRanwxUP0SBsWm3ER2Taam1rpkhc8XPV/yUpMOGTKws4R+pU9h7fA9tyK
         rHZGD/wdqc7D7ycbOu47SknpYSBzEsyXP7lQldFiNjuW0TTBRAuA3AlMj2Kt64QhiOGl
         JhMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=znLS0Flfr7bAoDo+PUGRaAiv2se/eRKzKSOxZeMt00o=;
        b=XDmjkqkZ2ZcEGlMN8XYE6wELTRkjg2J3IBbSyihujO7xo/2N/E/RtQaq89SgXM4sox
         ZkClwHfirf5CLFtJ9q22e0OHWcl+C09eoplH+oYJ5H4LWrL5q4JlMr6L7akz0OBiODIv
         gwp96iBwAjbRzF9Hw7NuWgSPygAxVuVFSNjM8TzJmsgrqcuknWLCH7nIBRIckFlzuCNE
         ac3E7MCER1/vBTvHPzmePwSG5/um3ZqfVutVSJH2lACdvcdZfXhtK5XL69OohjDsM0d9
         94syYUO7w7s4ibIsa8Jclqt2pzUd4BafAhebNG0sBF7EMOP8fHxZIcelDCUnhd0b+QIn
         KC9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qh1si4926274ejb.11.2019.07.23.00.06.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 00:06:44 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 77322AE91;
	Tue, 23 Jul 2019 07:06:43 +0000 (UTC)
Date: Tue, 23 Jul 2019 09:06:42 +0200
From: Michal Hocko <mhocko@kernel.org>
To: KarimAllah Ahmed <karahmed@amazon.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Oscar Salvador <osalvador@suse.de>,
	Mike Rapoport <rppt@linux.ibm.com>, Baoquan He <bhe@redhat.com>,
	Qian Cai <cai@lca.pw>, Wei Yang <richard.weiyang@gmail.com>,
	Logan Gunthorpe <logang@deltatee.com>
Subject: Re: [PATCH] mm: sparse: Skip no-map regions in memblocks_present
Message-ID: <20190723070642.GC4552@dhcp22.suse.cz>
References: <1562921491-23899-1-git-send-email-karahmed@amazon.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1562921491-23899-1-git-send-email-karahmed@amazon.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 12-07-19 10:51:31, KarimAllah Ahmed wrote:
> Do not mark regions that are marked with nomap to be present, otherwise
> these memblock cause unnecessarily allocation of metadata.

This begs for much more information. How come nomap regions are in
usable memblocks? What if memblock allocator used that memory?
In other words, shouldn't nomap (an unusable memory iirc) be in reserved
memblocks or removed altogethher?

> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mike Rapoport <rppt@linux.ibm.com>
> Cc: Baoquan He <bhe@redhat.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: KarimAllah Ahmed <karahmed@amazon.de>
> ---
>  mm/sparse.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index fd13166..33810b6 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -256,6 +256,10 @@ void __init memblocks_present(void)
>  	struct memblock_region *reg;
>  
>  	for_each_memblock(memory, reg) {
> +
> +		if (memblock_is_nomap(reg))
> +			continue;
> +
>  		memory_present(memblock_get_region_node(reg),
>  			       memblock_region_memory_base_pfn(reg),
>  			       memblock_region_memory_end_pfn(reg));
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs

