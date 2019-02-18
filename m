Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 825EAC10F01
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 17:57:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3BBE0217D9
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 17:57:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="XaKaNOye"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BBE0217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C12948E0003; Mon, 18 Feb 2019 12:57:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B992F8E0002; Mon, 18 Feb 2019 12:57:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A3A3A8E0003; Mon, 18 Feb 2019 12:57:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9A98E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 12:57:30 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 38so10626704pld.6
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 09:57:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+Plq0e0BG0Zenzxpp1loEbirrQRhIFIHE6Uh3NdBTOU=;
        b=kg0cp6Gax1D1dznn/C2GKqj7/211i/vo2aTS8tazw64uBwEo+S8NOsWxmqX0lYdTbQ
         gBIqRnYM9eVTQRubOHjxYreiRC9Me1p2cCoZCeCVoKW3ZxheefiwvEQKTyCftgYzcO7o
         EtTIVmGYxPXYwrBz22XkupK7GoPVuC1LERA6AjFZIzbXDmZtrNsPXdXYuVXMGxgkSOwE
         7W+mCOqu6Kmi6B57OnO61neWL02qJpPqmJ5efkbWqUHPD3NsOcaAhfiHVzlWIpmpNhyt
         8PJAkf8AAx/t9/64gWyNGzdbdC3BdyMy+fJIj07XS2/H28U10q4asqAgU7utkuYeTf/d
         1T8g==
X-Gm-Message-State: AHQUAua9ZEC9xA0/3l/1XwP4j+c1/biq/lCjiz9ZnItD7X9DWO9APLnZ
	slF34qnxUmeLR2xOjtyOgas9G8OPAh9a+0qFkxNyiBrKIq8llkG5+KkTqOlMZ1HXgeb9PCbdh0t
	7jOd7P6X9qE4nN+KKBCramnIJQ5Lhi4Rr/9cI3A76ErOM+gNrnjuialqExAhPW379kg==
X-Received: by 2002:a62:5c1:: with SMTP id 184mr25087081pff.165.1550512649926;
        Mon, 18 Feb 2019 09:57:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbREdRAXCQ5uZ9wVAvnEDG84rKyszKsiJA1yEMzFIurrFM5YFx8aUrItR5wGIY+tlBr5vXQ
X-Received: by 2002:a62:5c1:: with SMTP id 184mr25087042pff.165.1550512649316;
        Mon, 18 Feb 2019 09:57:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550512649; cv=none;
        d=google.com; s=arc-20160816;
        b=JN6l+v8XuZjCfQKK2Kk69/RwL1BccRH76kfBGAH6tPHk5fZwKnSWju1GZhCPMdRy8J
         F8Yw+hMiX8JLvCR+rQcCzAs4ortdqReP1UC/o7wnm3ww/60E//f/KV3coiT6NsdHSJs7
         2xOy5e3/VO29qJYf/xtSBIuSuAEdgK/cafrrFM4c4hwFBW6RQAWTyu5GWWG+w8EUXb80
         hcEaiPuVn7mj9ZFRgLlhsSPxlz47Ln6rqHLVnCnacdNSis32ukX6pEl2UKc6UGK/f2cw
         rm0+HTPfuLCWVuJAqjg9tsp7Q0skJnNluAdk4VcDARBZnUfavZiNfWWdCSQxHk4b26PQ
         1psg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+Plq0e0BG0Zenzxpp1loEbirrQRhIFIHE6Uh3NdBTOU=;
        b=ooi1P+kBmIL9hwkoKORjTjo3BE2UFyb0VSn0xVjVbgT+hHO7+xy9GmFPO8kWEEqzFZ
         Qw3Dyics95yky/rA4FKSr/lTnDWrEVxUubKGo5rA0JN0KyTIIuX6kpEC+AeK6dKUL8rc
         G5U3geaGEsxYXLeQNutDOU//FvuMZtwzS6Glygy2vw2kvNmZur6x2lfTH9hlukNZ0kDi
         AgZWPCjJueX2goXCf5wPl8w4f2yCSORlBwCxAzLfHPWU6Bg98KAFvpnzh/CbJiDCtjz2
         sLdDEGsMlucHCUNKwannXkbkO1RwRqifqbCjET7S12+1E9rSLFLq3OIaMydPZtebyKYp
         POig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=XaKaNOye;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n4si13698192pgd.10.2019.02.18.09.57.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 09:57:29 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=XaKaNOye;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=+Plq0e0BG0Zenzxpp1loEbirrQRhIFIHE6Uh3NdBTOU=; b=XaKaNOyelEJ3LS2EGOgFm5tvo
	TOj+pO6qm3IO4tsX5n6FTnzhLPojb3Ksjfn9BYX5TrTysdFk6Hz5iFg8Ow7+vCfV68CeSQs+YkRzA
	+9yGx7VFINhjJrk4hg1LoOEnuemS4tK6b71Ruc0vRUY8eUOULvSgFZKRILcxIEqm2OqbCLE58GG7T
	g/qByk2T8ha16EHt6REkmnm+aeWMhdFAZyvRiF2mKiIggOtBwDYT3W3O9fAvS57LHsrQ5L7JnOr/0
	ysN9bT3l7tcwRceG2q9VO3ZrcR7+ZzfDP7xab0hj5JECFHNCwNDn1NpO+sJjDarK8BX0hqTkZ6Hex
	5Yrky4LLg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gvnAU-00028C-Cp; Mon, 18 Feb 2019 17:57:26 +0000
Date: Mon, 18 Feb 2019 09:57:26 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>, Rong Chen <rong.a.chen@intel.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	linux-kernel@vger.kernel.org,
	Linux Memory Management List <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>, LKP <lkp@01.org>,
	Oscar Salvador <osalvador@suse.de>
Subject: Re: [LKP] efad4e475c [ 40.308255] Oops: 0000 [#1] PREEMPT SMP PTI
Message-ID: <20190218175726.GU12668@bombadil.infradead.org>
References: <20190218052823.GH29177@shao2-debian>
 <20190218070844.GC4525@dhcp22.suse.cz>
 <20190218085510.GC7251@dhcp22.suse.cz>
 <4c75d424-2c51-0d7d-5c28-78c15600e93c@intel.com>
 <20190218103013.GK4525@dhcp22.suse.cz>
 <20190218140515.GF25446@rapoport-lnx>
 <20190218152050.GS4525@dhcp22.suse.cz>
 <20190218152213.GT4525@dhcp22.suse.cz>
 <20190218164813.GG25446@rapoport-lnx>
 <20190218170558.GV4525@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190218170558.GV4525@dhcp22.suse.cz>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 06:05:58PM +0100, Michal Hocko wrote:
> +	end_pfn = min(start_pfn + nr_pages,
> +			zone_end_pfn(page_zone(pfn_to_page(start_pfn))));
>  
>  	/* Check the starting page of each pageblock within the range */
> -	for (; page < end_page; page = next_active_pageblock(page)) {
> -		if (!is_pageblock_removable_nolock(page))
> +	for (; start_pfn < end_pfn; start_pfn = next_active_pageblock(start_pfn)) {
> +		if (!is_pageblock_removable_nolock(start_pfn))

If you have a zone which contains pfns that run from ULONG_MAX-n to ULONG_MAX,
end_pfn is going to wrap around to 0 and this loop won't execute.  I think
you should use:

	max_pfn = min(start_pfn + nr_pages,
			zone_end_pfn(page_zone(pfn_to_page(start_pfn)))) - 1;

	for (; start_pfn <= max_pfn; ...)

