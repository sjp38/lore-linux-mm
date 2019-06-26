Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNWANTED_LANGUAGE_BODY,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 721BEC4646B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:24:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35D902085A
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:24:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35D902085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D53DC8E0007; Wed, 26 Jun 2019 02:24:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D03E38E0002; Wed, 26 Jun 2019 02:24:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1B078E0007; Wed, 26 Jun 2019 02:24:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 734008E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:24:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id a5so1573931edx.12
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 23:24:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ixbkhMjrvN4fyamwYxcbOCGRSUAVx754wX2dY3eqNS0=;
        b=bsPl43J/RM/g07REB6B86Dxmt9x2lLbsPbLA5bAb5CJu4MqfFKLEA4zodwx1qtkSKA
         hbPgf+F2vTDIXR6HcMnvXXCT70S5q9VT0DDYaRpH38ppgxjdHs28IMfzCRnZLlyUh0qh
         ms1w8Azm7IHM4UaSU2ht4kBgUKRQKsskk0hX4wPB2D2R8LaOsk3N+QM1eSX3r8Q7n4+d
         heT2NzT1Og7P0Kv5tBupJOwH4TPOsbS5wzuKggcfYS6yl8ecxGqJlyOmvkTbe98BwrqS
         zvP20/Ll8kzxdS2Q1y/GVJCXkFzORcMbrqvTT00vIhzrRwbZe6dgIHHBvMG00WYwE2r0
         zefA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVoK20miXedCjVaWJGdIlZNOTiiPktZOXEwLgD9mQFk2NnIOPf2
	yBGQs0D2H7KKmeJnMRefORRXPC/n6Kv8l7VHCHZMCpRJLhpiVkIYjszwhOE8+MOehWtS+we0AUg
	wi+mOF4KY4vP8EABCqU8Su34HHsdK5cuIdbBiqiEonX3C2AkPZVPf5hBBSk/gHLE=
X-Received: by 2002:a50:9f81:: with SMTP id c1mr3054277edf.140.1561530272054;
        Tue, 25 Jun 2019 23:24:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvnWdM7d8O/Ofkzh2MxmNx9Z5/yv6TYYeraagIMA0n5oopnmSZmab9CkpruI9yVNlgAq8z
X-Received: by 2002:a50:9f81:: with SMTP id c1mr3054232edf.140.1561530271435;
        Tue, 25 Jun 2019 23:24:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561530271; cv=none;
        d=google.com; s=arc-20160816;
        b=ydHgf5fTaGGd4vA01rfY2oeBpWR2aD0Pj6YBf87Pz54wkTdKMPhdnn4XafRvL/44FM
         rV5b2Zc3F/RXrCKlIIgkXUgFKFfplLoh/PJ4iQQWVmjrlEEyNYoE/rnXA/I4CHl6BnFn
         pR6sxR1YxZrlrRYVUj67sxeqoVoM/Qw+0R1cUBOhVnevFkODY27Jo7s7rAlJ4l1rOD3E
         xO6EHZAYzl+eaEmRQYtWAeG3cbxzIDJ+0boxBk/pqQJehfEM3cPo8wkwvb2Pm2FldkPT
         85r9cO9FtymvzE45L73YsgvjCbOKKf468mCRurjLNyXr/uMBEwSNOIHqHbCdnxYItaxN
         jT6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ixbkhMjrvN4fyamwYxcbOCGRSUAVx754wX2dY3eqNS0=;
        b=PIc55bu9kUPp1uyFQ4wNsSJacTu4itSEyOn06+eQ1dXlN3z0do32t/CW8JVo4dEm/+
         l91XT6dSYFX3+ho+gXTQZcTfykWQS9oS1Mq9+ioZHH7N3pF/U08A+/+6K8ecuCA8Edvd
         qJKUDFq+OO7K3J9hpca+Qn3ExMImrvO7f/Rw+k6F2eVECPNtIBOwZ67ktlyt/ZzK8SW0
         j6co/3K1f43lsbMvWe9HeZTac9buBSNvn1wGw9ZwtvOTNXHglTfX3QnZv8mbrAgJeoe+
         DnqFDwjZ/lvf8ffgFk8Kp2ATeYRZ7SNJz9J5RcLhvCBQA/HFMiSunaGprLNhpHG1hqXL
         YbBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x11si1858830ejf.153.2019.06.25.23.24.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 23:24:31 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 011A7AD47;
	Wed, 26 Jun 2019 06:24:31 +0000 (UTC)
Date: Wed, 26 Jun 2019 08:24:28 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alastair D'Silva <alastair@au1.ibm.com>
Cc: alastair@d-silva.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Oscar Salvador <osalvador@suse.de>,
	Mike Rapoport <rppt@linux.ibm.com>, Baoquan He <bhe@redhat.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v2 3/3] mm: Don't manually decrement num_poisoned_pages
Message-ID: <20190626062428.GH17798@dhcp22.suse.cz>
References: <20190626061124.16013-1-alastair@au1.ibm.com>
 <20190626061124.16013-4-alastair@au1.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626061124.16013-4-alastair@au1.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 26-06-19 16:11:23, Alastair D'Silva wrote:
> From: Alastair D'Silva <alastair@d-silva.org>
> 
> Use the function written to do it instead.

I am not sure a single line helper is a great win but this makes the
code consistent at least.

> Signed-off-by: Alastair D'Silva <alastair@d-silva.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/sparse.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 1ec32aef5590..d9b3625bfdf0 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -11,6 +11,8 @@
>  #include <linux/export.h>
>  #include <linux/spinlock.h>
>  #include <linux/vmalloc.h>
> +#include <linux/swap.h>
> +#include <linux/swapops.h>
>  
>  #include "internal.h"
>  #include <asm/dma.h>
> @@ -772,7 +774,7 @@ static void clear_hwpoisoned_pages(struct page *memmap,
>  
>  	for (i = start; i < start + count; i++) {
>  		if (PageHWPoison(&memmap[i])) {
> -			atomic_long_sub(1, &num_poisoned_pages);
> +			num_poisoned_pages_dec();
>  			ClearPageHWPoison(&memmap[i]);
>  		}
>  	}
> -- 
> 2.21.0

-- 
Michal Hocko
SUSE Labs

