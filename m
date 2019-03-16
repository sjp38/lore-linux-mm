Return-Path: <SRS0=HgWV=RT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80973C4360F
	for <linux-mm@archiver.kernel.org>; Sat, 16 Mar 2019 08:23:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26563218D0
	for <linux-mm@archiver.kernel.org>; Sat, 16 Mar 2019 08:23:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26563218D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 840606B02CF; Sat, 16 Mar 2019 04:23:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7ECB96B02D0; Sat, 16 Mar 2019 04:23:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6DB946B02D1; Sat, 16 Mar 2019 04:23:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 182AF6B02CF
	for <linux-mm@kvack.org>; Sat, 16 Mar 2019 04:23:58 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id p4so4847824edd.0
        for <linux-mm@kvack.org>; Sat, 16 Mar 2019 01:23:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=i2kcYL2mo3eoiQe4HbkfAUlUJ5Ud0yU1T8CG2rspfHw=;
        b=e0yszZw/EMFhudL2Ef2hRuqIK2UX0IlTDeefL0zpQcyIQZJH5w2xZRjOhhP6U2rW4T
         E6lAWKDVUTF5pdwZ9i0fZrG40yGuaYRfxNEpWYCeqVnGck9qtCAGwC0i5WERjhrzKScN
         OyJu9th+twBm+qzfeCpxAqwYvwvx41hvQqg2TQxqzYytsITOI3vX40y0LJ5CRNpneIOQ
         yI2VsOKCrCyH4lAMJd81Pp8UFVIR7YAd4u4TAZ6ps9GmB1e4Omo6hKI0sCCbNSWZTm/v
         TjxvNn6ALLq9Xjy/NfrkxGaTg2U8jxu8ZMsmCGKPp4zxeh2otmHuhRKTbQV0kMOhBF72
         zmAQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX+APaslgMwsc4M+VLx8w4YwDnC3Bo7UOz6tcuETYCkU/dk9VRu
	/NiQjFgAh4iKl5WBhFppTOPwq/RxE8Jb2Xy1x2e+0P5/p/lousV0ghh2QaJE2Rhk6Xw9rMht2Gm
	gKX11GUKwWAA+N1ii7wz+iT2vlkn1rwspQLEQxKKjzphMrAlR7AiDNz6TPLg1cWI=
X-Received: by 2002:a17:906:c9d5:: with SMTP id hk21mr4771852ejb.122.1552724637607;
        Sat, 16 Mar 2019 01:23:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIuk53K/Fl5tUMSO5aNyZWtXnIzpsyoKDXDVzFlhUIHZsxpiSnLuHkw99n1kQP4sHhYkSA
X-Received: by 2002:a17:906:c9d5:: with SMTP id hk21mr4771821ejb.122.1552724636650;
        Sat, 16 Mar 2019 01:23:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552724636; cv=none;
        d=google.com; s=arc-20160816;
        b=PT4Nwpn+2d6dRIiA33PS5D9vqxB1Mj9cOS39PmnTLcqPMSpaKwL6MKYah6q5/RmOi4
         1+twKbnBzM5ijveKaOkf0qVw8Ot9EjOzTq88zL6fIpLomztoFI90aGQWj2KNmN7rkVv3
         Zut8hqfcN/Sq4cSKPxRZOF0UCDqVo1uuEyCQXMdUrgapl8AI/Klad9Vv2j4KSBwFzuwr
         w/VknXqM06ABE5T81b/JuG2js3fWQ+ZRA3z0EO8+oJqbZl9+i7hn3rFKbxXXonm0nKOc
         op8PoY6i9UsS7/lA894Tk8IkgvFP5OQrclcLBdsZqbW+DCYTTrmYQhPmQOtf0Es7oQuG
         D8UA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=i2kcYL2mo3eoiQe4HbkfAUlUJ5Ud0yU1T8CG2rspfHw=;
        b=kBHu9Y9riMiFEDtHDgXOaHkYrD//FZ5cG+Rk57MZQYxzth0HSQmwZpTARDP+Nn9NTb
         +pZoaUCPzSxobRb80mwD7VpDsUcv2+5IFN8s08+GJJcGFTI/oMN2nJn5U/Td3s5dRxCb
         qpp2oBZX0mgEbBCbQOwzQkyzBw8Nn7/c4FHf5J1NsOH1LePs3goUbBK5PqpC5LBPcnS2
         QEdHoiSFPJQwgQa47tAt2WuKTHsWcgQ6GZsHlSdGJxAt3qWCVxrdBXFYUp8IclZOYOFY
         pLY2fCLAFZMPt2M8idVDY7Ywzjqt4ktWn6IO689xBNXcFyJkz5Ro7rnTmdbXnpkymdMB
         I+vw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w16si465364eje.64.2019.03.16.01.23.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Mar 2019 01:23:56 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A4B91AD3B;
	Sat, 16 Mar 2019 08:23:55 +0000 (UTC)
Date: Sat, 16 Mar 2019 09:23:54 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, anshuman.khandual@arm.com,
	william.kucharski@oracle.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>,
	Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: Fix __dump_page when mapping->host is not set
Message-ID: <20190316082354.GF15672@dhcp22.suse.cz>
References: <20190315121826.23609-1-osalvador@suse.de>
 <20190315124733.GE15672@dhcp22.suse.cz>
 <20190315143304.pkuvj4qwtlzgm7iq@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190315143304.pkuvj4qwtlzgm7iq@d104.suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 15-03-19 15:33:07, Oscar Salvador wrote:
> On Fri, Mar 15, 2019 at 01:47:33PM +0100, Michal Hocko wrote:
> > diff --git a/mm/debug.c b/mm/debug.c
> > index 1611cf00a137..499c26d5ebe5 100644
> > --- a/mm/debug.c
> > +++ b/mm/debug.c
> > @@ -78,6 +78,9 @@ void __dump_page(struct page *page, const char *reason)
> >  	else if (PageKsm(page))
> >  		pr_warn("ksm ");
> >  	else if (mapping) {
> > +		if (PageSwapCache(page))
> > +			mapping = page_swap_info(page)->swap_file->f_mapping;
> > +
> >  		pr_warn("%ps ", mapping->a_ops);
> >  		if (mapping->host->i_dentry.first) {
> >  			struct dentry *dentry;
> 
> This looks like a much nicer fix, indeed.

If we go this way then we should swap the order and print the mapping
before we alter it.

> I gave it a spin and it works.

Thanks for testing!

> Since the mapping is set during the swapon, I would assume that this should
> always work for swap.
> Although I am not sure if once you start playing with e.g zswap the picture can
> change.
> 
> Let us wait for Hugh and Jan.

Yes, I really cannot tell this is really safe. Maybe we want to do the
check for host anyway. Just to be sure.
-- 
Michal Hocko
SUSE Labs

