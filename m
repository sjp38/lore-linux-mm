Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6F5CC48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 10:29:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74A4D214DA
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 10:29:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74A4D214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C402A6B0003; Tue, 25 Jun 2019 06:29:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C20928E0003; Tue, 25 Jun 2019 06:29:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A903C8E0002; Tue, 25 Jun 2019 06:29:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 838FF6B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 06:29:07 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id h47so20301892qtc.20
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 03:29:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=443X608BzxXnVe6yF4xP655Rl5akVeNC0ApPjcl5GZ8=;
        b=oxRcqOWco6xIaYfYr4nlzs63GBbnX2kqlLlbeAho17Y2rteRvo0NPswS7eHauYzLjI
         HhswmZti2YyDSwt+OJFKVOLnLTgi//uq1tVxcH1LS6UcYSU3KnbLc69iR9cHwxY9A5yt
         +3kXJb4lhyctvoE6NvjvCj19OBYli7fXxInE+uwM9cpaoS8kInkAkQmsl3/KC+yFFbWe
         u1C5YbOoES32zPVRMmKQhFYWYERmBAXBHMjGUFUr8yR+2YRhxMnJRAtxD8WxFZO6r5e7
         g2rsIHBYrmVbL5CQ7cScH52esromuIdiqr/Pokoilm1KC1+/8P2XlsIKlq5kMOPxkMHU
         Ceew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXmhLLtAMeIqWE1r7OMPvZngDzaYHUT2P1n6756haJZyhiFJdcf
	R2dtatjcDkw10lUF/orCYIyEkiv7IsxiOkisf5OnO44fcV+cR9ULCNxVHKpUKGIezuvjK0Zyrmt
	j5P4Rkdm9f8CzMTm+K5OeUsD8oGouhSXCZq3zJS1F0YT4+t8zxsi6UGr3z2m0jRH7Yw==
X-Received: by 2002:a37:4d06:: with SMTP id a6mr1231437qkb.298.1561458547314;
        Tue, 25 Jun 2019 03:29:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwh25GJ7qrd+icW8uxZcL5YAy0ET0uFIw98fkeZcfscuhNSA7UpoPw3MGdiEov7jpUNZ4+G
X-Received: by 2002:a37:4d06:: with SMTP id a6mr1231396qkb.298.1561458546504;
        Tue, 25 Jun 2019 03:29:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561458546; cv=none;
        d=google.com; s=arc-20160816;
        b=SZhTRxIHPFlcg1OBktu2R7KJmMN0lsyVq5eEv/1YZe7rSSYl1fVYwO5EZh3KR2Pcvs
         bvP+Gjnc+tQPaeRWkdJIzqL2e5n8uFVRmiDYzvFsFxUqtkpKuKrK6lk7VKyRZLLNs9R+
         qxRbiy6bLFhKoH0thvHW/gKWiAFuLOPLeuzhX/XvvGyeFZ6kpTWCn3LtWJeukHMLT319
         gnXERXUORu44B9ikvsKwgvvedDPHSLV1Ijz+WBha3BLh5HhSsnuJv0/uUlrdlKbp/Yoy
         7oR5JBYPPuzHnJ+kOHxTRZEVzgmgAFquunDcHqg3j5jYAbRp6PArkK08K8ZfHhbaMwZ5
         my+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=443X608BzxXnVe6yF4xP655Rl5akVeNC0ApPjcl5GZ8=;
        b=SrX9JGn4CHouKZxhPPen9LQDX9/ADRmvNwrwTehT5ijv4gYxfxev76KlNMLDXFuLGV
         S4FmIfaENZqrZd7TwY52Fg8vI1TpCOivLnXMUUQVk568sO06Zksl2Domo4aqLovjfu3/
         q3CHIjiCiG0RXucAcmXc8aGU54XudUcdFNZHBKCR681xUpoOIGzC/9TvqKOM9ZS7LuBQ
         bWovxTJxPek6tY8m1+TNCBzl2Xi4H5N8sg3O0H8ynLbZyhTim14n2SQneSmWfiJ+rwu7
         Ice3rqTr3tf+QUZDeMR9GTJ4+3YZMZuI1Q5eMCM8fhZhAq1CIuXVLt9cQuBhPpBWpqO/
         Qugw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y198si7907799qka.85.2019.06.25.03.29.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 03:29:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7AAA43098558;
	Tue, 25 Jun 2019 10:29:00 +0000 (UTC)
Received: from [10.36.117.83] (ovpn-117-83.ams2.redhat.com [10.36.117.83])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 52C67600C7;
	Tue, 25 Jun 2019 10:28:57 +0000 (UTC)
Subject: Re: [PATCH v2 3/5] mm,memory_hotplug: Introduce Vmemmap page helpers
To: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, pasha.tatashin@soleen.com,
 Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com, vbabka@suse.cz,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Matthew Wilcox <willy@infradead.org>
References: <20190625075227.15193-1-osalvador@suse.de>
 <20190625075227.15193-4-osalvador@suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <649ae422-9be8-8d2f-4e8e-f08c1ca9244f@redhat.com>
Date: Tue, 25 Jun 2019 12:28:56 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190625075227.15193-4-osalvador@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Tue, 25 Jun 2019 10:29:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25.06.19 09:52, Oscar Salvador wrote:
> Introduce a set of functions for Vmemmap pages.
> Set of functions:
> 
> - {Set,Clear,Check} Vmemmap flag
> - Given a vmemmap page, get its vmemmap-head
> - Get #nr of vmemmap pages taking into account the current position
>   of the page
> 
> These functions will be used for the code handling Vmemmap pages.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  include/linux/page-flags.h | 34 ++++++++++++++++++++++++++++++++++
>  mm/util.c                  |  2 ++
>  2 files changed, 36 insertions(+)
> 
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index b848517da64c..a8b9b57162b3 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -466,6 +466,40 @@ static __always_inline int __PageMovable(struct page *page)
>  				PAGE_MAPPING_MOVABLE;
>  }
>  
> +#define VMEMMAP_PAGE		(~PAGE_MAPPING_FLAGS)
> +static __always_inline int PageVmemmap(struct page *page)
> +{
> +	return PageReserved(page) && (unsigned long)page->mapping == VMEMMAP_PAGE;
> +}
> +
> +static __always_inline int __PageVmemmap(struct page *page)
> +{
> +	return (unsigned long)page->mapping == VMEMMAP_PAGE;
> +}
> +
> +static __always_inline void __ClearPageVmemmap(struct page *page)
> +{

Should we VM_BUG_ON in case !PG_reserved || pg->mapping != VMEMMAP_PAGE ?

> +	__ClearPageReserved(page);
> +	page->mapping = NULL;
> +}
> +
> +static __always_inline void __SetPageVmemmap(struct page *page)
> +{

Should we VM_BUG_ON in case PG_reserved || pg->mapping != NULL ?

> +	__SetPageReserved(page);
> +	page->mapping = (void *)VMEMMAP_PAGE;
> +}
> +
> +static __always_inline struct page *vmemmap_get_head(struct page *page)
> +{
> +	return (struct page *)page->freelist;

freelist is a "slab, slob and slub" concept (reading
include/linux/mm_types.h). page->mapping is a "Page cache and anonymous
pages" concept. Hmmm...

> +}
> +
> +static __always_inline unsigned long get_nr_vmemmap_pages(struct page *page)
> +{
> +	struct page *head = vmemmap_get_head(page);
> +	return head->private - (page - head);
> +}
> +
>  #ifdef CONFIG_KSM
>  /*
>   * A KSM page is one of those write-protected "shared pages" or "merged pages"
> diff --git a/mm/util.c b/mm/util.c
> index 021648a8a3a3..5e20563cdef6 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -607,6 +607,8 @@ struct address_space *page_mapping(struct page *page)
>  	mapping = page->mapping;
>  	if ((unsigned long)mapping & PAGE_MAPPING_ANON)
>  		return NULL;
> +	if ((unsigned long)mapping == VMEMMAP_PAGE)
> +		return NULL;
>  
>  	return (void *)((unsigned long)mapping & ~PAGE_MAPPING_FLAGS);
>  }
> 
I wonder if using a page type would be appropriate here instead. Then,
define a new sub-structure within "struct page" that describes what you
actually want (instead of reusing ->private and ->mapping). Just an
idea, we have to find out if that is possible.

vmemmap_get_head() smells like __GFP_COMP, but of course, these vmemmap
pages never saw the buddy. But sounds like you want a similar concept.

-- 

Thanks,

David / dhildenb

