Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31DFBC10F03
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:33:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0E0B20643
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:33:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0E0B20643
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BBC18E0003; Wed, 13 Mar 2019 14:33:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86B4E8E0001; Wed, 13 Mar 2019 14:33:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75A608E0003; Wed, 13 Mar 2019 14:33:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4F1EA8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 14:33:40 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id t13so2398432qkm.2
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 11:33:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Hq+l7G6CzXArhjrhowlaQSnx08ZD53wrWA/4rB03MRE=;
        b=JXk4+6YKlEmakhaQiDp2+ctkRARb8gaJGDHoF94HnDqIZ4Jc6lXkKyMV66fafUO9fM
         rEMhT4dwBsEYqoI7xs6WZfbWXHQZszW129NNFq3KTXEqZV0fR0jjwiMSox1bxlwNuwWH
         9mTgZkFrUiHf2BxF6u6MiYhBbhqd79arqhUcMHTYK9k5Vw2KN6qZI70Jbu/49X68z/cR
         bl3mLL+OKX5Ey+0ZIWPbUrMQ15T2bTwJXFq2twP94z69p3DnoIeEGAkK/saXnxXybC1T
         W8Uw1X8ZYrBskVgFFbLvnIkyYtd3UjSikvfIfUjdg7wi/Bh26X6oF8Jf2fd8VyDetdyP
         MtYw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWqD4DSZzqyql/hDUWnHOBQDucNv2TcjbPuXV0+fpqhkuvFR4Sm
	3D0HxM5uKFp5qYkkpjltmKyl8aTTex2fdVnc+8DvIIbLprnwzqriX3Pqz6b+i2m8Ewv0v5OG/Fs
	d5myf+KoVnMLWoVVZhHjQkS0mA7ebIrcgDHenzgFQMXVD8ZzhJwtLuMmUJ5xpp+pOFQ==
X-Received: by 2002:a0c:c607:: with SMTP id v7mr12149623qvi.188.1552502020073;
        Wed, 13 Mar 2019 11:33:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgj0OKtPqA6nhlcCBPQQ5+u795DGKiWpViYXvWm/G/IYqQkWD2hqtRAlhvsjG/8SXcvfoo
X-Received: by 2002:a0c:c607:: with SMTP id v7mr12149550qvi.188.1552502019135;
        Wed, 13 Mar 2019 11:33:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552502019; cv=none;
        d=google.com; s=arc-20160816;
        b=sS4eGgGif/o6K7JHRKuhaeCuKoYyrkQZ8hiKKRfNvvSIgDLR2XaPplw+RMYvxNyXr9
         fDWr7KeTBgvTpdecCVz/zbYS1rkZ1z9BmajQ8MUgZXYaaJDVoslJd59wZInI94pe8TDa
         gg1fScQuasZo9PfWY2sqnFDNyCj7KhhbN+KSCtz/a0wEet2DX8t61BWCPbLjlMFxTCHI
         wXYyhMoQlLB8aCrRQltaYeXkgfwVyCRcL4IHaf9Ze4TY/xRVLCXDdWSXu57PFOSUFO/v
         gLj45PKSGeF1mHhZgRDgHDRQ3Be/FdUHnKTFb0bnUZaBMDOz23S2P3/17Yt5g070SWBz
         y6Qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=Hq+l7G6CzXArhjrhowlaQSnx08ZD53wrWA/4rB03MRE=;
        b=IL3lMOVrKkbXE+vxBUWYo6EUTlgNPBL91xXgvH8fWzowF+Bfv7WBe5pOs7kpX5hLX/
         04O1IHrkZkDp53DDNIi93Aks51Y5WAa8frBIUCfliect6CjBcoiOORtjLt/StoxvQbbz
         dNyXnRmSvbSLSRpR+9XUOMrKEbp7B+yYjNnFX8OcyUk7BsLAIk9H/QNw7m69xDYYZxGy
         zrMKTsvGgmbsKxFW1j6gr4gkIW+kAM+hKhy6WBezH0WTT7e3MuddyJ394rO7fFZ4Vkrr
         7qZ2hx/XXezNiohy11flIraQfGZhAqdJp2hlMWWt+fHJyN6g18xKyGA4rUO+jFDLIO/X
         D6qw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j61si201717qtb.221.2019.03.13.11.33.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 11:33:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 63F14C04AC51;
	Wed, 13 Mar 2019 18:33:38 +0000 (UTC)
Received: from redhat.com (ovpn-125-95.rdu2.redhat.com [10.10.125.95])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 00A235C280;
	Wed, 13 Mar 2019 18:33:36 +0000 (UTC)
Date: Wed, 13 Mar 2019 14:33:35 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 00/10] HMM updates for 5.1
Message-ID: <20190313183245.GA4651@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190313012706.GB3402@redhat.com>
 <20190313091004.b748502871ba0aa839b924e9@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190313091004.b748502871ba0aa839b924e9@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Wed, 13 Mar 2019 18:33:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 09:10:04AM -0700, Andrew Morton wrote:
> On Tue, 12 Mar 2019 21:27:06 -0400 Jerome Glisse <jglisse@redhat.com> wrote:
> 
> > Andrew you will not be pushing this patchset in 5.1 ?
> 
> I'd like to.  It sounds like we're converging on a plan.
> 
> It would be good to hear more from the driver developers who will be
> consuming these new features - links to patchsets, review feedback,
> etc.  Which individuals should we be asking?  Felix, Christian and
> Jason, perhaps?
> 

Adding Ben as nouveau maintainer. Note that this patchset only add
2 new function the rest is just refactoring to allow RDMA ODP. The
2 news functions will both be use by ODP and nouveau. Ben this is
the dma map function we discuss previously. If they get in 5.1 then
i will push there user in nouveau at least in 5.2. I will soon repost
ODP v2 patchset on top of RDMA tree so if this does not get in 5.1
then ODP will have to be push to 5.3 or to when this get upstream.

Cheers,
Jérôme

