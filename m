Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFD63C282DB
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 12:45:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8804A21872
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 12:45:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8804A21872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 227D48E0002; Fri,  1 Feb 2019 07:45:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1AF368E0001; Fri,  1 Feb 2019 07:45:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C53E8E0002; Fri,  1 Feb 2019 07:45:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A149A8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 07:45:31 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t2so2738391edb.22
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 04:45:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fsUfyrqdxhJzsiazWw30FQJbEwdlRozBSwe6chPLUw8=;
        b=B+jd0mhwX3G6Ue/kIPSqSVUuOYpRBdJlQvDY0PU/vtgsYVM3yK37RXogr95wKZuiKp
         PatTIMlippoQL+JQG/ALnECrjptYJa9SvOMGD7UqwEHKwBa95ZWKAI5wAGBaShfan2cq
         lUlqNwNO0KbdH4AM5dnnt5HGhYx7JYxOm2j0u50uRYoihfTRl03x1dJM/hh6RTwpQes0
         t2PR6tgLcOdcmO/BsspWThYTywtMcE+0Bg2jHANR+g/nIIU5gtcWwNXvc7YkBR18KrMW
         sp60o8bBMmd7U0L+9m3pt46zb6T3zeGRwtC0iy1IRr9aDydbG738AhGJBrp3J/r5WOms
         /RFQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukfGDVc2WmmIQctpytCWhywPMET6lAiJhLNux4gVUYWJOC7bdjJj
	wLKG4NSttZMJCQjR8bQ0pSCPnYQ9SBbLtaHIOKYz1pkAADK+6sKDyoHOM/hSTeBfBH6TvjfXPam
	HK4t60Utix0bdVHAoGGKgkOa2y66cKCiMYfSF4mcU3bcdlpFKd2gb4Wlz23mTQlQ=
X-Received: by 2002:a50:ee1a:: with SMTP id g26mr37885321eds.266.1549025131162;
        Fri, 01 Feb 2019 04:45:31 -0800 (PST)
X-Google-Smtp-Source: ALg8bN59p8jKo3cx+NGeYFY5ve+wGqiy9Shoi1+8THtW6uzqtlwHGKjjndrrGSAClowIAx3eMauz
X-Received: by 2002:a50:ee1a:: with SMTP id g26mr37885270eds.266.1549025130253;
        Fri, 01 Feb 2019 04:45:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549025130; cv=none;
        d=google.com; s=arc-20160816;
        b=EWFf4g3hT6b9bzOhr1TC11bx0wkKifk2QrEHVTVe+tDzTI3D0QRc2n41QFLONU72V0
         VvXHN8hjb8Atx9pCsg+AOHsQQdQii8oC+OFDdEJ+azDBOwWPJI2BSnyDExaW6EuP8PY4
         HVCxyEJjODJ8DtAdhnrMgvSVrY6fQpm+/jFmlY4RMP53tjGuiNkgnQfU96Plj+hBu0Du
         iZXymmtsJgT8lHs7ycz/565NwaQIT5Pti+v5vTChwi81uFTMQX4dWseBgAqz2Sdjcql5
         kX8ZftaAFfFnxouzaZEh2qeXb/L/EAeLRPnWd3B0olmbwnMx/dhmVqQX2Q+gUbIke1iw
         7LwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fsUfyrqdxhJzsiazWw30FQJbEwdlRozBSwe6chPLUw8=;
        b=oPsaSASUYPKMlRBFPHBuGv3rcauLte8Po1VXtsZa2MEiswyiP6Dbtx9OVMAZXz33cv
         UaychjnvnZ881+SFYqdfvGZYWv8KC99gotdnZlCc1AGza8IwR4OKPegFja5W/NlqE25z
         OWJaLv9Lzwkc7+Sv98CCSCubBxicBuEBWq0e0v2WhMcA33iKLYbLOX9hiDFDA5oOO6a0
         emF2iWVKh+MTmmVnBxao4WRn2TR7HpLxp6O/85P2biV1N52qtrThKaOO2a9NFEUnbtJ7
         zXTcPsJUdoLtFbsM9rmgWFlbBwn1HPZPe0dLDCEqBJ9K5rl5t8aRfL0/5MmsiSx93EfG
         U32Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x8si771047ejb.290.2019.02.01.04.45.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 04:45:30 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A07E4ACD4;
	Fri,  1 Feb 2019 12:45:29 +0000 (UTC)
Date: Fri, 1 Feb 2019 13:45:28 +0100
From: Michal Hocko <mhocko@kernel.org>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Matthew Wilcox <willy@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/1] mm/vmalloc: convert vmap_lazy_nr to atomic_long_t
Message-ID: <20190201124528.GN11599@dhcp22.suse.cz>
References: <20190131162452.25879-1-urezki@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190131162452.25879-1-urezki@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 31-01-19 17:24:52, Uladzislau Rezki (Sony) wrote:
> vmap_lazy_nr variable has atomic_t type that is 4 bytes integer
> value on both 32 and 64 bit systems. lazy_max_pages() deals with
> "unsigned long" that is 8 bytes on 64 bit system, thus vmap_lazy_nr
> should be 8 bytes on 64 bit as well.

But do we really need 64b number of _pages_? I have hard time imagine
that we would have that many lazy pages to accumulate.

> 
> Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
> ---
>  mm/vmalloc.c | 20 ++++++++++----------
>  1 file changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index abe83f885069..755b02983d8d 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -632,7 +632,7 @@ static unsigned long lazy_max_pages(void)
>  	return log * (32UL * 1024 * 1024 / PAGE_SIZE);
>  }
>  
> -static atomic_t vmap_lazy_nr = ATOMIC_INIT(0);
> +static atomic_long_t vmap_lazy_nr = ATOMIC_LONG_INIT(0);
>  
>  /*
>   * Serialize vmap purging.  There is no actual criticial section protected
> @@ -650,7 +650,7 @@ static void purge_fragmented_blocks_allcpus(void);
>   */
>  void set_iounmap_nonlazy(void)
>  {
> -	atomic_set(&vmap_lazy_nr, lazy_max_pages()+1);
> +	atomic_long_set(&vmap_lazy_nr, lazy_max_pages()+1);
>  }
>  
>  /*
> @@ -658,10 +658,10 @@ void set_iounmap_nonlazy(void)
>   */
>  static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
>  {
> +	unsigned long resched_threshold;
>  	struct llist_node *valist;
>  	struct vmap_area *va;
>  	struct vmap_area *n_va;
> -	int resched_threshold;
>  
>  	lockdep_assert_held(&vmap_purge_lock);
>  
> @@ -681,16 +681,16 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
>  	}
>  
>  	flush_tlb_kernel_range(start, end);
> -	resched_threshold = (int) lazy_max_pages() << 1;
> +	resched_threshold = lazy_max_pages() << 1;
>  
>  	spin_lock(&vmap_area_lock);
>  	llist_for_each_entry_safe(va, n_va, valist, purge_list) {
> -		int nr = (va->va_end - va->va_start) >> PAGE_SHIFT;
> +		unsigned long nr = (va->va_end - va->va_start) >> PAGE_SHIFT;
>  
>  		__free_vmap_area(va);
> -		atomic_sub(nr, &vmap_lazy_nr);
> +		atomic_long_sub(nr, &vmap_lazy_nr);
>  
> -		if (atomic_read(&vmap_lazy_nr) < resched_threshold)
> +		if (atomic_long_read(&vmap_lazy_nr) < resched_threshold)
>  			cond_resched_lock(&vmap_area_lock);
>  	}
>  	spin_unlock(&vmap_area_lock);
> @@ -727,10 +727,10 @@ static void purge_vmap_area_lazy(void)
>   */
>  static void free_vmap_area_noflush(struct vmap_area *va)
>  {
> -	int nr_lazy;
> +	unsigned long nr_lazy;
>  
> -	nr_lazy = atomic_add_return((va->va_end - va->va_start) >> PAGE_SHIFT,
> -				    &vmap_lazy_nr);
> +	nr_lazy = atomic_long_add_return((va->va_end - va->va_start) >>
> +				PAGE_SHIFT, &vmap_lazy_nr);
>  
>  	/* After this point, we may free va at any time */
>  	llist_add(&va->purge_list, &vmap_purge_list);
> -- 
> 2.11.0
> 

-- 
Michal Hocko
SUSE Labs

