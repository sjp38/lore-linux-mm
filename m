Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46DDBC282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 08:41:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E94821841
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 08:41:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E94821841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7058A6B0010; Thu, 11 Apr 2019 04:41:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B34B6B0266; Thu, 11 Apr 2019 04:41:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 57BA46B0269; Thu, 11 Apr 2019 04:41:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0543D6B0010
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 04:41:46 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f7so2728492edi.3
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 01:41:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Hv0Tu5vKqrOSuiUXKFVHMWeUz81r+CwRL52LI/dsHVw=;
        b=Rv9LIUcyjFl/lNhFnEMsCLdVBJGbXhrFXAqZdCB8HcP0vvtlcPKTwjmrLa2f5PMqB4
         QqOl+pq9eNjbbFxthc/1s2LTj+A8uGDV5bklIdVpGrqMNxMKhLeJ9i1u9hm4fH0f4Bzr
         vjbBegPT1IWJx5Nt0LuIctA7lM0VL3wTtipaNMLqdgjmqNdCmWHcs1krXRzrKL/BUB7N
         KGWtEMsEo+Lw/gva5fSDmod3LJnvCcQXQtMegaahptchBNp59Cmpit2gi1fRCtyakToF
         tCMiyEF+BW3yQkvTaUehUo36ecChHYBOVik/S+fXvZVGKJaipaUlGdNzslKtd8TDKkX0
         Qt9Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU1D4QTabQZE8vbd9ZawooFLqyR78ITsIsJ7YTNOyCuXBcXjnc8
	a4pNew6U9XydeQHq8GHg3y7Ex5Vh9X5r2Il7ezURqsX5O89Nbjfn8r5hRFPpoufODDbwVTuIAFG
	/jio3p8iV8r9RqEvAj2PrLi7QzCfKCYGJVdkfQDo6AWKS26ucOK8Q30mcFDYrS2U=
X-Received: by 2002:a17:906:2481:: with SMTP id e1mr5538677ejb.22.1554972105538;
        Thu, 11 Apr 2019 01:41:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwOFZ6+VhCKgKJmtQhKk/MQHtZncRelLSO6/YbTbEl1llvGa9jtVkZrKsSG0mLQTMLGUpp
X-Received: by 2002:a17:906:2481:: with SMTP id e1mr5538635ejb.22.1554972104584;
        Thu, 11 Apr 2019 01:41:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554972104; cv=none;
        d=google.com; s=arc-20160816;
        b=Q3YQFrGo8R2LEeSInd94UjmcN28d2MJYmsU1IrDQk+dg2eDt7vYDaaVBYZUuBu1Lfv
         aTsKVWdfVxNuOMKtlMomqFn9iSl6xeg1IZqJ7+li78T3yOp5p4gH8NixWIn7uN+StvmJ
         MN6257VXYw56efF2Z60kcA6UMUZqLYGuXiQecwlQ3U0tjUbU6JGs9RtUnuiJrCAo1Xgl
         71MvzOJHGyfj+dUAc3HWujbjuLtHU54PIipGW/uco57NzM4GGG/AMX5Ajk20oKjpGsWx
         1Hf7nGPNPVV+5TVA7dRLZBaSinG7+xwtrPhkglKsmBoft236uBy7/rT5AFUCZ/dqod63
         uFAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Hv0Tu5vKqrOSuiUXKFVHMWeUz81r+CwRL52LI/dsHVw=;
        b=c9VIp34eU+DGibIn2FhwpPMm0waVvLRgVUV1J2mzHlaAmvpqqjGvhJcii9VdWxEzef
         cGTAK/43x/4jrxUIrnaUo/nIG2z5M/Np84DhdfjXp5YCOodc2lQbuear6alPet8ekS9h
         Ung//UM//7wYaWkwohJEwl6mmHNKpNme9MSavE0ort1VSpKzZDnzIKV2zoJD0oMj8n58
         gJVzZzg/7ADCXgaxfs664bsQPUCSEfAJ+QvxOL2pHM6TYe6fEnA6hrc8T0AS+Um4c/tC
         LfvlqjpeYzkpaBBl/dgGjGLrL52Aqu4OTFWpXTt+Lar6k3J3abcJn36wUStD7mO5LiVa
         qvmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h18si3420351ede.228.2019.04.11.01.41.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 01:41:44 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B8AC1AD65;
	Thu, 11 Apr 2019 08:41:43 +0000 (UTC)
Date: Thu, 11 Apr 2019 10:41:41 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: Re: [PATCH] mm/memory_hotplug: Drop memory device reference after
 find_memory_block()
Message-ID: <20190411084141.GQ10383@dhcp22.suse.cz>
References: <20190410101455.17338-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190410101455.17338-1-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 10-04-19 12:14:55, David Hildenbrand wrote:
> While current node handling is probably terribly broken for memory block
> devices that span several nodes (only possible when added during boot,
> and something like that should be blocked completely), properly put the
> device reference we obtained via find_memory_block() to get the nid.

The changelog could see some improvements I believe. (Half) stating
broken status of multinode memblock is not really useful without a wider
context so I would simply remove it. More to the point, it would be much
better to actually describe the actual problem and the user visible
effect.

"
d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug") has started
using find_memory_block to get a nodeid for the beginnig of the onlined
pfn range. The commit has missed that the memblock contains a reference
counted object and a missing put_device will leak the kobject behind
which ADD THE USER VISIBLE EFFECT HERE.
"

> Fixes: d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug")
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Mathieu Malaterre <malat@debian.org>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Other than that
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memory_hotplug.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 5eb4a4c7c21b..328878b6799d 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -854,6 +854,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  	 */
>  	mem = find_memory_block(__pfn_to_section(pfn));
>  	nid = mem->nid;
> +	put_device(&mem->dev);
>  
>  	/* associate pfn range with the zone */
>  	zone = move_pfn_range(online_type, nid, pfn, nr_pages);
> -- 
> 2.20.1

-- 
Michal Hocko
SUSE Labs

