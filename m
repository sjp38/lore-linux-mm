Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BE0DC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 16:37:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 299A9217F4
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 16:37:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 299A9217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDA1C6B0010; Thu,  8 Aug 2019 12:37:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8B286B0266; Thu,  8 Aug 2019 12:37:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A794E6B0269; Thu,  8 Aug 2019 12:37:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 884EA6B0010
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 12:37:49 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id r58so86089304qtb.5
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 09:37:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BxmTRd1oiIxF3kyOyoKVj3Yuo6YDzkPKRvKbQqACDXg=;
        b=oFELEP7RDKoZsB7mwEhMTV4Da73tuk9/AWmdMOdLaGL09uZ6aojW6eeylHMCob7H9H
         MYoCYTSkY/O3LzzQqroqCDvJXyV052UUCE/WVxF3CWBrFLIvhIukyxKlMkBBY6tCHDzw
         2rRUdt820zWigAJCb7qoSMPCE7O25gYDJx7PBaIdfnu8KSKcFJ0lst1QdK9gbSHT40qT
         Hhz/J1q4QSwT2kS1u4+JhLFFEP52CvcWZmnRn+RO62BcMvUXAS0I2BgfZyogYeUI8UY8
         p2OVUqxlrXTN+/PM5pEp6iXRYnjVR3CCu+QyMxKgeSAkmV/xXqFvS2bfJvw0eDTiL5Xj
         f2BQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXKtQ9TkzMtxEsAzWsBv7xWFztDw4rmbDz0tQrSRpEQvi9BEYca
	80MEWT+ks5AZyK2QIovIHOJLzyFUj5h4Z6LXEDt2ZrRoJTZnwRALT0QsCUjZkSlSca7IxiybQKC
	lgPC4Au0pEbeIbXni24AAhjjG9LqD/4cBDurmVGFpkjvWtbdwTvsvJmbbSgEzhO9KwA==
X-Received: by 2002:ac8:128c:: with SMTP id y12mr1063733qti.242.1565282269363;
        Thu, 08 Aug 2019 09:37:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyalrK76EZjDm7CEbyzqSZISIFTufaGlYAgnK1mkKmm7aaxu7q/WNpJDgw+/oMnCNsRCki8
X-Received: by 2002:ac8:128c:: with SMTP id y12mr1063700qti.242.1565282268933;
        Thu, 08 Aug 2019 09:37:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565282268; cv=none;
        d=google.com; s=arc-20160816;
        b=EB9m9ctcqtcD8Y+5xCfy5ZEUMzMJ5ca8EAhL9kM+IiwDS4JJabixb3WmOCiZ4fTU9W
         sLk82Zz8Skf/npDQeh6vdWQ9smGfUhuobm3Aob7a5jaTwKSHVOW1PP2DsHBEIZh5bzSQ
         nVeqHxFNlI53BMz4ExnJhqDVhXUwgH2yiZwChLVcML8OOU198BZVqzTOP93Yd+WgJFbr
         B0XXIc6JoOPZ1cXxg5eD7SMqJ2sHXjXwd22D8qDBJLMJEmAmLhTpecrQC/ZuTXMJg8VY
         55KWxXyIEpGQ10Yu7g1rrkjE1DNGINKGoraonmnd+4n+MO7eo5QFkxihzAKyJmciB4hQ
         l2bg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BxmTRd1oiIxF3kyOyoKVj3Yuo6YDzkPKRvKbQqACDXg=;
        b=WQVa6uaDNEqpfhVW2A2G0/Y+SyVtfKQw2D4Y8REslwzUmOhBRbGMm8c//CtGEVEKHd
         VUN4FycgbEpxTsgIh3J7TQh85pn2nn83MouChxoal52icmf6rVXH/Yc0njJneqCfaLNl
         o8hXn9hkGnIzE6l1qIkmm4j1eqceaj4Uq+90Yjvvbus9KMZPYIqWEaWlIhB4Sc6FotlZ
         uUGtU8h0Nvojfk7iUF3qW+LMsK1lQFQlh7k3QYCr3gB6l+l+QT6QMoQ9mtguTvnDva81
         3AE3sS38QBJ2VUaZ6Dn8mP2izpec4Jk5VKtER/GkMJIrFNYeJnprIKvRqMZ/dO0vy2OT
         gmgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h67si54146046qke.108.2019.08.08.09.37.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 09:37:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 327817BDDA;
	Thu,  8 Aug 2019 16:37:48 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 6AEDE5D784;
	Thu,  8 Aug 2019 16:37:46 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Thu,  8 Aug 2019 18:37:47 +0200 (CEST)
Date: Thu, 8 Aug 2019 18:37:45 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, srikar@linux.vnet.ibm.com
Subject: Re: [PATCH v12 3/6] mm, thp: introduce FOLL_SPLIT_PMD
Message-ID: <20190808163745.GC7934@redhat.com>
References: <20190807233729.3899352-1-songliubraving@fb.com>
 <20190807233729.3899352-4-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807233729.3899352-4-songliubraving@fb.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 08 Aug 2019 16:37:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/07, Song Liu wrote:
>
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
> +			ret = pte_alloc(mm, pmd) ? -ENOMEM : 0;
>  		}

Can't resist, let me repeat that I do not like this patch because imo
it complicates this code for no reason.

But I can't insist and of course I could miss something.

Oleg.

