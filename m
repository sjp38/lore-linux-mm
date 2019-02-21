Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC00DC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:17:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7552A2083B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:17:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7552A2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B7228E00A3; Thu, 21 Feb 2019 13:17:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28BEF8E0094; Thu, 21 Feb 2019 13:17:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 132BB8E00A3; Thu, 21 Feb 2019 13:17:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC8308E0094
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 13:17:44 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id x63so5973836qka.5
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 10:17:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=bNH8JIGECsQWSdNJdeRu/s8TPP7NtINtEqaBg5SRL50=;
        b=ujgP1UBQYOUgVwiJ4JqICwETodwtGisuMnbCwrJQoh+KeaTuaUBdX+Pf6AzPwV9QP7
         nyF4Q2ZOk1VEetfUtH1GBy0LuCySHBNcGzZ6jrTEZYrqDILOgMx3wTHKXnQ5v/FFsq+0
         u9/sZFB8VSAtCg51l4nFM5K8HcFRrtVKO48Q4BZfajgyF2Eb7yGSlKJW8a4oyk5A8j3O
         6jL5jF2Q2fvO9cKV79MFHIdefxFRzN2bkiLoL3CuvQX0Mp60LKvu2EANpRyemmNK83QW
         tH3dIdXQrHy0t07uu7Agt9t0QHfE5q6Qmb77G7MbDKAPe+dB77gdCjC974kvvPD/YaOF
         1g+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZRqe/DWjdREfAeFccxBxdO5uo40L67xpwYxpLI6lWEaAbl+h7Z
	K4jq+111Z8GuXVblPHONJzmDa3q9arbhmn+90ktuHyF6gwT7BidZtVn3Mo5acS5us/R9/Xl1L88
	ClQxwKVaXRb8fMr6Z37TRzxNK+va8MCSvSQKpHfeUI5zmXgDmetNOSAZ9oevQAG4HNA==
X-Received: by 2002:ac8:3437:: with SMTP id u52mr33045745qtb.185.1550773064675;
        Thu, 21 Feb 2019 10:17:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZdLNYBHdOTI23NLz8ozrSdFTgAh/61ncxLlCdT6eMDPZGODWlX+64epefUK7DPKIiOyDKK
X-Received: by 2002:ac8:3437:: with SMTP id u52mr33045715qtb.185.1550773064161;
        Thu, 21 Feb 2019 10:17:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550773064; cv=none;
        d=google.com; s=arc-20160816;
        b=iuC//0Ba0CfL4GlPc9IE6t/ozZXuuqddyB7GN8Ke4Qm9TCIqPHpYixz6N8HWLLeabL
         5EijMzVRoKQ4sHsjJwVVOdk3wu6/TUJ/V4ljb17/WCDmH3Qk1qupUw/WSwJxcXMuJ0o9
         iv6tuu8RxYGoVWMyjJGH0OPGF2Ww29+bUWeJDV5Jx6rWWqIVIFaQi+zn3zB7dcrkqLac
         CFA66Wa5hDS91VWWnqD7821bDVmj73Db6rUpNuvoPDYOcZZ3PemHQ4C62LG3pE4bSxNA
         JpTGaZ+vDBIPMgsQ2wnPSnVhuKetATmiD80ma8tCa9oHrQ26OlMwnM4+tbgdw0ReA2B7
         rPZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=bNH8JIGECsQWSdNJdeRu/s8TPP7NtINtEqaBg5SRL50=;
        b=qWP2sMBtXriZJsPOgnLQumJhAuou4ERRGDHkvy/dONh1r/h7ZShYQuXTMfJmcA5CjT
         f0OIxqcuiQLpKZ59CecbOjqF7wwsrlwqoeQFH/JVT59I3bJptWxOe7OdDlbam2M/WqPV
         mDs7+k5l7HsLbeEwRG46W0Kdexp2AmMvj7LitBksgi+qWjJonnMxu2IXisldG23N5eS8
         1x7UwE0S6M3zGzgTFJYNGGQHC+VWgaUdbYzFPX5viaSBl3VNvBrcZvz+HdOTdLtKFFnN
         9FeNDyfs6xudhoKxmH3IGWL4M0SVPElOcy/hqEN8S9wb2L4/08a9BarFAD/W6H4Pc/sQ
         ZkOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r16si1056974qtn.298.2019.02.21.10.17.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 10:17:44 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DE04A59446;
	Thu, 21 Feb 2019 18:17:42 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id DC35660BE6;
	Thu, 21 Feb 2019 18:17:36 +0000 (UTC)
Date: Thu, 21 Feb 2019 13:17:34 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 18/26] khugepaged: skip collapse if uffd-wp detected
Message-ID: <20190221181734.GR2813@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-19-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190212025632.28946-19-peterx@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 21 Feb 2019 18:17:43 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:24AM +0800, Peter Xu wrote:
> Don't collapse the huge PMD if there is any userfault write protected
> small PTEs.  The problem is that the write protection is in small page
> granularity and there's no way to keep all these write protection
> information if the small pages are going to be merged into a huge PMD.
> 
> The same thing needs to be considered for swap entries and migration
> entries.  So do the check as well disregarding khugepaged_max_ptes_swap.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  include/trace/events/huge_memory.h |  1 +
>  mm/khugepaged.c                    | 23 +++++++++++++++++++++++
>  2 files changed, 24 insertions(+)
> 
> diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
> index dd4db334bd63..2d7bad9cb976 100644
> --- a/include/trace/events/huge_memory.h
> +++ b/include/trace/events/huge_memory.h
> @@ -13,6 +13,7 @@
>  	EM( SCAN_PMD_NULL,		"pmd_null")			\
>  	EM( SCAN_EXCEED_NONE_PTE,	"exceed_none_pte")		\
>  	EM( SCAN_PTE_NON_PRESENT,	"pte_non_present")		\
> +	EM( SCAN_PTE_UFFD_WP,		"pte_uffd_wp")			\
>  	EM( SCAN_PAGE_RO,		"no_writable_page")		\
>  	EM( SCAN_LACK_REFERENCED_PAGE,	"lack_referenced_page")		\
>  	EM( SCAN_PAGE_NULL,		"page_null")			\
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index 4f017339ddb2..396c7e4da83e 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -29,6 +29,7 @@ enum scan_result {
>  	SCAN_PMD_NULL,
>  	SCAN_EXCEED_NONE_PTE,
>  	SCAN_PTE_NON_PRESENT,
> +	SCAN_PTE_UFFD_WP,
>  	SCAN_PAGE_RO,
>  	SCAN_LACK_REFERENCED_PAGE,
>  	SCAN_PAGE_NULL,
> @@ -1123,6 +1124,15 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>  		pte_t pteval = *_pte;
>  		if (is_swap_pte(pteval)) {
>  			if (++unmapped <= khugepaged_max_ptes_swap) {
> +				/*
> +				 * Always be strict with uffd-wp
> +				 * enabled swap entries.  Please see
> +				 * comment below for pte_uffd_wp().
> +				 */
> +				if (pte_swp_uffd_wp(pteval)) {
> +					result = SCAN_PTE_UFFD_WP;
> +					goto out_unmap;
> +				}
>  				continue;
>  			} else {
>  				result = SCAN_EXCEED_SWAP_PTE;
> @@ -1142,6 +1152,19 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>  			result = SCAN_PTE_NON_PRESENT;
>  			goto out_unmap;
>  		}
> +		if (pte_uffd_wp(pteval)) {
> +			/*
> +			 * Don't collapse the page if any of the small
> +			 * PTEs are armed with uffd write protection.
> +			 * Here we can also mark the new huge pmd as
> +			 * write protected if any of the small ones is
> +			 * marked but that could bring uknown
> +			 * userfault messages that falls outside of
> +			 * the registered range.  So, just be simple.
> +			 */
> +			result = SCAN_PTE_UFFD_WP;
> +			goto out_unmap;
> +		}
>  		if (pte_write(pteval))
>  			writable = true;
>  
> -- 
> 2.17.1
> 

