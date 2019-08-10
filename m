Return-Path: <SRS0=GuKW=WG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF7FDC31E40
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 00:06:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2440E20C01
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 00:06:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="izwR1/V7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2440E20C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9AB226B0005; Fri,  9 Aug 2019 20:06:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 935096B0006; Fri,  9 Aug 2019 20:06:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FD316B0007; Fri,  9 Aug 2019 20:06:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 440126B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 20:06:47 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id q67so2676044pfc.10
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 17:06:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=jTuLvBzGh+kRCSFsoIGwjCgOacpl2q44m+IwnKc4d+0=;
        b=qL04nVe1Rw16ox3I0/flpN8oTvRqs1t4jzxGdjIomfyIL8cq9jlDn0tZgyODn5979j
         Y095qGRsmcqFrgsS+A9Nnd2JcUctKqZm9HPY1XM7VwtzJ9CJ7dm6QvgAbDG+polpzlrh
         AY2gjcspW3XnoeOQsxOCSiJNKNUldq86xaHM5o3s/OT9YCdtwVhQr4dMgQ+HHwjAARmc
         B5koM42SaS4utiJR/zOihcAUlg/a4GOaJ8sa5pRFY30nEO6itMa2G3S0mfReNPQdRppf
         l4wuj62eqOxTnofnPBv0TCZZExVAjRz0o2hvXUzPtYsrL1icF4Z5oII4RRexZYGBeLuj
         VDXg==
X-Gm-Message-State: APjAAAVVRPppUAAzeUzuk7mLZAOXuvAsehSBdR6DHYiEmuINz0i+3Tks
	qf3gQAda126oczHfF5F6qacPY1ZZCtU0fuYumtzKYUoooQplv45/s2TMIBo/6gE5/XLhEySStjS
	a06pAkxc1pfFYYTGLkBogjDcYeDlXgWXhK2iJXhSiRGVeKQctmLzcVlYFJ4319d4t7w==
X-Received: by 2002:aa7:8e10:: with SMTP id c16mr23705860pfr.124.1565395606859;
        Fri, 09 Aug 2019 17:06:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyGvYzSN5QyhBBIjeNYvnh8KwgJz1aVOYLSsvn5TsF7JtPbY00QheT5mNh1RK1miwiq1Hou
X-Received: by 2002:aa7:8e10:: with SMTP id c16mr23705809pfr.124.1565395606026;
        Fri, 09 Aug 2019 17:06:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565395606; cv=none;
        d=google.com; s=arc-20160816;
        b=nCKfT7ZkbxvV5BAbMG04rAmg8+N+k7mmz+Rh6eHq6tLkDNJF2VcBYofFUeesqLKFNj
         eQjcYY++0QXqOc/noxvp8LQq6RHXqT0o8EiXcEg8P6z5QmRIQxPZHpO38a7/bLuznwFk
         0EqC2wizf+S6zXln6F387F2iD/XCgdfh0FqvJAS0gzv9PvfhI3GvauaFHxldO5yTsxGo
         YI6QfOIzIbJ/z6gUTEdbvrfki5d6yyOI9kVVXJu33wl5DfEXzkNu9qQ7BguY9y7Z+714
         uCOqrNRBeZt6UH/ghMav3pppVNEAxkpL/JsTQZgUgERW4GSMBX/IHRdKvaSd2d28/MUI
         kMVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=jTuLvBzGh+kRCSFsoIGwjCgOacpl2q44m+IwnKc4d+0=;
        b=cNBROSbB/6eX8lZD1VpxbAOQbfyZpaKvFtQNQdcktHQQwKV57ExE5yUvrjamVahgxW
         Jqa2Evwo//CnCyTwi96O+eDcFhntJWwv9bEXvqy4IjRWHiYVdTw72F+brrDPRO8rRo0H
         JZwOyQ4UhixCnNtYPtbTfL9128VqdcqQDGu1F8hfKQiZpyP5jqRsZUDhg/+1mzmyZdQA
         qLx8prGbwzA/NZSMGaNgkreRnMUHCnv9K8+D0IfRnjP8qFVtSCMWt0iCO7asrd1MlZAo
         xM+gqTzZxrde+l9pPeJWu8+t09JfJd7LddiB95rq/4dg+jP6p9vrpMeEUuyNgYZHZxwV
         ZV5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="izwR1/V7";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id r62si628289plb.363.2019.08.09.17.06.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 17:06:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="izwR1/V7";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d4e0a9f0000>; Fri, 09 Aug 2019 17:06:55 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 09 Aug 2019 17:06:45 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 09 Aug 2019 17:06:45 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Sat, 10 Aug
 2019 00:06:44 +0000
Subject: Re: [RFC PATCH v2 09/19] mm/gup: Introduce vaddr_pin structure
To: <ira.weiny@intel.com>, Andrew Morton <akpm@linux-foundation.org>
CC: Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Theodore Ts'o
	<tytso@mit.edu>, Michal Hocko <mhocko@suse.com>, Dave Chinner
	<david@fromorbit.com>, <linux-xfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <linux-nvdimm@lists.01.org>,
	<linux-ext4@vger.kernel.org>, <linux-mm@kvack.org>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190809225833.6657-10-ira.weiny@intel.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <e92723cf-97a1-9860-9482-8466ff2feaa8@nvidia.com>
Date: Fri, 9 Aug 2019 17:06:44 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809225833.6657-10-ira.weiny@intel.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565395615; bh=jTuLvBzGh+kRCSFsoIGwjCgOacpl2q44m+IwnKc4d+0=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=izwR1/V7u6R4rPsmxBRUBZRR9/F2NLCDO+Jw6k19oSt+MczMwnsovxf3IqKW5nI2/
	 3/QCYIcTnTfeTCmrFCBmCUus4X4UjXn/+DnCU0TtdxZM+7Ol5CgAQUA5CTFMsPQdyp
	 vxVho4K/RzlmF3r/A+tJhDGCAVsidkv3A8TFn63cPRsZKXDwbt9Vd/5JqNloweOqAN
	 Vr3hxEUUNo/XljBaDL1tsqD98/AHiYdndOCKZgRPCdctEPmYNm06OJ1q5oknXUlZr/
	 DfTFOHtlAeRE45q/jSiZDXBvrROpK4a7RoVxqXDq/ibzLd0FnEbRB9IVoTq6zmwQHg
	 tNADgPlRdswiA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/9/19 3:58 PM, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> Some subsystems need to pass owning file information to GUP calls to
> allow for GUP to associate the "owning file" to any files being pinned
> within the GUP call.
> 
> Introduce an object to specify this information and pass it down through
> some of the GUP call stack.
> 
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> ---
>  include/linux/mm.h |  9 +++++++++
>  mm/gup.c           | 36 ++++++++++++++++++++++--------------
>  2 files changed, 31 insertions(+), 14 deletions(-)
> 

Looks good, although you may want to combine it with the next patch. 
Otherwise it feels like a "to be continued" when you're reading them.

Either way, though:

    Reviewed-by: John Hubbard <jhubbard@nvidia.com>


thanks,
-- 
John Hubbard
NVIDIA

> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 04f22722b374..befe150d17be 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -971,6 +971,15 @@ static inline bool is_zone_device_page(const struct page *page)
>  }
>  #endif
>  
> +/**
> + * @f_owner The file who "owns this GUP"
> + * @mm The mm who "owns this GUP"
> + */
> +struct vaddr_pin {
> +	struct file *f_owner;
> +	struct mm_struct *mm;
> +};
> +
>  #ifdef CONFIG_DEV_PAGEMAP_OPS
>  void __put_devmap_managed_page(struct page *page);
>  DECLARE_STATIC_KEY_FALSE(devmap_managed_key);
> diff --git a/mm/gup.c b/mm/gup.c
> index 0b05e22ac05f..7a449500f0a6 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1005,7 +1005,8 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
>  						struct page **pages,
>  						struct vm_area_struct **vmas,
>  						int *locked,
> -						unsigned int flags)
> +						unsigned int flags,
> +						struct vaddr_pin *vaddr_pin)
>  {
>  	long ret, pages_done;
>  	bool lock_dropped;
> @@ -1165,7 +1166,8 @@ long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
>  
>  	return __get_user_pages_locked(tsk, mm, start, nr_pages, pages, vmas,
>  				       locked,
> -				       gup_flags | FOLL_TOUCH | FOLL_REMOTE);
> +				       gup_flags | FOLL_TOUCH | FOLL_REMOTE,
> +				       NULL);
>  }
>  EXPORT_SYMBOL(get_user_pages_remote);
>  
> @@ -1320,7 +1322,8 @@ static long __get_user_pages_locked(struct task_struct *tsk,
>  		struct mm_struct *mm, unsigned long start,
>  		unsigned long nr_pages, struct page **pages,
>  		struct vm_area_struct **vmas, int *locked,
> -		unsigned int foll_flags)
> +		unsigned int foll_flags,
> +		struct vaddr_pin *vaddr_pin)
>  {
>  	struct vm_area_struct *vma;
>  	unsigned long vm_flags;
> @@ -1504,7 +1507,7 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
>  		 */
>  		nr_pages = __get_user_pages_locked(tsk, mm, start, nr_pages,
>  						   pages, vmas, NULL,
> -						   gup_flags);
> +						   gup_flags, NULL);
>  
>  		if ((nr_pages > 0) && migrate_allow) {
>  			drain_allow = true;
> @@ -1537,7 +1540,8 @@ static long __gup_longterm_locked(struct task_struct *tsk,
>  				  unsigned long nr_pages,
>  				  struct page **pages,
>  				  struct vm_area_struct **vmas,
> -				  unsigned int gup_flags)
> +				  unsigned int gup_flags,
> +				  struct vaddr_pin *vaddr_pin)
>  {
>  	struct vm_area_struct **vmas_tmp = vmas;
>  	unsigned long flags = 0;
> @@ -1558,7 +1562,7 @@ static long __gup_longterm_locked(struct task_struct *tsk,
>  	}
>  
>  	rc = __get_user_pages_locked(tsk, mm, start, nr_pages, pages,
> -				     vmas_tmp, NULL, gup_flags);
> +				     vmas_tmp, NULL, gup_flags, vaddr_pin);
>  
>  	if (gup_flags & FOLL_LONGTERM) {
>  		memalloc_nocma_restore(flags);
> @@ -1588,10 +1592,11 @@ static __always_inline long __gup_longterm_locked(struct task_struct *tsk,
>  						  unsigned long nr_pages,
>  						  struct page **pages,
>  						  struct vm_area_struct **vmas,
> -						  unsigned int flags)
> +						  unsigned int flags,
> +						  struct vaddr_pin *vaddr_pin)
>  {
>  	return __get_user_pages_locked(tsk, mm, start, nr_pages, pages, vmas,
> -				       NULL, flags);
> +				       NULL, flags, vaddr_pin);
>  }
>  #endif /* CONFIG_FS_DAX || CONFIG_CMA */
>  
> @@ -1607,7 +1612,8 @@ long get_user_pages(unsigned long start, unsigned long nr_pages,
>  		struct vm_area_struct **vmas)
>  {
>  	return __gup_longterm_locked(current, current->mm, start, nr_pages,
> -				     pages, vmas, gup_flags | FOLL_TOUCH);
> +				     pages, vmas, gup_flags | FOLL_TOUCH,
> +				     NULL);
>  }
>  EXPORT_SYMBOL(get_user_pages);
>  
> @@ -1647,7 +1653,7 @@ long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
>  
>  	return __get_user_pages_locked(current, current->mm, start, nr_pages,
>  				       pages, NULL, locked,
> -				       gup_flags | FOLL_TOUCH);
> +				       gup_flags | FOLL_TOUCH, NULL);
>  }
>  EXPORT_SYMBOL(get_user_pages_locked);
>  
> @@ -1684,7 +1690,7 @@ long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
>  
>  	down_read(&mm->mmap_sem);
>  	ret = __get_user_pages_locked(current, mm, start, nr_pages, pages, NULL,
> -				      &locked, gup_flags | FOLL_TOUCH);
> +				      &locked, gup_flags | FOLL_TOUCH, NULL);
>  	if (locked)
>  		up_read(&mm->mmap_sem);
>  	return ret;
> @@ -2377,7 +2383,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  EXPORT_SYMBOL_GPL(__get_user_pages_fast);
>  
>  static int __gup_longterm_unlocked(unsigned long start, int nr_pages,
> -				   unsigned int gup_flags, struct page **pages)
> +				   unsigned int gup_flags, struct page **pages,
> +				   struct vaddr_pin *vaddr_pin)
>  {
>  	int ret;
>  
> @@ -2389,7 +2396,8 @@ static int __gup_longterm_unlocked(unsigned long start, int nr_pages,
>  		down_read(&current->mm->mmap_sem);
>  		ret = __gup_longterm_locked(current, current->mm,
>  					    start, nr_pages,
> -					    pages, NULL, gup_flags);
> +					    pages, NULL, gup_flags,
> +					    vaddr_pin);
>  		up_read(&current->mm->mmap_sem);
>  	} else {
>  		ret = get_user_pages_unlocked(start, nr_pages,
> @@ -2448,7 +2456,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
>  		pages += nr;
>  
>  		ret = __gup_longterm_unlocked(start, nr_pages - nr,
> -					      gup_flags, pages);
> +					      gup_flags, pages, NULL);
>  
>  		/* Have to be a bit careful with return values */
>  		if (nr > 0) {
> 

