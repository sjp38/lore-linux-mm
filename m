Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 653E1C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 15:05:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A42420850
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 15:05:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A42420850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 981108E0004; Fri,  1 Mar 2019 10:05:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 930868E0001; Fri,  1 Mar 2019 10:05:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 820EB8E0004; Fri,  1 Mar 2019 10:05:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 290508E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 10:05:13 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id k21so7221226eds.19
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 07:05:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=NQN9Xde2IY7gXlIGuPSW2EqM0dii3XmCEhF9nciEJJU=;
        b=MNBhADmMt/csmZqMmeQKQYAGL7wlt0k7FxeOaVBmwP7oXAPE3ePxSaAT18AcAP4qq/
         itpvVlmNd0iHPnAAvpXyRWraGDydp6Fa47fXxR2QBR/7aiUqFhAiy/bTfZdwY8eMr0EW
         4h3nHonaqu8brSzt69on01IGOXbqokYXIxizyrbOnRzwPv5PCKLx/teXWPWWyz4zO9R3
         QR/et88iTSopOiNCv1p3iU4au1Xa/k3pc3ywnkrEnfUohSJKJknSVD4aKqEKLc15d0YJ
         fxW1UsTmvGmjX2uSK4tgtvpmV0/ZN7PPjv3eqH1S3Tu0g447hqqTTgEufhbqvr6Hu44l
         mWZA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAXKArEMeK73yfUrrLfQYl32/+nCWOsEEEdAbsma/ztHaOq3bKzB
	7tM2gAktet1GP9uB8lXozTRuCSG646+rNbq8Y389rxu0SACIRqKMgS1z79g7AcRevoIcE9fALFd
	Ar/iPEKwnnPYRHDQYSPzxJqOWoBZgbGgIid48VCm2CjJkVUWCnpbJiGeiEsYhLIFPPg==
X-Received: by 2002:a50:b6db:: with SMTP id f27mr4353715ede.188.1551452712705;
        Fri, 01 Mar 2019 07:05:12 -0800 (PST)
X-Google-Smtp-Source: APXvYqylXTbDiLo9zPSu8flyF/o+gYsn1SEUMRCDm0f1WnUivvFgwHd5QMqe6xOt5u75tvbgtr94
X-Received: by 2002:a50:b6db:: with SMTP id f27mr4353654ede.188.1551452711642;
        Fri, 01 Mar 2019 07:05:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551452711; cv=none;
        d=google.com; s=arc-20160816;
        b=I+OzB6zXcDlkIDtFV968Bq5gWiCbOhgE9FDRFmeZCCiGThARS7zs673BbrCJQ8lN2c
         FMxoxa7isLgCjY018whKpXrFKjpMbeJ6zUTT86rh76ljXPeswBlSh2t2IJPERhhNhbnz
         TcuUqVkB0kAV/aILeq6yln/Nb6d9QGrJzRpNrzsbMQeYRwmyRdmj8zX2KMITHSLGflbm
         UfUU6AMIt8iCTi3fw57RGRmE9my1+w3WSpVTnEdY//9/77MtSArXX0GltDX/man2u8/e
         n7tTFKgk2qktpWaX/k1MgkEukYFwqdCUWxKhZUcKWWTLqVmYZnX56GVQDR+mbkmLucEC
         AbJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=NQN9Xde2IY7gXlIGuPSW2EqM0dii3XmCEhF9nciEJJU=;
        b=aONOrU4O1rb98hWQCYTyRwbRQ2dZHZ1KlwC0LdXoU58Ywo2QH26fFRufKY7QJ/w7Jo
         7YlWboZMQUaCkV0hqSJMnewy0L5+z1P0JzMIcI3XBgPQ+iCo7EPzgV2FzHfh9xNi2AI+
         /jyaNPE1fYcnThC4Kejr6BazY3VIXomge1PLZGbFE1e6VlgY7hVpl/jSujdztS5otZrw
         FLmYbZT4AvFoFfwp2+fZSEYfJhlIU195kE+JxYQiHPVgjNEMFlBOZBjAbEPVDHtRGjPS
         M8hAKf7fjxUlB58Q0uzgMg4MpJtWqk0Ey6LCnnmqnCwvGueSE/hpez1q5fwEV2XfI8Fh
         KnGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m48si902514edd.347.2019.03.01.07.05.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 07:05:11 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0FF77AC91;
	Fri,  1 Mar 2019 15:05:11 +0000 (UTC)
Subject: Re: [PATCH 3/3] mm: show number of vmalloc pages in /proc/meminfo
To: Roman Gushchin <guroan@gmail.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>,
 Johannes Weiner <hannes@cmpxchg.org>, kernel-team@fb.com,
 Roman Gushchin <guro@fb.com>, Linus Torvalds
 <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>
References: <20190225203037.1317-1-guro@fb.com>
 <20190225203037.1317-4-guro@fb.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <3321e666-acb7-d037-0140-ee107625e5a6@suse.cz>
Date: Fri, 1 Mar 2019 16:05:10 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190225203037.1317-4-guro@fb.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/25/19 9:30 PM, Roman Gushchin wrote:
> Vmalloc() is getting more and more used these days (kernel stacks,
> bpf and percpu allocator are new top users), and the total %
> of memory consumed by vmalloc() can be pretty significant
> and changes dynamically.
> 
> /proc/meminfo is the best place to display this information:
> its top goal is to show top consumers of the memory.
> 
> Since the VmallocUsed field in /proc/meminfo is not in use
> for quite a long time (it has been defined to 0 by the
> commit a5ad88ce8c7f ("mm: get rid of 'vmalloc_info' from
> /proc/meminfo")), let's reuse it for showing the actual

Hm that commit is not that old (2015) and talks about two caching
approaches from Linus and Ingo, so CCing them here for input, as
apparently it was not deemed worth the trouble at that time.

> physical memory consumption of vmalloc().
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  fs/proc/meminfo.c       |  2 +-
>  include/linux/vmalloc.h |  2 ++
>  mm/vmalloc.c            | 10 ++++++++++
>  3 files changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
> index 568d90e17c17..465ea0153b2a 100644
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -120,7 +120,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
>  	show_val_kb(m, "Committed_AS:   ", committed);
>  	seq_printf(m, "VmallocTotal:   %8lu kB\n",
>  		   (unsigned long)VMALLOC_TOTAL >> 10);
> -	show_val_kb(m, "VmallocUsed:    ", 0ul);
> +	show_val_kb(m, "VmallocUsed:    ", vmalloc_nr_pages());
>  	show_val_kb(m, "VmallocChunk:   ", 0ul);
>  	show_val_kb(m, "Percpu:         ", pcpu_nr_pages());
>  
> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> index 398e9c95cd61..0b497408272b 100644
> --- a/include/linux/vmalloc.h
> +++ b/include/linux/vmalloc.h
> @@ -63,10 +63,12 @@ extern void vm_unmap_aliases(void);
>  
>  #ifdef CONFIG_MMU
>  extern void __init vmalloc_init(void);
> +extern unsigned long vmalloc_nr_pages(void);
>  #else
>  static inline void vmalloc_init(void)
>  {
>  }
> +static inline unsigned long vmalloc_nr_pages(void) { return 0; }
>  #endif
>  
>  extern void *vmalloc(unsigned long size);
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index f1f19d1105c4..3a1872ee8294 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -340,6 +340,13 @@ static unsigned long cached_align;
>  
>  static unsigned long vmap_area_pcpu_hole;
>  
> +static atomic_long_t nr_vmalloc_pages;
> +
> +unsigned long vmalloc_nr_pages(void)
> +{
> +	return atomic_long_read(&nr_vmalloc_pages);
> +}
> +
>  static struct vmap_area *__find_vmap_area(unsigned long addr)
>  {
>  	struct rb_node *n = vmap_area_root.rb_node;
> @@ -1566,6 +1573,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
>  			BUG_ON(!page);
>  			__free_pages(page, 0);
>  		}
> +		atomic_long_sub(area->nr_pages, &nr_vmalloc_pages);
>  
>  		kvfree(area->pages);
>  	}
> @@ -1742,12 +1750,14 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>  		if (unlikely(!page)) {
>  			/* Successfully allocated i pages, free them in __vunmap() */
>  			area->nr_pages = i;
> +			atomic_long_add(area->nr_pages, &nr_vmalloc_pages);
>  			goto fail;
>  		}
>  		area->pages[i] = page;
>  		if (gfpflags_allow_blocking(gfp_mask|highmem_mask))
>  			cond_resched();
>  	}
> +	atomic_long_add(area->nr_pages, &nr_vmalloc_pages);
>  
>  	if (map_vm_area(area, prot, pages))
>  		goto fail;
> 

