Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AD25C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:19:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1A3321850
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:19:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1A3321850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40D696B0005; Wed, 17 Apr 2019 17:19:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3959E6B0006; Wed, 17 Apr 2019 17:19:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 283AB6B0007; Wed, 17 Apr 2019 17:19:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 049D36B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 17:19:56 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id f196so104873qke.4
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:19:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=1kAzASYHkfgAZCKTJ2Tv8jItou+SG0ZxW/nDe41aKCI=;
        b=fYsYoBqardWm43xPL9M0HpZi58T3je8fTmaaUlklItl54mQDNzgPiziYHr+sYgLE5G
         jbg0BuAX9ghzbE8o4T+l7vONtWkuSjjOVuYTwyk8ONiuaYnIfQ2hWDSyNJiaOVUJV9Tz
         5whTKv8kL06YxUmzooY2u9ih7G2mCRhf6oubKuDj1nMaKKZaxtSm1wGClzue/7D7wbsX
         ePQerZ3Suhe1OxMIYC03e/1O1u3FGaE6Jo14SU1csaP2KT8CPCinEN99/NzKjj7iwlEv
         B59Q61EnRIneD7BN03whdKzLYoBdDqgVYjFjQsX5hq4oI2AdCl+m37T16OS2HoZNh6fe
         Q+RQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUFiRfoHTZivnlucUwB34s2w3cgpKAc2TI0Bik2I7QHV0Loq0Ku
	v74Yb+o34KCZfxYdMdXP0yo8WHlkodqb9mExNPyPsMtXU28N0GYJxjQ0GwAj8h+hLyMspLNI4VZ
	7z8v1F2duSJE/NKRNs492lvCjfqojX2XP+xJJ9ryXFvKRGdexwYtJqEPb31REpSMaCw==
X-Received: by 2002:a05:620a:3d0:: with SMTP id r16mr1350933qkm.210.1555535995737;
        Wed, 17 Apr 2019 14:19:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNlwE5DsO708zy2XI2sVovH2XKG2t1QIbTQj18r6SBfGVlGUFumF9L0p7YJT4g7Mgf4Bs8
X-Received: by 2002:a05:620a:3d0:: with SMTP id r16mr1350890qkm.210.1555535995038;
        Wed, 17 Apr 2019 14:19:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555535995; cv=none;
        d=google.com; s=arc-20160816;
        b=PIYVsH44lNUSgh3D/UKczhGI1zv0WH7IChCqwRTG2o9eGMHC7SLBb/pcJVYM24Ri9d
         D734+tTYrte6mFekYMkExlMNfsI1QGATgnuYOsduQr1V770wR0oqOSIIrsP2jpRt43IN
         k1eXb6zXtCmwGO9IHA3hGJWTvxVTDPJFN88JNcUU9WDpY2ZkGNS5bcJwwPHjV/uuMh3V
         CJUix/Q7dWHAbE42CxoO5uM2/EiuH4/n6SnVyxPtuK+QVBHfiUSdgw+BVjtk72jmaHTf
         nBVf9WXM/SClBpZSFXJk5xmYa0MROkeqhKqY45xiupWR+PZ1ksxHjDqTtFFBL3eW5ANp
         Q2Zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=1kAzASYHkfgAZCKTJ2Tv8jItou+SG0ZxW/nDe41aKCI=;
        b=OVnubDxROotuKGUYVDZ8eLgpxKjyXKio/5fVszOfJDhBnQu26jTiGbbl23gXs4d4Yq
         biJnVHi8fGRmYap9ZGmP+VDoi5qeJ7LAdHRLH3sAiKE3cHtPT7DMEeGaoAV6Gd1GKHhJ
         vRWj4XcKy5pShx4hdfLEcTQ9+3DKuMJ7QZa8yTLQwcs/uRPq8jiDLNrpTGhTaWbcy9TE
         Lrxd3B/2YKdi8qy34Fun6Lc3UB0qM4Y6b1ijDXag1NOTVTkQyAr7Qqvh8tDu68QE4kh3
         AE+/bqZx/mkYBBgubeqyKLcwlHfhyhSkCH3P6bflGtIfW1JaB7M2QGpM4pFfyDlBLc29
         Gs4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t65si1522879qka.236.2019.04.17.14.19.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 14:19:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7062D307EAA0;
	Wed, 17 Apr 2019 21:19:53 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 830616014E;
	Wed, 17 Apr 2019 21:19:45 +0000 (UTC)
Date: Wed, 17 Apr 2019 17:19:43 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Boaz Harrosh <openosd@gmail.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Kent Overstreet <kent.overstreet@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-block@vger.kernel.org, Linux MM <linux-mm@kvack.org>,
	John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Ming Lei <ming.lei@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org,
	Yan Zheng <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
	Ilya Dryomov <idryomov@gmail.com>, Alex Elder <elder@kernel.org>,
	ceph-devel@vger.kernel.org, Eric Van Hensbergen <ericvh@gmail.com>,
	Latchesar Ionkov <lucho@ionkov.net>,
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>,
	Dominique Martinet <asmadeus@codewreck.org>,
	v9fs-developer@lists.sourceforge.net, Coly Li <colyli@suse.de>,
	linux-bcache@vger.kernel.org,
	Ernesto =?iso-8859-1?Q?A=2E_Fern=E1ndez?= <ernesto.mnd.fernandez@gmail.com>
Subject: Re: [PATCH v1 00/15] Keep track of GUPed pages in fs and block
Message-ID: <20190417211943.GA24523@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <2c124cc4-b97e-ee28-2926-305bc6bc74bd@plexistor.com>
 <20190416185922.GA12818@kmo-pixel>
 <CAPcyv4jLrQ6evLAJzsASh=H6Tzx8E1oiF+YR3L2fOpbZYNUWGg@mail.gmail.com>
 <ccac6c5a-7120-0455-88de-ca321b01e825@plexistor.com>
 <20190416195735.GE21526@redhat.com>
 <41e2d7e1-104b-a006-2824-015ca8c76cc8@gmail.com>
 <20190416231655.GB22465@redhat.com>
 <fa00a2ff-3664-3165-7af8-9d9c53238245@plexistor.com>
 <20190417020345.GB3330@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190417020345.GB3330@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Wed, 17 Apr 2019 21:19:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 10:03:45PM -0400, Jerome Glisse wrote:
> On Wed, Apr 17, 2019 at 04:11:03AM +0300, Boaz Harrosh wrote:
> > On 17/04/19 02:16, Jerome Glisse wrote:
> > > On Wed, Apr 17, 2019 at 01:09:22AM +0300, Boaz Harrosh wrote:
> > >> On 16/04/19 22:57, Jerome Glisse wrote:

[...]

> > >>
> > >> BTW: Are you aware of the users of iov_iter_get_pages_alloc() Do they need fixing too?
> > > 
> > > Yeah and that patchset should address those already, i do not think
> > > i missed any.
> > > 
> > 
> > I could not find a patch for nfs/direct.c where a put_page is called
> > to balance the iov_iter_get_pages_alloc(). Which takes care of for example of
> > the blocklayout.c pages state
> > 
> > So I think the deep Audit needs to be for iov_iter_get_pages and get_user_pages
> > and the balancing of that. And the all of bio_alloc and bio_add_page should stay
> > agnostic to any pege-refs taking/putting
> 
> Will try to get started on that and see if i hit any roadblock. I will
> report once i get my feet wet, or at least before i drown ;)

So far it does not look too bad:

https://cgit.freedesktop.org/~glisse/linux/log/?h=gup-bio-v2

they are few things that will be harder to fit in like splice
and pipe that are populated from GUP.

Cheers,
Jérôme

