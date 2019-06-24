Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63ED5C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 07:31:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24BC520663
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 07:31:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24BC520663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0A398E0003; Mon, 24 Jun 2019 03:31:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A93FD8E0001; Mon, 24 Jun 2019 03:31:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95C068E0003; Mon, 24 Jun 2019 03:31:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5E2A58E0001
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 03:31:39 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id q11so492659pll.22
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 00:31:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=P/4otxNZXsJ3DrxtjL4MfDh/yanXKbhi/owheLbgkpk=;
        b=CXChs25xsqBwvoV3f9WlkREgftJLo4zqb08vtCD12BYdeM4ZdF9GNnncV/SzVTwqhA
         VX45WEZ95Nj0BEij8C6OOOT4tnvlwRjnCFI5JXtuwWxJZ7AvrWdWwBQD0oLitf18bK5e
         XN1daBpZHnw6Xiu5yYOyBo+rbsdnUZSkWxFZv9+FTPeYQXdvpegfC4A0nH00fynSjlBp
         4wSb4asLYLjHbnaSSCtRd2/7DnLUJMwtPpEi/DZNiJUq+r1UqWPwhCKGpHg41RSY+IL6
         LEtRLA9ehmhDV+W1co5icTKp508Bz6uxUhYtScNCrAy97Mlwp+w0Hyc2ZWC9pOMaOmA4
         +VvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXFpQFiBwgsd8f4PVu2V0ot7hClWaPi42qWRletz8EkP1YykT9O
	scM89JENNwmt+14Rn0etKx574Mwp9Qxy9TohjMbN3pzWSQ/97oQNjRV1WlD2SR/Cwt0bH36JFjv
	xyVUjc2SlXP9RcHAYWPOoJ4g2s3jd3N3w8zbyXoYNs2sM0kCgFzvJBxkOlclfEoStkg==
X-Received: by 2002:a17:90a:ad86:: with SMTP id s6mr23297377pjq.42.1561361499022;
        Mon, 24 Jun 2019 00:31:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBGbowXWhhYsnyNW36Zq+GtP5CfnGSW64VbGzms7cLU3c78D0nyXVZC+OdZjk0erh+5KaF
X-Received: by 2002:a17:90a:ad86:: with SMTP id s6mr23297329pjq.42.1561361498333;
        Mon, 24 Jun 2019 00:31:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561361498; cv=none;
        d=google.com; s=arc-20160816;
        b=hNccRvanw/vLhhB7YJ9zA00o7lsv2EIChaiWPcrfx8/vQA+kkW4Pj6XToObZ8QyL8F
         sOWxc2HfyUhBfyZSs4COje2bk3Bf69VRuwvZjzVB8pa/sT545HKL8sNAuyTsHARyfv+V
         TirHBV8t3vSFSJs/hjqF1aINzVORRGWaWIGb7THLQf/YxapRXxhk+0B6MWU/KzuEzcys
         z4pVcddZPyXLv6Ha0hZUCcqqPYRGWPBwAZrc+GixSTaiQVrOlFZXT9r/sF02zqRX/ATE
         kEQ/jy1g+oah4IMycLuELAOvlrzPoeqU3coUdaENK7VdnamibME15gX95n1fGKSNoA28
         1sRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=P/4otxNZXsJ3DrxtjL4MfDh/yanXKbhi/owheLbgkpk=;
        b=0avTQlWq2gqJYrEP9la66WmJDH/o5sUSsK4Sd/ptJYJJkbCa6TTDl4zbAJKWXraWKL
         NaUBEg2exY0MH+dsNZVLG1vgzKm9IuDb0J7jkhKPOHE/2Lc7x4+7HDlL2DY/9YA78/Ss
         nkVVVaviXxhASbZGvzrGEuwOKyD8XLmD84ksHZBsOAzU8H6i+q+gUh9rzKzoA0rCedjj
         RCBBcdkedLJGrONPln5qw2j+wQfhPLqPbOuEqiG0uhK5NQer0lZsg3HELafi1dHvQ19D
         AJ/U8thxpMZCOoaHX0cwNX2w2G6u6F5eBH4kOh96onw322tZP9n7kiNrpjQbjw1A5mVH
         O5fg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id t16si10480556pfh.100.2019.06.24.00.31.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 00:31:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jun 2019 00:31:37 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,411,1557212400"; 
   d="scan'208";a="184049844"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by fmsmga004.fm.intel.com with ESMTP; 24 Jun 2019 00:31:36 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Ming Lei <ming.lei@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>,  Michal Hocko <mhocko@kernel.org>,  "Johannes Weiner" <hannes@cmpxchg.org>,  Hugh Dickins <hughd@google.com>,  Minchan Kim <minchan@kernel.org>,  Rik van Riel <riel@redhat.com>,  Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -mm] mm, swap: Fix THP swap out
References: <20190624022336.12465-1-ying.huang@intel.com>
	<20190624033438.GB6563@ming.t460p>
	<87imsvbnie.fsf@yhuang-dev.intel.com>
	<20190624072830.GA10539@ming.t460p>
Date: Mon, 24 Jun 2019 15:31:35 +0800
In-Reply-To: <20190624072830.GA10539@ming.t460p> (Ming Lei's message of "Mon,
	24 Jun 2019 15:28:31 +0800")
Message-ID: <87ef3jbfs8.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Ming Lei <ming.lei@redhat.com> writes:

> On Mon, Jun 24, 2019 at 12:44:41PM +0800, Huang, Ying wrote:
>> Ming Lei <ming.lei@redhat.com> writes:
>> 
>> > Hi Huang Ying,
>> >
>> > On Mon, Jun 24, 2019 at 10:23:36AM +0800, Huang, Ying wrote:
>> >> From: Huang Ying <ying.huang@intel.com>
>> >> 
>> >> 0-Day test system reported some OOM regressions for several
>> >> THP (Transparent Huge Page) swap test cases.  These regressions are
>> >> bisected to 6861428921b5 ("block: always define BIO_MAX_PAGES as
>> >> 256").  In the commit, BIO_MAX_PAGES is set to 256 even when THP swap
>> >> is enabled.  So the bio_alloc(gfp_flags, 512) in get_swap_bio() may
>> >> fail when swapping out THP.  That causes the OOM.
>> >> 
>> >> As in the patch description of 6861428921b5 ("block: always define
>> >> BIO_MAX_PAGES as 256"), THP swap should use multi-page bvec to write
>> >> THP to swap space.  So the issue is fixed via doing that in
>> >> get_swap_bio().
>> >> 
>> >> BTW: I remember I have checked the THP swap code when
>> >> 6861428921b5 ("block: always define BIO_MAX_PAGES as 256") was merged,
>> >> and thought the THP swap code needn't to be changed.  But apparently,
>> >> I was wrong.  I should have done this at that time.
>> >> 
>> >> Fixes: 6861428921b5 ("block: always define BIO_MAX_PAGES as 256")
>> >> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>> >> Cc: Ming Lei <ming.lei@redhat.com>
>> >> Cc: Michal Hocko <mhocko@kernel.org>
>> >> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> >> Cc: Hugh Dickins <hughd@google.com>
>> >> Cc: Minchan Kim <minchan@kernel.org>
>> >> Cc: Rik van Riel <riel@redhat.com>
>> >> Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
>> >> ---
>> >>  mm/page_io.c | 7 ++-----
>> >>  1 file changed, 2 insertions(+), 5 deletions(-)
>> >> 
>> >> diff --git a/mm/page_io.c b/mm/page_io.c
>> >> index 2e8019d0e048..4ab997f84061 100644
>> >> --- a/mm/page_io.c
>> >> +++ b/mm/page_io.c
>> >> @@ -29,10 +29,9 @@
>> >>  static struct bio *get_swap_bio(gfp_t gfp_flags,
>> >>  				struct page *page, bio_end_io_t end_io)
>> >>  {
>> >> -	int i, nr = hpage_nr_pages(page);
>> >>  	struct bio *bio;
>> >>  
>> >> -	bio = bio_alloc(gfp_flags, nr);
>> >> +	bio = bio_alloc(gfp_flags, 1);
>> >>  	if (bio) {
>> >>  		struct block_device *bdev;
>> >>  
>> >> @@ -41,9 +40,7 @@ static struct bio *get_swap_bio(gfp_t gfp_flags,
>> >>  		bio->bi_iter.bi_sector <<= PAGE_SHIFT - 9;
>> >>  		bio->bi_end_io = end_io;
>> >>  
>> >> -		for (i = 0; i < nr; i++)
>> >> -			bio_add_page(bio, page + i, PAGE_SIZE, 0);
>> >
>> > bio_add_page() supposes to work, just wondering why it doesn't recently.
>> 
>> Yes.  Just checked and bio_add_page() works too.  I should have used
>> that.  The problem isn't bio_add_page(), but bio_alloc(), because nr ==
>> 512 > 256, mempool cannot be used during swapout, so swapout will fail.
>
> Then we can pass 1 to bio_alloc(), together with single bio_add_page()
> for making the code more readable.
>

Yes.  Will send out v2 to replace __bio_add_page() with bio_add_page().

Best Regards,
Huang, Ying

