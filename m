Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6393C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 17:52:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 979F921743
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 17:52:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 979F921743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 374046B027D; Fri,  9 Aug 2019 13:52:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 325696B027E; Fri,  9 Aug 2019 13:52:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2136F6B0292; Fri,  9 Aug 2019 13:52:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C3FC06B027D
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 13:52:18 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c31so60788595ede.5
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 10:52:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+EnQ/hBCrWz4kOJWZvaOZliKLpp2eiWthmSJe+7Vl3o=;
        b=aGleLLnUhF6EXHkS+mAB/R/D435alk67RZdO5GluGRE4qNgcVcH3hCcCIIUX2KViyq
         Xn+z6Xf/2f9wplV1AcX7da36SMLkks4euHmQhhqwowOgpdlnQAAuCvCcyoiJrp0i4EsO
         fzwHG8zMcresoIXP6PMsjo7aFY4IV/+ERIiD5wwA85nMCLaDakt68x6FTV8kiF5F8hHs
         MsTksXI8unZpk3pb/kxXChHeI9DgUTi48qAN+9M3wAO1Y0p+aHMsoeHsDQqlAHE0nF7T
         AQlwXGy0NfXAIcDlt8GczxRoXLB/T8NIi4qy+MTO4PcBZWVDNhkcy9b7QdC+7PaVuG28
         i2tw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVVvzXFOr5yjt7KHg3eI6Gz6iaYMomoR+UdzJkzGXwnZXqHNQOZ
	g8GGFOt32HbFloKrXl/8jgkFqVInbWO32a/bvPXKsOwq1eAr8y1DnIRjEYHQLWawwEdouHpzU3P
	spq2gkmBevj3yL9jtMeJNgw0MwFy69/BMF6gilPywqXMjsYlQUPRJJgOMifk3Vfs=
X-Received: by 2002:a17:906:b34d:: with SMTP id cd13mr19513729ejb.107.1565373138339;
        Fri, 09 Aug 2019 10:52:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxilRm8LcavCOfV878zLNDKSfQW8SUz7Ifv3EA0n3Il9Namvtb6dDFJg4/Otv33vE+2nYO6
X-Received: by 2002:a17:906:b34d:: with SMTP id cd13mr19513667ejb.107.1565373137386;
        Fri, 09 Aug 2019 10:52:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565373137; cv=none;
        d=google.com; s=arc-20160816;
        b=r6jcypJBflam8eyeWDLO04mtXiTl4H2VFF3l/YIG4A14u/gTJWN3yCgY1Fka3v1HQF
         24evlHtf6hVKX2/ppLJUOVLXUhh/WWcFw1UaWmIqwJU6k6997On8mWGAstV6Fyc9aDyV
         b0LG+rrcij7kuK4kHxGRHAiSx3xNhKjVk316AOTLjO29aX7iOZaKJQ5/VZaYbdAu9VT8
         qBkeczHYhCxydVOxaFXXL3XajgYNxC3+h/rEp4dNudNbxh/evfqOjCYeSVcPuRrFmIXe
         Tedw2tOC6a2KKDhasqT7ZqBuGn+KAzJPl5mm3CbNhYbvQO9BDDNWdhIleC5fM6ex+Qc2
         MraQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+EnQ/hBCrWz4kOJWZvaOZliKLpp2eiWthmSJe+7Vl3o=;
        b=DncV9CeEV0c/q1K7fedGm1I9sMc47nTvU1XW1kssUX80ArXl86DugBAV8/aeleEBsJ
         oCXQo2CmioQwxVqySQ4db6Hyj13F8AOOlwlK+PviuJsFbGXdhJ6WCACEtGMrXgXLAlTi
         qoD/ushKCgGcbZGGykRRTJDMBfE6vn0yS37l5AA3IOuSgAR0dzq66TJh887VIma0TxSJ
         grVN01Wj/meBQ0esGJcZE0BTKL1+dcygsYtOUWyt3T53RyZmmn57fFKk3+ytPcNqL0HW
         G4quPkh53k+HPSut8ON4MJqsyHjwe20VWBkpybuDfuRW3dBXIs/krf+K9wo/l14Iuhnc
         uAjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o25si33187628eju.237.2019.08.09.10.52.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 10:52:17 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 97480ADCB;
	Fri,  9 Aug 2019 17:52:16 +0000 (UTC)
Date: Fri, 9 Aug 2019 19:52:10 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Jan Kara <jack@suse.cz>
Cc: John Hubbard <jhubbard@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Ira Weiny <ira.weiny@intel.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Jerome Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	Dan Williams <dan.j.williams@intel.com>,
	Daniel Black <daniel@linux.ibm.com>,
	Matthew Wilcox <willy@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>
Subject: Re: [PATCH 1/3] mm/mlock.c: convert put_page() to put_user_page*()
Message-ID: <20190809175210.GR18351@dhcp22.suse.cz>
References: <20190805222019.28592-2-jhubbard@nvidia.com>
 <20190807110147.GT11812@dhcp22.suse.cz>
 <01b5ed91-a8f7-6b36-a068-31870c05aad6@nvidia.com>
 <20190808062155.GF11812@dhcp22.suse.cz>
 <875dca95-b037-d0c7-38bc-4b4c4deea2c7@suse.cz>
 <306128f9-8cc6-761b-9b05-578edf6cce56@nvidia.com>
 <d1ecb0d4-ea6a-637d-7029-687b950b783f@nvidia.com>
 <420a5039-a79c-3872-38ea-807cedca3b8a@suse.cz>
 <20190809082307.GL18351@dhcp22.suse.cz>
 <20190809135813.GF17568@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190809135813.GF17568@quack2.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 09-08-19 15:58:13, Jan Kara wrote:
> On Fri 09-08-19 10:23:07, Michal Hocko wrote:
> > On Fri 09-08-19 10:12:48, Vlastimil Babka wrote:
> > > On 8/9/19 12:59 AM, John Hubbard wrote:
> > > >>> That's true. However, I'm not sure munlocking is where the
> > > >>> put_user_page() machinery is intended to be used anyway? These are
> > > >>> short-term pins for struct page manipulation, not e.g. dirtying of page
> > > >>> contents. Reading commit fc1d8e7cca2d I don't think this case falls
> > > >>> within the reasoning there. Perhaps not all GUP users should be
> > > >>> converted to the planned separate GUP tracking, and instead we should
> > > >>> have a GUP/follow_page_mask() variant that keeps using get_page/put_page?
> > > >>>  
> > > >>
> > > >> Interesting. So far, the approach has been to get all the gup callers to
> > > >> release via put_user_page(), but if we add in Jan's and Ira's vaddr_pin_pages()
> > > >> wrapper, then maybe we could leave some sites unconverted.
> > > >>
> > > >> However, in order to do so, we would have to change things so that we have
> > > >> one set of APIs (gup) that do *not* increment a pin count, and another set
> > > >> (vaddr_pin_pages) that do. 
> > > >>
> > > >> Is that where we want to go...?
> > > >>
> > > 
> > > We already have a FOLL_LONGTERM flag, isn't that somehow related? And if
> > > it's not exactly the same thing, perhaps a new gup flag to distinguish
> > > which kind of pinning to use?
> > 
> > Agreed. This is a shiny example how forcing all existing gup users into
> > the new scheme is subotimal at best. Not the mention the overal
> > fragility mention elsewhere. I dislike the conversion even more now.
> > 
> > Sorry if this was already discussed already but why the new pinning is
> > not bound to FOLL_LONGTERM (ideally hidden by an interface so that users
> > do not have to care about the flag) only?
> 
> The new tracking cannot be bound to FOLL_LONGTERM. Anything that gets page
> reference and then touches page data (e.g. direct IO) needs the new kind of
> tracking so that filesystem knows someone is messing with the page data.
> So what John is trying to address is a different (although related) problem
> to someone pinning a page for a long time.

OK, I see. Thanks for the clarification.

> In principle, I'm not strongly opposed to a new FOLL flag to determine
> whether a pin or an ordinary page reference will be acquired at least as an
> internal implementation detail inside mm/gup.c. But I would really like to
> discourage new GUP users taking just page reference as the most clueless
> users (drivers) usually need a pin in the sense John implements. So in
> terms of API I'd strongly prefer to deprecate GUP as an API, provide
> vaddr_pin_pages() for drivers to get their buffer pages pinned and then for
> those few users who really know what they are doing (and who are not
> interested in page contents) we can have APIs like follow_page() to get a
> page reference from a virtual address.

Yes, going with a dedicated API sounds much better to me. Whether a
dedicated FOLL flag is used internally is not that important. I am also
for making the underlying gup to be really internal to the core kernel.

Thanks!
-- 
Michal Hocko
SUSE Labs

