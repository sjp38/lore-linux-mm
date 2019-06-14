Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0787DC31E4D
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 15:35:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C96922177E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 15:35:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C96922177E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CA426B000D; Fri, 14 Jun 2019 11:35:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67B086B000E; Fri, 14 Jun 2019 11:35:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 591066B0266; Fri, 14 Jun 2019 11:35:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0B6B96B000D
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:35:44 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i9so4139527edr.13
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 08:35:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=iitiSONiOt/KeScHjUeGXfdj2CqUz1GvYKXpCZFQaww=;
        b=ExEJCR13Yt6WPB4l6PDL15sl2VbsXJrFN8TWztMdoQItm+HMnR+UtiOkY6Za3Wbn9w
         p/hvn9kStkDJMlSmZ+8FERsQ8ClF+AFMDEYZ2ySgIVHZKF5O2211+b06t3HGroOO7aa/
         F2QdMazerI56wNNZZzi7M+wyuDbmcbLQoyZAusQNZ2eWZpNxZnWaNGFJWJg/SrS4AVmH
         SB1oBJ0DlDAo1XMFxGd+RJsmNbfeASyG71PpdnPsISV+YOtbp+Q34QMexFhjQaaT4e9f
         27Qar9coWb5b2luNAQufDWVVIxmxZ57eYocm7Y6PoRRA2JpsUuuXsLsON6y/GjhVk6nm
         nqtQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUVwb/gOOoE9SR00fJHIci9M2Z1tMQughEUWBR+FeTwT2mOlKwh
	AeKn24GuvT0MOv1YZRSoOFfT7qvHVv7Nk9wyJFZ4i8kxU4osB+ArzQixpnwoV8pWSs+Y42m3fMV
	7P4jJTNVVF338koe62zAwNZYeAh3+ppiLFfcY2k4QAgP2bkF8H66WMACsOBYU2Eqt4g==
X-Received: by 2002:a50:94a2:: with SMTP id s31mr61924975eda.290.1560526543550;
        Fri, 14 Jun 2019 08:35:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdUJhn+7l4RFIeBgw7k1J9kA6CxXgGqIfq72dzA9Amsz732Ph7VsWuNRG76CmTA8juSNbu
X-Received: by 2002:a50:94a2:: with SMTP id s31mr61924887eda.290.1560526542716;
        Fri, 14 Jun 2019 08:35:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560526542; cv=none;
        d=google.com; s=arc-20160816;
        b=IEQu0HCmZRBfiPOoOIrQZGeAjNdXmldZmMwIZmXwv8xQHPwGbV6WWy4KOcpv0pTmUb
         oijeOtOlgb4Y/NKML0ULtJhEzSfsulkwvkTmeeBYjszl/6j1ordVKf0a1z3vWXAY5tbL
         OYrqcSOPJuoIobNkYgnHvj2luSNmQh6duuqEfdiy5bi9F9VSlEB817zyhKcTd+WJD6B7
         XBGIEg9PVfQ3z4NDWTIqRVMtRjs59Vw95X/RiXtEUP5PnQKT7N09rO//d7HqYRvjfZKg
         oMOKVuGx5rkDwxTq9vVeH4/IRA8ul/8s2KWFBqvFywUcd0XPwyyKP08sZckM0039qj0+
         K0pg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=iitiSONiOt/KeScHjUeGXfdj2CqUz1GvYKXpCZFQaww=;
        b=dlXcG98HnK/64SbFjAzTKAuOH3akBcPhJWewo1h4B1SlZGP3D7u+6CzKWiI+pjysl0
         7nf7Qs8yHveNAkRHwAfptRxzRr2MykJajFZGN1YUUNB60eb1SWpnbfGboL8e6vgxv/sQ
         2QMveKBMLT4by/XdSZU/5yf8FbEzj7fTD5HBA/V9//bms/eFdbWjwG9uPmHlKUl2Php9
         Z6HCCu+TDE8VvCQzKTeeki5OCgoNFC4D3GVMhVrhJfVr++wU60jsBEAqq2DU0fyamSS1
         rTpqAyCTtqWyRpBYKPB0QSfs24tEH8tJdHWOX3dPT4p3A2vDaK7BvcihW0ADm+bta9mz
         qFYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x46si2192011eda.54.2019.06.14.08.35.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 08:35:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E91E2ACAC;
	Fri, 14 Jun 2019 15:35:41 +0000 (UTC)
Date: Fri, 14 Jun 2019 17:35:39 +0200
From: Oscar Salvador <osalvador@suse.de>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Qian Cai <cai@lca.pw>, Dan Williams <dan.j.williams@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH -next] mm/hotplug: skip bad PFNs from pfn_to_online_page()
Message-ID: <20190614153535.GA9900@linux>
References: <1560366952-10660-1-git-send-email-cai@lca.pw>
 <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com>
 <CAPcyv4iuNYXmF0-EMP8GF5aiPsWF+pOFMYKCnr509WoAQ0VNUA@mail.gmail.com>
 <1560376072.5154.6.camel@lca.pw>
 <87lfy4ilvj.fsf@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87lfy4ilvj.fsf@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 02:28:40PM +0530, Aneesh Kumar K.V wrote:
> Can you check with this change on ppc64.  I haven't reviewed this series yet.
> I did limited testing with change . Before merging this I need to go
> through the full series again. The vmemmap poplulate on ppc64 needs to
> handle two translation mode (hash and radix). With respect to vmemap
> hash doesn't setup a translation in the linux page table. Hence we need
> to make sure we don't try to setup a mapping for a range which is
> arleady convered by an existing mapping. 
> 
> diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
> index a4e17a979e45..15c342f0a543 100644
> --- a/arch/powerpc/mm/init_64.c
> +++ b/arch/powerpc/mm/init_64.c
> @@ -88,16 +88,23 @@ static unsigned long __meminit vmemmap_section_start(unsigned long page)
>   * which overlaps this vmemmap page is initialised then this page is
>   * initialised already.
>   */
> -static int __meminit vmemmap_populated(unsigned long start, int page_size)
> +static bool __meminit vmemmap_populated(unsigned long start, int page_size)
>  {
>  	unsigned long end = start + page_size;
>  	start = (unsigned long)(pfn_to_page(vmemmap_section_start(start)));
>  
> -	for (; start < end; start += (PAGES_PER_SECTION * sizeof(struct page)))
> -		if (pfn_valid(page_to_pfn((struct page *)start)))
> -			return 1;
> +	for (; start < end; start += (PAGES_PER_SECTION * sizeof(struct page))) {
>  
> -	return 0;
> +		struct mem_section *ms;
> +		unsigned long pfn = page_to_pfn((struct page *)start);
> +
> +		if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
> +			return 0;

I might be missing something, but is this right?
Having a section_nr above NR_MEM_SECTIONS is invalid, but if we return 0 here,
vmemmap_populate will go on and populate it.

-- 
Oscar Salvador
SUSE L3

