Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A53DEC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:57:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5865420850
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:57:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5865420850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF8506B0010; Thu, 21 Mar 2019 10:57:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7F5E6B0269; Thu, 21 Mar 2019 10:57:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C20BF6B026B; Thu, 21 Mar 2019 10:57:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF5B6B0010
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:57:49 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l19so2302437edr.12
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 07:57:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=i2uSTCGkfQuL3YOlx+NsfZROp2req3n+zLD2kKxzDZ8=;
        b=HVC5/f7GRr49Isf3Ad16ZNsMkloBYLM4dJZ+lsWoo3kFlei12k48b56NpVvd8Z/Cr0
         ADQHXNnE09vHVNSWPbkrbdyOF+bxzn/ngn1p/iJa15V3rwLkrx9s5SvPS09dPAiwo+gH
         9aOmmJQbDwaVwK9Njm5FloHO+EaEbmZEz6TUtxHzSiAmtEKzDq/FsatmGYbQa5n6n+15
         RvnisnyTOJwPfmTXS/RRn39MEGae3bBASmWUQtQ78b4DNor0p8f54HIhjW2jstFBqXeF
         hfpeInQ+KVmXUsntmrzmYR0Dh5+4q2T/gRX1XCRUwwCN3eD2FKHE+KDjHogKC0GbdpnP
         TsZQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWiwjn6EY4ycpSWazVZsmzSgNpCF/lraEftIaejItEnSuoWYJqA
	IVLZ9jDKBiGvLWmsVDy8D3gkgQnUBaA4QcCvionT6342EAmJX697DxuVrxhH95Jq3s98f49HRLq
	aPlF+z60rQM1EI8mYJTwWou8Rx51M4PO13eBqvk4lzSqSGZQm6KffZvDgvz4pmEo=
X-Received: by 2002:aa7:dc5a:: with SMTP id g26mr2790595edu.273.1553180269005;
        Thu, 21 Mar 2019 07:57:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxMYXtu6K9khMZVxXgFhQbPhtF/huU2F03bwG/Mh5paW0R3R05CYMhE8PygUKSl1neApZPI
X-Received: by 2002:aa7:dc5a:: with SMTP id g26mr2790546edu.273.1553180267826;
        Thu, 21 Mar 2019 07:57:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553180267; cv=none;
        d=google.com; s=arc-20160816;
        b=g6O8yV8th4Pkaf7Ymb5iQWiETFIJtxYuQ+Jy5sNpssQVFt7STQI+vbvcMbyC2HL3HN
         gOgtu4gZA6kk/ld/bXFryvjQjIRRAUsYYSelpy8Ke0/jOmsHjwd2kIyBelszk33/oog8
         RkcU7qvMDrlsmHXu10UmQ3SCgKsM+INwog2QPC6Qb9EsgqGeNzTqtkiAgOj6ti54Gn9a
         KYAa8VUkzrc1CeSnSnGCZGfB1g1fiz4eQyX8ShO15+5o9alJYcWrqMvHqkbqsYd3M5+i
         opObkSnR9O7XpC/mIj11dL6lWkoGF/ZIWSF9qSVWoxWCNcmqAkzuImfp6N+NnVNUxO0I
         ystg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=i2uSTCGkfQuL3YOlx+NsfZROp2req3n+zLD2kKxzDZ8=;
        b=W9eBHVgczyUhfwZwaf822uLa/N9Hh2j88OPjtuH/VSd41VEEo/jKsCL+ooxweg1aBh
         fKesIc1un2u14VOh7KUEBFToAUgObv10emFD1AbFdUqNRyTj5tgLFNTOKklc9UaRYfq3
         ipAy309vi7BLSFyQdWEP+J1QgYrhhWJ4khaqX8EeIhapdvuKon3V4bs+LNrfw9hkx1pV
         rJSVv3DTAgw/Yz/rEI6f1UygbnReKNx/3Y4B5QsKdDuU7bouQ6mASX8vTC13jZVKhSou
         rHdgDk2L1ZeIYbCJliAfNwywVvX5ojo7K6Al3464tkeqrgHpoNnblNEaRBHUXq8Mwg7S
         4afQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y1si792435edp.441.2019.03.21.07.57.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 07:57:47 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CD105ABDC;
	Thu, 21 Mar 2019 14:57:46 +0000 (UTC)
Date: Thu, 21 Mar 2019 15:57:45 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mgorman@techsingularity.net, vbabka@suse.cz, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH] mm: mempolicy: remove MPOL_MF_LAZY
Message-ID: <20190321145745.GS8696@dhcp22.suse.cz>
References: <1553041659-46787-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1553041659-46787-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 20-03-19 08:27:39, Yang Shi wrote:
> MPOL_MF_LAZY was added by commit b24f53a0bea3 ("mm: mempolicy: Add
> MPOL_MF_LAZY"), then it was disabled by commit a720094ded8c ("mm:
> mempolicy: Hide MPOL_NOOP and MPOL_MF_LAZY from userspace for now")
> right away in 2012.  So, it is never ever exported to userspace.
> 
> And, it looks nobody is interested in revisiting it since it was
> disabled 7 years ago.  So, it sounds pointless to still keep it around.

The above changelog owes us a lot of explanation about why this is
safe and backward compatible. I am also not sure you can change
MPOL_MF_INTERNAL because somebody still might use the flag from
userspace and we want to guarantee it will have the exact same semantic.

> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
> Hi folks,
> I'm not sure if you still would like to revisit it later. And, I may be
> not the first one to try to remvoe it. IMHO, it sounds pointless to still
> keep it around if nobody is interested in it.
> 
>  include/uapi/linux/mempolicy.h |  3 +--
>  mm/mempolicy.c                 | 13 -------------
>  2 files changed, 1 insertion(+), 15 deletions(-)
> 
> diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
> index 3354774..eb52a7a 100644
> --- a/include/uapi/linux/mempolicy.h
> +++ b/include/uapi/linux/mempolicy.h
> @@ -45,8 +45,7 @@ enum {
>  #define MPOL_MF_MOVE	 (1<<1)	/* Move pages owned by this process to conform
>  				   to policy */
>  #define MPOL_MF_MOVE_ALL (1<<2)	/* Move every page to conform to policy */
> -#define MPOL_MF_LAZY	 (1<<3)	/* Modifies '_MOVE:  lazy migrate on fault */
> -#define MPOL_MF_INTERNAL (1<<4)	/* Internal flags start here */
> +#define MPOL_MF_INTERNAL (1<<3)	/* Internal flags start here */
>  
>  #define MPOL_MF_VALID	(MPOL_MF_STRICT   | 	\
>  			 MPOL_MF_MOVE     | 	\
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index af171cc..67886f4 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -593,15 +593,6 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
>  
>  	qp->prev = vma;
>  
> -	if (flags & MPOL_MF_LAZY) {
> -		/* Similar to task_numa_work, skip inaccessible VMAs */
> -		if (!is_vm_hugetlb_page(vma) &&
> -			(vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE)) &&
> -			!(vma->vm_flags & VM_MIXEDMAP))
> -			change_prot_numa(vma, start, endvma);
> -		return 1;
> -	}
> -
>  	/* queue pages from current vma */
>  	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
>  		return 0;
> @@ -1181,9 +1172,6 @@ static long do_mbind(unsigned long start, unsigned long len,
>  	if (IS_ERR(new))
>  		return PTR_ERR(new);
>  
> -	if (flags & MPOL_MF_LAZY)
> -		new->flags |= MPOL_F_MOF;
> -
>  	/*
>  	 * If we are using the default policy then operation
>  	 * on discontinuous address spaces is okay after all
> @@ -1226,7 +1214,6 @@ static long do_mbind(unsigned long start, unsigned long len,
>  		int nr_failed = 0;
>  
>  		if (!list_empty(&pagelist)) {
> -			WARN_ON_ONCE(flags & MPOL_MF_LAZY);
>  			nr_failed = migrate_pages(&pagelist, new_page, NULL,
>  				start, MIGRATE_SYNC, MR_MEMPOLICY_MBIND);
>  			if (nr_failed)
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

