Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0863EC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:23:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF80F2173E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:23:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF80F2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A8956B0005; Fri,  9 Aug 2019 04:23:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4323B6B0006; Fri,  9 Aug 2019 04:23:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 321526B0007; Fri,  9 Aug 2019 04:23:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D6A246B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 04:23:09 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l14so59876969edw.20
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 01:23:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+qK2N6eyLQw8l+UY3rt97fTziJpeYBs2qOi3sj1MsaM=;
        b=hNdLNdbCngj3WamK+8+1txuXxgITNAVhbNO8hfwhkirIseCxzTQYSNoyEjbEA2n/UV
         DNaFd2f1pxwWPM2TvnETncvBd3ru1KYhPPoBLqRbh6z4Fark4R7MKLtrFXQ+3yV8Tif/
         +g10J8DeNbPdeKf1iv3k2RL31luNpGY1HuF/TBB7Vq+wPGbhgFun0bgnTbqQPeJWNnGT
         9AbhFBjAZW4xJbpn07pAeS29q2syT8Yye/cWjvJ4lhlfxemH4354cE60YE3clEGwSKJV
         rVkomQYRSko1QgigDkXe4K1pLeikxeED7Ycd2pm45facyFOdmEdhMSLgiT4SYza3yDa1
         7mZw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWd0iUkMKBaQ/U7TXyQFZMJWgbFJRMBCRIqRIpKYZVnCH/TsV+T
	+RphmjW4cXm804d+ntYsJHqqD1Xj0Wj7hkbpkrdzwDn2uz/LjWE/Jf7EU3YxbaowP+25rtASL/Q
	2BBP1cTSQwcyK1FKYFB4UjrHrAtGuL0JPfIgMrZgfgCXpxYyMb+4F4lbt827AYVc=
X-Received: by 2002:a17:906:1105:: with SMTP id h5mr16917927eja.53.1565338989431;
        Fri, 09 Aug 2019 01:23:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypzjBxpP7AzD7ObE/l/3bFXHdG94ok4USot4bEijiilSRmxErtvG7/QQWnfPWRirUjK16+
X-Received: by 2002:a17:906:1105:: with SMTP id h5mr16917886eja.53.1565338988662;
        Fri, 09 Aug 2019 01:23:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565338988; cv=none;
        d=google.com; s=arc-20160816;
        b=exKyHQNUOSFIBO/2KMSf/sdjBlmKzbjefwZsA5AG9ITKqZ2MwZCR+BWTfh1r31kS9f
         7cC9tqf2Z0o70upeYQn6Vbxc5lnNq4hbz09ZR15Ck/D/arAJO9A5gAE0Dhw0BzgDGPPb
         Cf0Y3Qya4iLiaq+h7XiAyGzItCCynxZGqEzJ0BVfPNR79V6Dunxvqq+pufvqE1e8uX/d
         h8MNfnUBZ5COjTIoW4WHel8z1lnaCRF7wnstBcV/7tHnqH/sX6CCeIsxOBxmCooijV27
         k7VsXqa/M8A/D4DjyexZ6dEGTawQ6AS9rf4inUlp4aq/nE3Bqmh6ZDySoudCCcqvA3Oa
         qfWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+qK2N6eyLQw8l+UY3rt97fTziJpeYBs2qOi3sj1MsaM=;
        b=pW0zl4l7a/5Pzm2XuzYze3ea7SG9kNbvj/G/mjIqiPRKzkVVsXrCuVfXaylVzdzy24
         M7Y5+0Fe9xuFYSTMhDTpyN5ps//2cIESS7Bg8Rf4EbMSZwaYz3rcT3c6sqHAHHXYccIS
         s9g+RgJZBiWo0gfOo9OqSPho2tGyAywUl4FHO9wCTKtyhyaIdU342kQD0FQ1sptADDlm
         sNtkxaeHsd7h75xy1ssbYAqD4DfEgOt9nCq5bRinPv2ODRy3YSJobDEgZ8rtnq3UWR9t
         V/00q5Jkm4RXuQK7mACQhYzUh6KUXubGiD3/IEgNJbTv8CeaOGvyMMtZwF7h40IseezD
         BrfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n55si34735497edd.231.2019.08.09.01.23.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 01:23:08 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C33ACAF50;
	Fri,  9 Aug 2019 08:23:07 +0000 (UTC)
Date: Fri, 9 Aug 2019 10:23:07 +0200
From: Michal Hocko <mhocko@kernel.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	Dan Williams <dan.j.williams@intel.com>,
	Daniel Black <daniel@linux.ibm.com>,
	Matthew Wilcox <willy@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>
Subject: Re: [PATCH 1/3] mm/mlock.c: convert put_page() to put_user_page*()
Message-ID: <20190809082307.GL18351@dhcp22.suse.cz>
References: <20190805222019.28592-1-jhubbard@nvidia.com>
 <20190805222019.28592-2-jhubbard@nvidia.com>
 <20190807110147.GT11812@dhcp22.suse.cz>
 <01b5ed91-a8f7-6b36-a068-31870c05aad6@nvidia.com>
 <20190808062155.GF11812@dhcp22.suse.cz>
 <875dca95-b037-d0c7-38bc-4b4c4deea2c7@suse.cz>
 <306128f9-8cc6-761b-9b05-578edf6cce56@nvidia.com>
 <d1ecb0d4-ea6a-637d-7029-687b950b783f@nvidia.com>
 <420a5039-a79c-3872-38ea-807cedca3b8a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <420a5039-a79c-3872-38ea-807cedca3b8a@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 09-08-19 10:12:48, Vlastimil Babka wrote:
> On 8/9/19 12:59 AM, John Hubbard wrote:
> >>> That's true. However, I'm not sure munlocking is where the
> >>> put_user_page() machinery is intended to be used anyway? These are
> >>> short-term pins for struct page manipulation, not e.g. dirtying of page
> >>> contents. Reading commit fc1d8e7cca2d I don't think this case falls
> >>> within the reasoning there. Perhaps not all GUP users should be
> >>> converted to the planned separate GUP tracking, and instead we should
> >>> have a GUP/follow_page_mask() variant that keeps using get_page/put_page?
> >>>  
> >>
> >> Interesting. So far, the approach has been to get all the gup callers to
> >> release via put_user_page(), but if we add in Jan's and Ira's vaddr_pin_pages()
> >> wrapper, then maybe we could leave some sites unconverted.
> >>
> >> However, in order to do so, we would have to change things so that we have
> >> one set of APIs (gup) that do *not* increment a pin count, and another set
> >> (vaddr_pin_pages) that do. 
> >>
> >> Is that where we want to go...?
> >>
> 
> We already have a FOLL_LONGTERM flag, isn't that somehow related? And if
> it's not exactly the same thing, perhaps a new gup flag to distinguish
> which kind of pinning to use?

Agreed. This is a shiny example how forcing all existing gup users into
the new scheme is subotimal at best. Not the mention the overal
fragility mention elsewhere. I dislike the conversion even more now.

Sorry if this was already discussed already but why the new pinning is
not bound to FOLL_LONGTERM (ideally hidden by an interface so that users
do not have to care about the flag) only?
-- 
Michal Hocko
SUSE Labs

