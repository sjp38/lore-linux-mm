Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1A1DC48BE3
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 15:17:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3CBA20675
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 15:17:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3CBA20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 297176B0005; Thu, 20 Jun 2019 11:17:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 246B68E0002; Thu, 20 Jun 2019 11:17:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10D538E0001; Thu, 20 Jun 2019 11:17:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB4FD6B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 11:17:37 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id i35so781595pgi.18
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 08:17:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=pOPK3l6R1avTxnN2tM3phaUZz7dyRdq6tPURmmF4Smw=;
        b=jJ32BNBzXxTNmXHomq3RbNbaSQKZI/16L9Y+hnmNEjz8O0hxH9HFplnrmgS4a9fx+H
         BQGQWnxye9uqGfa/54qzgpLUyZmuGt3m0vInSa3uSFnBkPSU94NTEmrMehVV3DNYFtEb
         4K7obHHq5i8JzMClD27Bs2heFw0igCtka7W7SwYRmuWkkF/IzQbD56bYVp0HkQQBXFm1
         pGty4c+ZCE/LAnrXTl+Gz+DDhi6F2sdRWoKRN0KLs3HT9jhs/eaRyNYeb8JSrhUpoVVe
         OKcrD4lLJWcyNmhIuh6NuPoCHW8tff7Yd8TDhrcg6IO5PAnjqJxWLPwUlbTBCj32BDRy
         Oc4g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXUSDzu+MHUBQYxs+ykEM8xtOW5SdCCzAsUgVYiAGeHvq8t2gu7
	FEqblafWVy2T3kDcrnY/j78SIqfx4JOJiEFMEz2LgajCTjIDYaUgDaVicPIHVj64+JEUJEEAkaw
	68H1yQC1bf5leEysL+GXCMaIWBxIblFXSv1KJx5o55JHxcYRkabu+Qj9g2Ahdl57Txg==
X-Received: by 2002:a63:d444:: with SMTP id i4mr13433971pgj.14.1561043857380;
        Thu, 20 Jun 2019 08:17:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0hyccZRiicYSsKUL0MfjzZPlRnIlvnVpfvSt5VnQRMf1U9xm4NIxV9wUaaY9ejSxh5DI4
X-Received: by 2002:a63:d444:: with SMTP id i4mr13433875pgj.14.1561043856049;
        Thu, 20 Jun 2019 08:17:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561043856; cv=none;
        d=google.com; s=arc-20160816;
        b=iACRHAxXt2tjzzaD9kAqqtsESm3AJS+gyWjldJGflXF68LaeBPo3/U7uiyKaFTiKbo
         w2to3yG4MaZ/B4Oz8SWoF1G1EcsNMR6tgtae31sWsR3xvt0ZYsKpdNojLTF2oH1o4TZP
         T0m2KYmFBS6cJYviiwtYGegB6ChNPS+oegYrLGbXK7+GQacIHBmQepJJmjcsgDwD4oV/
         Nlij3/VBqUvICQPgJVGh4emzkELjRNHjBNGIBYbPs7g9E7ItSGwgjRfWS74Xyd8nEsn9
         t1HzZqWSsKqqGZU15Sy1Su9EyOTWWZ2uMGBpgzyFJ035yETANzaNkFpQ+7hM1GpiOZtK
         d5WQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:to:from:subject:message-id;
        bh=pOPK3l6R1avTxnN2tM3phaUZz7dyRdq6tPURmmF4Smw=;
        b=GHhIyDbzW2UqJSxKpc9C6/+hBHqcXgZQ1vL7blvui78PO0hLxdLuHc+C2egH3YOyzX
         exlchu9JIUZNG9aBoy+0p8A009kG1Ybyg5yS5yiFIf3kOa8VrQNcVODYyc82p1wYvsnQ
         YFH31q3/luFix4cqPJ4j9Ug2vgP1O8SRjBEl5h15rnffXIi3Q5ZWMyXaS3a7nyqlFT8T
         zIIwAa8cXCPzjFK7taI8TvoYL0vROFHgJ8y+Ga8gmVrFsKGmoaQTvOHw+P6CLdrywUqO
         gpp8i5kHLLHx2jKXzUZvZJ7H6TQ3vls5lpNSmVukF6u2ZpEf405o0iIrnNBjL5tpW7z3
         QaLA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id m3si35840pld.40.2019.06.20.08.17.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 08:17:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Jun 2019 08:17:35 -0700
X-IronPort-AV: E=Sophos;i="5.63,397,1557212400"; 
   d="scan'208";a="154144455"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga008-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Jun 2019 08:17:35 -0700
Message-ID: <d11cf6a9ac9f2f21b6102464bf80925ada02bc78.camel@linux.intel.com>
Subject: Re: [PATCH RFC] mm: fix regression with deferred struct page init
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Juergen Gross <jgross@suse.com>, xen-devel@lists.xenproject.org, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Thu, 20 Jun 2019 08:17:35 -0700
In-Reply-To: <20190620094015.21206-1-jgross@suse.com>
References: <20190620094015.21206-1-jgross@suse.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-06-20 at 11:40 +0200, Juergen Gross wrote:
> Commit 0e56acae4b4dd4a9 ("mm: initialize MAX_ORDER_NR_PAGES at a time
> instead of doing larger sections") is causing a regression on some
> systems when the kernel is booted as Xen dom0.
> 
> The system will just hang in early boot.
> 
> Reason is an endless loop in get_page_from_freelist() in case the first
> zone looked at has no free memory. deferred_grow_zone() is always
> returning true due to the following code snipplet:
> 
>   /* If the zone is empty somebody else may have cleared out the zone */
>   if (!deferred_init_mem_pfn_range_in_zone(&i, zone, &spfn, &epfn,
>                                            first_deferred_pfn)) {
>           pgdat->first_deferred_pfn = ULONG_MAX;
>           pgdat_resize_unlock(pgdat, &flags);
>           return true;
>   }
> 
> This in turn results in the loop as get_page_from_freelist() is
> assuming forward progress can be made by doing some more struct page
> initialization.
> 
> Fixes: 0e56acae4b4dd4a9 ("mm: initialize MAX_ORDER_NR_PAGES at a time instead of doing larger sections")
> ---
> This patch makes my system boot again as Xen dom0, but I'm not really
> sure it is the correct way to do it, hence the RFC.
> Signed-off-by: Juergen Gross <jgross@suse.com>
> ---
>  mm/page_alloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d66bc8abe0af..6ee754b5cd92 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1826,7 +1826,7 @@ deferred_grow_zone(struct zone *zone, unsigned int order)
>  						 first_deferred_pfn)) {
>  		pgdat->first_deferred_pfn = ULONG_MAX;
>  		pgdat_resize_unlock(pgdat, &flags);
> -		return true;
> +		return false;
>  	}
>  
>  	/*

The one change I might make to this would be to do:
	return first_deferred_pfn != ULONG_MAX;

That way in the event the previous caller did free up the last of the 
pages and empty the zone just before we got here then we will try one more
time. Otherwise if it was already done before we got here we exit.

