Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7EC3C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 13:25:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70332217F5
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 13:25:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70332217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 082BE8E0003; Tue, 26 Feb 2019 08:25:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00C7F8E0001; Tue, 26 Feb 2019 08:25:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E18398E0003; Tue, 26 Feb 2019 08:25:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 815DF8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 08:25:45 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f2so5343491edm.18
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 05:25:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=KPbIIVxQ2UyzAFO6IzPSI+9d4ATJf7SWXlpnkYUXrQM=;
        b=Hdxrl1bOeehEmD0pnFx+I+jgFfpdff0mHH/EUEmW8OPzwrEbuirE7cV2a5IxJqpI0a
         7Za05BrWV03Pl2qfLWbDA1KtEGZsfnqKbPBh2NPydk0Fxl5QAgbH4GievAQZIOuxiRyp
         2p+xVWm68M9Mr6Fb047rjML1PLt6Zalzi+ih+HLhpNke+Qf2G3NdVH6lYhzTg0hhzncg
         dmhlpy0vot1N7gQGlCxjqz0QRScdf6alpEwqianxO26CDHTc76G8KSEz+Om9wm++U7mJ
         Wt+D5XvbQviJZrm0Z/53tsbjZWnDAwvEVjpU5OWhMKflCM0JZl1pbE/tb53ZbPodIQbI
         2ktA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZBujglpmNCveWMCKBw5aOgD4hyWQLMT0wgEiw9hpFBzKqDG3VJ
	hERN+Mn46Iq9+/7H2TcZCpXL+/mq8AbTk/K96X9JaaS+2Ooa0DxmLt11KhwVJqRKerp0/8jHKQ8
	pPcH5pxeVnS/P3TIFV2ulnR97+68RN3dQsox7/PuHpVfgDqb6YnAHW8aTl9k4jMw=
X-Received: by 2002:aa7:df8b:: with SMTP id b11mr18645291edy.166.1551187545093;
        Tue, 26 Feb 2019 05:25:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaRsjHKvGOhkIXQKIwt8ZxonoQjuI0KlUMwXc8skZO/U8CCEFsYtVNi4T9rQQc627VpVaXs
X-Received: by 2002:aa7:df8b:: with SMTP id b11mr18645240edy.166.1551187544235;
        Tue, 26 Feb 2019 05:25:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551187544; cv=none;
        d=google.com; s=arc-20160816;
        b=kbi2NGHaYwMXWSrpRCIoFjGtQ0kTCNLjYdvFw6wf2NIVahbQKw1OhWINW2LS9Scf3r
         RgA3CfH6KO+zRSYYASBrVQ+nRmY2WjISCqKu7IAXK8IBxOsC7UIA+7luXEAz4aMIXPl6
         kG5SRlqYoAJZy8l2UluNto2MZmjxDsPu7HRKrTG25ESt0KePq2Z04OLchLKWEPN8bzAD
         RXGNbJ85KAu+wnXRp2xYhfAoWsKfBHDxGau6u5nKrWQyQVdmmjebnAssQMUFRICn2ZMX
         Hoc/wiblZsWXBsFo1JnpYqj3YZX7nzhftk/mMpm07TZODacpL1G9Ulnl4+bqqiYj3IZW
         lWbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=KPbIIVxQ2UyzAFO6IzPSI+9d4ATJf7SWXlpnkYUXrQM=;
        b=f8i+Slq3onmtG03hFrnCcUhQl4usggmMmO9vHJE+Z+vPV/wMDo6cHkZ/69aTEzZbEN
         PZpyvpKlj3MrtoTM0++zgpmvawHBmV2aFN6yLiolG7ocY/ZQUcizNj0veDacUNScMbaV
         i7tjbXRCcA/jyvexzHM0nZsUNGnNM7kZ34d7IIdj9UafctMoywBK/MZrC7Hti7hH+Isj
         +4+Pr73ECzAmKB8MpmWKF4sKm4RSh/K3y5u1H4D0POtw8R4DKN8g0lF3HSrKlPoTShHF
         JaKAatGwXfzX0PGk9iC5vBdqpBdQ2Nnw6/2ooxVgG9IXXlfn5OSMYE5Kga57P2uVJImw
         YA3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g47si2752494eda.400.2019.02.26.05.25.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 05:25:44 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 87974ACB7;
	Tue, 26 Feb 2019 13:25:43 +0000 (UTC)
Date: Tue, 26 Feb 2019 14:25:42 +0100
From: Michal Hocko <mhocko@kernel.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, hughd@google.com,
	"Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: hwpoison: fix thp split handing in
 soft_offline_in_use_page()
Message-ID: <20190226132542.GB10588@dhcp22.suse.cz>
References: <1551179880-65331-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1551179880-65331-1-git-send-email-zhongjiang@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Cc Kirril for the THP side]

On Tue 26-02-19 19:18:00, zhong jiang wrote:
> From: zhongjiang <zhongjiang@huawei.com>
> 
> When soft_offline_in_use_page() runs on a thp tail page after pmd is plit,
> we trigger the following VM_BUG_ON_PAGE():
> 
> Memory failure: 0x3755ff: non anonymous thp
> __get_any_page: 0x3755ff: unknown zero refcount page type 2fffff80000000
> Soft offlining pfn 0x34d805 at process virtual address 0x20fff000
> page:ffffea000d360140 count:0 mapcount:0 mapping:0000000000000000 index:0x1
> flags: 0x2fffff80000000()
> raw: 002fffff80000000 ffffea000d360108 ffffea000d360188 0000000000000000
> raw: 0000000000000001 0000000000000000 00000000ffffffff 0000000000000000
> page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)
> ------------[ cut here ]------------
> kernel BUG at ./include/linux/mm.h:519!
> 
> soft_offline_in_use_page() passed refcount and page lock from tail page to
> head page, which is not needed because we can pass any subpage to
> split_huge_page().
> 
> Cc: <stable@vger.kernel.org>        [4.5+]
> Signed-off-by: zhongjiang <zhongjiang@huawei.com>
> ---
>  mm/memory-failure.c | 14 ++++++--------
>  1 file changed, 6 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index d9b8a24..6edc6db 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1823,19 +1823,17 @@ static int soft_offline_in_use_page(struct page *page, int flags)
>  	struct page *hpage = compound_head(page);
>  
>  	if (!PageHuge(page) && PageTransHuge(hpage)) {
> -		lock_page(hpage);
> -		if (!PageAnon(hpage) || unlikely(split_huge_page(hpage))) {
> -			unlock_page(hpage);
> -			if (!PageAnon(hpage))
> +		lock_page(page);
> +		if (!PageAnon(page) || unlikely(split_huge_page(page))) {
> +			unlock_page(page);
> +			if (!PageAnon(page))
>  				pr_info("soft offline: %#lx: non anonymous thp\n", page_to_pfn(page));
>  			else
>  				pr_info("soft offline: %#lx: thp split failed\n", page_to_pfn(page));
> -			put_hwpoison_page(hpage);
> +			put_hwpoison_page(page);
>  			return -EBUSY;
>  		}
> -		unlock_page(hpage);
> -		get_hwpoison_page(page);
> -		put_hwpoison_page(hpage);
> +		unlock_page(page);
>  	}
>  
>  	/*
> -- 
> 1.7.12.4
> 

-- 
Michal Hocko
SUSE Labs

