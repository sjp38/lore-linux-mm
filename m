Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D343C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 16:11:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09361208E4
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 16:11:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09361208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 643308E0005; Tue, 30 Jul 2019 12:11:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6199E8E0001; Tue, 30 Jul 2019 12:11:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52EC58E0005; Tue, 30 Jul 2019 12:11:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2448E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 12:11:21 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id n185so28204032vkf.14
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 09:11:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pTZuPkkB8u6xyziJ1eyRam1LNjIXH7rFxfwuuW48seM=;
        b=UWvnix3kfv37ATMhvjxod3Mt000+enD69Q3P+dt+ozJJsrBO3vu68in4xl0TfwEzz0
         yB88pfMpIwcGerbJ2OZryqdXCw29l2fK3B/C3g6e/zz4bUohEHWcEolO6wkiVy52GNfs
         DsykW/QvulxTcswDIQ2p3Z/Svsunurfz7Y4NhiGfOj3/UWRu+PwF3iqbMUp1bAmXyUxM
         ZOd7WbhjGF46LPN+MAFApbqB+mp0eCr+9VA5CgkXjpyJXWRdKk5vwjruSKAN9KjYE/ft
         vVxcYDC24Cso7Y3gDfVzSPBfB0jl0srIxnKHPocYZaxpdvj2rc63qXqU2EI/FS63bPdA
         krcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWFggc6oQuiU2j6faahpOFt4Y6QaENSuS0gJDAfTRq+qRei3nBG
	Ix26k/d+wKpX8fkbxhPO7URdtEoDgXM5PgCwbzksMfQoI/ihD/Tb1n3kI16XiZqEIYu/6KBf/3k
	rjOX65iCwKSj66hiSZ+SfdA9idfO0FpwC4GhTH65ntrP8AWhZJ0jEbEQOmRDmE2V5EA==
X-Received: by 2002:a1f:a887:: with SMTP id r129mr1123403vke.75.1564503079333;
        Tue, 30 Jul 2019 09:11:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzTh+PKG25bCWgUf3b4TvqGzgp7zT40IffAmVZW50LXRcv7CZn11/kGd3wO9ITbnDhF53om
X-Received: by 2002:a1f:a887:: with SMTP id r129mr1123313vke.75.1564503078329;
        Tue, 30 Jul 2019 09:11:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564503078; cv=none;
        d=google.com; s=arc-20160816;
        b=cyuGZ1b93M9wkP19Haqpf64NXPd5AM5W/spqQmUb0YI4GYnF5xDi0W2Pb8xCGfI4FO
         cwVeANEjorTHO0OOo89Gl7NLdu3IjVs+26y3X+SuXzhXw939gky4bUwAdnB8V760WOHn
         4kcplWD2IRAn6DJuO0QO0Nl5yoVWoqP+fgTNZV5UM9012Xp9XN/4t3Oar6QaUTi4HkFc
         GjQT82str/ZmgJvYp6EjHztQ7lPO6U8ZlLBhZxI2soG7OUB5rRveiEsoYAR9qldINTeE
         Y8ORV46yvSZ7NH6boko4PWoR8dduKY0AnsGrjoERttXR1JHS1USlYxF8CH2eZyLUMEfA
         HhVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pTZuPkkB8u6xyziJ1eyRam1LNjIXH7rFxfwuuW48seM=;
        b=crq3fq9urtPjo81aAWCWvp+Wu6Uo68EbA/vvGDCq2xk+Q58PmUL/VW/6CN0vcbas3M
         lM63FspknSC9q093tTBnJtbMI+4XA9+GDGw2GIND+E3hE5CgoTyanLFXs/9P1iuB/DmM
         iHEuQalk4YbosqdD8uJT+U07c7CjvJWKg7+aNpxF2Ug2D2O7UuKwCZaUPXsOHHn6a3ux
         ZYLdUmPEtb+tsiyO5NqSAecO2DI71gUvDOvEWeIyyxUcu3GCloCEwk9Yk+/6u9gqimqx
         8lRt6I4wGMZnqQi0eJeucjHKFeZxKSX4eMnovZ42lSAMVMPwhOmtQUZKbnMWvbpJhGVE
         IFFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i3si14296381vsm.21.2019.07.30.09.11.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 09:11:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2A55481F25;
	Tue, 30 Jul 2019 16:11:17 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 3B4561001938;
	Tue, 30 Jul 2019 16:11:15 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Tue, 30 Jul 2019 18:11:16 +0200 (CEST)
Date: Tue, 30 Jul 2019 18:11:14 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, srikar@linux.vnet.ibm.com
Subject: Re: [PATCH v10 3/4] mm, thp: introduce FOLL_SPLIT_PMD
Message-ID: <20190730161113.GC18501@redhat.com>
References: <20190730052305.3672336-1-songliubraving@fb.com>
 <20190730052305.3672336-4-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730052305.3672336-4-songliubraving@fb.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 30 Jul 2019 16:11:17 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I don't understand this code, so I can't review, but.

On 07/29, Song Liu wrote:
>
> This patches introduces a new foll_flag: FOLL_SPLIT_PMD. As the name says
> FOLL_SPLIT_PMD splits huge pmd for given mm_struct, the underlining huge
> page stays as-is.
>
> FOLL_SPLIT_PMD is useful for cases where we need to use regular pages,
> but would switch back to huge page and huge pmd on. One of such example
> is uprobe. The following patches use FOLL_SPLIT_PMD in uprobe.

So after the next patch we have a single user of FOLL_SPLIT_PMD (uprobes)
and a single user of FOLL_SPLIT: arch/s390/mm/gmap.c:thp_split_mm().

Hmm.

> @@ -399,7 +399,7 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
>  		spin_unlock(ptl);
>  		return follow_page_pte(vma, address, pmd, flags, &ctx->pgmap);
>  	}
> -	if (flags & FOLL_SPLIT) {
> +	if (flags & (FOLL_SPLIT | FOLL_SPLIT_PMD)) {
>  		int ret;
>  		page = pmd_page(*pmd);
>  		if (is_huge_zero_page(page)) {
> @@ -408,7 +408,7 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
>  			split_huge_pmd(vma, pmd, address);
>  			if (pmd_trans_unstable(pmd))
>  				ret = -EBUSY;
> -		} else {
> +		} else if (flags & FOLL_SPLIT) {
>  			if (unlikely(!try_get_page(page))) {
>  				spin_unlock(ptl);
>  				return ERR_PTR(-ENOMEM);
> @@ -420,6 +420,10 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
>  			put_page(page);
>  			if (pmd_none(*pmd))
>  				return no_page_table(vma, flags);
> +		} else {  /* flags & FOLL_SPLIT_PMD */
> +			spin_unlock(ptl);
> +			split_huge_pmd(vma, pmd, address);
> +			ret = pte_alloc(mm, pmd);

I fail to understand why this differs from the is_huge_zero_page() case above.

Anyway, ret = pte_alloc(mm, pmd) can't be correct. If __pte_alloc() fails pte_alloc()
will return 1. This will fool the IS_ERR(page) check in __get_user_pages().

Oleg.

