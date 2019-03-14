Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88478C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 10:15:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 381072064A
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 10:15:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 381072064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFED98E0003; Thu, 14 Mar 2019 06:15:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AAF368E0001; Thu, 14 Mar 2019 06:15:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99EED8E0003; Thu, 14 Mar 2019 06:15:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1988E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 06:15:29 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k21so2185276eds.19
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 03:15:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xfyjjVhnh242HGF+JWhUGlScIwO6qOC65zque3ERCq0=;
        b=bk6Wlm8i9TKKB7yuwC5SqC5B5gFvuUdXuPLdsVahUgmS1NJXS1UDk4mGv69FWXM44t
         iEQcEsCDvD6HOZML2QPRIoRUY5Rc0Z9e/uxwMQF8FI/6NVDtmx5UX42yN4adcdUJXO1b
         MqW+1jpct5gfxSQR9EewDtZbl2iELjfG9N0ZLwIxcEtSP4Q88l64mK9isbGSW/KMkqrk
         xk2uGL5i5jLxI2teW3Ng3lTFDL3G9ATQvzWOde/szsOgjAJHqtVWItklGo32zN+se2X4
         QxGywov1PwLHKmaNJUQjBP249d9QTUe0lqmYBscbUMjPQVLZRPjeQZmo8eN1fqgbKRhP
         iJXA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAUJdPKIGiE4QmOkgDOwaEGLKRj4JahMn4Ihgk14mh9JjaibW0h5
	7s65vb8ZKzOxr3Ziq9IbvmRikCexZESgq2Zu73EyTceEoVunFImZaLUIjy41UaSMGx2Y+rmaso7
	NZEb8BYRCIKj4j0/kmQFSk8UVVCNzN+kEJisxQMAoyM69n5inPFqS4Xp1cXtXECImEA==
X-Received: by 2002:a17:906:4dda:: with SMTP id f26mr3515996ejw.79.1552558528787;
        Thu, 14 Mar 2019 03:15:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDfQnVaDXovO1ATbyHYTY8VH3tZM70j5Ut2TNh1lREixpeSsgm2ntQHoJIHIH5ngj387jo
X-Received: by 2002:a17:906:4dda:: with SMTP id f26mr3515949ejw.79.1552558527731;
        Thu, 14 Mar 2019 03:15:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552558527; cv=none;
        d=google.com; s=arc-20160816;
        b=uZyd/ROz/9bNZfvZ6o4LyuvY0aE1JIHHMvsg6lpHGmwt0E1Wk0beik68hbW5/GguTc
         46MXjcEAvZtbUkkZMrrxZjz4+LdMqMgOMiiJpV5xTCdTo5PJZQpKfNYkTUO5kmooiCHC
         WPZfQ5kBkJkfFRi+ikVrf0rhRavj171+odsSkv0CRCupjcTaSjaMioSOESoMY7+zL6dc
         xn2Hh22J6hahmvyjd3AjSZTt0MaYBwWIvhzp4foQUD+6NNHIncN4y7PS0j7cKOWmS75R
         ubSEZHQee1fFz0E3cbNmz415izmCL2+aUzeAw96AixrvYiQ5QQrb6wtHQqiWZ++sl1sG
         Kp/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xfyjjVhnh242HGF+JWhUGlScIwO6qOC65zque3ERCq0=;
        b=QMY/ndJPpaHUjf8b9++lFJxMkVtm1mSSFqVJsyCsdnDDhprXEqy15x01V5MPP/diae
         4q8vIyrzfu3R+eGwhNLlJpMW41gHHqp1PYe6bjMoQREkuF4tczLYqx6KfXHMEe0fTb+l
         yu9Cfp+g1e9iuaXNtMooXF0MSOzAYtPZq4yyllzbuNNunGO9PGIfE9pIbzKsYvRlsNmT
         APTGC3ib/NLYemE9hTEtK6l8P761Q1t1TrSB7fUldTaCUqvjcKXpu6aSifod1moaA1kh
         nayZvtx1PWTb9cPbCQSck3ydiaq26Tv5Apzz40dLdmqyGkPMcYXHmiIAJ0pIDy2SR+G4
         qM4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gf23si1608134ejb.42.2019.03.14.03.15.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 03:15:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F0412AFF6;
	Thu, 14 Mar 2019 10:15:26 +0000 (UTC)
Date: Thu, 14 Mar 2019 11:15:26 +0100
From: Michal Hocko <mhocko@suse.com>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Takashi Iwai <tiwai@suse.de>
Subject: Re: [PATCH v2] mm, page_alloc: disallow __GFP_COMP in
 alloc_pages_exact()
Message-ID: <20190314101526.GH7473@dhcp22.suse.cz>
References: <20190314093944.19406-1-vbabka@suse.cz>
 <20190314094249.19606-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190314094249.19606-1-vbabka@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 14-03-19 10:42:49, Vlastimil Babka wrote:
> alloc_pages_exact*() allocates a page of sufficient order and then splits it
> to return only the number of pages requested. That makes it incompatible with
> __GFP_COMP, because compound pages cannot be split.
> 
> As shown by [1] things may silently work until the requested size (possibly
> depending on user) stops being power of two. Then for CONFIG_DEBUG_VM, BUG_ON()
> triggers in split_page(). Without CONFIG_DEBUG_VM, consequences are unclear.
> 
> There are several options here, none of them great:
> 
> 1) Don't do the spliting when __GFP_COMP is passed, and return the whole
> compound page. However if caller then returns it via free_pages_exact(),
> that will be unexpected and the freeing actions there will be wrong.
> 
> 2) Warn and remove __GFP_COMP from the flags. But the caller wanted it, so
> things may break later somewhere.
> 
> 3) Warn and return NULL. However NULL may be unexpected, especially for
> small sizes.
> 
> This patch picks option 3, as it's best defined.

The question is whether callers of alloc_pages_exact do have any
fallback because if they don't then this is forcing an always fail path
and I strongly suspect this is not really what users want. I would
rather go with 2) because "callers wanted it" is much less probable than
"caller is simply confused and more gfp flags is surely better than
fewer".

> [1] https://lore.kernel.org/lkml/20181126002805.GI18977@shao2-debian/T/#u
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
> Sent v1 before amending commit, sorry.
> 
>  mm/page_alloc.c | 15 ++++++++++++---
>  1 file changed, 12 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0b9f577b1a2a..dd3f89e8f88d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4752,7 +4752,7 @@ static void *make_alloc_exact(unsigned long addr, unsigned int order,
>  /**
>   * alloc_pages_exact - allocate an exact number physically-contiguous pages.
>   * @size: the number of bytes to allocate
> - * @gfp_mask: GFP flags for the allocation
> + * @gfp_mask: GFP flags for the allocation, must not contain __GFP_COMP
>   *
>   * This function is similar to alloc_pages(), except that it allocates the
>   * minimum number of pages to satisfy the request.  alloc_pages() can only
> @@ -4768,6 +4768,10 @@ void *alloc_pages_exact(size_t size, gfp_t gfp_mask)
>  	unsigned long addr;
>  
>  	addr = __get_free_pages(gfp_mask, order);
> +
> +	if (WARN_ON_ONCE(gfp_mask & __GFP_COMP))
> +		return NULL;
> +
>  	return make_alloc_exact(addr, order, size);
>  }
>  EXPORT_SYMBOL(alloc_pages_exact);
> @@ -4777,7 +4781,7 @@ EXPORT_SYMBOL(alloc_pages_exact);
>   *			   pages on a node.
>   * @nid: the preferred node ID where memory should be allocated
>   * @size: the number of bytes to allocate
> - * @gfp_mask: GFP flags for the allocation
> + * @gfp_mask: GFP flags for the allocation, must not contain __GFP_COMP
>   *
>   * Like alloc_pages_exact(), but try to allocate on node nid first before falling
>   * back.
> @@ -4785,7 +4789,12 @@ EXPORT_SYMBOL(alloc_pages_exact);
>  void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask)
>  {
>  	unsigned int order = get_order(size);
> -	struct page *p = alloc_pages_node(nid, gfp_mask, order);
> +	struct page *p;
> +
> +	if (WARN_ON_ONCE(gfp_mask & __GFP_COMP))
> +		return NULL;
> +
> +	p = alloc_pages_node(nid, gfp_mask, order);
>  	if (!p)
>  		return NULL;
>  	return make_alloc_exact((unsigned long)page_address(p), order, size);
> -- 
> 2.20.1

-- 
Michal Hocko
SUSE Labs

