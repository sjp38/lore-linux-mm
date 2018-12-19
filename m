Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D88DB8E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 05:20:13 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id x15so15886975edd.2
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 02:20:13 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t12-v6si38102ejd.265.2018.12.19.02.20.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 02:20:12 -0800 (PST)
Date: Wed, 19 Dec 2018 11:20:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: skip checking poison pattern for page_to_nid()
Message-ID: <20181219102010.GF5758@dhcp22.suse.cz>
References: <1545172285.18411.26.camel@lca.pw>
 <20181219015732.26179-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219015732.26179-1-cai@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, mingo@kernel.org, hpa@zytor.com, mgorman@techsingularity.net, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 18-12-18 20:57:32, Qian Cai wrote:
[...]
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 5411de93a363..f083f366ea90 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -985,9 +985,7 @@ extern int page_to_nid(const struct page *page);
>  #else
>  static inline int page_to_nid(const struct page *page)
>  {
> -	struct page *p = (struct page *)page;
> -
> -	return (PF_POISONED_CHECK(p)->flags >> NODES_PGSHIFT) & NODES_MASK;
> +	return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
>  }
>  #endif

I didn't get to think about a proper fix but this is clearly worng. If
the page is still poisoned then flags are clearly bogus and the node you
get is a garbage as well. Have you actually tested this patch?
-- 
Michal Hocko
SUSE Labs
