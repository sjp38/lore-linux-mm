Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20A22C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:55:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D20D02146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:55:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D20D02146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 738726B0003; Wed, 20 Mar 2019 03:55:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E8086B0006; Wed, 20 Mar 2019 03:55:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FE686B0007; Wed, 20 Mar 2019 03:55:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3EB406B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 03:55:20 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id d49so1568864qtk.8
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 00:55:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=EkQoGWxx7L4z4o1mlMk8I8652LlgSIOpYnDpXFCYYH8=;
        b=C8/TMll1XwU+SWQYm86k5Fag60pfGyCUEhyrM5sWXj0l2NqOBxKzmva+H1q5qHw/d6
         zygEnAp/GOhYO3Yc5a9D/IrQL5Xgx0UMIypXd7dwneVi0qxWEUwL3gFRCQIeWWTjnAqo
         XxbFkoGbDmG5Z5vcec8aAua86uZwY3OALMLYVjyrcGgUqELif/idarRVylg5MJ/yRK+w
         7LHBjXxumrqOM23xmH9/qUr2foTLDPKg6aX2L2HGFGC8E9Bafl/vynRtu6X9nkc7Btxa
         fcNtTGPhuN55UceZrnSoS3ZM+jtSIbpg5XQCnIAzQUIWi9mzeZBUfwB7WTIZsZYxXMKV
         5JNA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUv3G2vN90e6PixHXP1F424V3OA7Vb3KXWvC0b/5E2TH4WomTrp
	/M7dPRNat3N7utWZ5ayiHZ0eIE+DESrB4MagTIpWh6hCkhVmmDQF8+/Tem8eVWj4mMr4ZG0X0ZF
	Awi7kcW5FMczE8tTZy9AUUjTTOzwomXovGEq2DWqBIZZ3LYSUkQykGDUZUw6mX2W+bw==
X-Received: by 2002:a0c:92e7:: with SMTP id c36mr5515010qvc.80.1553068520017;
        Wed, 20 Mar 2019 00:55:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgdzjEQAfBvOsmpw1QXClM6ZEBPTkxlU/zsgObznGu1KiLkkVZbQWQDX3/8RPZpF7EKSmJ
X-Received: by 2002:a0c:92e7:: with SMTP id c36mr5514957qvc.80.1553068519006;
        Wed, 20 Mar 2019 00:55:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553068519; cv=none;
        d=google.com; s=arc-20160816;
        b=NNAUEZXXrttFPvFNBspyTNW2I7tLZO3xCF8hVUQy7Q4H90XxDbzyKNT/kcP+SG06eY
         70wnIeSoMk3Zqz5VoArmzK5xrkBqgazK7O4Ht471zL3uNLnkDq+H3qsH0eHh8s+6g3xK
         eP1YjR1M0wecIAur/2oYBW74YWPFNtmomMy1KW5LRZNXXPSpFrUG81xgPl2iaipsMjaZ
         J8B6exu5G+EPsZHOSJXcPbgC+VSn7lq0ID4xeuwznctQZfbubxpR/Jtmc9u12SuDobDv
         8x7AhWjrlvdmkodRQmPb3wCkhrFX6cYEdHhqurQXJDnOd+Q8TQLyOHZmqv82tQem0Qtd
         WFtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=EkQoGWxx7L4z4o1mlMk8I8652LlgSIOpYnDpXFCYYH8=;
        b=WMlJQznB5IQG7emUAOLp7Ou2J2PPDWUjfyAxRxP1+jehIJhWGOjILASMzUjLg0lE5V
         NnDjfoxNMCk9VZUAUzN3OyDGMAiLt4HUVwNM26+I4sPZt3aH9p0gStYsk+eMfeKiDl/a
         5+GpjUTRkTYhw3jLJvEJBWy2wtBXHA6dIYxu/iEXyPyrdO8J+FPPDuCNwlNzcGeiCs4M
         fzMLJw79fHojZLWYjRoyB9+erFfvmCspLyV3jYEH7ycvxmyhd7/mYF5k4DUPnPBHgDWD
         KYR4JLEVj5wcsd8bxEuGxbPVxNdQXxv5QIA/v8S31OZZjB3gYfhFWmWe5hKSkaADSTXy
         YV6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b47si786818qtc.43.2019.03.20.00.55.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 00:55:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 26FBC307D911;
	Wed, 20 Mar 2019 07:55:18 +0000 (UTC)
Received: from localhost (ovpn-12-38.pek2.redhat.com [10.72.12.38])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 610765D9C4;
	Wed, 20 Mar 2019 07:55:16 +0000 (UTC)
Date: Wed, 20 Mar 2019 15:55:14 +0800
From: Baoquan He <bhe@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, osalvador@suse.de, mhocko@suse.com,
	rppt@linux.vnet.ibm.com, richard.weiyang@gmail.com,
	linux-mm@kvack.org
Subject: Re: [PATCH] mm/sparse: Rename function related to section memmap
 allocation/free
Message-ID: <20190320075514.GI18740@MiWiFi-R3L-srv>
References: <20190320075301.13994-1-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320075301.13994-1-bhe@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Wed, 20 Mar 2019 07:55:18 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/20/19 at 03:53pm, Baoquan He wrote:
> These functions are used allocate/free section memmap, have nothing
                          ^ 'to' missed here, will update later.
> to do with kmalloc/free during the handling. Rename them to remove
> the confusion.
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

