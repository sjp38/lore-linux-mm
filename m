Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1CC2C10F05
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 08:14:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BD7E2084B
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 08:14:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BD7E2084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 185766B0006; Mon,  1 Apr 2019 04:14:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10EE86B0008; Mon,  1 Apr 2019 04:14:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F17CB6B000A; Mon,  1 Apr 2019 04:14:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 99A2A6B0006
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 04:14:44 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z98so4043549ede.3
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 01:14:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=OlwPsHPL3UFoVGCXCQloUW0f8hygBy/Kizop/FlYfQk=;
        b=YHPhWEhCuK4sDkY/t9kXKF1KQWtFz2Vj05MmbAu3gdkCXPRilSGUty1y/Kh5SX5PG/
         WXUdqPaZe6aTj0A/Lvk74wUCNs7bG08IDVLBWf8rrv8kTEHt0duvna96GHQ4lLkQ7Nbr
         MF9CqMYIBlCbfERQYamb59+5+vjRhn5Aty0dzZJR6dEab2lF11dB+f6Xmqc8lDePF6wD
         eHL7OcpS4b3Rf+gUui9bVToQZcvguYc4nRJ3yeNneKDWgEnTTB9t7plUz8vuMEAvYoKg
         qAKPGzZGdNi5rhw5bm5au9JipZaT1mNw8dOBW1dzpuzkBKWLrunj5uxZlAnz2+AlPJmu
         tM8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAUYPamITOUPJFLR5iDhvrp8Dm+pDy0Q5hi7g1kCFzeiz6twF46t
	s3vwyjymrscXEwCQxkh4CpkNK+6cT5Ycyelql7C7LA0KfJ7YnDBRz43jfEUiuVlRbfkO9zIersE
	jkYaKH5svOZBXhG9JfsHftlUKro1C52k2gBSXUIxwpVSXbxKY8qcG5iwMD5UDCBGc5Q==
X-Received: by 2002:a17:906:1584:: with SMTP id k4mr32037055ejd.226.1554106484107;
        Mon, 01 Apr 2019 01:14:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1kJjJNqzehE3HWqrBQf2Y4f1l2hlxCJF6cz3Vi6fn8rFIx3NblD7IiTUbdZnILJbQnLdT
X-Received: by 2002:a17:906:1584:: with SMTP id k4mr32037018ejd.226.1554106483186;
        Mon, 01 Apr 2019 01:14:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554106483; cv=none;
        d=google.com; s=arc-20160816;
        b=sMzf8bO6R9z/1S6l2kmVhPgv1YRywW0OureankpISMXcE7fnebD5d4DeeHzjqWTQcB
         rqQOXYL79AKQ3aEa5IkBsAjDhcU9/DNPsfcD9kqAcy9BqCQm5a8hYoNbflp8tLtZkltE
         28l5VXESlJ2O/ELuYqFKWCQL1/NRcX3zGodHgRxqHu1cv1QaKPGQiIy4xrRbbuQYrfws
         XksTNqM+tkyCiR094GLcZ1M62cCsC+A5q8+0eTxeHy2c/A5LRWSBXz062bAAuJundZaS
         tHQ4EJ+06ZUSirOIcV7cgA4ElJDbfMNMeVh86nFSjFyG8eIw0az7f4veQth5xtjcDViP
         VDGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=OlwPsHPL3UFoVGCXCQloUW0f8hygBy/Kizop/FlYfQk=;
        b=0XZ36h2PNGDh3Rst2wGykTlCucpJR3ey1mQ8OLkrlCFlSdrUQHBUZIaeHlAsK8Gcqz
         vmoQGumek4vfLPBGRrvBAk0HgimdwrUlrnEP2IMkqTAvFZi8fBGfIFs0OnpD+BgkUfqT
         haaexlvoYBhx+WrjHwMOP2d9aUQ+w0AOzN27YRILqQ94r6wBQHHR+J/QtPkCCgHgxENG
         nb4X6YJ/vzDvk2usKh/OorGx7ZV7OdfWo5TAqIxDUOeYpOoYI7yfEIyZ+KM2ApVMo7az
         uPWFzcm2QLfsh39pv4YoPwL0tM0ccfQkDYQY6FYZLTX5Q+KGDogM4nIfd4OOsYD2pmCb
         0pyg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t23si2626660ejl.208.2019.04.01.01.14.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 01:14:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 48BE9ACB1;
	Mon,  1 Apr 2019 08:14:42 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id DD5AC1E42C7; Mon,  1 Apr 2019 10:14:41 +0200 (CEST)
Date: Mon, 1 Apr 2019 10:14:41 +0200
From: Jan Kara <jack@suse.cz>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: dan.j.williams@intel.com, akpm@linux-foundation.org,
	Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org,
	linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org,
	stable@vger.kernel.org
Subject: Re: [PATCH] mm: Fix modifying of page protection by insert_pfn_pmd()
Message-ID: <20190401081441.GD4826@quack2.suse.cz>
References: <20190330054121.27831-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190330054121.27831-1-aneesh.kumar@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 30-03-19 11:11:21, Aneesh Kumar K.V wrote:
> With some architectures like ppc64, set_pmd_at() cannot cope with
> a situation where there is already some (different) valid entry present.
> 
> Use pmdp_set_access_flags() instead to modify the pfn which is built to
> deal with modifying existing PMD entries.
> 
> This is similar to
> commit cae85cb8add3 ("mm/memory.c: fix modifying of page protection by insert_pfn()")
> 
> We also do similar update w.r.t insert_pfn_pud eventhough ppc64 don't support
> pud pfn entries now.
> 
> CC: stable@vger.kernel.org
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>

Thanks for fixing this! The patch looks good to me. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/huge_memory.c | 31 +++++++++++++++++++++++++++++++
>  1 file changed, 31 insertions(+)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 404acdcd0455..f7dca413c4b2 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -755,6 +755,20 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
>  	spinlock_t *ptl;
>  
>  	ptl = pmd_lock(mm, pmd);
> +	if (!pmd_none(*pmd)) {
> +		if (write) {
> +			if (pmd_pfn(*pmd) != pfn_t_to_pfn(pfn)) {
> +				WARN_ON_ONCE(!is_huge_zero_pmd(*pmd));
> +				goto out_unlock;
> +			}
> +			entry = pmd_mkyoung(*pmd);
> +			entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> +			if (pmdp_set_access_flags(vma, addr, pmd, entry, 1))
> +				update_mmu_cache_pmd(vma, addr, pmd);
> +		}
> +		goto out_unlock;
> +	}
> +
>  	entry = pmd_mkhuge(pfn_t_pmd(pfn, prot));
>  	if (pfn_t_devmap(pfn))
>  		entry = pmd_mkdevmap(entry);
> @@ -770,6 +784,7 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
>  
>  	set_pmd_at(mm, addr, pmd, entry);
>  	update_mmu_cache_pmd(vma, addr, pmd);
> +out_unlock:
>  	spin_unlock(ptl);
>  }
>  
> @@ -821,6 +836,20 @@ static void insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
>  	spinlock_t *ptl;
>  
>  	ptl = pud_lock(mm, pud);
> +	if (!pud_none(*pud)) {
> +		if (write) {
> +			if (pud_pfn(*pud) != pfn_t_to_pfn(pfn)) {
> +				WARN_ON_ONCE(!is_huge_zero_pud(*pud));
> +				goto out_unlock;
> +			}
> +			entry = pud_mkyoung(*pud);
> +			entry = maybe_pud_mkwrite(pud_mkdirty(entry), vma);
> +			if (pudp_set_access_flags(vma, addr, pud, entry, 1))
> +				update_mmu_cache_pud(vma, addr, pud);
> +		}
> +		goto out_unlock;
> +	}
> +
>  	entry = pud_mkhuge(pfn_t_pud(pfn, prot));
>  	if (pfn_t_devmap(pfn))
>  		entry = pud_mkdevmap(entry);
> @@ -830,6 +859,8 @@ static void insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
>  	}
>  	set_pud_at(mm, addr, pud, entry);
>  	update_mmu_cache_pud(vma, addr, pud);
> +
> +out_unlock:
>  	spin_unlock(ptl);
>  }
>  
> -- 
> 2.20.1
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

