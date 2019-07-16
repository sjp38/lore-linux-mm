Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8EBEC76188
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 08:12:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56BC921738
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 08:12:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56BC921738
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D78FD6B0003; Tue, 16 Jul 2019 04:12:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D02F76B0005; Tue, 16 Jul 2019 04:12:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7D558E0001; Tue, 16 Jul 2019 04:12:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5D7386B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 04:12:03 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c31so15552287ede.5
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 01:12:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=c4IFaZyI/hBUkmiVw1PiAlaqx6i2QJB2+F7YyrvDTDA=;
        b=H+tQRTyggbXXIL8kzC8c980+5ejC7/A1PrPUq3C/F6SwUyMZ7LRcbc+/eywEYuaFm8
         UXSEqtk6KN8iX/kRjqjYVX3dNhh0HOX4W2/dTV9shteZamlfwf6fXX5e3VJ+CLZ2cFrr
         6CdRNaYN7ZZKNcqdzCiilDVH2Ootj1CxqUadSKPKxWG+zS1QXj12h/NwU5MGKcZuyWps
         Txo0NGGF3lqbwiWe/WwTPn/LGdrZJS2p90PhKQIcYsM72AhFgZcyaf/F/UpqHCIaKS9P
         zqASaeHgNiqC6zdZ96dgXCzV/5K/ZY6DvqaQ63Bu3AQYRISCnMMoij14uMR+spOZ/lkw
         hs8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAW0IlurTanY1E4fb716/pFsKRqbTcRWeKGV9mbIaBXtlkkxVEq3
	xEAlCjInvu12rBrd6q7DCCFUQv+nLM0ivjLmMHmMbwf/oZfDtdiISizxCRNDouAUGquv43ZlyeJ
	XPzXMRd2DAzGiaW/DRczOWHOB/ewABpej6shk/qFrFaKvB4NxZKTNTlrV5TTiYFa4jA==
X-Received: by 2002:a50:ba57:: with SMTP id 23mr28479768eds.196.1563264722874;
        Tue, 16 Jul 2019 01:12:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3Xj3cxZn5PO0fjYuvKiPtc6ZFf5PDkpa15ZTu6ftAjKijnv/YAQ2gfejN3u/EaVAsbSr1
X-Received: by 2002:a50:ba57:: with SMTP id 23mr28479705eds.196.1563264721814;
        Tue, 16 Jul 2019 01:12:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563264721; cv=none;
        d=google.com; s=arc-20160816;
        b=jV/VIU3Tc90NYcGEA+PPD1sWG+8LsJfNUjpDypHGyxNTzMMncmaEsWoDrF89PruHxX
         60JjYus8yJFR0/ohbf6VuA8QhI582aI7Ywvf7x29SG1QLamWYJHsr1Ds7RRcX2/G/DWs
         A3q7EmzM7RScC8hAunWc70nQLYPH6KFDPT2zCg3YlVKlCpBc+XUX4ws5nz5w762K9Gni
         NsuZSkJ5zDT+Tj93liWySs+QMYykX6lNoNh4Ke5L/a4fXGxIcHtlKVNDDkooXI5KNNA3
         LGZJoqDfL8hOMopNTMPyGaoIn9aYvTtFOZ5Mti+VaXIIegJYIjILX0oeeTqSzyY+WHCo
         Gzlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=c4IFaZyI/hBUkmiVw1PiAlaqx6i2QJB2+F7YyrvDTDA=;
        b=Bm+ku1XQBv1/KToQKaTCDaR2lBgTzydWSCb9onD+bDEUsPqZbWMjzElnvaMDecdADj
         WBAZ2FUnxlp6j/zDOW44vRqEvnYB+9hAasK9VDmQT6nIsMGKYJ7C77W/zXSw5174MFtp
         2kROGLfpXfpji8eko5thyTYBZDs6D6oDlVjLpBBVg8c8Wbz4okhbmO1MB7lKCtgbpip3
         MI3d2Z54wfy41UrfR+OwwZzoLZvJ2LurwynlxmnDHeQ3cvY2iFdxr3mtjSbzmZ/kth+p
         MivP7U1H2SLwT88yxODF+v3cqrLr/5E0KtEt3nd7A+KQg9Ml7OcjTO8O3+VjevBSpt6z
         XJiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l22si10219017ejb.1.2019.07.16.01.12.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 01:12:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A333CABED;
	Tue, 16 Jul 2019 08:12:00 +0000 (UTC)
Subject: Re: [v2 PATCH 1/2] mm: mempolicy: make the behavior consistent when
 MPOL_MF_MOVE* and MPOL_MF_STRICT were specified
To: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@kernel.org,
 mgorman@techsingularity.net, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1561162809-59140-1-git-send-email-yang.shi@linux.alibaba.com>
 <1561162809-59140-2-git-send-email-yang.shi@linux.alibaba.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <fb74d657-90cd-6667-f253-162c951f1b05@suse.cz>
Date: Tue, 16 Jul 2019 10:12:00 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <1561162809-59140-2-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/22/19 2:20 AM, Yang Shi wrote:
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

Agreed with the goal, but I think there's a bug, and room for improvement.

> ---
>  mm/mempolicy.c | 86 +++++++++++++++++++++++++++++++++++++++++-----------------
>  1 file changed, 61 insertions(+), 25 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 01600d8..b50039c 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -429,11 +429,14 @@ static inline bool queue_pages_required(struct page *page,
>  }
>  
>  /*
> - * queue_pages_pmd() has three possible return values:
> + * queue_pages_pmd() has four possible return values:
> + * 2 - there is unmovable page, and MPOL_MF_MOVE* & MPOL_MF_STRICT were
> + *     specified.
>   * 1 - pages are placed on the right node or queued successfully.
>   * 0 - THP was split.

I think if you renumbered these, it would be more consistent with
queue_pages_pte_range() and simplify the code there.
0 - pages on right node/queued
1 - unmovable page with right flags specified
2 - THP split

> - * -EIO - is migration entry or MPOL_MF_STRICT was specified and an existing
> - *        page was already on a node that does not follow the policy.
> + * -EIO - is migration entry or only MPOL_MF_STRICT was specified and an
> + *        existing page was already on a node that does not follow the
> + *        policy.
>   */
>  static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
>  				unsigned long end, struct mm_walk *walk)
> @@ -463,7 +466,7 @@ static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
>  	/* go to thp migration */
>  	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
>  		if (!vma_migratable(walk->vma)) {
> -			ret = -EIO;
> +			ret = 2;
>  			goto unlock;
>  		}
>  
> @@ -488,16 +491,29 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,

Perhaps this function now also deserves a list of possible return values.

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
> +		switch (ret) {

With renumbering suggested above, this could be:
if (ret != 2)
    return ret;

> +		/* THP was split, fall through to pte walk */
> +		case 0:
> +			break;
> +		/* Pages are placed on the right node or queued successfully */
> +		case 1:
>  			return 0;
> -		else if (ret < 0)
> +		/*
> +		 * Met unmovable pages, MPOL_MF_MOVE* & MPOL_MF_STRICT
> +		 * were specified.
> +		 */
> +		case 2:
> +			return 1;
> +		case -EIO:
>  			return ret;
> +		}
>  	}
>  
>  	if (pmd_trans_unstable(pmd))
> @@ -519,14 +535,21 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
>  		if (!queue_pages_required(page, qp))
>  			continue;
>  		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
> -			if (!vma_migratable(vma))
> +			/* MPOL_MF_STRICT must be specified if we get here */
> +			if (!vma_migratable(vma)) {
> +				has_unmovable |= true;
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
> @@ -639,7 +662,13 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
>   *
>   * If pages found in a given range are on a set of nodes (determined by
>   * @nodes and @flags,) it's isolated and queued to the pagelist which is
> - * passed via @private.)
> + * passed via @private.
> + *
> + * queue_pages_range() has three possible return values:
> + * 1 - there is unmovable page, but MPOL_MF_MOVE* & MPOL_MF_STRICT were
> + *     specified.
> + * 0 - queue pages successfully or no misplaced page.
> + * -EIO - there is misplaced page and only MPOL_MF_STRICT was specified.
>   */
>  static int
>  queue_pages_range(struct mm_struct *mm, unsigned long start, unsigned long end,
> @@ -1182,6 +1211,7 @@ static long do_mbind(unsigned long start, unsigned long len,
>  	struct mempolicy *new;
>  	unsigned long end;
>  	int err;
> +	int ret;
>  	LIST_HEAD(pagelist);
>  
>  	if (flags & ~(unsigned long)MPOL_MF_VALID)
> @@ -1243,26 +1273,32 @@ static long do_mbind(unsigned long start, unsigned long len,
>  	if (err)
>  		goto mpol_out;
>  
> -	err = queue_pages_range(mm, start, end, nmask,
> +	ret = queue_pages_range(mm, start, end, nmask,
>  			  flags | MPOL_MF_INVERT, &pagelist);
> -	if (!err)
> -		err = mbind_range(mm, start, end, new);
> -
> -	if (!err) {
> -		int nr_failed = 0;
>  
> -		if (!list_empty(&pagelist)) {
> -			WARN_ON_ONCE(flags & MPOL_MF_LAZY);
> -			nr_failed = migrate_pages(&pagelist, new_page, NULL,
> -				start, MIGRATE_SYNC, MR_MEMPOLICY_MBIND);
> -			if (nr_failed)
> -				putback_movable_pages(&pagelist);
> -		}
> +	if (ret < 0)
> +		err = -EIO;

I think after your patch, you miss putback_movable_pages() in cases
where some were queued, and later the walk returned -EIO. The previous
code doesn't miss it, but it's also not obvious due to the multiple if
(!err) checks. I would rewrite it some thing like this:

if (ret < 0) {
    putback_movable_pages(&pagelist);
    err = ret;
    goto mmap_out; // a new label above up_write()
}

The rest can have reduced identation now.

> +	else {
> +		err = mbind_range(mm, start, end, new);
>  
> -		if (nr_failed && (flags & MPOL_MF_STRICT))
> -			err = -EIO;
> -	} else
> -		putback_movable_pages(&pagelist);
> +		if (!err) {
> +			int nr_failed = 0;
> +
> +			if (!list_empty(&pagelist)) {
> +				WARN_ON_ONCE(flags & MPOL_MF_LAZY);
> +				nr_failed = migrate_pages(&pagelist, new_page,
> +					NULL, start, MIGRATE_SYNC,
> +					MR_MEMPOLICY_MBIND);
> +				if (nr_failed)
> +					putback_movable_pages(&pagelist);
> +			}
> +
> +			if ((ret > 0) ||
> +			    (nr_failed && (flags & MPOL_MF_STRICT)))
> +				err = -EIO;
> +		} else
> +			putback_movable_pages(&pagelist);

While at it, IIRC the kernel style says that when the 'if' part uses
'{ }' then the 'else' part should as well, and it shouldn't be mixed.

Thanks,
Vlastimil

> +	}
>  
>  	up_write(&mm->mmap_sem);
>   mpol_out:
> 

