Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC62CC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 18:12:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C2392085A
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 18:12:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C2392085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2DBC8E0004; Mon, 18 Feb 2019 13:11:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDC038E0002; Mon, 18 Feb 2019 13:11:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ACD278E0004; Mon, 18 Feb 2019 13:11:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 575D08E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:11:59 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id a21so6246176eda.3
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 10:11:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BPEyRHUeW9pHOKKVpyBbmYudYBxq69ZRRT70XUQav04=;
        b=CGnJcvczZM0VtAv6e9Z7drRYOsM+yJn/bvc8ig9L31+b4x1hqb/lwtIzgHKEnr25UN
         XfUWImE7hP6UYPQMzWpXS37mdjd+dc0whLaqFq9QCFSGJ2KMJyK0E733bG5mM0AlOY5X
         Bjo7c8+1JERPWbJUmgcUViqSDPmgxISL+zL/nx0ul7lZmhHoxrlX61JQQqJAISKlAWzb
         F5Z46MTh7uE8EuAmopbZ5wVaZZVeC/JmJKFv38gtWydHmHUdKwqTkENyrkdVLyhDfPHe
         Cp3lE4SSCH+qHclYrx2i988zIK/EIDqfHv1k2l9z/jE7fIGLBFt0xH2ZXGfnay3eJEvV
         364A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYFE1hIfho0oNmdGa9YvZjg5NEIovVrv1qHIc1WVoJOdlOQCaMN
	U/CgAooC60vieUYP4yjm/qmIPCiz9n14LbPQ0qAU3MD+Z/tJ6qsswzHG8Bt6pHnGP+Ny9wu63iG
	57133KH+xPwIiMK7IXXkVq1UgkRyg4g7irrQvp5xcavqxhUJuOVPIVYZydPTbuxI=
X-Received: by 2002:a50:b49b:: with SMTP id w27mr3868638edd.54.1550513518827;
        Mon, 18 Feb 2019 10:11:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbVWfjg5TfYAB5HeARg3m2WX82q98zxMTKPNWrgM1gr4sOxHI8WDn5nwv7V6gVC4Vpz8la/
X-Received: by 2002:a50:b49b:: with SMTP id w27mr3868576edd.54.1550513517805;
        Mon, 18 Feb 2019 10:11:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550513517; cv=none;
        d=google.com; s=arc-20160816;
        b=jD4G/icMOcGvW0g7dhSPMKqsj/BuDyISq1nmkJcvTu6MRrtVL64fIQRAIZK4zOeOlk
         7+Dj0KgrlbUEptGeiCEQkz6QJOi2GJfwf4YHIC+sKUR+rpMvv0mDTQOunDaAeQ9gIkbU
         ksDy0zG2OzIm3p4sqh1CBEyovlT25D4fZieEfFIJZKU0epCAaIX4mlK7OqXcFMbLuFc6
         MYqntwpQz2nG7Yu8ncM5VAGNXVgJTy0BVCDaWGqGq/CzBQ4UOjInPSrtA24GsVDxCP9S
         RFCg+eLR3uwx5pGyCjnf9MpTU+sEsfQpgWlXCaMb3QFhlAIeuf5jeGpxRQRKPZhDPbi7
         Gy1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BPEyRHUeW9pHOKKVpyBbmYudYBxq69ZRRT70XUQav04=;
        b=lQcSehWalBe7Fd418c18hBjhbHdP7K8V98Ep5Ejwn4i0veoQfS624RwcDFpm+mMCDS
         I67Lql8dHWiu0MmQVtnpVX0nZwXffAYNer1WS/GQ0pshUC2VHTc+exAIQDUTBOMouh8v
         EYv5q9KBci3th0SB3nia1SGR6hCjte8DW4ZN0GLxsxPe8NOZ3yGPDEGrr3j/7vTap1L/
         9SN9zkDB+u4zTN+Iead0KeYSVGHt8G1V8+t7dGlaP36ieWoaZOuPelvOB6oP0LoH8zHi
         Kcp5wXg5wAblJ6YA7hxGTUfLskVhRR/ME65ps1hcnbYaeohx73bYNdyJaEDKQH2CQGr8
         ZfBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n6si1520086edr.330.2019.02.18.10.11.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 10:11:57 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E0754AC4C;
	Mon, 18 Feb 2019 18:11:56 +0000 (UTC)
Date: Mon, 18 Feb 2019 19:11:55 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>, Rong Chen <rong.a.chen@intel.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	linux-kernel@vger.kernel.org,
	Linux Memory Management List <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>, LKP <lkp@01.org>,
	Oscar Salvador <osalvador@suse.de>
Subject: Re: [LKP] efad4e475c [ 40.308255] Oops: 0000 [#1] PREEMPT SMP PTI
Message-ID: <20190218181155.GC4525@dhcp22.suse.cz>
References: <20190218070844.GC4525@dhcp22.suse.cz>
 <20190218085510.GC7251@dhcp22.suse.cz>
 <4c75d424-2c51-0d7d-5c28-78c15600e93c@intel.com>
 <20190218103013.GK4525@dhcp22.suse.cz>
 <20190218140515.GF25446@rapoport-lnx>
 <20190218152050.GS4525@dhcp22.suse.cz>
 <20190218152213.GT4525@dhcp22.suse.cz>
 <20190218164813.GG25446@rapoport-lnx>
 <20190218170558.GV4525@dhcp22.suse.cz>
 <20190218175726.GU12668@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190218175726.GU12668@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 18-02-19 09:57:26, Matthew Wilcox wrote:
> On Mon, Feb 18, 2019 at 06:05:58PM +0100, Michal Hocko wrote:
> > +	end_pfn = min(start_pfn + nr_pages,
> > +			zone_end_pfn(page_zone(pfn_to_page(start_pfn))));
> >  
> >  	/* Check the starting page of each pageblock within the range */
> > -	for (; page < end_page; page = next_active_pageblock(page)) {
> > -		if (!is_pageblock_removable_nolock(page))
> > +	for (; start_pfn < end_pfn; start_pfn = next_active_pageblock(start_pfn)) {
> > +		if (!is_pageblock_removable_nolock(start_pfn))
> 
> If you have a zone which contains pfns that run from ULONG_MAX-n to ULONG_MAX,
> end_pfn is going to wrap around to 0 and this loop won't execute.

Is this a realistic situation to bother?

> I think
> you should use:
> 
> 	max_pfn = min(start_pfn + nr_pages,
> 			zone_end_pfn(page_zone(pfn_to_page(start_pfn)))) - 1;
> 
> 	for (; start_pfn <= max_pfn; ...)

I do not really care strongly, but we have more places were we do
start_pfn + nr_pages and then use it as pfn < end_pfn construct. I
suspect we would need to make a larger audit and make the code
consistent so unless there are major concerns I would stick with what
I have for now and leave the rest for the cleanup. Does that sound
reasonable?

-- 
Michal Hocko
SUSE Labs

