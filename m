Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1A68C282CD
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 22:45:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A702F2175B
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 22:45:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="TPTYJCkU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A702F2175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66E988E0003; Mon, 28 Jan 2019 17:45:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6226F8E0001; Mon, 28 Jan 2019 17:45:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50F8E8E0003; Mon, 28 Jan 2019 17:45:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 24ACE8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 17:45:31 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id w1so22129817qta.12
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 14:45:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Ma4gMd+9dw3VfggiKiIwCmxrdS3+NuicG/7QTIikafw=;
        b=n7cPUAGPA8glcpSEcLSg32Zp/Jri81kfB8I/2r4Hg2jgmuiAnH4veNefa1vt6tlA3j
         iGD3+kgSA+XXxxMJ0I6WFWmZRemdEs8NZ4SAU4vSYSlUdxlJJ7fpCxbRd/Hht1pts+H5
         IELTMk0OR50eSzK2dpohMotHDWm5WA9BNGvqJhLUlKyQIMba+sMYsyd+3um2zPR/hKmA
         f4BW9CnB+EjjhmQUb9k4lurl6JUKOEYXKMkuow5SKZySK5rokeyPf5/jsuNVyO4dNemZ
         YltV7Ax36xayvviYCcFHW7oNL1bDFBEVrTeBAVegcTSvl/L1oYu0CobH+vbmNGOcMZeu
         KFPg==
X-Gm-Message-State: AJcUukfcimLF9AX69Kwv3trAflqlSMC6Nm9t6P8DCs1dRTqr0L0iLFAT
	VJ4YbU9bTYTZ+dRoxmap5U/3/MrcMB1gIvotFgLvKvhCxKnqnf6FBvVcIjllVi86fFdY5olUsoO
	ewm98b/wZJnqNV46YJCc9SlVCGmZeWCuRouiqQR9pKQQzBn6ApNNuoohPRcPYZSnKg6SZ9lROXq
	MJcdR/MRXrJXPXFT2im1rxtc1i6pOg+uBwQtJIJd6JQWI6TsNqxS2sS7qLesu8gnMaKx72zZ2ZN
	c5FuSqhKO0vW0QwOR/7vQf51jrMRubh7yZYILVdYql6gdEsbpc9HKsYN87ViTh8TxC3KxgZWRe5
	17TFHFeZnkNh/Te+v4AnhPpG4rMHxbkbAbset7CBrOcWWUXPNYa96F/XGjOruBRI3P9tlQJwVdX
	g
X-Received: by 2002:ac8:231a:: with SMTP id a26mr23876500qta.40.1548715530903;
        Mon, 28 Jan 2019 14:45:30 -0800 (PST)
X-Received: by 2002:ac8:231a:: with SMTP id a26mr23876457qta.40.1548715530293;
        Mon, 28 Jan 2019 14:45:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548715530; cv=none;
        d=google.com; s=arc-20160816;
        b=tyzj2V98U9RPuw9+0BMbovMeXz484w3PIvlcadlKTm3nBRtfkpVp6zKml5bu+fDoJU
         w6suBEAbNtkpouWGawCjRhLm4iDSCpKf+w/ytPYVswPF9uU0U68h4zwD56P8AFSrkMM4
         /H02QRXriKGB4ED6DRRQfOIcpl6dN0gzWT0BdZqnFSwKFeEO/6Zhz2BelelKizlKgQTq
         h66V9krETtR58e4tEBBCtgdpsij16Rc2mv7kh9VMWP9147rb1lF8UFhJUUf8PxkUyKfD
         i6f+rBOWBDcqDfRZfa8H94YDPa99EyxcEMQ/4uEiFKTwgB0QkU3mqaZKvhlgSxYoqQ23
         /oYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Ma4gMd+9dw3VfggiKiIwCmxrdS3+NuicG/7QTIikafw=;
        b=y7OSwvKu1dNF0Ics5ED7b+cI587DDrwU9fo7UGcM7l67jy2mngkprTuxTk9BnnXXYG
         1bYhXu05wt5V3SzuBXFoV18KS7Zal7S137vqSB35gAfnrTRx8ZR+D4wNK9KSYn2Sy52p
         VlJNOPuiRUiGxEeLFUL+PLfJqNDxjpmrDxSPc+V8yr/V6pMvyROgtzV1GCw4cbLgYrY+
         Vt2A0JIiLS2t+icO1sNp5Vjw95zs+2rwXm5CG9dWxtVys/OiWj8kYauxYcccsO5j8MTZ
         H2IRdbTRDqP5yxqWiAoLIVZcrSrXr4WkPMEO4UXHZHx6O+7Fdt2UsboUwqkOhIpU9Kjx
         mlcw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=TPTYJCkU;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m53sor124499011qvh.62.2019.01.28.14.45.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 14:45:30 -0800 (PST)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=TPTYJCkU;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Ma4gMd+9dw3VfggiKiIwCmxrdS3+NuicG/7QTIikafw=;
        b=TPTYJCkUhd6bgO13sc0uwD+Es+t+aRGKl+NaO029KYESxB6+O6CajTu6q6CviHuZuM
         WShcA7pwr22DZC0S4HMGrCywnTRVy4c0oZnNIcv1Dd6CrppZHE9CpseemkMeU/245MnH
         THoXvc8JHAb+5h52FQNDYC9tMXMByRjWmOJPs=
X-Google-Smtp-Source: ALg8bN6F5olPmlLpiXIP9Hb57M5Qktvq1qbb/tHKjEiaMclG8cHMr3wbSBiP/lGhmaxZmszR5x2PcQ==
X-Received: by 2002:a0c:ae30:: with SMTP id y45mr21676404qvc.145.1548715529790;
        Mon, 28 Jan 2019 14:45:29 -0800 (PST)
Received: from localhost ([2620:0:1004:1100:cca9:fccc:8667:9bdc])
        by smtp.gmail.com with ESMTPSA id n8sm90742157qtk.91.2019.01.28.14.45.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 28 Jan 2019 14:45:28 -0800 (PST)
Date: Mon, 28 Jan 2019 17:45:28 -0500
From: Joel Fernandes <joel@joelfernandes.org>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v1 2/2] mm: add priority threshold to
 __purge_vmap_area_lazy()
Message-ID: <20190128224528.GB38107@google.com>
References: <20190124115648.9433-1-urezki@gmail.com>
 <20190124115648.9433-3-urezki@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190124115648.9433-3-urezki@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 24, 2019 at 12:56:48PM +0100, Uladzislau Rezki (Sony) wrote:
> commit 763b218ddfaf ("mm: add preempt points into
> __purge_vmap_area_lazy()")
> 
> introduced some preempt points, one of those is making an
> allocation more prioritized over lazy free of vmap areas.
> 
> Prioritizing an allocation over freeing does not work well
> all the time, i.e. it should be rather a compromise.
> 
> 1) Number of lazy pages directly influence on busy list length
> thus on operations like: allocation, lookup, unmap, remove, etc.
> 
> 2) Under heavy stress of vmalloc subsystem i run into a situation
> when memory usage gets increased hitting out_of_memory -> panic
> state due to completely blocking of logic that frees vmap areas
> in the __purge_vmap_area_lazy() function.
> 
> Establish a threshold passing which the freeing is prioritized
> back over allocation creating a balance between each other.

I'm a bit concerned that this will introduce the latency back if vmap_lazy_nr
is greater than half of lazy_max_pages(). Which IIUC will be more likely if
the number of CPUs is large.

In fact, when vmap_lazy_nr is high, that's when the latency will be the worst
so one could say that that's when you *should* reschedule since the frees are
taking too long and hurting real-time tasks.

Could this be better solved by tweaking lazy_max_pages() such that purging is
more aggressive?

Another approach could be to detect the scenario you brought up (allocations
happening faster than free), somehow, and avoid a reschedule?

thanks,

 - Joel

> 
> Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
> ---
>  mm/vmalloc.c | 18 ++++++++++++------
>  1 file changed, 12 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index fb4fb5fcee74..abe83f885069 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -661,23 +661,27 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
>  	struct llist_node *valist;
>  	struct vmap_area *va;
>  	struct vmap_area *n_va;
> -	bool do_free = false;
> +	int resched_threshold;
>  
>  	lockdep_assert_held(&vmap_purge_lock);
>  
>  	valist = llist_del_all(&vmap_purge_list);
> +	if (unlikely(valist == NULL))
> +		return false;
> +
> +	/*
> +	 * TODO: to calculate a flush range without looping.
> +	 * The list can be up to lazy_max_pages() elements.
> +	 */
>  	llist_for_each_entry(va, valist, purge_list) {
>  		if (va->va_start < start)
>  			start = va->va_start;
>  		if (va->va_end > end)
>  			end = va->va_end;
> -		do_free = true;
>  	}
>  
> -	if (!do_free)
> -		return false;
> -
>  	flush_tlb_kernel_range(start, end);
> +	resched_threshold = (int) lazy_max_pages() << 1;
>  
>  	spin_lock(&vmap_area_lock);
>  	llist_for_each_entry_safe(va, n_va, valist, purge_list) {
> @@ -685,7 +689,9 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
>  
>  		__free_vmap_area(va);
>  		atomic_sub(nr, &vmap_lazy_nr);
> -		cond_resched_lock(&vmap_area_lock);
> +
> +		if (atomic_read(&vmap_lazy_nr) < resched_threshold)
> +			cond_resched_lock(&vmap_area_lock);
>  	}
>  	spin_unlock(&vmap_area_lock);
>  	return true;
> -- 
> 2.11.0
> 

