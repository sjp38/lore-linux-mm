Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B51AEC43381
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 07:23:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4607C2070B
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 07:23:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4607C2070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9826B6B0005; Tue,  2 Apr 2019 03:23:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 932A86B0007; Tue,  2 Apr 2019 03:23:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FB9F6B0008; Tue,  2 Apr 2019 03:23:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2E14B6B0005
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 03:23:55 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f2so5431940edv.15
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 00:23:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1zevk8C117eY9FU5TF0TtfeNWw5rUr3UHY3CECO6uag=;
        b=lmDXAo8G+UorUjCr5KHcNWuVeisd+1UWUJCL+KhkPFhrh578qBLVwGTEgCJQheabrG
         y4zxoRW+G+29UmlO0NI1PDGOvIXsXQMXNd2/sTbbU0gJxeVz1a+SKM89XWPdkcJlRFS7
         VXUu8df/p5hqk7lJ+zvVJiBganOmle3/FQnXLXyXY/xgcoeo0dziqM17LsfxrsP3AW//
         7B/qBBEIyj/QLBKkc6TDW9oi6I8a9oyiBJs+0BhyqRQhDvdStHGr1cnUVJEaU6cKE4uo
         dApqOv8+CjUTwr7lXLTIPHtsy6ZfFl08kEAH/iYwT71I4cH0JnAv1nvIUPDVHuj7EeRB
         wI3w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAWFNepDi1UjV+gz41e6FuOhUuqHk9+WQha5BDqCHEnbMYxmPUw4
	2gNfdWckzeLQZONVcOd1zSsTfkED0wqhnxYz+taJvlKaefgP8E2XF6Cqxl/MgmgLL87gszt2osb
	KJ5T/puKBQHSO+46L1vVd0D/QZVvdDgy3WD7xgII64gGIxz0gr7HkRiOqJY4a5tl0OA==
X-Received: by 2002:a50:90b3:: with SMTP id c48mr45298999eda.8.1554189834609;
        Tue, 02 Apr 2019 00:23:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxk8isLbUdF6+JXhkeQEGRuFTh+39LdcSw43uEQrdv1hMS0R3bx03q08C0vtS21SN5Gqjs8
X-Received: by 2002:a50:90b3:: with SMTP id c48mr45298942eda.8.1554189833442;
        Tue, 02 Apr 2019 00:23:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554189833; cv=none;
        d=google.com; s=arc-20160816;
        b=Sy5EOsuNIsqeWXQ0h6B5YKnD2ROh0N0Ebg41NnRquLGxIt5EfyF1jaPRoThlFJ6zHB
         M0LqnVh6tYEtINLuVs/AQS6wTpW36k7y8i03RFgE8gYwK8J1PvRzhKfwwNimkX7Cmn5X
         TBuZ77zQWmKK8Z3Q3/swIPKOE98Oh86sdHvhPLLlxDfAaoYHiaBxGojGudEoH+oREZY9
         QWawW+mHii/CH46NeELrZ411AUNbhy2P00VCCBYbPpjAQh6LtqpD/l04cmh7no3R36Mu
         GiZr6SJAIIz6Hn40K2X7i2SUNq3GhLOc+rDaZRAoa4MV9oT2ItlW/ApMMhZuyj8NHW2S
         cLng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=1zevk8C117eY9FU5TF0TtfeNWw5rUr3UHY3CECO6uag=;
        b=eJzU72eGuclJ3eg1DUgzRnGCExU8FUk9Uz2UZduP2tbkJL5s1d/AnP2ttdIfBzemjv
         96hrG6XSgMKrdY5E/lALzuuEXeu9plMwdUoctPRsGSWuzijy776k4clrtq3d6CWvX9Ky
         fd/ud5Segbyoo7pFKw8/UNpSWizfyQfePJURMKYdFv7PgDg2D2/5/Yw1FnEgZAVV25Yt
         yg5+GzAzFRVTyNqCZpFdKj3uGUYB97PwQfOb3HFUyHdUxl5AEm6YP4T8debTEHHZ5ac3
         yKxwC5KjVpsSXSzh4YQsvudiOYBtjMtwT9hXEfJ0V7SgMJtuuxsKeUDLX/dktEyvBG98
         qJRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v12si449540edq.189.2019.04.02.00.23.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 00:23:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B3EA0AFF5;
	Tue,  2 Apr 2019 07:23:52 +0000 (UTC)
Date: Tue, 2 Apr 2019 09:23:51 +0200
From: Michal Hocko <mhocko@suse.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: willy@infradead.org, jack@suse.cz, hughd@google.com, vbabka@suse.cz,
	akpm@linux-foundation.org, linux-mm@kvack.org
Subject: Re: [PATCH] mm: add vm event for page cache miss
Message-ID: <20190402072351.GN28293@dhcp22.suse.cz>
References: <1554185720-26404-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1554185720-26404-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 02-04-19 14:15:20, Yafang Shao wrote:
> We found that some latency spike was caused by page cache miss on our
> database server.
> So we decide to measure the page cache miss.
> Currently the kernel is lack of this facility for measuring it.

What are you going to use this information for?

> This patch introduces a new vm counter PGCACHEMISS for this purpose.
> This counter will be incremented in bellow scenario,
> - page cache miss in generic file read routine
> - read access page cache miss in mmap
> - read access page cache miss in swapin
>
> NB, readahead routine is not counted because it won't stall the
> application directly.

Doesn't this partially open the side channel we have closed for mincore
just recently?

> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> ---
>  include/linux/pagemap.h       | 7 +++++++
>  include/linux/vm_event_item.h | 1 +
>  mm/filemap.c                  | 2 ++
>  mm/memory.c                   | 1 +
>  mm/shmem.c                    | 9 +++++----
>  mm/vmstat.c                   | 1 +
>  6 files changed, 17 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index f939e00..8355b51 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -233,6 +233,13 @@ pgoff_t page_cache_next_miss(struct address_space *mapping,
>  pgoff_t page_cache_prev_miss(struct address_space *mapping,
>  			     pgoff_t index, unsigned long max_scan);
>  
> +static inline void page_cache_read_miss(struct vm_fault *vmf)
> +{
> +	if (!vmf || (vmf->flags & (FAULT_FLAG_USER | FAULT_FLAG_WRITE)) ==
> +	    FAULT_FLAG_USER)
> +		count_vm_event(PGCACHEMISS);
> +}
> +
>  #define FGP_ACCESSED		0x00000001
>  #define FGP_LOCK		0x00000002
>  #define FGP_CREAT		0x00000004
> diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
> index 47a3441..d589f05 100644
> --- a/include/linux/vm_event_item.h
> +++ b/include/linux/vm_event_item.h
> @@ -29,6 +29,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>  		PGFREE, PGACTIVATE, PGDEACTIVATE, PGLAZYFREE,
>  		PGFAULT, PGMAJFAULT,
>  		PGLAZYFREED,
> +		PGCACHEMISS,
>  		PGREFILL,
>  		PGSTEAL_KSWAPD,
>  		PGSTEAL_DIRECT,
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 4157f85..fc12c2d 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2256,6 +2256,7 @@ static ssize_t generic_file_buffered_read(struct kiocb *iocb,
>  		goto out;
>  
>  no_cached_page:
> +		page_cache_read_miss(NULL);
>  		/*
>  		 * Ok, it wasn't cached, so we need to create a new
>  		 * page..
> @@ -2556,6 +2557,7 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
>  		fpin = do_async_mmap_readahead(vmf, page);
>  	} else if (!page) {
>  		/* No page in the page cache at all */
> +		page_cache_read_miss(vmf);
>  		count_vm_event(PGMAJFAULT);
>  		count_memcg_event_mm(vmf->vma->vm_mm, PGMAJFAULT);
>  		ret = VM_FAULT_MAJOR;
> diff --git a/mm/memory.c b/mm/memory.c
> index bd157f2..63bcd41 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2754,6 +2754,7 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
>  		ret = VM_FAULT_MAJOR;
>  		count_vm_event(PGMAJFAULT);
>  		count_memcg_event_mm(vma->vm_mm, PGMAJFAULT);
> +		page_cache_read_miss(vmf);
>  	} else if (PageHWPoison(page)) {
>  		/*
>  		 * hwpoisoned dirty swapcache pages are kept for killing
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 3a4b74c..47e33a4 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -127,7 +127,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
>  static int shmem_swapin_page(struct inode *inode, pgoff_t index,
>  			     struct page **pagep, enum sgp_type sgp,
>  			     gfp_t gfp, struct vm_area_struct *vma,
> -			     vm_fault_t *fault_type);
> +			     struct vm_fault *vmf, vm_fault_t *fault_type);
>  static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
>  		struct page **pagep, enum sgp_type sgp,
>  		gfp_t gfp, struct vm_area_struct *vma,
> @@ -1159,7 +1159,7 @@ static int shmem_unuse_swap_entries(struct inode *inode, struct pagevec pvec,
>  		error = shmem_swapin_page(inode, indices[i],
>  					  &page, SGP_CACHE,
>  					  mapping_gfp_mask(mapping),
> -					  NULL, NULL);
> +					  NULL, NULL, NULL);
>  		if (error == 0) {
>  			unlock_page(page);
>  			put_page(page);
> @@ -1614,7 +1614,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
>  static int shmem_swapin_page(struct inode *inode, pgoff_t index,
>  			     struct page **pagep, enum sgp_type sgp,
>  			     gfp_t gfp, struct vm_area_struct *vma,
> -			     vm_fault_t *fault_type)
> +			     struct vm_fault *vmf, vm_fault_t *fault_type)
>  {
>  	struct address_space *mapping = inode->i_mapping;
>  	struct shmem_inode_info *info = SHMEM_I(inode);
> @@ -1636,6 +1636,7 @@ static int shmem_swapin_page(struct inode *inode, pgoff_t index,
>  			*fault_type |= VM_FAULT_MAJOR;
>  			count_vm_event(PGMAJFAULT);
>  			count_memcg_event_mm(charge_mm, PGMAJFAULT);
> +			page_cache_read_miss(vmf);
>  		}
>  		/* Here we actually start the io */
>  		page = shmem_swapin(swap, gfp, info, index);
> @@ -1758,7 +1759,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
>  	page = find_lock_entry(mapping, index);
>  	if (xa_is_value(page)) {
>  		error = shmem_swapin_page(inode, index, &page,
> -					  sgp, gfp, vma, fault_type);
> +					  sgp, gfp, vma, vmf, fault_type);
>  		if (error == -EEXIST)
>  			goto repeat;
>  
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 36b56f8..c49ecba 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1188,6 +1188,7 @@ int fragmentation_index(struct zone *zone, unsigned int order)
>  	"pgfault",
>  	"pgmajfault",
>  	"pglazyfreed",
> +	"pgcachemiss",
>  
>  	"pgrefill",
>  	"pgsteal_kswapd",
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

