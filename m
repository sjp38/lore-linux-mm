Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6D78C04AB1
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 18:10:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E08E2086A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 18:10:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E08E2086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F7B76B0005; Mon, 13 May 2019 14:10:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CF496B0007; Mon, 13 May 2019 14:10:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB4EA6B0008; Mon, 13 May 2019 14:10:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id CC1E96B0005
	for <linux-mm@kvack.org>; Mon, 13 May 2019 14:10:06 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id a12so13596384qkb.3
        for <linux-mm@kvack.org>; Mon, 13 May 2019 11:10:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=R8/txI0W2+q3QpmLYg0kWx8VfSmW9zxrPZWFMFqQ25g=;
        b=Pwdhpwi+yyjhKYk7KeWA2JaY2J3WDpmDd2K02rVnF8WQ8ukEQ51tM38PAvFIi3vIyj
         HVn5SvMRgGKaHl4up6Vge/8x7+SiSHg/IcTwppWJ7j8c8s7vOL8k1LEfQrrOzOoBr3jn
         8ZhBgoHZcsXzTO3tjB+HHVM9NPYC4WAusKbIkgOXV5bJZg1Jb/e9o8K2Q+r3s0mkw5dh
         MYN05liIeM6frPyHqSfMoHNoZgtImt/B5ksKHdp63rXDzcgs9rQ85Odj2L0PhVtwSGr7
         P7gcwq5+BS3iooF+JOQ+yHFLeyHAzs35rodViMZC93aq36zet6wpnRzLOE8u0R7rEhTT
         CldQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUFbSJ02ZQj7hZJZD81wC/ZtYHHe39O1pfP+tuiOCtvYT4VBVMz
	xnrguVKBp8viyt68iTbiPR765x1Q7VeOJnLI6/1ROLbo/d1sUW/AG12JT9tVEaPIVZjBIxb4jaQ
	FVFd4v/8S5XufduDLvTIiYcGZxepF4nv9Zpt1atjjb8DTRnzJX3I5nm2MAEushvKSgg==
X-Received: by 2002:a37:9ce:: with SMTP id 197mr23686945qkj.190.1557771006513;
        Mon, 13 May 2019 11:10:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDMIXTc43kl1EbvzXOzd4gsWvWruMQDGmnlHVulFfBaPtjcKrZ3RP92gRVruCoD7ZuH677
X-Received: by 2002:a37:9ce:: with SMTP id 197mr23686881qkj.190.1557771005858;
        Mon, 13 May 2019 11:10:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557771005; cv=none;
        d=google.com; s=arc-20160816;
        b=APb1qNGpFbwdq780QkWfY4+/l/1I2St1lJdWkz+dAYZKJNhXdwmM9u7H4tByCE7Pn4
         OH+ud9PQ6984lSijndclxdI9IZCJFu8oEHbxswQNc95riTVFVYI9n4jbXQhSg6hqhdaF
         jD7he00+XvV47R5viDZpzwcSMXJ9X3pYypYEaJU8/MEMk4XqJFdwULrkiifd269H+we2
         iDASNfFlK5PDNfhSLNOGYLfxJadqrVldlF9eXavAwm0nfGKHRZaqrfnuTZVYePdvR8Xd
         CXRw8x1F/iGD3X6Iiewb8PGDfB57ZnkIlv0bDBWdDVPCMuXJfnrCzaXMv8j9qWyrdJkl
         l+Sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=R8/txI0W2+q3QpmLYg0kWx8VfSmW9zxrPZWFMFqQ25g=;
        b=rhDAogve5y6ViODR1sBOmniTBjr8owImWz28sSvUhdfMIdExcVVa2g5OrhI/SEQqPX
         40ZNFvDndzmiwL3qty5buMKkM4xoFPVOc6nkRRrETeYaBYym1I41W1ucJFsRKuj/KlZn
         KNqde6wLRPsNDEt0gOSetcfKAfoy3owH1gCd8Q1uXHaQTIkEp0BQWOXEmk7tNiQLP68K
         SWMV8AU+Qot6a1N2iUqZNRn6uDM6tH0b4wL67UfqXbnEhUrk/Fh5fBSprWb9gjrN83KH
         2jj1sQQHG7npr4uWjnvwMlvuSaMz+7TIV1QMctzSQPH1n/YwebWWRIqgmaSR/SuG6Jnx
         ojWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v25si69894qkj.53.2019.05.13.11.10.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 11:10:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E75513087951;
	Mon, 13 May 2019 18:10:04 +0000 (UTC)
Received: from redhat.com (ovpn-112-54.rdu2.redhat.com [10.10.112.54])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id B974E18A5D;
	Mon, 13 May 2019 18:10:02 +0000 (UTC)
Date: Mon, 13 May 2019 14:10:00 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/5] mm/hmm: HMM documentation updates and code fixes
Message-ID: <20190513181000.GA30726@redhat.com>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
 <20190512150832.GB4238@redhat.com>
 <89c6ce48-190b-65df-7c35-a0eb0f5d936f@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <89c6ce48-190b-65df-7c35-a0eb0f5d936f@nvidia.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Mon, 13 May 2019 18:10:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 10:26:59AM -0700, Ralph Campbell wrote:
> 
> 
> On 5/12/19 8:08 AM, Jerome Glisse wrote:
> > On Mon, May 06, 2019 at 04:29:37PM -0700, rcampbell@nvidia.com wrote:
> > > From: Ralph Campbell <rcampbell@nvidia.com>
> > > 
> > > I hit a use after free bug in hmm_free() with KASAN and then couldn't
> > > stop myself from cleaning up a bunch of documentation and coding style
> > > changes. So the first two patches are clean ups, the last three are
> > > the fixes.
> > > 
> > > Ralph Campbell (5):
> > >    mm/hmm: Update HMM documentation
> > >    mm/hmm: Clean up some coding style and comments
> > >    mm/hmm: Use mm_get_hmm() in hmm_range_register()
> > >    mm/hmm: hmm_vma_fault() doesn't always call hmm_range_unregister()
> > >    mm/hmm: Fix mm stale reference use in hmm_free()
> > 
> > This patchset does not seems to be on top of
> > https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-5.2-v3
> > 
> > So here we are out of sync, on documentation and code. If you
> > have any fix for https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-5.2-v3
> > then please submit something on top of that.
> > 
> > Cheers,
> > Jérôme
> > 
> > > 
> > >   Documentation/vm/hmm.rst | 139 ++++++++++++++++++-----------------
> > >   include/linux/hmm.h      |  84 ++++++++++------------
> > >   mm/hmm.c                 | 151 ++++++++++++++++-----------------------
> > >   3 files changed, 174 insertions(+), 200 deletions(-)
> > > 
> > > -- 
> > > 2.20.1
> 
> The patches are based on top of Andrew's mmotm tree
> git://git.cmpxchg.org/linux-mmotm.git v5.1-rc6-mmotm-2019-04-25-16-30.
> They apply cleanly to that git tag as well as your hmm-5.2-v3 branch
> so I guess I am confused where we are out of sync.

No disregard my email, i was trying to apply on top of wrong
branch yesterday morning while catching up on big backlog of
email. Failure was on my side.

Cheers,
Jérôme

