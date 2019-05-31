Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48416C04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 06:04:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00E5B2642D
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 06:04:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00E5B2642D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9160B6B0278; Fri, 31 May 2019 02:04:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C6436B027A; Fri, 31 May 2019 02:04:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78E9F6B027C; Fri, 31 May 2019 02:04:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 25BD26B0278
	for <linux-mm@kvack.org>; Fri, 31 May 2019 02:04:05 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n52so12356315edd.2
        for <linux-mm@kvack.org>; Thu, 30 May 2019 23:04:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=TePGN/41FXMoeh0XTBKeiBxlJZNh/ZzSQaCsuxq9YG4=;
        b=k4PHZEEFPTRsh5cfrS7rzsLxYgh9vTxwts2bJI77hODdp0noWOijuofapdBBlyLoyE
         Mm7hSTVM5Q65mN3ILmwV28If+ai2d8qWh32BRyzYzC3311hHDhPc6cljYIHu2LY3kEyY
         ObZMiowxP/r8YAU/g0EwQ25DePfXhLSwj8vjKey8Fm2m9tr+euo2w52LdTw05Iq1K9S+
         YfrZRWqzm4+w6N863ILZOxl4MBKnbwZ92ix53VKr0Sv56oaGhZA0IQneBJ3qn67NTO3q
         tUrRMO9cRNr7p4YPHOKi2Pwm7hN5fuQiR3PyyP87LKO/qXQIeG2mfK3dowF32kT+R1Lm
         jzXw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXhvtUA67vELDL24zJewQoSi+jChowy6U3D6yQrSYVCsoLkdMRE
	b+TZj3LsIOPiH43kas4h58Tvn2GqwpOaiUhstIYwuKGdHx6LMvymo8sDsyzeVxqYVL5pSpZgJaM
	u8zf9nwDiBp0XKdeAzflapHnoqVyV+2DwWnOg/W140UXNsQk3wL2E2uhoyNbhqZ0=
X-Received: by 2002:a17:906:d513:: with SMTP id ge19mr7474536ejb.222.1559282644542;
        Thu, 30 May 2019 23:04:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCGNzwOXRs2O65gtvvzbsKr8GLMe0Z9aiB5R3ZcdRc9lq8qCyYCQ7OV3smOA9dhopzgck5
X-Received: by 2002:a17:906:d513:: with SMTP id ge19mr7474409ejb.222.1559282643061;
        Thu, 30 May 2019 23:04:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559282643; cv=none;
        d=google.com; s=arc-20160816;
        b=kmUoKz7dRBKzLaJN3FZ7Vy1YVhzAHbtzoaVxdIDUbGvcWZkVcokbe1bQ+D5ZfIBoU6
         0isXuW1LwXWGPLrDLlC0FzX2SIqOpr9i3Ild3AylAVHuI8HzEIxaMuWgCXdmBMdzgWFS
         XFk2uC3+HTElPfAgDOU00mwVvEVkNYDWVLGWq9jtZT49lQL95Hj/BQ58+73JSYM/mxrZ
         eFOJwGT3lP1adi+LjRWzSxqAaHsoaUD7HBU2+o7wcM/whQgcwAWstZE4BVB+jLlWVlRk
         Cv0VLgGN9bAS6DGdLhVsbc/lje5gpx2ySBQZeD3+T7/XOgKSAsEHdn1OoXKbBbslsztS
         cx7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=TePGN/41FXMoeh0XTBKeiBxlJZNh/ZzSQaCsuxq9YG4=;
        b=OAf3ERIabnMFUqm38MTauRCtvaAS47rIv/omdnT9qy0WAnuaJLEpd2I1moXX2O8d/D
         fDAUb4ox8dlwczLnmnYGPrAE2Egj1e7ZrjDX1AVGaJbY9FJ8dwKPVixi+6dEhDCJU1qD
         wZV69AAH/elxjF0xB+GsuFd5X6bPPnOQWHMYrHrz0R7wIErVbmhZc3rZHvBxs/SknuUX
         oMnW3k7xkQzAafB/sZBWeWGHVvx/f4jktYLagscUZpoZZDfy5xk1xXxrJQV1UM1QtlZp
         PpVFRndeAu5oIMnMmsfRPNx6RGPwH7KNrDnbImyr5pEHL3j+tT+YQyyLaWwXbHAAI5bB
         gmiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h18si784037ejq.269.2019.05.30.23.04.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 23:04:03 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7BEF9AF32;
	Fri, 31 May 2019 06:04:02 +0000 (UTC)
Date: Fri, 31 May 2019 08:04:01 +0200
From: Michal Hocko <mhocko@kernel.org>
To: semenzato@chromium.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, sonnyrao@chromium.org,
	Yu Zhao <yuzhao@chromium.org>, linux-api@vger.kernel.org
Subject: Re: [PATCH v2 1/1] mm: smaps: split PSS into components
Message-ID: <20190531060401.GA7386@dhcp22.suse.cz>
References: <20190531002633.128370-1-semenzato@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190531002633.128370-1-semenzato@chromium.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Please always Cc linux-api mailing list (now added) when adding a new
user visible API. Keeping the rest of the email intact for reference]

On Thu 30-05-19 17:26:33, semenzato@chromium.org wrote:
> From: Luigi Semenzato <semenzato@chromium.org>
> 
> Report separate components (anon, file, and shmem)
> for PSS in smaps_rollup.
> 
> This helps understand and tune the memory manager behavior
> in consumer devices, particularly mobile devices.  Many of
> them (e.g. chromebooks and Android-based devices) use zram
> for anon memory, and perform disk reads for discarded file
> pages.  The difference in latency is large (e.g. reading
> a single page from SSD is 30 times slower than decompressing
> a zram page on one popular device), thus it is useful to know
> how much of the PSS is anon vs. file.
> 
> This patch also removes a small code duplication in smaps_account,
> which would have gotten worse otherwise.
> 
> Acked-by: Yu Zhao <yuzhao@chromium.org>
> Signed-off-by: Luigi Semenzato <semenzato@chromium.org>
> ---
>  fs/proc/task_mmu.c | 91 +++++++++++++++++++++++++++++++---------------
>  1 file changed, 61 insertions(+), 30 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 01d4eb0e6bd1..ed3b952f0d30 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -417,17 +417,53 @@ struct mem_size_stats {
>  	unsigned long shared_hugetlb;
>  	unsigned long private_hugetlb;
>  	u64 pss;
> +	u64 pss_anon;
> +	u64 pss_file;
> +	u64 pss_shmem;
>  	u64 pss_locked;
>  	u64 swap_pss;
>  	bool check_shmem_swap;
>  };
>  
> +static void smaps_page_accumulate(struct mem_size_stats *mss,
> +		struct page *page, unsigned long size, unsigned long pss,
> +		bool dirty, bool locked, bool private)
> +{
> +	mss->pss += pss;
> +
> +	if (PageAnon(page))
> +		mss->pss_anon += pss;
> +	else if (PageSwapBacked(page))
> +		mss->pss_shmem += pss;
> +	else
> +		mss->pss_file += pss;
> +
> +	if (locked)
> +		mss->pss_locked += pss;
> +
> +	if (dirty || PageDirty(page)) {
> +		if (private)
> +			mss->private_dirty += size;
> +		else
> +			mss->shared_dirty += size;
> +	} else {
> +		if (private)
> +			mss->private_clean += size;
> +		else
> +			mss->shared_clean += size;
> +	}
> +}
> +
>  static void smaps_account(struct mem_size_stats *mss, struct page *page,
>  		bool compound, bool young, bool dirty, bool locked)
>  {
>  	int i, nr = compound ? 1 << compound_order(page) : 1;
>  	unsigned long size = nr * PAGE_SIZE;
>  
> +	/*
> +	 * First accumulate quantities that depend only on |size| and the type
> +	 * of the compound page.
> +	 */
>  	if (PageAnon(page)) {
>  		mss->anonymous += size;
>  		if (!PageSwapBacked(page) && !dirty && !PageDirty(page))
> @@ -440,42 +476,24 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
>  		mss->referenced += size;
>  
>  	/*
> +	 * Then accumulate quantities that may depend on sharing, or that may
> +	 * differ page-by-page.
> +	 *
>  	 * page_count(page) == 1 guarantees the page is mapped exactly once.
>  	 * If any subpage of the compound page mapped with PTE it would elevate
>  	 * page_count().
>  	 */
>  	if (page_count(page) == 1) {
> -		if (dirty || PageDirty(page))
> -			mss->private_dirty += size;
> -		else
> -			mss->private_clean += size;
> -		mss->pss += (u64)size << PSS_SHIFT;
> -		if (locked)
> -			mss->pss_locked += (u64)size << PSS_SHIFT;
> +		smaps_page_accumulate(mss, page, size, size << PSS_SHIFT, dirty,
> +			locked, true);
>  		return;
>  	}
> -
>  	for (i = 0; i < nr; i++, page++) {
>  		int mapcount = page_mapcount(page);
> -		unsigned long pss = (PAGE_SIZE << PSS_SHIFT);
> -
> -		if (mapcount >= 2) {
> -			if (dirty || PageDirty(page))
> -				mss->shared_dirty += PAGE_SIZE;
> -			else
> -				mss->shared_clean += PAGE_SIZE;
> -			mss->pss += pss / mapcount;
> -			if (locked)
> -				mss->pss_locked += pss / mapcount;
> -		} else {
> -			if (dirty || PageDirty(page))
> -				mss->private_dirty += PAGE_SIZE;
> -			else
> -				mss->private_clean += PAGE_SIZE;
> -			mss->pss += pss;
> -			if (locked)
> -				mss->pss_locked += pss;
> -		}
> +		unsigned long pss = PAGE_SIZE << PSS_SHIFT;
> +
> +		smaps_page_accumulate(mss, page, PAGE_SIZE, pss / mapcount,
> +			dirty, locked, mapcount < 2);
>  	}
>  }
>  
> @@ -754,10 +772,23 @@ static void smap_gather_stats(struct vm_area_struct *vma,
>  		seq_put_decimal_ull_width(m, str, (val) >> 10, 8)
>  
>  /* Show the contents common for smaps and smaps_rollup */
> -static void __show_smap(struct seq_file *m, const struct mem_size_stats *mss)
> +static void __show_smap(struct seq_file *m, const struct mem_size_stats *mss,
> +	bool rollup_mode)
>  {
>  	SEQ_PUT_DEC("Rss:            ", mss->resident);
>  	SEQ_PUT_DEC(" kB\nPss:            ", mss->pss >> PSS_SHIFT);
> +	if (rollup_mode) {
> +		/*
> +		 * These are meaningful only for smaps_rollup, otherwise two of
> +		 * them are zero, and the other one is the same as Pss.
> +		 */
> +		SEQ_PUT_DEC(" kB\nPss_Anon:       ",
> +			mss->pss_anon >> PSS_SHIFT);
> +		SEQ_PUT_DEC(" kB\nPss_File:       ",
> +			mss->pss_file >> PSS_SHIFT);
> +		SEQ_PUT_DEC(" kB\nPss_Shmem:      ",
> +			mss->pss_shmem >> PSS_SHIFT);
> +	}
>  	SEQ_PUT_DEC(" kB\nShared_Clean:   ", mss->shared_clean);
>  	SEQ_PUT_DEC(" kB\nShared_Dirty:   ", mss->shared_dirty);
>  	SEQ_PUT_DEC(" kB\nPrivate_Clean:  ", mss->private_clean);
> @@ -794,7 +825,7 @@ static int show_smap(struct seq_file *m, void *v)
>  	SEQ_PUT_DEC(" kB\nMMUPageSize:    ", vma_mmu_pagesize(vma));
>  	seq_puts(m, " kB\n");
>  
> -	__show_smap(m, &mss);
> +	__show_smap(m, &mss, false);
>  
>  	seq_printf(m, "THPeligible:    %d\n", transparent_hugepage_enabled(vma));
>  
> @@ -841,7 +872,7 @@ static int show_smaps_rollup(struct seq_file *m, void *v)
>  	seq_pad(m, ' ');
>  	seq_puts(m, "[rollup]\n");
>  
> -	__show_smap(m, &mss);
> +	__show_smap(m, &mss, true);
>  
>  	release_task_mempolicy(priv);
>  	up_read(&mm->mmap_sem);
> -- 
> 2.22.0.rc1.257.g3120a18244-goog

-- 
Michal Hocko
SUSE Labs

