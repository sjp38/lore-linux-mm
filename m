Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D92FC46470
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 21:19:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 192E5206A3
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 21:19:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="JB3/ofVK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 192E5206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 988FF6B026D; Tue,  7 May 2019 17:19:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93A2A6B026E; Tue,  7 May 2019 17:19:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DAA86B026F; Tue,  7 May 2019 17:19:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 532C26B026D
	for <linux-mm@kvack.org>; Tue,  7 May 2019 17:19:34 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id k66so838787oib.20
        for <linux-mm@kvack.org>; Tue, 07 May 2019 14:19:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=3hK5kgswQ8wv2TZkCFoSuWyjsyMg02YpSTLcE/+WG/U=;
        b=B3YrnGkfHyW7gww4AWBQuU3HxaszjWb93quG8+N5880ILHdozTYAbbKh5Z720O7B0l
         vIZMmADOQF3ymIDe/IackRkNTQbSlU/cqu5hnqvKkrmkJd+pyAzgV6zpgLqLKrish8LB
         eXiDoYHT3/Es+SN/qBZ0VkteMK4KZ7skfVbj4GooPJxqH0iF1urdUz2/0jc8xzQsLdqB
         heX3P7NsB2v7m8c+HOqBA3xrrIjY0KzgYy4J2BYkZu7+y/5O4fbTUXDfDwUgQ/UZRPI2
         o6GUYTxkO4qOmnlWbmuetYoOTuQfwabrtqSkruEMMIocXtSbKjqZKhF4Pwxchx+XoNiZ
         j2/w==
X-Gm-Message-State: APjAAAUrICvOFFG0bGjStdknI/301/Mqxpyre6h4IKIMqhZ71A9SqG/e
	WOvkp6k177OzCdbXd1BJVXr+dct1yhexv7iJDLvs03SGztXbOuKPz9z4IyjQvwpJvrus7wSUEPy
	w4x3/DglFPdifPxq4bva6dtABUc/MOYbALY+fIOhE4aQ0+yX0ABQGPVmA2OwkWiqubw==
X-Received: by 2002:a9d:5919:: with SMTP id t25mr24508129oth.133.1557263973987;
        Tue, 07 May 2019 14:19:33 -0700 (PDT)
X-Received: by 2002:a9d:5919:: with SMTP id t25mr24508077oth.133.1557263973332;
        Tue, 07 May 2019 14:19:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557263973; cv=none;
        d=google.com; s=arc-20160816;
        b=VoEbM5VGpc6B+XkPk5xD1xo/8IzlAYiQxFCECxwbBT9pu7/vBK3COcpZpbSGHT2ot0
         FF9MD7YP0EwRwcxOqPOWJdkwTXXsAAf7ob4OUJY9u6QTvlADGavqcLIDNfVBfsvLoKBz
         ksaArKRT/2jj/58D1mo3xNugKYQQ7Zr4XN6TLw01938QmT5CZVJDEwof++J/8w+Nr3t3
         j1eY+VVTQzOSsaNviq8Gbm97kSXZKuOjBBU9kJO36bplfYiTJ0JAanZgEi6dOTP+BbYV
         hZIxFDmTlckaxKGiEcY4zIUvVOXGBgCsaSWHBz4Exjqhfvwi2OtLiJFVSyCPQuTZLUCn
         SClQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=3hK5kgswQ8wv2TZkCFoSuWyjsyMg02YpSTLcE/+WG/U=;
        b=UZSIEZSJrwTmm5YqGbItvfrNWweV4cN1oS9vH1wudBrcoVD56p0Cf9zPtQ0twqsWTc
         YXE5GkCHBiihwbn9O37umeff0g2hwUP63GNux6Iuk7Lrr5C4VmdENuz9/7jMPayMvCh6
         YqORPQnYhw2F5mXU9QYr0rCI4D7DwmyW7EKoJwBk0s05Oe9U/No3EoDzznhpxAbEluhY
         LF5E4tsxnsqPR4U8Y3nkO4DMViKaXhhL96uTqgiNyPPBmZn49m6U4xQNMm8/gmxqAW3Z
         y067MnLGcUrJKfaPQCzJqgws62yDYs3MQhS9AawySL23WvY/fp2Zjok/yTykSfL9jY+z
         M/oQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="JB3/ofVK";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l5sor6732549otk.83.2019.05.07.14.19.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 14:19:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="JB3/ofVK";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3hK5kgswQ8wv2TZkCFoSuWyjsyMg02YpSTLcE/+WG/U=;
        b=JB3/ofVKMzM47vp5cpkgsnhZ8ZoLv1EVoO9+f31886li2wtHIqmVJSjWZgBJwXVWkQ
         BX8fXeuRngRf/Ks+w1ntTvElqYBed9sGLskf82OMafAfaVt9JAi0cGsgfLfsvJoqqDNr
         leYUf1Qr603j9SX7YPOMJQJ/cTCjxhAKYRdtUuxeKEq3ug1IPoCPnsVf+3r99jUb+zmR
         INxH8W2mrFhA3n0T4xrdVH8dH6T52i5DTkq3iyhP8i9MzOP7NEL5WL7OGtJR7yWG5TTZ
         DDa00gAnvg3r1yMN6dj4XSo/K//hjnmaEZqeXhVR8JHWgv3lVtO0ckrsHunC8Zyn08k4
         ovPw==
X-Google-Smtp-Source: APXvYqw7pnu1SJKRDXTAG+qXmcSugmMrCCEKA6B2yg/hWV1/XWlJZJvmUs9rNfdS4aafceF7Ulls7pnfgUmoZQnK/CQ=
X-Received: by 2002:a9d:222c:: with SMTP id o41mr23286782ota.353.1557263973069;
 Tue, 07 May 2019 14:19:33 -0700 (PDT)
MIME-Version: 1.0
References: <20190507183804.5512-1-david@redhat.com> <20190507183804.5512-6-david@redhat.com>
In-Reply-To: <20190507183804.5512-6-david@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 7 May 2019 14:19:22 -0700
Message-ID: <CAPcyv4ge1pSOopfHof4USn=7Skc-UV4Xhd_s=h+M9VXSp_p1XQ@mail.gmail.com>
Subject: Re: [PATCH v2 5/8] mm/memory_hotplug: Drop MHP_MEMBLOCK_API
To: David Hildenbrand <david@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, 
	Linux-sh <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Oscar Salvador <osalvador@suse.com>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, Wei Yang <richard.weiyang@gmail.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Qian Cai <cai@lca.pw>, Arun KS <arunks@codeaurora.org>, 
	Mathieu Malaterre <malat@debian.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 7, 2019 at 11:38 AM David Hildenbrand <david@redhat.com> wrote:
>
> No longer needed, the callers of arch_add_memory() can handle this
> manually.
>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Oscar Salvador <osalvador@suse.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Mathieu Malaterre <malat@debian.org>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  include/linux/memory_hotplug.h | 8 --------
>  mm/memory_hotplug.c            | 9 +++------
>  2 files changed, 3 insertions(+), 14 deletions(-)
>
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 2d4de313926d..2f1f87e13baa 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -128,14 +128,6 @@ extern void arch_remove_memory(int nid, u64 start, u64 size,
>  extern void __remove_pages(struct zone *zone, unsigned long start_pfn,
>                            unsigned long nr_pages, struct vmem_altmap *altmap);
>
> -/*
> - * Do we want sysfs memblock files created. This will allow userspace to online
> - * and offline memory explicitly. Lack of this bit means that the caller has to
> - * call move_pfn_range_to_zone to finish the initialization.
> - */
> -
> -#define MHP_MEMBLOCK_API               (1<<0)
> -
>  /* reasonably generic interface to expand the physical pages */
>  extern int __add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
>                        struct mhp_restrictions *restrictions);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index e1637c8a0723..107f72952347 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -250,7 +250,7 @@ void __init register_page_bootmem_info_node(struct pglist_data *pgdat)
>  #endif /* CONFIG_HAVE_BOOTMEM_INFO_NODE */
>
>  static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
> -               struct vmem_altmap *altmap, bool want_memblock)
> +                                  struct vmem_altmap *altmap)
>  {
>         int ret;
>
> @@ -293,8 +293,7 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
>         }
>
>         for (i = start_sec; i <= end_sec; i++) {
> -               err = __add_section(nid, section_nr_to_pfn(i), altmap,
> -                               restrictions->flags & MHP_MEMBLOCK_API);
> +               err = __add_section(nid, section_nr_to_pfn(i), altmap);
>
>                 /*
>                  * EEXIST is finally dealt with by ioresource collision
> @@ -1066,9 +1065,7 @@ static int online_memory_block(struct memory_block *mem, void *arg)
>   */
>  int __ref add_memory_resource(int nid, struct resource *res)
>  {
> -       struct mhp_restrictions restrictions = {
> -               .flags = MHP_MEMBLOCK_API,
> -       };
> +       struct mhp_restrictions restrictions = {};

With mhp_restrictions.flags no longer needed, can we drop
mhp_restrictions and just go back to a plain @altmap argument?

