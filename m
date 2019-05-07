Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3B4EC04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 20:46:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9AE2220825
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 20:46:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="rqW6lucK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AE2220825
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EB926B0003; Tue,  7 May 2019 16:46:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 274FD6B0006; Tue,  7 May 2019 16:46:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13D456B0007; Tue,  7 May 2019 16:46:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id DACB16B0003
	for <linux-mm@kvack.org>; Tue,  7 May 2019 16:46:20 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id l107so9884532otc.9
        for <linux-mm@kvack.org>; Tue, 07 May 2019 13:46:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Fw0JPQ4oQ07pMZfSEOmqFo0Ax/JNe6lqDNiuIeW+cfk=;
        b=iD5jYHzSzDo+V3w8mGPMSQZhT9LtVBgvyV0EmwqQSkVuZ4vpaH+CWnYrvXw0IIL9Sl
         Y2DeiZWD13ORZTDGmpBOwJFE4PBZwkVW5iOOltWQLZuwHrPtYW4qIQQjEHvLzcyr8hgR
         w+uDq9uiedclY80gPyUILH2yNt57NzW+nyJDrsqkv3dZSvsDqz17oi1UkdrNI7WbPvZW
         EDDz2bRG4jLE2WNP5+5c5HHIfJ+g0ssFaLYVjUxGSfycV3aObPnopRDsE3ZUA0ik4XOE
         /0CTwh0loeixeAbEQz492CZnoWvK1RIwGT6SIh6zjALKUpyXeJuqwqwLK/HXXcsxKFvy
         3VNw==
X-Gm-Message-State: APjAAAXuDdJimYsQQGG05YFIv62B6Xg4cI9rjG8xxelV1NaspNvsc/5W
	HAIEO6T8nI20Ejt3okzLCYc/vv+DjwF0HWmbexR+u5Je7LM5BpZy/dOR9EXc+c99mP9U3eUS2u2
	9K9KgZe/Vh7Yd85ofLjtZ69LG8/GHab+UzXOW+k1CGlCqEm8s6m25tL+5/YjJ1V+lqQ==
X-Received: by 2002:aca:fccf:: with SMTP id a198mr253551oii.69.1557261980590;
        Tue, 07 May 2019 13:46:20 -0700 (PDT)
X-Received: by 2002:aca:fccf:: with SMTP id a198mr253527oii.69.1557261979843;
        Tue, 07 May 2019 13:46:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557261979; cv=none;
        d=google.com; s=arc-20160816;
        b=FE4uUfSpZBnhj5nWdSl3qS7YB0KnnZrxjJyvIZTyUxuifyez2CWkEc7uu7jZswDqFC
         jclgpAQOZLiML4HFRLHIITCcRQwSWZFjMh3ikwaECkA2sWYBZQj2n76aR9MWjemNNtqu
         LwIHzKn56zB0K9pZujAHSzdCwqadUdFJPLKsZOe2DSKUSTR2lJm6660+R2QonlHJZ8es
         WgOYF2Oxh50kBLkavHofUbjupnO7hskvSpg1THW9REqkARIJA0q1JFAptLJzT4M1WLFM
         2D8T20fkgDz/DMfaHxg4jSxX8ZMs0d22VK11oKl2qdEbGc3/p/qOdl+WrNrFl39/OZy8
         ptmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Fw0JPQ4oQ07pMZfSEOmqFo0Ax/JNe6lqDNiuIeW+cfk=;
        b=kciQ1HK+HzBs7NQ1w+jAns3CAoXwygrKwBRdQz4RuIl3ZxI1ahMChhgH0/ZsmNPSa9
         AcpNcxVVFxrYfqT1ZlimhQaMjTIaY8EvyQi44TP3DknqFvI3kUeIyroT6tgwtx3BpAj5
         IqGhfQ6UymExUNfCRxrr+PvntPviXodxg/Br5raDAoDq9Z0Idwms1++I9600tBSgNZ/o
         Q6eaB7I9T5Ge3rbENxnbvozpXNiI54dxwq4VMkesPWnitw3lyJ9ajXrokog3MKe5m3nn
         svuU/vKLq+aY8rhHIEkaN2PLDNUHAF+ebfKL2vClzybIDdxl/FXPuEY99/KCBZPyW3Yw
         Pmpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=rqW6lucK;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m10sor6616279otl.112.2019.05.07.13.46.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 13:46:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=rqW6lucK;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Fw0JPQ4oQ07pMZfSEOmqFo0Ax/JNe6lqDNiuIeW+cfk=;
        b=rqW6lucK5GLSkk6D3VC83NNNr3p5l4cDVk4n80Uvm322BBV2qCuKSPr4z+P2ezcoyK
         z+YMgkO0V+5hEmcMr0MwF6O3QHG8xWVY2eTA1Py3k6awm18aqMlPP98eZujqBEdbRRXN
         aS93k1uMcPJFXIHF98HnDfB8WCQgSAWAn+PzoKcCdVTC+uJmNJ+7TTcrUEmBZNFgGikS
         JoN377FDE4nzpHgH/fCwVvnpugUJXF2ApAVZaCrgrLXf7ZjFcE/OLNwmWNUpvbW/wIQU
         Uwg4mKk8U4/mWeh5D1XY1VYZpFjHtv4IPmwLoWQVjBRPrwTp5axa3EA9O5FG/AT874cG
         VNvQ==
X-Google-Smtp-Source: APXvYqwkL7vHIYJxD+HfiXZUkr4PGh3XR7bd+koUKuRLubXL7y6kGEyKk74Z2RGz0ad/moc44qYziRyn+VmkpRZHHO8=
X-Received: by 2002:a9d:6f19:: with SMTP id n25mr2402081otq.367.1557261979262;
 Tue, 07 May 2019 13:46:19 -0700 (PDT)
MIME-Version: 1.0
References: <20190507183804.5512-1-david@redhat.com> <20190507183804.5512-3-david@redhat.com>
In-Reply-To: <20190507183804.5512-3-david@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 7 May 2019 13:46:08 -0700
Message-ID: <CAPcyv4gtAMn2mDz0s1GRTJ52MeTK3jJYLQne6MiEx_ipPFUsmA@mail.gmail.com>
Subject: Re: [PATCH v2 2/8] s390x/mm: Implement arch_remove_memory()
To: David Hildenbrand <david@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, 
	Linux-sh <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, 
	Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Vasily Gorbik <gor@linux.ibm.com>, Oscar Salvador <osalvador@suse.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 7, 2019 at 11:38 AM David Hildenbrand <david@redhat.com> wrote:
>
> Will come in handy when wanting to handle errors after
> arch_add_memory().
>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Vasily Gorbik <gor@linux.ibm.com>
> Cc: Oscar Salvador <osalvador@suse.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  arch/s390/mm/init.c | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
>
> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
> index 31b1071315d7..1e0cbae69f12 100644
> --- a/arch/s390/mm/init.c
> +++ b/arch/s390/mm/init.c
> @@ -237,12 +237,13 @@ int arch_add_memory(int nid, u64 start, u64 size,
>  void arch_remove_memory(int nid, u64 start, u64 size,
>                         struct vmem_altmap *altmap)
>  {
> -       /*
> -        * There is no hardware or firmware interface which could trigger a
> -        * hot memory remove on s390. So there is nothing that needs to be
> -        * implemented.
> -        */
> -       BUG();
> +       unsigned long start_pfn = start >> PAGE_SHIFT;
> +       unsigned long nr_pages = size >> PAGE_SHIFT;
> +       struct zone *zone;
> +
> +       zone = page_zone(pfn_to_page(start_pfn));

Does s390 actually support passing in an altmap? If 'yes', I think it
also needs the vmem_altmap_offset() fixup like x86-64:

        /* With altmap the first mapped page is offset from @start */
        if (altmap)
                page += vmem_altmap_offset(altmap);

...but I suspect it does not support altmap since
arch/s390/mm/vmem.c::vmemmap_populate() does not arrange for 'struct
page' capacity to be allocated out of an altmap defined page pool.

I think it would be enough to disallow any arch_add_memory() on s390
where @altmap is non-NULL. At least until s390 gains ZONE_DEVICE
support and can enable the pmem use case.

