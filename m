Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90F36C04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 13:59:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B6482054F
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 13:59:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B6482054F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D10546B0005; Mon,  6 May 2019 09:59:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9A216B0006; Mon,  6 May 2019 09:59:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B395F6B0007; Mon,  6 May 2019 09:59:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 62A2F6B0005
	for <linux-mm@kvack.org>; Mon,  6 May 2019 09:59:57 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b22so12300104edw.0
        for <linux-mm@kvack.org>; Mon, 06 May 2019 06:59:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=AzVOi9B/o+hwpu1QwDLluRFv8LqJiaSijGvI5Yui/0U=;
        b=OyC5DV22HghajWlZEoUNAgjFpmijp3ZVcde1oe6AIHHgNh445KbObNydwViYg2rawH
         kWQ/dYXNxeKDb5LC14WmYtB3C9AHAzmkHRnScqQHBrWZFbtrkqnRVy+AdZFLN/vNeZ4J
         N0XDwAvSG71vPF0YuA46pw0xXFLOVlkTLGHYg2C6ohO+JXP/h8JkafWfe4xu7EH7SRG3
         SUb4gjsAZv0D9IPLN5SzULYgGkh4qsZdJYoXNz6VBhD/Tp99Mr+KSgyI2DtpHqun7abS
         qtwD/UcUXhkxV3l4/6wybocpDOaZckO5M+2H0hxq/7haT86HhPjG+H0nc86xhSeEfkGQ
         ha7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAWOsNUD6zarQv6KmQRQleB5S+zRjkIWIrvPxNo71wxW3mJCFMo0
	9Iud3mCnALF2zquLrBcUuSBQnMeVQgTNBac6+yASWMJvhBNKeMz3a32cwPfa265PRALiEIBcooP
	21YzpBBTsWke0c6/1fnTxgjjbtmZQ6oLvcd8SrPZ3sSYIxNIrReZ+hKy73yHjY71eLw==
X-Received: by 2002:a17:906:660c:: with SMTP id b12mr19476207ejp.299.1557151196932;
        Mon, 06 May 2019 06:59:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZe1m0h4rwir1EDC48rLfCpYnrov7tPj+alZvhdPAM5TR6n64FUMsU8hcnxAi6Yo7wx9Lh
X-Received: by 2002:a17:906:660c:: with SMTP id b12mr19476116ejp.299.1557151195758;
        Mon, 06 May 2019 06:59:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557151195; cv=none;
        d=google.com; s=arc-20160816;
        b=qZ8aHpKdiVJtbEhtW0OTxnuJ8h0YZvmDi20y5rp2el0oYY04b6aqsYKJUcc/yMNm1y
         XKo9R8vORw+s/WeeUra9F/bO872NUApxztAUPF+5ykU8nihB9/yLYQZHhodvprOeWolQ
         LZZ8X45xI1bY9EuovSwXY4vUKDGfmQW+vJyizEuz4bZrsm5PuhrCdBp6ATWKHxGzBjbN
         xDxB0Ex+Bwou8+uKUGr1T5e7os/JPjqq3NpPqyqOMlPSA4IKz2mD2HVwenuDcR2Q/CI4
         YZLslHOAThVKo2OZ6iYatcXd670qxYtoSJNf2It5NMulrObRid0iFqO6vknG1sG9HJUi
         GNWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=AzVOi9B/o+hwpu1QwDLluRFv8LqJiaSijGvI5Yui/0U=;
        b=nTvQV8X7iJ5RzECP059FCVn9ENUeqJ/3jUNSns/sNa4uuHr5qOtL5DROEUk9s9PWV5
         zEsO6a9EnHu7nOZeZjoqrtd6J3Hw0QLJD8xRrwR9fmODlWHTEkq8QPdZ74jhQ8vJWkC8
         4H9fhMU5axuYMxnK60VA7hj73lhq/3tQSXte+VGrxXS4+UgYpYn6yRoLD30wkRpFySwm
         6LSUrjWfSgePbfFb3XmMnd/xLJ3a8M0IFojWVjcy+80OsUwPci1prsnGuT7r7Ftme/84
         CQtN4TGQa6TJXnHcwWZembz6D5ljjsz/wWFusGX+K+jMW/nWjrhExB0prjCqpX8d/ua+
         lDBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g55si1685450edc.336.2019.05.06.06.59.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 06:59:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3253EAECB;
	Mon,  6 May 2019 13:59:55 +0000 (UTC)
Date: Mon, 6 May 2019 15:59:54 +0200
From: Michal Hocko <mhocko@suse.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm/memcontrol: avoid unnecessary PageTransHuge() when
 counting compound page
Message-ID: <20190506135954.GB31017@dhcp22.suse.cz>
References: <1557038457-25924-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1557038457-25924-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun 05-05-19 14:40:57, Yafang Shao wrote:
> If CONFIG_TRANSPARENT_HUGEPAGE is not set, hpage_nr_pages() is always 1;
> if CONFIG_TRANSPARENT_HUGEPAGE is set, hpage_nr_pages() will
> call PageTransHuge() to judge whether the page is compound page or not.
> So we can use the result of hpage_nr_pages() to avoid uneccessary
> PageTransHuge().

The changelog doesn't describe motivation. Does this result in a better
code/performance?
 
> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> ---
>  mm/memcontrol.c | 13 ++++++-------
>  1 file changed, 6 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2535e54..65c6f7c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -6306,7 +6306,6 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage)
>  {
>  	struct mem_cgroup *memcg;
>  	unsigned int nr_pages;
> -	bool compound;
>  	unsigned long flags;
>  
>  	VM_BUG_ON_PAGE(!PageLocked(oldpage), oldpage);
> @@ -6328,8 +6327,7 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage)
>  		return;
>  
>  	/* Force-charge the new page. The old one will be freed soon */
> -	compound = PageTransHuge(newpage);
> -	nr_pages = compound ? hpage_nr_pages(newpage) : 1;
> +	nr_pages = hpage_nr_pages(newpage);
>  
>  	page_counter_charge(&memcg->memory, nr_pages);
>  	if (do_memsw_account())
> @@ -6339,7 +6337,7 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage)
>  	commit_charge(newpage, memcg, false);
>  
>  	local_irq_save(flags);
> -	mem_cgroup_charge_statistics(memcg, newpage, compound, nr_pages);
> +	mem_cgroup_charge_statistics(memcg, newpage, nr_pages > 1, nr_pages);
>  	memcg_check_events(memcg, newpage);
>  	local_irq_restore(flags);
>  }
> @@ -6533,6 +6531,7 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>  	struct mem_cgroup *memcg, *swap_memcg;
>  	unsigned int nr_entries;
>  	unsigned short oldid;
> +	bool compound;
>  
>  	VM_BUG_ON_PAGE(PageLRU(page), page);
>  	VM_BUG_ON_PAGE(page_count(page), page);
> @@ -6553,8 +6552,9 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>  	 */
>  	swap_memcg = mem_cgroup_id_get_online(memcg);
>  	nr_entries = hpage_nr_pages(page);
> +	compound = nr_entries > 1;
>  	/* Get references for the tail pages, too */
> -	if (nr_entries > 1)
> +	if (compound)
>  		mem_cgroup_id_get_many(swap_memcg, nr_entries - 1);
>  	oldid = swap_cgroup_record(entry, mem_cgroup_id(swap_memcg),
>  				   nr_entries);
> @@ -6579,8 +6579,7 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>  	 * only synchronisation we have for updating the per-CPU variables.
>  	 */
>  	VM_BUG_ON(!irqs_disabled());
> -	mem_cgroup_charge_statistics(memcg, page, PageTransHuge(page),
> -				     -nr_entries);
> +	mem_cgroup_charge_statistics(memcg, page, compound, -nr_entries);
>  	memcg_check_events(memcg, page);
>  
>  	if (!mem_cgroup_is_root(memcg))
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

