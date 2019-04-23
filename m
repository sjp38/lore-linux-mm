Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6390C282E1
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 06:50:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 983AC20643
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 06:50:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 983AC20643
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 345446B0003; Tue, 23 Apr 2019 02:50:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2CA3C6B0006; Tue, 23 Apr 2019 02:50:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16BD66B0007; Tue, 23 Apr 2019 02:50:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B6AA46B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 02:50:26 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n25so7456847edd.5
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 23:50:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=jD+8DUCoVQgBWAtwdgeeix+moiolWyT23gO9EZ6PCyM=;
        b=TFfer7zT2vpsando+qdyGG+4GeW2ShqkPz+QuAE/BZdE3Y4+E+kPKjus3WAGIxGqsX
         IYBQJsrntfVkSnFkcnZ0iSRPjtexGCnoMmjp7vmUbU1sYL8pwW1FNm49xeINkUyt5fSj
         HqcPI3wExOKm/e9vcSCYIuz39araWvS9GNPofnMkIx0ZtSdNizdOJjMxjl4jOXXbvn8w
         nPEmX3XsaC1PLQIQDrngPNWbb2ENGzXpv/905ulrvE/o2hoQdXzRnLR0dRkrAsS0CQOR
         t1dzu5TCTuVKatxkH/v45WnY731xgLf5SETTdDxdR90HHG5FQsecB9Nw6cEWDu1yLNut
         yDvA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWKJHDeq3+atafMybSq1IqEebi6O0Phogk6IUf7r0fgtntyYRO1
	NvCEGyj1InNxneLUlmJVDkhqak8baCGsONWyjLD0tN0CvaHPOZ9nPWi+8e+/DiWd+PTi1IVXdNV
	WS9B54bFBrvjP9chtIcM3smTlGPMqTR8eshGljvWQh3+L7ZQF8lS0XTMlc2gaqfQ=
X-Received: by 2002:a50:f78b:: with SMTP id h11mr10692553edn.143.1556002226280;
        Mon, 22 Apr 2019 23:50:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9w/twmF6lCwkCdYZx9lUQq4rSBmjRl20dYJl2oZJBWqSF4vsbRrIcoryO0yZYBCFLZ6fO
X-Received: by 2002:a50:f78b:: with SMTP id h11mr10692515edn.143.1556002225448;
        Mon, 22 Apr 2019 23:50:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556002225; cv=none;
        d=google.com; s=arc-20160816;
        b=uojll+jVWkQKlfC71Fd7H6Z5r2Ce4ovzt4ck5FNe4ey85XSFwRdtanQ64w4hORlVJx
         LJnJFlDpVFy2KnrOGXD7ZvEZkLGbKelOektKYvTzg3VNxzmXV4HacLOb9WY51SZzqjns
         kgE6sR/L9no9A4oPqJCmDiaNJfm1Uwmz7CGVaTm/5lXKWceJQILAZhiZIkrluTiICPX+
         xrtYNutQuv4J9Fsm5cjrjTKn+TBfsRkYI/DIzDXotuQeclojZaWYLluWYzOO+Kp7nDvr
         BHLQq3HVoU1SNKGiPdvnTCUBM7ckTXXbbZZ5DQVpW7J1YKSCubWYznEbkVcJhu6QcK/N
         N/WQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=jD+8DUCoVQgBWAtwdgeeix+moiolWyT23gO9EZ6PCyM=;
        b=vAoEhflVL6/cGjwMSVuN/SVzbqW4Hzw/LfTnXARQINpRpHiN7eUWK6Dk+QD9FKzjSE
         8RFXg+hwu/A3CBWPVfEHua8qhAdDEVndZJJnno3aphHN8DMXhMxaYmV8fMZwrNeEN5r6
         guoy6liYQFzVtxJRgkxqU1Blh+OdZQkOzHTVbUcEEKSXQEBzKGCIWIZHxEIUu4fPA+Ea
         w1VdvRYF6GIu1pG9S8ipzp3cZYnB8mm1gciz2OCgPXFLOqJXHu4rcsTboWUTJt+jvcQE
         px6ZsOfupmWvMc6Sg7cGJDslp+/19R24VmozA6PT/szwkCZK84txnR2SMsau+XmBMQRp
         B3gQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j2si2313283ejn.201.2019.04.22.23.50.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 23:50:25 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8BB55AE32;
	Tue, 23 Apr 2019 06:50:24 +0000 (UTC)
Date: Tue, 23 Apr 2019 08:50:23 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: vbabka@suse.cz, rientjes@google.com, kirill@shutemov.name,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: thp: fix false negative of shmem vma's THP
 eligibility
Message-ID: <20190423065023.GA25106@dhcp22.suse.cz>
References: <1555971893-52276-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1555971893-52276-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 23-04-19 06:24:53, Yang Shi wrote:
> The commit 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each
> vma") introduced THPeligible bit for processes' smaps. But, when checking
> the eligibility for shmem vma, __transparent_hugepage_enabled() is
> called to override the result from shmem_huge_enabled().  It may result
> in the anonymous vma's THP flag override shmem's.

Hmm, I was under impression that thw global sysfs is not anonymous
memory specific and it overrides whatever sysfs comes with. Isn't
ignoring the global setting a bug in the shmemfs allocation paths?
Kirill what is the actual semantic here?

> For example, running a
> simple test which create THP for shmem, but with anonymous THP disabled,
> when reading the process's smaps, it may show:
> 
> 7fc92ec00000-7fc92f000000 rw-s 00000000 00:14 27764 /dev/shm/test
> Size:               4096 kB
> ...
> [snip]
> ...
> ShmemPmdMapped:     4096 kB
> ...
> [snip]
> ...
> THPeligible:    0
> 
> And, /proc/meminfo does show THP allocated and PMD mapped too:
> 
> ShmemHugePages:     4096 kB
> ShmemPmdMapped:     4096 kB
> 
> This doesn't make too much sense.  The anonymous THP flag should not
> intervene shmem THP.  Calling shmem_huge_enabled() with checking
> MMF_DISABLE_THP sounds good enough.  And, we could skip stack and
> dax vma check since we already checked if the vma is shmem already.

Even if I am wrong about the /sys/kernel/mm/transparent_hugepage/enabled
being the global setting for _all_ THP then this patch is not sufficient
because it doesn't reflect VM_NOHUGEPAGE.
> 
> Fixes: 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each vma")
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  mm/huge_memory.c | 4 ++--
>  mm/shmem.c       | 2 ++
>  2 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 165ea46..5881e82 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -67,8 +67,8 @@ bool transparent_hugepage_enabled(struct vm_area_struct *vma)
>  {
>  	if (vma_is_anonymous(vma))
>  		return __transparent_hugepage_enabled(vma);
> -	if (vma_is_shmem(vma) && shmem_huge_enabled(vma))
> -		return __transparent_hugepage_enabled(vma);
> +	if (vma_is_shmem(vma))
> +		return shmem_huge_enabled(vma);
>  
>  	return false;
>  }
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 2275a0f..be15e9b 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -3873,6 +3873,8 @@ bool shmem_huge_enabled(struct vm_area_struct *vma)
>  	loff_t i_size;
>  	pgoff_t off;
>  
> +	if (test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
> +		return false;
>  	if (shmem_huge == SHMEM_HUGE_FORCE)
>  		return true;
>  	if (shmem_huge == SHMEM_HUGE_DENY)
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

