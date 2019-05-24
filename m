Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05544C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 04:16:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99ECE217D7
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 04:16:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99ECE217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1192E6B0005; Fri, 24 May 2019 00:16:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D21D6B0006; Fri, 24 May 2019 00:16:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAC4B6B0007; Fri, 24 May 2019 00:15:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id AAB056B0005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 00:15:59 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d22so5426867pgg.2
        for <linux-mm@kvack.org>; Thu, 23 May 2019 21:15:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=q8/J8T9UxuNqfgGjepBgeEz0VlZPk/PEqF8wi//EvHU=;
        b=gS4c985qSu2q7ggPiwq5O3Qba1aU0vpaU/247sZvVAL1vG/vzIs4kvlh8ljvHiMgMz
         BJMMwe1JcdKNn4NF9L4acHbvL6GB6VAzlSARtgOIr6DNlbVtob94Oa/WonwzOmi5HjbG
         hF48HGvEA0rvlz5BJsweQLbEBaa5NBec001Ae1DHu/C7/pZueRNImxQorpZOCBW6QCTx
         fKvu0sI0PAaNd48Q+1FwExGxRiRdZavSE8uk3xiMoAr9LMuzt5Qpmet5EduVha7cnvn9
         Ee+ILZvryMnK8M+ex+RGu/Bz25gGu843pZBCpEs3HDSFf9ewDPkUONu8CYiBA4G8jN1T
         zM+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.212 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAXtufTpgNjb3X7DAY8/opGt1N+1r00dbzjfgHzjNxO04qLRh4dx
	tX0JZlJsW/7bQGC3NOX1JBiO9USJz9Z6LoMuihW3OBM+2LJ7nS/NaB9y6WSy+TTa6Z0z5spBdd0
	v0zCDutkT/E0+62LrDNEWilxtxDVTnMS7Qd/7z9lsWej2Jbof7EIC19HK1vAKLPRBfA==
X-Received: by 2002:a63:6f06:: with SMTP id k6mr101311974pgc.170.1558671359235;
        Thu, 23 May 2019 21:15:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy16e3/9aydqAvBrfje9Lh7n1i5+GccgEq1nREnDKLdW8BJF1aYpPNsrk1Cfl6dkmhri7ew
X-Received: by 2002:a63:6f06:: with SMTP id k6mr101311936pgc.170.1558671358285;
        Thu, 23 May 2019 21:15:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558671358; cv=none;
        d=google.com; s=arc-20160816;
        b=d1lDOGjsrlwyf7WdU3uMLuo40S39dwLZ7X4Fly7WebWc8DE0Bt5s/HwoUs/QCdGhB9
         FCGpPII+YdLUI8jRyBYZYLPmaU0ZJFa5ZizSpmq73jkJfXBGgIIIjELkyUW6iEUDx2qU
         f3qPuF4S8QUqp5pIGnQS5vP+xLXarr+3SF3Gvu2GFJhrvCWjL2YJiMKDxfUKJTE73+g8
         h7Ris5MwQd4IAUH9ot7Au6t3KWVKwfLU4X1OT/JPnDg4f9vLbnc12W28FaVphV7x6Ubk
         jCVFhRq/us5iQJR5qungkr0K94ZsWEmaMiMm1NLBuzEwPJ+uTmJA8UwXeB5t6ibuAxWp
         Jh1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=q8/J8T9UxuNqfgGjepBgeEz0VlZPk/PEqF8wi//EvHU=;
        b=khjaU1mRSAFDDVC2Ep3h47EnxDFXMItGUAUEaHfqcwHxAlng/dIvIIV5CCYtL11ttt
         CG3GwImBEyHB4zaK573tSSejRL5T5cQ3DGsXadqKE/fztuA8nz8d+L2w1lSBOSngcbfI
         j84BIR18Vp0PfGvLUgQWKK3gam/VNFNlYJCrBa73Iy473poao1bc8vm7fdphDIeAVr9g
         OpCMbSS3CqL8trHH/4btO58w6G+yAxkJbMTJ0rtWOLFFjpByu+qeksIOq2ZzrRz+AW7Q
         Se2s18KxWluffPXQKAa0UZvsfZ30NuupMJXlSvTKzDIU3EeA93TW5DUA1jUGnlx/4/7d
         c03Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.212 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail7-212.sinamail.sina.com.cn (mail7-212.sinamail.sina.com.cn. [202.108.7.212])
        by mx.google.com with SMTP id o45si2228006pje.42.2019.05.23.21.15.57
        for <linux-mm@kvack.org>;
        Thu, 23 May 2019 21:15:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.7.212 as permitted sender) client-ip=202.108.7.212;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.212 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([114.253.229.186])
	by sina.com with ESMTP
	id 5CE76FF900003828; Fri, 24 May 2019 12:15:56 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 238489394089
From: Hillf Danton <hdanton@sina.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: ying.huang@intel.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	mgorman@techsingularity.net,
	kirill.shutemov@linux.intel.com,
	josef@toxicpanda.com,
	hughd@google.com,
	shakeelb@google.com,
	akpm@linux-foundation.org,
	hdanton@sina.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v4 PATCH 1/2] mm: vmscan: remove double slab pressure by inc'ing sc->nr_scanned
Date: Fri, 24 May 2019 12:15:45 +0800
Message-Id: <20190524041545.10820-1-hdanton@sina.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 23 May 2019 10:27:37 +0800 Yang Shi wrote:
> The commit 9092c71bb724 ("mm: use sc->priority for slab shrink targets")
> has broken up the relationship between sc->nr_scanned and slab pressure.
> The sc->nr_scanned can't double slab pressure anymore.  So, it sounds no
> sense to still keep sc->nr_scanned inc'ed.  Actually, it would prevent
> from adding pressure on slab shrink since excessive sc->nr_scanned would
> prevent from scan->priority raise.
> 
The deleted code below wants to get more slab pages shrinked, and it can do
that without raising scan priority first even after commit 9092c71bb724. Or
we may face the risk that priority goes up too much faster than thought, per
the following snippet.

		/*
		 * If we're getting trouble reclaiming, start doing
		 * writepage even in laptop mode.
		 */
		if (sc->priority < DEF_PRIORITY - 2)

> The bonnie test doesn't show this would change the behavior of
> slab shrinkers.
> 
> 				w/		w/o
> 			  /sec    %CP      /sec      %CP
> Sequential delete: 	3960.6    94.6    3997.6     96.2
> Random delete: 		2518      63.8    2561.6     64.6
> 
> The slight increase of "/sec" without the patch would be caused by the
> slight increase of CPU usage.
> 
> Cc: Josef Bacik <josef@toxicpanda.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
> v4: Added Johannes's ack
> 
>  mm/vmscan.c | 5 -----
>  1 file changed, 5 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 7acd0af..b65bc50 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1137,11 +1137,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		if (!sc->may_unmap && page_mapped(page))
>  			goto keep_locked;
>  
> -		/* Double the slab pressure for mapped and swapcache pages */
> -		if ((page_mapped(page) || PageSwapCache(page)) &&
> -		    !(PageAnon(page) && !PageSwapBacked(page)))
> -			sc->nr_scanned++;
> -
>  		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
>  			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
>  
> -- 
> 1.8.3.1
> 
Best Regards
Hillf

