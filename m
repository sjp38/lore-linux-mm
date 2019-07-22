Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90B4AC76188
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 08:11:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5911D21E70
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 08:11:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5911D21E70
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E406A6B0006; Mon, 22 Jul 2019 04:11:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF1986B0007; Mon, 22 Jul 2019 04:11:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE07E8E0001; Mon, 22 Jul 2019 04:11:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7EED56B0006
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 04:11:19 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d27so25828654eda.9
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 01:11:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Qb7BEtNSY6YJscdZNl4JnYQL83SzOmRWvDsiZpuK1nE=;
        b=s+COp/j1pupqvI8mjFKKeGSXgVH1XI+s1WCf6zjOeoiSCISgUlJfwQ546uB7G+8E+S
         BhCZFfCyLnCOEPJtGXt9AZRf4VbGhZHEekmG5+iSelQ95OLgGvzVGU9lxhriyIQPVyQf
         urkszeXGLKHWc9pr7xGep1y6hgUYOCwQb4FF1fkzMpViNDw+FRfqAS2bLf9bUCXd0ABy
         QlCZD7oN9bn/GLzlEZFS9I97zztn7PoXpwfbJmEg9F88Agh6c2SOlIo+5hXt9W6+ScTe
         FHM6WY1fE08Grh3WAQps6K92OUIpUFIUXgZnJrG87WA6RWs5atnUt2vRYk3jjSfwB4v6
         jOug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
X-Gm-Message-State: APjAAAWqKITHlSHC2R/Ep9yRS4jCViZLxNT6synYlvnzIgpf7wFpa+hP
	HkZWh6LfXlzNB30MigKsLbZvFzxWQv5P9fzkFpTlcllt354axAdVmBtyV9ZdJJRe38v3HTV4/tp
	jG37BlS5L7axR8YDNnGhCj7Ikbs0lm6AgWZhuCTc3oS4WGZOWYDu1a+j3ipnV3UzfcA==
X-Received: by 2002:a50:97c8:: with SMTP id f8mr58887045edb.176.1563783079083;
        Mon, 22 Jul 2019 01:11:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzz65Bq77cnwJhEjFM2mbVTQ8QSv3XgkfErzCQ74sT+TXmLGqDhY/LRqSsu5MmeGsJP4jO+
X-Received: by 2002:a50:97c8:: with SMTP id f8mr58887006edb.176.1563783078417;
        Mon, 22 Jul 2019 01:11:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563783078; cv=none;
        d=google.com; s=arc-20160816;
        b=xWISlhJ9vhpqFy2EyU4a7M4RJJw8213qF8KSxkUu4bL+3vpkmL+fCvg1TGHHOMhWAP
         BadTJWKyvoa0VDO5+KU/dn1mmJac0MR/HcN4VdRX9qRYrmeL+p4lmKmly7XlNkAEpYfn
         Vyq6IW/h7WFjjMHvW+XN5Qw/2wxkXZ1aA5rceeH60UwzjYMx8UZ+ANJhUFNZLeZj/k3Y
         ILLRBWxNfJYQqKHFp9WDxh/olVEl+OnsAZDik/zNgAXR85GGIQDFOH+tQK81SsKNnW99
         34Ey6Nu6YO986KTPQMGMzDJL990hgkg/uyrjxQ5zeqTKeQgoGsDmiF3AJKDLfm8qfMU6
         ruOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Qb7BEtNSY6YJscdZNl4JnYQL83SzOmRWvDsiZpuK1nE=;
        b=MrldWXzRVSd9xNIQ1jzp6rb3L+TcMgJdFkhkjhRe1ItoPzLtrTJEkzh/ue3GgvzbAl
         HQVmNauB9OkdHrh79nzAf3iqwIGsjfpyjwbqP45mW7n6Uu6+x2CpVoe8yeEzhLDmUljk
         8Pv3K9LLY4LB7OaI9WestHYPYtAcw/2D9xtXB8S6qUUKEqQe+8KO+bvrF1UCGYpATCGz
         zil24yiIKu2k59lB/ehfagb9Eo6z1MgsbNHc3Zk+pDGUrNFF+smoRgRgRI0bK/P3/ciP
         s5T8weXMyg1kzcQIvViAaMOQeJVkuCRIUehsesRzpSCiRSf0EZ5RvIO5d7KLa2IJOvxo
         tx6A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k25si4562326edd.322.2019.07.22.01.11.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 01:11:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D86DDAF8E;
	Mon, 22 Jul 2019 08:11:17 +0000 (UTC)
Date: Mon, 22 Jul 2019 10:11:15 +0200
From: Joerg Roedel <jroedel@suse.de>
To: Joerg Roedel <joro@8bytes.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 3/3] mm/vmalloc: Sync unmappings in vunmap_page_range()
Message-ID: <20190722081115.GH19068@suse.de>
References: <20190719184652.11391-1-joro@8bytes.org>
 <20190719184652.11391-4-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190719184652.11391-4-joro@8bytes.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Srewed up the subject :(, it needs to be

	"mm/vmalloc: Sync unmappings in __purge_vmap_area_lazy()"

of course.

On Fri, Jul 19, 2019 at 08:46:52PM +0200, Joerg Roedel wrote:
> From: Joerg Roedel <jroedel@suse.de>
> 
> On x86-32 with PTI enabled, parts of the kernel page-tables
> are not shared between processes. This can cause mappings in
> the vmalloc/ioremap area to persist in some page-tables
> after the region is unmapped and released.
> 
> When the region is re-used the processes with the old
> mappings do not fault in the new mappings but still access
> the old ones.
> 
> This causes undefined behavior, in reality often data
> corruption, kernel oopses and panics and even spontaneous
> reboots.
> 
> Fix this problem by activly syncing unmaps in the
> vmalloc/ioremap area to all page-tables in the system before
> the regions can be re-used.
> 
> References: https://bugzilla.suse.com/show_bug.cgi?id=1118689
> Reviewed-by: Dave Hansen <dave.hansen@linux.intel.com>
> Fixes: 5d72b4fba40ef ('x86, mm: support huge I/O mapping capability I/F')
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>  mm/vmalloc.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 4fa8d84599b0..e0fc963acc41 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1258,6 +1258,12 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
>  	if (unlikely(valist == NULL))
>  		return false;
>  
> +	/*
> +	 * First make sure the mappings are removed from all page-tables
> +	 * before they are freed.
> +	 */
> +	vmalloc_sync_all();
> +
>  	/*
>  	 * TODO: to calculate a flush range without looping.
>  	 * The list can be up to lazy_max_pages() elements.
> @@ -3038,6 +3044,9 @@ EXPORT_SYMBOL(remap_vmalloc_range);
>  /*
>   * Implement a stub for vmalloc_sync_all() if the architecture chose not to
>   * have one.
> + *
> + * The purpose of this function is to make sure the vmalloc area
> + * mappings are identical in all page-tables in the system.
>   */
>  void __weak vmalloc_sync_all(void)
>  {
> -- 
> 2.17.1

