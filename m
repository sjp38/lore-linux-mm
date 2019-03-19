Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BE26C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 13:27:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C433206BA
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 13:27:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C433206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBF176B0003; Tue, 19 Mar 2019 09:27:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6DC26B0006; Tue, 19 Mar 2019 09:27:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5D1F6B0007; Tue, 19 Mar 2019 09:27:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5E6636B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 09:27:37 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o9so8145218edh.10
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 06:27:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DZsqno0zV+2IhWSck9i1ORZwdbnkP/TTOB3fzHLxxmg=;
        b=uX/6bKhaX4KAS6OAbhOsgfvR9lzWvg3pzfz4qrLJfjnCgTaXLZ+i/ml0KIlY+4i1kE
         8eosK6boGPZGjtUopZZRqdF8m1coZeMxjhHyqfkVTNOcZ/4It/6472T7w6qRp+1rGSQi
         TFxbmcX5OJ3QeiT3EXn8CUtIgZi7UAkf5SKnQjSs24+WLvo1xdnCcZo5xbF05Hg7gZ00
         9BMIx6A60vRKORi7mbu7+ykEwv2GGB1KvjpNOAn4ptAGMPhPgqBRiq+e35KShPb6+uot
         vGFQ1+tKEwlz1588Qdah3a8jRdRhkkh7V7tcrNd4roaFSgFsg2ERKz9qOjQAm1gk71hg
         8mzA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUM+s3pVVIV4xk0q2RwsDrGRnK4hr2MtQ0gb1v5CHnjXLaX+Sdr
	O6XWd4DHWDGolLMuyBHXLCb5JqptnGTpwhPNJV+egXJd+96pAhprY/A9/FH1sD0p4UMEOadmnuu
	Gli66QRg3PHcd8LVJIFkuni7Gmso74HjWXLkAw25oMvQOF+rcZhAWZeflKfUD3bAP9Q==
X-Received: by 2002:a17:906:2a98:: with SMTP id l24mr9532025eje.25.1553002056877;
        Tue, 19 Mar 2019 06:27:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCzAqKpQWBtDVfUeY2GNSeAbwzS5iuvkO60TdAOZVsamzj5Q9+H5LBTf/evg8dKe9E0lcF
X-Received: by 2002:a17:906:2a98:: with SMTP id l24mr9531983eje.25.1553002055768;
        Tue, 19 Mar 2019 06:27:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553002055; cv=none;
        d=google.com; s=arc-20160816;
        b=qaXKead9na/CKmadAT/D1mqra69QNahCw8o6rE0Nv1kzfiLdEIb2En3lKOaQO21Df/
         bIKc1DWtaMW+9bB/3Ys8bYw9QM1XzAip1B/3YHohbzPqb0rxaQZRAgz2MhxmeNXLd6XT
         +lIC2c5Km8LJ2zNi+/I2weNvM7hWaIPZL9r6Iu/ufCkkmQD7TcwyCtXdT3Jg/ullFskv
         Udn4JuEFxGZib+mqYNgqxYzFNRx71LVs673uNpuOXIQWZCh6Sfr5S9KoNK9Ettjmq6+X
         uIDQaLsx8NyHNTQ/1dxzaFTWhtQQlVleThVNHzp4LWUkz0flAFcLmzyH7LLZ/xIVBFTu
         8RWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=DZsqno0zV+2IhWSck9i1ORZwdbnkP/TTOB3fzHLxxmg=;
        b=lIKvjVl0dd1DTtgzPDTT8NRD2QPrIbc4OAx2/p43fSmDhmkIrx2QPFTf85U+Yyb6IP
         6v91lGWCHbv3BSzrCY8H6AeeBiiacCmHoas1853v0gBuJZdCiYbmPrDxJkQ7oJJdarlE
         pxaaTxM3t9DDjhNg3YDDEkAGoptc+3WaHoveaUqz3+Ls83whyBbhAe2zE/ULeXUMrevW
         HXRul2CaR+oRwzIUw1CSVY+a8b56sVF1xKdpZkGxlRXmBCpDtqjuKaQ5ORk03GZhm/zX
         gGubqPMCWVng1yuaiYFdeljSsVGEyCh+WWHYVrysmXMgJ7NRFpd+4lWE1cbZwKCirrCj
         opvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id a6si3939305edn.261.2019.03.19.06.27.35
        for <linux-mm@kvack.org>;
        Tue, 19 Mar 2019 06:27:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id B5EE14601; Tue, 19 Mar 2019 14:27:33 +0100 (CET)
Date: Tue, 19 Mar 2019 14:27:33 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Yang Shi <shy828301@gmail.com>
Cc: Cyril Hrubis <chrubis@suse.cz>, Linux MM <linux-mm@kvack.org>,
	linux-api@vger.kernel.org, ltp@lists.linux.it,
	Vlastimil Babka <vbabka@suse.cz>, kirill.shutemov@linux.intel.com
Subject: Re: mbind() fails to fail with EIO
Message-ID: <20190319132729.s42t3evt6d65sz6f@d104.suse.de>
References: <20190315160142.GA8921@rei>
 <CAHbLzkqvQ2SW4soYHOOhWG0ShkdUhaiNK0_y+ULaYYHo62O0fQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHbLzkqvQ2SW4soYHOOhWG0ShkdUhaiNK0_y+ULaYYHo62O0fQ@mail.gmail.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

+CC Kirill

On Mon, Mar 18, 2019 at 11:12:19AM -0700, Yang Shi wrote:
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index abe7a67..6ba45aa 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -521,11 +521,14 @@ static int queue_pages_pte_range(pmd_t *pmd,
> unsigned long addr,
>                         continue;
>                 if (!queue_pages_required(page, qp))
>                         continue;
> -               migrate_page_add(page, qp->pagelist, flags);
> +               if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
> +                       migrate_page_add(page, qp->pagelist, flags);
> +               else
> +                       break;
>         }
>         pte_unmap_unlock(pte - 1, ptl);
>         cond_resched();
> -       return 0;
> +       return addr != end ? -EIO : 0;
>  }
> 
>  static int queue_pages_hugetlb(pte_t *pte, unsigned long hmask,

This alone is not going to help.

The problem is that we do skip the vma early in queue_pages_test_walk() in
case MPOL_MF_MOVE and MPOL_MF_MOVE_ALL are not set.

walk_page_range
 walk_page_test
  queue_pages_test_walk

	...
 	...
	/* queue pages from current vma */
	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
		return 0;
	return 1;

So, we skip the vma and keep going.

Before ("77bf45e78050: mempolicy: do not try to queue pages from !vma_migratable()"),
queue_pages_test_walk() would not have skipped the vma in case we had MPOL_MF_STRICT
or MPOL_MF_MOVE | MPOL_MF_MOVE_ALL.

I did not give it a lot of thought, but it seems to me that we might need to reach
queue_pages_to_pte_range() in order to see whether the page is in the required node
or not by calling queue_pages_required(), and if it is not, check for
MPOL_MF_MOVE | MPOL_MF_MOVE_ALL like the above patch does, so we would be able to
return -EIO.
That would imply that we would need to re-add MPOL_MF_STRICT in queue_pages_test_walk().

-- 
Oscar Salvador
SUSE L3

