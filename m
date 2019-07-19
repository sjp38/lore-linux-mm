Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98A51C76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 12:48:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E9352082F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 12:48:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E9352082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B5B96B0005; Fri, 19 Jul 2019 08:48:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83EE08E0003; Fri, 19 Jul 2019 08:48:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 753868E0001; Fri, 19 Jul 2019 08:48:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2BB8C6B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 08:48:27 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n3so21974261edr.8
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 05:48:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=lVA7wBE3fHjuwQq9jdeHEw0nicOLf8sMDsOSBu4TZVw=;
        b=ri/wvOwHXbk2lp8rQzNgvM/tNL2UmPSCgOg553R17VksqNGR5XuM9qkA4YNhnSGjqU
         pKnX8fnonBV4MUf1eyOmIiK+SH1jA0vwhDmvJOz4i9gOTcGQYsRPmqQNNcsIQPIX6Pba
         C613wx4PuKjSyKHhI1c4yygueRH3UEbXRQazbD59upe1HDd2shHw4eB4l0fZLy+cxXM7
         9R1YlzG0D9FRXhZQn8HR/lnIP0K+uSA7xC0Om68m9beWlOng6+nbuLwXd8puyB7nUqZc
         Xkagmt/BgGrDhITcQ1WNjFJnAaXaIjhFLU/NPioMHecQPD+Gg0W0dunyWM2MvAgwkk8A
         mMbQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAWSy/F074EB6UHmp71GCJh1WEayTi5F1V5oyopHa/MpuTGOhN7G
	/WYd+BGPrNhkXDzyP+bDtHogjnh8PlnXui9r1nXoxHl6mGcC2DgBOBNLBrlLATFGfSR1ZrvuN5A
	HE99nf7BskZIDsLYKkiT2gfs3BntDlSMGgnJ86Sr3vCtJvB25i/QWtUfNLyR0zZb6xg==
X-Received: by 2002:a50:871c:: with SMTP id i28mr46358119edb.29.1563540506733;
        Fri, 19 Jul 2019 05:48:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwItR0sjaeJpbUxt+lfEzZk8iWzylr1gpCECs2NuhZkD++LB6f8WuQMsi4tRbTr916yKNoX
X-Received: by 2002:a50:871c:: with SMTP id i28mr46358058edb.29.1563540505752;
        Fri, 19 Jul 2019 05:48:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563540505; cv=none;
        d=google.com; s=arc-20160816;
        b=IbQL0AzYDamLO3v4VUHI59sZ2Biv5uCg/bWmq72O3bAY8LMUD57BDDmjpoPX8qrCze
         982Z7S0IAjiKS4njwY5O5L6uiiNakJUTLSz7jQuJ6FU/R7iqSxOw0wu+eSscyifOENfL
         6yDmZAOnR4Mybw1sujgnUsGFAHVs8HSZojByMERrbzTmk8HGPbSGuIuPjNCrywMrsHeT
         MB+neHHdoIPY2j+YVVA7gx8dcuE5+mfVyodKkqLEuFTGONeIRtMRyqwoU6TJHMWN2VqA
         7h+EpaHKCvRlYjwpQ8ssyn1x/NdWNGF3PFOrMC9PceSnh/OaOAn6gncFEm5mJdDwOtxf
         niqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=lVA7wBE3fHjuwQq9jdeHEw0nicOLf8sMDsOSBu4TZVw=;
        b=PApDUYfKBsTfFpfckueJiIAdqo4HmE+cZMaaF+SGoZyNa4XDq1ijL9WGpcXqoSIAnT
         wBDUdRHHuaesTXyRd6CYhNtGuGWtLDaaeILHhbyTD9tdXamAdSODa4SWFZKeylecTuZv
         3mLP5kzyWr8ceb4u/e4gY0QnCyOUpKK1Lwwzah6zv8fKqYjPXFPDEZMEGZwVWUtsRc7v
         aT4n9qRwzKtraS/gnfoooFnH0lq3jWAwUDj0rGjBIDS12YrLsVwUyjxkwng9GyV8a5f7
         3MpUtO/YJRCBXuFn56lCjj+AGFeDJhZh+km4Kdm7VKl9/B7ThmWMWSC8p72Dkx7dWrxP
         fsVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id by8si293399ejb.129.2019.07.19.05.48.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 05:48:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D75DEAF6B;
	Fri, 19 Jul 2019 12:48:24 +0000 (UTC)
Subject: Re: [v3 PATCH 1/2] mm: mempolicy: make the behavior consistent when
 MPOL_MF_MOVE* and MPOL_MF_STRICT were specified
To: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@kernel.org,
 mgorman@techsingularity.net, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-api@vger.kernel.org
References: <1563470274-52126-1-git-send-email-yang.shi@linux.alibaba.com>
 <1563470274-52126-2-git-send-email-yang.shi@linux.alibaba.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c1e2b48a-972f-3944-bc17-598cb81a6658@suse.cz>
Date: Fri, 19 Jul 2019 14:48:24 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1563470274-52126-2-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/18/19 7:17 PM, Yang Shi wrote:
> When both MPOL_MF_MOVE* and MPOL_MF_STRICT was specified, mbind() should
> try best to migrate misplaced pages, if some of the pages could not be
> migrated, then return -EIO.
> 
> There are three different sub-cases:
> 1. vma is not migratable
> 2. vma is migratable, but there are unmovable pages
> 3. vma is migratable, pages are movable, but migrate_pages() fails
> 
> If #1 happens, kernel would just abort immediately, then return -EIO,
> after the commit a7f40cfe3b7ada57af9b62fd28430eeb4a7cfcb7 ("mm:
> mempolicy: make mbind() return -EIO when MPOL_MF_STRICT is specified").
> 
> If #3 happens, kernel would set policy and migrate pages with best-effort,
> but won't rollback the migrated pages and reset the policy back.
> 
> Before that commit, they behaves in the same way.  It'd better to keep
> their behavior consistent.  But, rolling back the migrated pages and
> resetting the policy back sounds not feasible, so just make #1 behave as
> same as #3.
> 
> Userspace will know that not everything was successfully migrated (via
> -EIO), and can take whatever steps it deems necessary - attempt rollback,
> determine which exact page(s) are violating the policy, etc.
> 
> Make queue_pages_range() return 1 to indicate there are unmovable pages
> or vma is not migratable.
> 
> The #2 is not handled correctly in the current kernel, the following
> patch will fix it.
> 
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Reviewed-by: Vlastimil Babka <vbabka@suse.cz>

Some nits below (I guess Andrew can incorporate them, no need to resend)

...

> @@ -488,15 +496,15 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
>  	struct queue_pages *qp = walk->private;
>  	unsigned long flags = qp->flags;
>  	int ret;
> +	bool has_unmovable = false;
>  	pte_t *pte;
>  	spinlock_t *ptl;
>  
>  	ptl = pmd_trans_huge_lock(pmd, vma);
>  	if (ptl) {
>  		ret = queue_pages_pmd(pmd, ptl, addr, end, walk);
> -		if (ret > 0)
> -			return 0;
> -		else if (ret < 0)
> +		/* THP was split, fall through to pte walk */
> +		if (ret != 2)
>  			return ret;

The comment should better go here after the if, as that's where fall through
happens.

>  	}
>  
> @@ -519,14 +527,21 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
>  		if (!queue_pages_required(page, qp))
>  			continue;
>  		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
> -			if (!vma_migratable(vma))
> +			/* MPOL_MF_STRICT must be specified if we get here */
> +			if (!vma_migratable(vma)) {
> +				has_unmovable |= true;

'|=' is weird, just use '='

>  				break;
> +			}
>  			migrate_page_add(page, qp->pagelist, flags);
>  		} else
>  			break;
>  	}
>  	pte_unmap_unlock(pte - 1, ptl);
>  	cond_resched();
> +
> +	if (has_unmovable)
> +		return 1;
> +
>  	return addr != end ? -EIO : 0;
>  }
>  
...
> @@ -1259,11 +1286,12 @@ static long do_mbind(unsigned long start, unsigned long len,
>  				putback_movable_pages(&pagelist);
>  		}
>  
> -		if (nr_failed && (flags & MPOL_MF_STRICT))
> +		if ((ret > 0) || (nr_failed && (flags & MPOL_MF_STRICT)))
>  			err = -EIO;
>  	} else
>  		putback_movable_pages(&pagelist);
>  
> +up_out:
>  	up_write(&mm->mmap_sem);
>   mpol_out:

The new label made the wrong identation of this one stand out, so I'd just fix
it up while here.

Thanks!

>  	mpol_put(new);
> 

