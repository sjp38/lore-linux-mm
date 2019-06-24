Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27396C48BE8
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 07:28:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD7D920663
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 07:28:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD7D920663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 714FE8E0002; Mon, 24 Jun 2019 03:28:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C51C8E0001; Mon, 24 Jun 2019 03:28:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DB068E0002; Mon, 24 Jun 2019 03:28:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3ED058E0001
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 03:28:57 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id c1so15229476qkl.7
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 00:28:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=XyYRgx350jjujPbQ0+x5JSnjeXS7I6qwUhZF2MfrE4A=;
        b=GQ8glQQMx9ueZrDQ8W9w7kXkGz32ziyhMQMAIRJzsgwSMtBJQ+akrtG1FBy9KkmAA/
         0gp+jNNjYzc9TqBQf5/l7MEqoHHkVQmYIsBjtnCTNkqZ5l7wdzkjin/wYywOuX7XlE2E
         eMySWhxCo9XzrLnuE31c+26JotQTKbiI2BCBXhUiibIrN/+zJ//5eg3+o3y8etOiweXp
         lI9E6LOF3l05QJR91ZY9EvpyIAkB+NTtmLhdiNgvPaKW0ky9R9lm6EtYKnJXZvKQu/5K
         C/aTkHh9XjVSTor7mBuWB+2x7NCQbWfACgbgHYdmBMR/Hmr/4twwxiT6BzUqt0GLVhKv
         HsmQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU2sito5ps3rhxi/xC230Y643cLW2Ns+vD7h+dFY9dGgvIOh7bX
	5alfpEN/fxDRrmyylA23WaHl7CXS0vQtE578A8E/BXg9S+CtnifK9iaiImPM64m2t8f+QbBeFkL
	HSY/2m6Q8pm4iCfm9eC+/B3PWeWWIMTQHfM/aIHRXna+d8uxeHZUUaUnsY1+TvB4Tww==
X-Received: by 2002:a0c:acab:: with SMTP id m40mr13693352qvc.52.1561361337024;
        Mon, 24 Jun 2019 00:28:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyv2ofHLL1icVrEZnRS4vVcnriYi6s3lSYX9UwxfrMvJT/EDEgg5JBFoIj+BZvCbQyctq5n
X-Received: by 2002:a0c:acab:: with SMTP id m40mr13693317qvc.52.1561361336221;
        Mon, 24 Jun 2019 00:28:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561361336; cv=none;
        d=google.com; s=arc-20160816;
        b=P+ZfN2YY2mR1YTy0azacYX75FMjSYNYRdaBBtlTWZYImDmfthXrIPK1jgvfB6R5PNp
         3flq4+5LsSie1Ua5JcjmTQmN/AwHnC/hgSelQHJnfNrxZdhXh2OmWlWBpDDWn0HJar0+
         CKqyEnBtmEt1t+8yc+8QDepiOrRZVzolvNMSAAnD9QP3CVdCGMxDmcgSwq9NChrFdgOn
         EZ9WXwkpdLPay0JI72gZUfhBS3tf5reGVoip8s0Oywx6gIqmHlSIbFGRnljy44PZm++G
         kSs+qrAS2cJdQn6Cua68yyvf7Seh7GNeLiof/cpX05Iv+boSiSCC6QSqWz1OCrgM4DVO
         cnlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=XyYRgx350jjujPbQ0+x5JSnjeXS7I6qwUhZF2MfrE4A=;
        b=cMKvOv8cmxmK12d1dHbB1eStDKYlZvGJpyIMm9q47Nc/nxj6YneXhO8PHhZ2K3Qr7T
         Gjw+XVQHChYOuBIAuac16K9MbxSv+H1XaKL8VMseLH5MqIyrpBTqev0TSiJYXnL1+8kS
         RyUjunNU1CNgONHTsBfex50IeZCwYBtireb3JnN7HGCRcczW3iF5m2MtfEA9bfA4uQwh
         8jLlP2qYk8VJamjEYH2hgKF+3bhTbpam6RoG0DjmHPa8QUxy3EfFUZ5H4PIcjuZ56N6A
         19V4tAbujbv3GnHGC2MO6yrcrYnONppMGSrS/l9h8AHy6oJcu2gxNg2fkHGu4CIZ4LWP
         CZ4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u11si6884869qvf.139.2019.06.24.00.28.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 00:28:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 56D955AFF8;
	Mon, 24 Jun 2019 07:28:50 +0000 (UTC)
Received: from ming.t460p (ovpn-8-18.pek2.redhat.com [10.72.8.18])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id DC51B5C1B5;
	Mon, 24 Jun 2019 07:28:36 +0000 (UTC)
Date: Mon, 24 Jun 2019 15:28:31 +0800
From: Ming Lei <ming.lei@redhat.com>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>,
	Rik van Riel <riel@redhat.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -mm] mm, swap: Fix THP swap out
Message-ID: <20190624072830.GA10539@ming.t460p>
References: <20190624022336.12465-1-ying.huang@intel.com>
 <20190624033438.GB6563@ming.t460p>
 <87imsvbnie.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87imsvbnie.fsf@yhuang-dev.intel.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Mon, 24 Jun 2019 07:28:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 12:44:41PM +0800, Huang, Ying wrote:
> Ming Lei <ming.lei@redhat.com> writes:
> 
> > Hi Huang Ying,
> >
> > On Mon, Jun 24, 2019 at 10:23:36AM +0800, Huang, Ying wrote:
> >> From: Huang Ying <ying.huang@intel.com>
> >> 
> >> 0-Day test system reported some OOM regressions for several
> >> THP (Transparent Huge Page) swap test cases.  These regressions are
> >> bisected to 6861428921b5 ("block: always define BIO_MAX_PAGES as
> >> 256").  In the commit, BIO_MAX_PAGES is set to 256 even when THP swap
> >> is enabled.  So the bio_alloc(gfp_flags, 512) in get_swap_bio() may
> >> fail when swapping out THP.  That causes the OOM.
> >> 
> >> As in the patch description of 6861428921b5 ("block: always define
> >> BIO_MAX_PAGES as 256"), THP swap should use multi-page bvec to write
> >> THP to swap space.  So the issue is fixed via doing that in
> >> get_swap_bio().
> >> 
> >> BTW: I remember I have checked the THP swap code when
> >> 6861428921b5 ("block: always define BIO_MAX_PAGES as 256") was merged,
> >> and thought the THP swap code needn't to be changed.  But apparently,
> >> I was wrong.  I should have done this at that time.
> >> 
> >> Fixes: 6861428921b5 ("block: always define BIO_MAX_PAGES as 256")
> >> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> >> Cc: Ming Lei <ming.lei@redhat.com>
> >> Cc: Michal Hocko <mhocko@kernel.org>
> >> Cc: Johannes Weiner <hannes@cmpxchg.org>
> >> Cc: Hugh Dickins <hughd@google.com>
> >> Cc: Minchan Kim <minchan@kernel.org>
> >> Cc: Rik van Riel <riel@redhat.com>
> >> Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
> >> ---
> >>  mm/page_io.c | 7 ++-----
> >>  1 file changed, 2 insertions(+), 5 deletions(-)
> >> 
> >> diff --git a/mm/page_io.c b/mm/page_io.c
> >> index 2e8019d0e048..4ab997f84061 100644
> >> --- a/mm/page_io.c
> >> +++ b/mm/page_io.c
> >> @@ -29,10 +29,9 @@
> >>  static struct bio *get_swap_bio(gfp_t gfp_flags,
> >>  				struct page *page, bio_end_io_t end_io)
> >>  {
> >> -	int i, nr = hpage_nr_pages(page);
> >>  	struct bio *bio;
> >>  
> >> -	bio = bio_alloc(gfp_flags, nr);
> >> +	bio = bio_alloc(gfp_flags, 1);
> >>  	if (bio) {
> >>  		struct block_device *bdev;
> >>  
> >> @@ -41,9 +40,7 @@ static struct bio *get_swap_bio(gfp_t gfp_flags,
> >>  		bio->bi_iter.bi_sector <<= PAGE_SHIFT - 9;
> >>  		bio->bi_end_io = end_io;
> >>  
> >> -		for (i = 0; i < nr; i++)
> >> -			bio_add_page(bio, page + i, PAGE_SIZE, 0);
> >
> > bio_add_page() supposes to work, just wondering why it doesn't recently.
> 
> Yes.  Just checked and bio_add_page() works too.  I should have used
> that.  The problem isn't bio_add_page(), but bio_alloc(), because nr ==
> 512 > 256, mempool cannot be used during swapout, so swapout will fail.

Then we can pass 1 to bio_alloc(), together with single bio_add_page()
for making the code more readable.


thanks,
Ming

