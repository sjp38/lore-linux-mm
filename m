Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E90EAC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:16:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B570121743
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:16:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B570121743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D3136B0005; Fri,  9 Aug 2019 05:16:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 25C486B0006; Fri,  9 Aug 2019 05:16:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FCF56B0007; Fri,  9 Aug 2019 05:16:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B02C86B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 05:16:16 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k22so59948529ede.0
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 02:16:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MA1fK0KtLP5wo+bM1c0XFXmTq958i6JcPGSsXrTh1nY=;
        b=aDXCEN/A/mmMQlW2LYWwoEvJQElpoI5NzwFyjCHmo3y9KcmBMeyEThO9p/tpxUjAH1
         zypZjEhxqRH5yArWwOcIajEVRTKz3zad3xzMCuBGxYCOfL/PCb33DgMIK+raeYALFw1E
         5dzlRLS/k4yT3bH4iqVyCNOojB6uDqmIz2NIk83dxl0zUQil17qUCkP2bi88gv+9/ykM
         4stq9B/x+OAAIUI9U1stL27osAoRvP7E6Cc6aSigCNk53mnziLvg/DWnswcy8OwPkU/5
         vLkVjBX4koePbfQIevWEb3stdd/QpHSs088xpp+oo7SM1Ues7AOBXIQGtpGu8wk7lV7f
         reuQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUz2FkhcqpDj98T1U7Fps5hgJM+KlCZYKOtx1nVtL7PioDlXBKM
	pXj8sDe36RBCZDIyXeVSHYeE4+f95HaknUawyt+p8SmBqGDWzXdjPyDK9wHV3uyCjMGvRbTAgMt
	AMzAxPhxcJUTM3Lg1j+R+zF+KpWn0QTQlN47TY+7sveqziLChcTm0gp7EycynOhc=
X-Received: by 2002:a50:f599:: with SMTP id u25mr21132397edm.195.1565342176271;
        Fri, 09 Aug 2019 02:16:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWbW82kx+5u3Zh9iIZHTWGiys46qK3Z8EMtzrHWfjMylgo7YeDPT3PnWeabcYqg/3bh8IW
X-Received: by 2002:a50:f599:: with SMTP id u25mr21132347edm.195.1565342175571;
        Fri, 09 Aug 2019 02:16:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565342175; cv=none;
        d=google.com; s=arc-20160816;
        b=xc9TcScJtIauWC/hG0M4HmyOpEOB5lEYE5K8hkRrCmPTjlN0tQukaU4U/lvJmEP/4Y
         FYy/1acdwP1x2VGZOR90gED3I3roteqUnaIZInGzXD/ytglgKBWysqx8dLC6yO2BjBtB
         7ZFJCBoDTUN2YGgJ6iSmZg17FOhnob7nAqJ4zYZCrO3Ql/8MNdQ9wwVS5PkUgSlUEkJH
         ENhK1Br5dBcd2Yba04ZtyTT7ATK9O+EZSxr5uVuJmk8Bjy8v6uH8TCCnhVvWPiZ6xp5k
         2xzdAL6Fp+5MaHtKR+ZrELgJh9SNbwZJyMCgrMl72Y4oZX1aJI0nGU/5JSyJORjGyKtq
         tSyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=MA1fK0KtLP5wo+bM1c0XFXmTq958i6JcPGSsXrTh1nY=;
        b=c+4597wCdmiUEm6R48oPyXQavpFUpSvOl5d9dyoYKESQwMdD3kLxbeIKPTt+s+kvrj
         h63TX01wE2PgINSJwTmTnj3tKUJ/NIeVZ7fFspUepyXEpcXYLZeKDAxFdQNcFqd8uCEx
         t+Cj+jcUAm9tves6nY3j51CLZBM5zw013uEPniJMxNWVNbknRzVv1bteDoRGoRnk3Jju
         YbpmKI2yXMhkpGvq7Z4JYY96GOAw25ngvsq+bEMkzNr9jcf4/s1nOnwF5nYtDFMnnv/F
         izbmB4ztHtj8FhtjX8lNk2kB/a06mKqi0UXPh1rJfI2vOF4xSbK7xxyyVJd5aqkihOH4
         amYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 47si40205979edu.294.2019.08.09.02.16.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 02:16:15 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EAA78B011;
	Fri,  9 Aug 2019 09:16:14 +0000 (UTC)
Date: Fri, 9 Aug 2019 11:16:14 +0200
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
Message-ID: <20190809091614.GO18351@dhcp22.suse.cz>
References: <20190805222019.28592-2-jhubbard@nvidia.com>
 <20190807110147.GT11812@dhcp22.suse.cz>
 <01b5ed91-a8f7-6b36-a068-31870c05aad6@nvidia.com>
 <20190808062155.GF11812@dhcp22.suse.cz>
 <875dca95-b037-d0c7-38bc-4b4c4deea2c7@suse.cz>
 <306128f9-8cc6-761b-9b05-578edf6cce56@nvidia.com>
 <d1ecb0d4-ea6a-637d-7029-687b950b783f@nvidia.com>
 <420a5039-a79c-3872-38ea-807cedca3b8a@suse.cz>
 <20190809082307.GL18351@dhcp22.suse.cz>
 <a83e4449-fc8d-7771-1b78-2fa645fa0772@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a83e4449-fc8d-7771-1b78-2fa645fa0772@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 09-08-19 02:05:15, John Hubbard wrote:
> On 8/9/19 1:23 AM, Michal Hocko wrote:
> > On Fri 09-08-19 10:12:48, Vlastimil Babka wrote:
> > > On 8/9/19 12:59 AM, John Hubbard wrote:
> > > > > > That's true. However, I'm not sure munlocking is where the
> > > > > > put_user_page() machinery is intended to be used anyway? These are
> > > > > > short-term pins for struct page manipulation, not e.g. dirtying of page
> > > > > > contents. Reading commit fc1d8e7cca2d I don't think this case falls
> > > > > > within the reasoning there. Perhaps not all GUP users should be
> > > > > > converted to the planned separate GUP tracking, and instead we should
> > > > > > have a GUP/follow_page_mask() variant that keeps using get_page/put_page?
> > > > > 
> > > > > Interesting. So far, the approach has been to get all the gup callers to
> > > > > release via put_user_page(), but if we add in Jan's and Ira's vaddr_pin_pages()
> > > > > wrapper, then maybe we could leave some sites unconverted.
> > > > > 
> > > > > However, in order to do so, we would have to change things so that we have
> > > > > one set of APIs (gup) that do *not* increment a pin count, and another set
> > > > > (vaddr_pin_pages) that do.
> > > > > 
> > > > > Is that where we want to go...?
> > > > > 
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
> > 
> 
> Oh, it's been discussed alright, but given how some of the discussions have gone,
> I certainly am not surprised that there are still questions and criticisms!
> Especially since I may have misunderstood some of the points, along the way.
> It's been quite a merry go round. :)

Yeah, I've tried to follow them but just gave up at some point.

> Anyway, what I'm hearing now is: for gup(FOLL_LONGTERM), apply the pinned tracking.
> And therefore only do put_user_page() on pages that were pinned with
> FOLL_LONGTERM. For short term pins, let the locking do what it will:
> things can briefly block and all will be well.
> 
> Also, that may or may not come with a wrapper function, courtesy of Jan
> and Ira.
> 
> Is that about right? It's late here, but I don't immediately recall any
> problems with doing it that way...

Yes that makes more sense to me. Whoever needs that tracking should
opt-in for it. Otherwise you just risk problems like the one discussed
in the mlock path (because we do a strange stuff in the name of
performance) and a never ending whack a mole where new users do not
follow the new API usage and that results in all sorts of weird issues.

Thanks!
-- 
Michal Hocko
SUSE Labs

