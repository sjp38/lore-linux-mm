Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1672DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 18:51:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD437217F5
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 18:51:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD437217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 127936B0003; Thu, 14 Mar 2019 14:51:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1000F6B0005; Thu, 14 Mar 2019 14:51:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 017106B0006; Thu, 14 Mar 2019 14:51:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B73016B0003
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 14:51:15 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e5so7184425pfi.23
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 11:51:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1xJAYMtOZPPeSDIyswdlqEQhUjMlZJOCPW1fclh7XQk=;
        b=SAGgHeDlz+/r3zzX77ghQn/NsCq7uGhKwZOqsp94rIqLeRzc23VWV3S44AK2NUfn/A
         d58iIt4sy8wHpYg6HSvLeCURml0Uo2IWs4fIcxoUMX9qAuIse0Tz2+12FbIkm9F3A4PW
         ErYqgnkcmNUu8lu7PXUocKO+YLvnPr5dki4p/v/UksQKxIvTwQkmjzjl4q0p0aGqHo9F
         zXdyo9LI7Wrk3Wt1YCVEH+rrZ3R+/Jv7EyvpyK8bvHfEgjK3jXRPDHWUsaoWGQgkar7S
         9cVUBYcqSkWhg90uWRUbKXBlsBRUw4j1jz6ynLoE1kDg+hWChFdHZpsTbAZOQ36MYsgT
         BESA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVCK3wfrOznT8jFXAsnTM6xSpM4mwYXryWFKozZ1lvJ3ojJi/RI
	G8EjWbE0YeUHIetOODxVenS6urIk82utEP9nk2Ho4xRSZMMJUQWLYXKezTrN2H9v7Wu6hIL/C+8
	Ea13x2hvEyUQ+6nvHGfG6C1EnL/n0PiG4LGS2r5+X0VhlYjFrd8bnbLrqAztakjBPEg==
X-Received: by 2002:a17:902:266:: with SMTP id 93mr48489222plc.161.1552589475352;
        Thu, 14 Mar 2019 11:51:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcKUvjMSC4N9zS75NZh8ZZDV4CVbvk4xJJVaNOcvM4ykamZcaJysTXHi4/qf31t7YpeXfM
X-Received: by 2002:a17:902:266:: with SMTP id 93mr48489152plc.161.1552589474339;
        Thu, 14 Mar 2019 11:51:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552589474; cv=none;
        d=google.com; s=arc-20160816;
        b=nbcMpdaY0g6d1QGOZ7AEovjrO11kVBpZyum4DW0HT3pyRLv76Fqk+VKY5fg4mBPPhT
         yZkbKFcOODua/4uWT70h1aSYF/T1hDbCtr775ReWIFbwWlRwQlEWEMLlPlZ0M6wSXknC
         2ae2X2r34gSVkj7Vf1tQ3rdYoATHdYCYc4ZIGtT62VOV1v6WVgFSd1YvNHo40JrBDXjr
         IN20LYgtvEiROIKIJYKNqlB82VQSjXwJ++2bGC2qaQGOhtquyLCaVRyguHsZkKNBy27V
         Rtzc052s8bBA0S+hPS4Ke3qUlb5ajzV9lWj82SnfoQvFqkI3V3xbe0kB9evJVXFQ5J4q
         ZESw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=1xJAYMtOZPPeSDIyswdlqEQhUjMlZJOCPW1fclh7XQk=;
        b=gj+O3q4+0dbIIIqa2CfQTqgIVwiAPAboNkv7c2/mzx6BUSJ016VGYXhs/1I5No9nPz
         +VtT6HHwFcThwrgsXKVP7e5dFYRtEYd1AIgJFVC9ve3P3SqZHt2L7x8131FOxisH1Ora
         wq94hCk0iQvQvxhLlh56Nh6PqDBLa85WeGVmod9dbRumQQn/8O122xDplGKwSDUp8KkJ
         9I7uMbciqsED6WHmIifh/lEZGYhSY39JVcavYy7o9Z4YLHWs5ms7CBMTW/lGgI6URTU3
         YsCXyE6wrapTISZ7Dbxy40PE+Ed31QTAyr4D5OTcYFBpWEDMNTHwKtcD68V76Lrb7tT1
         4Dsw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id a10si12691869pgt.357.2019.03.14.11.51.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 11:51:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Mar 2019 11:51:13 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,479,1544515200"; 
   d="scan'208";a="134116839"
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga003.jf.intel.com with ESMTP; 14 Mar 2019 11:51:11 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 9A686E4; Thu, 14 Mar 2019 20:51:10 +0200 (EET)
Date: Thu, 14 Mar 2019 21:51:10 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Takashi Iwai <tiwai@suse.de>
Subject: Re: [PATCH v2] mm, page_alloc: disallow __GFP_COMP in
 alloc_pages_exact()
Message-ID: <20190314185110.brwjq5a2jdyzwskn@black.fi.intel.com>
References:<20190314093944.19406-1-vbabka@suse.cz>
 <20190314094249.19606-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To:<20190314094249.19606-1-vbabka@suse.cz>
User-Agent: NeoMutt/20170714-126-deb55f (1.8.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 14, 2019 at 09:42:49AM +0000, Vlastimil Babka wrote:
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

Shouldn't it be before __get_free_pages() call? :P

>  	return make_alloc_exact(addr, order, size);
>  }
>  EXPORT_SYMBOL(alloc_pages_exact);

-- 
 Kirill A. Shutemov

