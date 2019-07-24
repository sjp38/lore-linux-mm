Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAC9DC7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:17:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98E5122ADC
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:17:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98E5122ADC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EA5A8E0008; Wed, 24 Jul 2019 10:17:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2998D8E0002; Wed, 24 Jul 2019 10:17:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 188C08E0008; Wed, 24 Jul 2019 10:17:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB8B78E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:17:13 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i44so30330441eda.3
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 07:17:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=P5o1IqIxqWWtMTOcSxGbhWfaa/TZisJGkD/0B3L1s9Q=;
        b=nhmsz+cutZ9zzKZt/ym1HXcS31VhxKJftSUMMIivhr9sH1BVJMHr/XrqxFiYxq8tkV
         34N7fCTM5GkpcCfijnnlT7AJ6KsLmaDtaqrmiZX9xKFAHhxnHdUffdOyEdbEOLAdNzK0
         rvDa3UxrQTA3LCDijLZszrEc1fbjHMKUIBcLxlFbSFFlnnTL/y3y4uclrtl51TXPI4Rg
         6yMz5n4UYDv4/kcxflekor5fYrKqDdbYQ8hWnjEIih9lVcTPVnmLmdFQ7KLxGCCctpPs
         NMPzk4PGklaWhknZIe2fyouvNPltCXw/uDynuic34+p33YmNiMw4H5yTNz9tccZnc2u1
         IsKA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWBXmvx3RK9qitjPSP7FGdw7Lkm/qhl8o25jCyowByCn8h1od1O
	84m+1Fi5Wuai/tHx2k9Ymf93ZhJrO5PPiMJoiJUU17KeZ9pRxY/tppGGmlfdYPTcBnxom0Q+Vqw
	gu44H7Yi97v2kPUtxxmMc0jiQRL1lzq5hIufQqKHFkbTimQBnVp2SbNPauOX4Zgg=
X-Received: by 2002:a17:906:1dcb:: with SMTP id v11mr63249704ejh.218.1563977833103;
        Wed, 24 Jul 2019 07:17:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyJu2rVK8bNeFs7hhxzH7TWjzHFZMrBFkkUa8WrxXyAzu8dgfPfxFEi5eABr+NNzusYCvuR
X-Received: by 2002:a17:906:1dcb:: with SMTP id v11mr63249625ejh.218.1563977832160;
        Wed, 24 Jul 2019 07:17:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563977832; cv=none;
        d=google.com; s=arc-20160816;
        b=dL0cfptZ2Jf6MvmtLEN/8HUNBHdDHtbkvctO5Wdu2N8OutmHw14H/VfnvjM1xAGncF
         eGOQLWfl6KC7UsQJLpAQmvrFjY6lhnoDRVPq5Ie7MT0qsPi7n6GPgS2fvA1ofqq6gc5P
         vPsyRTnQL9QQyRk6r6XyN/bbHflOU7B1pD2wgpynpx9Wf1vAFgm9SicZpJ9iAwKx5bYm
         mxHhhjxK8/LMZv7pqRU9QWYXbcF9sefBYqeWxKoJRzqoDxJcE0ruox5hBM4ltbvNjzX+
         WCb6CL/ex0GCHz9EtiS0IceUS/ocMKfkOhcVvw0OlA+ztk+vK9UGfp5P3YwfUSCWosKF
         yOvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=P5o1IqIxqWWtMTOcSxGbhWfaa/TZisJGkD/0B3L1s9Q=;
        b=XwDJUMwQY93d8BdtQnfChrktyJB7z8MITjGNaftfiqmNEGZaBDDjmEfUSf5oYz7fKj
         q1Ip3QVHSOBDpMXm2js9b4O6SOau833eW43T6Ef6uiQby0MYRg/hZJkAN1lbZXCIJUMD
         VKfoYseelh+wQg3GR+UW3oKOp+Njie+cqvxgT7mwHGiRqPP5dJPJ2SHMQ8/SoLfBlk/V
         5yl2+EeoFpQ7X90+XwP4V8WHrwfD5lw1dvfsQZZkvRm7kMqZaHMUXgaIlfJKRJKsG7YD
         aYIQarw8PlVGFvG1YWFAZDkslFoHU+vdejqhnxsY6tpSbZTobQS3e+0pX5mIgvb9VClM
         juEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j1si8809039eda.171.2019.07.24.07.17.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 07:17:12 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 42C0BAFD4;
	Wed, 24 Jul 2019 14:17:11 +0000 (UTC)
Date: Wed, 24 Jul 2019 16:17:10 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: YueHaibing <yuehaibing@huawei.com>, akpm@linux-foundation.org,
	kirill.shutemov@linux.intel.com, vbabka@suse.cz,
	yang.shi@linux.alibaba.com, jannh@google.com, walken@google.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH] mm/mmap.c: silence variable 'new_start' set but not used
Message-ID: <20190724141710.GD5584@dhcp22.suse.cz>
References: <20190724140739.59532-1-yuehaibing@huawei.com>
 <1563977465.11067.9.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1563977465.11067.9.camel@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 24-07-19 10:11:05, Qian Cai wrote:
> On Wed, 2019-07-24 at 22:07 +0800, YueHaibing wrote:
> > 'new_start' is used in is_hugepage_only_range(),
> > which do nothing in some arch. gcc will warning:
> > 
> > mm/mmap.c: In function acct_stack_growth:
> > mm/mmap.c:2311:16: warning: variable new_start set but not used [-Wunused-but-
> > set-variable]
> 
> Nope. Convert them to inline instead.

Agreed. Obfuscating the code is not really something we want.

> > Reported-by: Hulk Robot <hulkci@huawei.com>
> > Signed-off-by: YueHaibing <yuehaibing@huawei.com>
> > ---
> >  mm/mmap.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/mmap.c b/mm/mmap.c
> > index e2dbed3..56c2a92 100644
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -2308,7 +2308,7 @@ static int acct_stack_growth(struct vm_area_struct *vma,
> >  			     unsigned long size, unsigned long grow)
> >  {
> >  	struct mm_struct *mm = vma->vm_mm;
> > -	unsigned long new_start;
> > +	unsigned long __maybe_unused new_start;
> >  
> >  	/* address space limit tests */
> >  	if (!may_expand_vm(mm, vma->vm_flags, grow))

-- 
Michal Hocko
SUSE Labs

