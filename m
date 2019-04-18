Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCE9BC10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 14:15:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9839220675
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 14:15:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9839220675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 644D46B0005; Thu, 18 Apr 2019 10:15:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F1EB6B0007; Thu, 18 Apr 2019 10:15:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E13F6B000C; Thu, 18 Apr 2019 10:15:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 00A9A6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 10:15:10 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f7so1331544edi.3
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 07:15:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=qbUqGLSVDkxfqCdCwcVWFnMgG8JKZytKZPFSCBedmGQ=;
        b=XKsekOWiEX2QRqhcHJXSRdmu5/aGPDinVJ5g+G5vgWRpI3m3W3XtqZSGrYXt9+J3w6
         LZ8gx1UmyUqWiqZfgJgpHEh+ukw0b/4nR734WQwNO0c8bmEMPFIzn/GXhjtxUB6YS0UV
         JVn0rHNNehi8OSMVOPWVsm0dSBdxCb657RHjKSZPZcXV1lmk8Q7uxn5oj8igpZoQTteH
         ksX0GvHy3rzGs/dWP3u9929ePLekmW4tCl7r0cxUJFfOXwTcYEjN0fjw5bUSt7rA0SvA
         MtRiwiv920Qk/Iobh8ypVRG2U0CVFJH8uzxYFMq250dxCSBcurSq61cDPKe9z/o6ktLZ
         czFQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWkF+P3KmBLybi3LJJXLh15GK3AmCzqKA1lIm7xNu5GL4Kp02IB
	df4M8IVplCnvs3EHuuOQKsgGhKCsxXCfc2rGSuorDQrejgvP3XVsdGa1nb/aqNYvuSc+M7Z2CXP
	CImEbHnQCliRBxqQ9bi+ItByldAw1HwRaVYnjsX3WKmkblu9VtjpGWWhhqqWXeI0=
X-Received: by 2002:a17:906:2e52:: with SMTP id r18mr51276725eji.84.1555596910537;
        Thu, 18 Apr 2019 07:15:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxtnsAVcrFKR3mKPDgZx3w73NprYPuR1aPxD57FlBiLO3oHbzvdJw+PzOokv0hwHou2NOde
X-Received: by 2002:a17:906:2e52:: with SMTP id r18mr51276681eji.84.1555596909598;
        Thu, 18 Apr 2019 07:15:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555596909; cv=none;
        d=google.com; s=arc-20160816;
        b=p4y+0czy046A+xUnSUigSjpVRHfFwK2gYnTAdV+y5lkP922Zow920JbMaImydh6tbf
         RQuKULdn/AYBKhvj3bluepQDvz3+nOhhJpdmzBnpIbceDmtZgkUgGhsAXgbW/wWJzf1U
         ukNzUm2Xxt44bXUzRhu8gUxqRttNQ4jgfKbDN6lZb+8lPD3GblM3gfh+odc/HPl6fgMr
         GIg7pUsuGINTtLFnpc173zRfSVnZi6UTgd68tgWahkvh9mT1dtqsMRxK6SW0KgVYTWkr
         /nF1x+LrbPWXsHC4O9pg7jzUQQc4wlXBwTz0XqA/nw0JHVbLmcrHb68tkDajxRAc/+Y5
         tGfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=qbUqGLSVDkxfqCdCwcVWFnMgG8JKZytKZPFSCBedmGQ=;
        b=BNqBqFdRDz+2jgsMIyrgG/XF6Y67QNKDPh6fdftEhZacmbFUFJPVQhg58typeQ2fJ+
         j+VZpsYFWiFmKEiES5ZKorZJZQYRTjcdGR7JQ/sl4BW//E5xf2fP2wsNW5Y2bpoHIy8l
         KNkiQJIsVep8rSRdNfD/KKRJCRRp7frZ+5uD6rJn8VHyKTzahE8bRE9xFMGzg8cHlhf5
         2E4xvFOwKrtZnniZiSI7Zz3FbLNbB261/Az7pG82eTr4dvdFxkkJwqi4aw1GkJKToXjB
         q3ysah7N7gvm2KPJmfb7dhb5GpS6q26trZlAWZ2Vj6r3lhOcWTQJ4bKwe0OXSs83IBwp
         PY0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j22si1008845ejm.289.2019.04.18.07.15.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 07:15:09 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D8DD0B16E;
	Thu, 18 Apr 2019 14:15:08 +0000 (UTC)
Date: Thu, 18 Apr 2019 16:15:07 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, akpm@linux-foundation.org,
	arunks@codeaurora.org, brgl@bgdev.pl, geert+renesas@glider.be,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, mguzik@redhat.com,
	rppt@linux.ibm.com, vbabka@suse.cz,
	Laurent Dufour <ldufour@linux.ibm.com>
Subject: Re: [PATCH] prctl_set_mm: downgrade mmap_sem to read lock
Message-ID: <20190418141507.GO6567@dhcp22.suse.cz>
References: <20190417145548.GN5878@dhcp22.suse.cz>
 <20190418135039.19987-1-mkoutny@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190418135039.19987-1-mkoutny@suse.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 18-04-19 15:50:39, Michal Koutny wrote:
> I learnt, it's, alas, too late to drop the non PRCTL_SET_MM_MAP calls
> [1], so at least downgrade the write acquisition of mmap_sem as in the
> patch below (that should be stacked on the previous one or squashed).
> 
> Cyrill, you mentioned lock changes in [1] but the link seems empty. Is
> it supposed to be [2]? That could be an alternative to this patch after
> some refreshments and clarifications.
> 
> 
> [1] https://lore.kernel.org/lkml/20190417165632.GC3040@uranus.lan/
> [2] https://lore.kernel.org/lkml/20180507075606.870903028@gmail.com/
> 
> ========
> 
> Since commit 88aa7cc688d4 ("mm: introduce arg_lock to protect
> arg_start|end and env_start|end in mm_struct") we use arg_lock for
> boundaries modifications. Synchronize prctl_set_mm with this lock and
> keep mmap_sem for reading only (analogous to what we already do in
> prctl_set_mm_map).
> 
> Also, save few cycles by looking up VMA only after performing basic
> arguments validation.
> 
> Signed-off-by: Michal Koutný <mkoutny@suse.com>

Looks good to me. Please send both patches in one series once you get a
review feedback from other people.

> ---
>  kernel/sys.c | 12 +++++++++---
>  1 file changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/kernel/sys.c b/kernel/sys.c
> index 12df0e5434b8..bbce0f26d707 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -2125,8 +2125,12 @@ static int prctl_set_mm(int opt, unsigned long addr,
>  
>  	error = -EINVAL;
>  
> -	down_write(&mm->mmap_sem);
> -	vma = find_vma(mm, addr);
> +	/*
> +	 * arg_lock protects concurent updates of arg boundaries, we need mmap_sem for
> +	 * a) concurrent sys_brk, b) finding VMA for addr validation.
> +	 */
> +	down_read(&mm->mmap_sem);
> +	spin_lock(&mm->arg_lock);
>  
>  	prctl_map.start_code	= mm->start_code;
>  	prctl_map.end_code	= mm->end_code;
> @@ -2185,6 +2189,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
>  	if (error)
>  		goto out;
>  
> +	vma = find_vma(mm, addr);
>  	switch (opt) {
>  	/*
>  	 * If command line arguments and environment
> @@ -2218,7 +2223,8 @@ static int prctl_set_mm(int opt, unsigned long addr,
>  
>  	error = 0;
>  out:
> -	up_write(&mm->mmap_sem);
> +	spin_unlock(&mm->arg_lock);
> +	up_read(&mm->mmap_sem);
>  	return error;
>  }
>  
> -- 
> 2.16.4

-- 
Michal Hocko
SUSE Labs

