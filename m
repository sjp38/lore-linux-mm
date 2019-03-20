Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B12F1C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:58:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AA72218D4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:58:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AA72218D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F6D56B0007; Wed, 20 Mar 2019 03:58:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07E406B0008; Wed, 20 Mar 2019 03:58:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E60606B000A; Wed, 20 Mar 2019 03:58:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB70F6B0007
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 03:58:03 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id n13so1582295qtn.6
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 00:58:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=aE+38KfGc5qk2HKsb2RamJkVjg1qYYeZB6p5zW8nMwI=;
        b=iW7nA3hej05nfK9bHHO1HpgNiM0XDR/NCiQMbE8h9q27XcDDxWt0PGUlz716we0GZ9
         eQWCYWGalwe70vTEKFq/G2USQPYoR/4iRM+LSWSB/yoZQSKa1lY/ywXlGnaTCq1kLG6/
         Fmn/nGdnEkaSj7niN94+GpO6sxwiJGj9jj5nzKP3kcaWrrdFux/wVJbMCI0bcdsRBoL4
         aGXybpYuA0nbGJ3LE3f6X1DleM5HYpgx5ke8GOOuq1fGtJZXOisPvDSZRnSNRv+GRPTl
         QU+IQ/JzdU37LO/9hpXUmtJqgCvPW6iP9RECV12iQWUR0G4FVw8IS8pp0o8PAvu42XIu
         +LeA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUzMbmKK7ns8iiTMEjVqtj4H3wtUNCqy7sYpmB1si3OUJfyxpgW
	GA31fqAz+KDQjywZhSOF27sS6ktpx+K6t716yODo9RcOgwKCz8UHOuvIcw302z11VDmeOLpuH8q
	OLsO28PGdJDyS3sce+GbbqXuadgRnlPDhHk51/uE/tbNFyJzP8HN7/fOXnHOfxvkHsA==
X-Received: by 2002:ac8:2f1b:: with SMTP id j27mr1352580qta.263.1553068683546;
        Wed, 20 Mar 2019 00:58:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqGHV774GldBO1lytyB1bEzF1JwShR+fSb6qp3a4q410sV8AMy+6/XfafSNgRGgYg6gqvf
X-Received: by 2002:ac8:2f1b:: with SMTP id j27mr1352558qta.263.1553068682874;
        Wed, 20 Mar 2019 00:58:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553068682; cv=none;
        d=google.com; s=arc-20160816;
        b=ZmOkVZXtllblJDZWkj4kmRG36DSZBLo6zw8saMFFg4Vl3TRRxPanrEA+rdHNp2m0bN
         gK/q9+1vK4Lwjos7A0yuTMiUio5ewBGVItlQvB6us7Q7/8PXqEsJUNqkAm6vm+X6IMiI
         w5TJeA53rnISNKu6VEDnOCzi2rm8Opi3cXBq/Zu262jW3v9/tTeVKN+E49yDvy5IDo2+
         +4XlSaj9e0kVvoJWw/3fCEQOieZLtzvnQgh0VFc6QflZEC2ahEEn+TQpB+OoHNUmqBz7
         IsZJu8r7pCcBxvGhDd8194Dpo0lsepw00KI0RZFSqpRcEmY596e2y/p7zN+4VPsllMSI
         bioA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=aE+38KfGc5qk2HKsb2RamJkVjg1qYYeZB6p5zW8nMwI=;
        b=zEJttk9iNAgPZIUYEtLuJiKhEW9jfXIMQyUHlzovJsfFyIqo7s3Jna2qDml8KdQMHQ
         sY6lS5ogAhLwtExI+F3ccX0/QB98EwYFefTO/GL0OqOtoPmD0KraMROKTD297TfO2oma
         VhsNruPmbmEeOdT8pwtGewPaSpPKqBBMOy7ljxmz/l3UcF+iBDvJKFXc64+i4JsNHQda
         edgVqiuDplT8HI5q2IURjNGsydOIUsdTlYthPJuBxN6Jnlghwzm56tnz83B15a3ELdpI
         hogWoMPpd3ON9Lyb/OlC3Hk3J4sZwu5ZSCm/f6NZceH7rU0go6mpbZt38mevKsdqQflF
         eatQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w21si802433qth.249.2019.03.20.00.58.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 00:58:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F400130820DD;
	Wed, 20 Mar 2019 07:58:01 +0000 (UTC)
Received: from localhost (ovpn-12-38.pek2.redhat.com [10.72.12.38])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5F4FD6058F;
	Wed, 20 Mar 2019 07:58:01 +0000 (UTC)
Date: Wed, 20 Mar 2019 15:57:59 +0800
From: Baoquan He <bhe@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, osalvador@suse.de, mhocko@suse.com,
	rppt@linux.vnet.ibm.com, richard.weiyang@gmail.com,
	linux-mm@kvack.org
Subject: Re: [PATCH] mm/sparse: Rename function related to section memmap
 allocation/free
Message-ID: <20190320075759.GJ18740@MiWiFi-R3L-srv>
References: <20190320075301.13994-1-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320075301.13994-1-bhe@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Wed, 20 Mar 2019 07:58:02 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/20/19 at 03:53pm, Baoquan He wrote:
> These functions are used allocate/free section memmap, have nothing
> to do with kmalloc/free during the handling. Rename them to remove
> the confusion.

Sorry, wrong git operation caused this one sent. I intended to send out
other single patch.

Please ignore this one. It has been included in previous patchset.


> 
> Signed-off-by: Baoquan He <bhe@redhat.com>
> ---
>  mm/sparse.c | 18 +++++++++---------
>  1 file changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 054b99f74181..374206212d01 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -579,13 +579,13 @@ void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
>  #endif
>  
>  #ifdef CONFIG_SPARSEMEM_VMEMMAP
> -static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
> +static inline struct page *alloc_section_memmap(unsigned long pnum, int nid,
>  		struct vmem_altmap *altmap)
>  {
>  	/* This will make the necessary allocations eventually. */
>  	return sparse_mem_map_populate(pnum, nid, altmap);
>  }
> -static void __kfree_section_memmap(struct page *memmap,
> +static void __free_section_memmap(struct page *memmap,
>  		struct vmem_altmap *altmap)
>  {
>  	unsigned long start = (unsigned long)memmap;
> @@ -603,7 +603,7 @@ static void free_map_bootmem(struct page *memmap)
>  }
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
>  #else
> -static struct page *__kmalloc_section_memmap(void)
> +static struct page *__alloc_section_memmap(void)
>  {
>  	struct page *page, *ret;
>  	unsigned long memmap_size = sizeof(struct page) * PAGES_PER_SECTION;
> @@ -624,13 +624,13 @@ static struct page *__kmalloc_section_memmap(void)
>  	return ret;
>  }
>  
> -static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
> +static inline struct page *alloc_section_memmap(unsigned long pnum, int nid,
>  		struct vmem_altmap *altmap)
>  {
> -	return __kmalloc_section_memmap();
> +	return __alloc_section_memmap();
>  }
>  
> -static void __kfree_section_memmap(struct page *memmap,
> +static void __free_section_memmap(struct page *memmap,
>  		struct vmem_altmap *altmap)
>  {
>  	if (is_vmalloc_addr(memmap))
> @@ -701,7 +701,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>  	usemap = __kmalloc_section_usemap();
>  	if (!usemap)
>  		return -ENOMEM;
> -	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
> +	memmap = alloc_section_memmap(section_nr, nid, altmap);
>  	if (!memmap) {
>  		kfree(usemap);
>  		return -ENOMEM;
> @@ -726,7 +726,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>  out:
>  	if (ret < 0) {
>  		kfree(usemap);
> -		__kfree_section_memmap(memmap, altmap);
> +		__free_section_memmap(memmap, altmap);
>  	}
>  	return ret;
>  }
> @@ -777,7 +777,7 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap,
>  	if (PageSlab(usemap_page) || PageCompound(usemap_page)) {
>  		kfree(usemap);
>  		if (memmap)
> -			__kfree_section_memmap(memmap, altmap);
> +			__free_section_memmap(memmap, altmap);
>  		return;
>  	}
>  
> -- 
> 2.17.2
> 

