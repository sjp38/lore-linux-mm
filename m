Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F33DEC10F05
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 08:02:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE60D21841
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 08:02:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE60D21841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D3DC6B0003; Wed, 20 Mar 2019 04:02:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5834A6B0006; Wed, 20 Mar 2019 04:02:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 470626B0007; Wed, 20 Mar 2019 04:02:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 22BA96B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 04:02:39 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id d8so20037723qkk.17
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 01:02:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=p+yOt0tmYOb1T0SJdrlrnZ7BTc5E6G47px504gC7Dy0=;
        b=CW7BL+3kmYVZGdUQn+J7xKIF3z7ZuHv0kItXjmUBmT5NCUY77aLOhSHfnfkUBtgX13
         rnVq7mA98OjQKS4y86Y2Dm4Jae3ew3VGFswn3XxXnJ70tagndoKRAXusgce7IYsIMtz0
         cPgHsZ63Okk3pYIYxoFLbi8WCJbwbjR2+0mP3cu+ViIARMxw22YUzAf0lSpKQYheQsGA
         09r8Ybi2WfvFNuvCNB8M+rItdrRBFHR7W896gi8iUcVlxWs6VPBQawmm6WB1p7WUi4sV
         PPMKNOV696G8RoDrw08GEZ40n4tHDjw45YmNCGzzO3zeRKgWQOZFGISl70QcBj4toXCF
         8R7g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXTcBztBEqj81fgoN3ocn+7DAC2PLYY17DHB/69bdo377iKMASx
	87ZaEiIer7ShgbASCKGVIqmHULwacAbzQxjKFA5hwzvjJ6Awt00HkwJmezE/NcyfVRgzrOdgBWm
	mZUYd9CzeZKw2cZ50/cNl0f2wOVdWB0KCm3mVek8NgINpdu3iHQJe4Upk43b2tBF2Lw==
X-Received: by 2002:a0c:9906:: with SMTP id h6mr5517905qvd.45.1553068958904;
        Wed, 20 Mar 2019 01:02:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGej2lWu0znMGCzJYhtoa0dj0vtl/xLoWIng7WBeJFQfxxK7IVUMyr8yaHLfy77IL90sCw
X-Received: by 2002:a0c:9906:: with SMTP id h6mr5517855qvd.45.1553068958222;
        Wed, 20 Mar 2019 01:02:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553068958; cv=none;
        d=google.com; s=arc-20160816;
        b=BGnwvFF9gCxOt1z1KHerK6C9LIjeE73X62iFke32ufQuLtf7GlyXDdSPhDNXWrFWGq
         5ODpFUZJ70QTNRtLIsL39uRr1xlhIDk9vN9lytAFYvTUP3avRg9NC7Kp6lxDCjrbbW62
         R8DabAuS3MoL2UpeQEMkNlNKYtWxmNjMftd8lQdN8/QqToeY0PxzKa07lfOY63J4D8UY
         dhLyRKy32ANuvNFMmR9lhNQ4PD0KlvoxF1Iz3J982Mrq53Nqm8SO3x690+rGKIESWKKl
         ZjStli82SNE1h9YUUOjOH9hrzuTusMWkl30pmEVVZXZEnPWG44iLPm5EltRTmMECv1uS
         KPmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=p+yOt0tmYOb1T0SJdrlrnZ7BTc5E6G47px504gC7Dy0=;
        b=da0TY4aHFI6ywfFrVHrrYm4qTjGGK4VuF1uJnfMAr+3qEKqBYe/9kyItWBpIxC2grV
         CoQMtKdASR/gLRBpgTtf8XMRYB5z+2E47ewzZPFLeZjc6IlKHbcmXbXdKhOpAtwmNuiG
         XlUHJqH+OAewq0xwOEeCOmFtY1xlE4ABc+3Dtt1B53Gdw6tkLXIOJi9QDzbBJRIYYr9A
         +t2dHMsYUt2kdHz+rwn9gqUqeVM2jkfHq0Hcgv3Yoz9FZ4+P7/TvDVqMwHCmHlqV6qTX
         QgLSyEChHlYrG8U7YvOhlQv0nuhOYmRsdMFtk9h3E7XqVmfz8oOOsa0C1iLToMT+yuVx
         z6zA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c45si769530qta.303.2019.03.20.01.02.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 01:02:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5F7E081F31;
	Wed, 20 Mar 2019 08:02:37 +0000 (UTC)
Received: from localhost (ovpn-12-38.pek2.redhat.com [10.72.12.38])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 7CBEC17DF3;
	Wed, 20 Mar 2019 08:02:36 +0000 (UTC)
Date: Wed, 20 Mar 2019 16:02:30 +0800
From: Baoquan He <bhe@redhat.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	osalvador@suse.de, mhocko@suse.com, rppt@linux.vnet.ibm.com,
	richard.weiyang@gmail.com, linux-mm@kvack.org
Subject: Re: [PATCH] mm/sparse: Rename function related to section memmap
 allocation/free
Message-ID: <20190320080230.GL18740@MiWiFi-R3L-srv>
References: <20190320075301.13994-1-bhe@redhat.com>
 <20190320075908.GD13626@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320075908.GD13626@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 20 Mar 2019 08:02:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/20/19 at 09:59am, Mike Rapoport wrote:
> On Wed, Mar 20, 2019 at 03:53:01PM +0800, Baoquan He wrote:
> > These functions are used allocate/free section memmap, have nothing
> > to do with kmalloc/free during the handling. Rename them to remove
> > the confusion.
> > 
> > Signed-off-by: Baoquan He <bhe@redhat.com>
> 
> Acked-by: Mike Rapoport <rppt@linux.ibm.com>

Thanks for reviewing, Mike. I makde mistake to send this one twice.
You can see it has been added into the patchset. Anyway, I will add your
'Acked-by' when repost to address those issues you pointed out.

Thanks
Baoquan

> 
> > ---
> >  mm/sparse.c | 18 +++++++++---------
> >  1 file changed, 9 insertions(+), 9 deletions(-)
> > 
> > diff --git a/mm/sparse.c b/mm/sparse.c
> > index 054b99f74181..374206212d01 100644
> > --- a/mm/sparse.c
> > +++ b/mm/sparse.c
> > @@ -579,13 +579,13 @@ void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
> >  #endif
> > 
> >  #ifdef CONFIG_SPARSEMEM_VMEMMAP
> > -static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
> > +static inline struct page *alloc_section_memmap(unsigned long pnum, int nid,
> >  		struct vmem_altmap *altmap)
> >  {
> >  	/* This will make the necessary allocations eventually. */
> >  	return sparse_mem_map_populate(pnum, nid, altmap);
> >  }
> > -static void __kfree_section_memmap(struct page *memmap,
> > +static void __free_section_memmap(struct page *memmap,
> >  		struct vmem_altmap *altmap)
> >  {
> >  	unsigned long start = (unsigned long)memmap;
> > @@ -603,7 +603,7 @@ static void free_map_bootmem(struct page *memmap)
> >  }
> >  #endif /* CONFIG_MEMORY_HOTREMOVE */
> >  #else
> > -static struct page *__kmalloc_section_memmap(void)
> > +static struct page *__alloc_section_memmap(void)
> >  {
> >  	struct page *page, *ret;
> >  	unsigned long memmap_size = sizeof(struct page) * PAGES_PER_SECTION;
> > @@ -624,13 +624,13 @@ static struct page *__kmalloc_section_memmap(void)
> >  	return ret;
> >  }
> > 
> > -static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
> > +static inline struct page *alloc_section_memmap(unsigned long pnum, int nid,
> >  		struct vmem_altmap *altmap)
> >  {
> > -	return __kmalloc_section_memmap();
> > +	return __alloc_section_memmap();
> >  }
> > 
> > -static void __kfree_section_memmap(struct page *memmap,
> > +static void __free_section_memmap(struct page *memmap,
> >  		struct vmem_altmap *altmap)
> >  {
> >  	if (is_vmalloc_addr(memmap))
> > @@ -701,7 +701,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
> >  	usemap = __kmalloc_section_usemap();
> >  	if (!usemap)
> >  		return -ENOMEM;
> > -	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
> > +	memmap = alloc_section_memmap(section_nr, nid, altmap);
> >  	if (!memmap) {
> >  		kfree(usemap);
> >  		return -ENOMEM;
> > @@ -726,7 +726,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
> >  out:
> >  	if (ret < 0) {
> >  		kfree(usemap);
> > -		__kfree_section_memmap(memmap, altmap);
> > +		__free_section_memmap(memmap, altmap);
> >  	}
> >  	return ret;
> >  }
> > @@ -777,7 +777,7 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap,
> >  	if (PageSlab(usemap_page) || PageCompound(usemap_page)) {
> >  		kfree(usemap);
> >  		if (memmap)
> > -			__kfree_section_memmap(memmap, altmap);
> > +			__free_section_memmap(memmap, altmap);
> >  		return;
> >  	}
> > 
> > -- 
> > 2.17.2
> > 
> 
> -- 
> Sincerely yours,
> Mike.
> 

