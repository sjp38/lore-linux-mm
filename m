Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30D5CC76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 22:11:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB42F218D4
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 22:11:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB42F218D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CC436B0006; Tue, 23 Jul 2019 18:11:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A4138E0003; Tue, 23 Jul 2019 18:11:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B8E08E0002; Tue, 23 Jul 2019 18:11:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4440D6B0006
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 18:11:48 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id d190so27068462pfa.0
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 15:11:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=wWUWqMB+sxzUrOj2hwcNcJgBnFaIDbzdce5wlkTDShI=;
        b=Xi+7QGWaF3nfUO+AYr9YNGoBQYk0pwv4yYFlkybm7EScSFAadwrzak8APMUHVfbAoB
         np5B2dg8IdSVx+w08nx9gy8JNjV9Ta6i++nLzC99J2sjng1s8s952jPjVwPoIuM3Y/8U
         U8kDt0EEiHQTmO6BoJlgIZp8kmy2lznjPE4sZ96rp4V2gmzNbLH0+oejQ5Pc4aePYqM/
         gZ4JLWgQlrtb7n/RhbCmVGgcMt/B7lBuPPsFrTRjKwQHoT+t/VEdWdNsdZJcwmAaMHVZ
         zhxzeCHR/4XbXIf87D5mwCloBhb090s+aTB228HWs/mg7uIG/24bx8dTCAy4+KRuvFOM
         AZ/g==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXfL5sq9mCwsE8rlLigdUbPgSkSqU9RQVWqp5k5WhKDzFF/iELq
	CfH9lHoZuQ8k/skNxcCrkF9IJLKaDZzagZs5tXeeZjFmpxLH16eyWXdjfmFSszAJ8CVhyuazqYX
	WvmwdmvroBhLLg37ml4i87VyccZPciAnzze263jpAtZx4UsUezqDmI5G7o3AIeAM=
X-Received: by 2002:a65:63cd:: with SMTP id n13mr78027018pgv.153.1563919907833;
        Tue, 23 Jul 2019 15:11:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzU0UP1421Z/xVG0AGdsr3ZVeQ0aQsxFbdo5nOZMFUny5oxxwQHfk39DI9K0ePyAgzqEGIu
X-Received: by 2002:a65:63cd:: with SMTP id n13mr78026965pgv.153.1563919907068;
        Tue, 23 Jul 2019 15:11:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563919907; cv=none;
        d=google.com; s=arc-20160816;
        b=bJRLfmzTX7E4PrGT43mERrLBCn7BanjYf9biV2FmnhPawHwtRwNAZtlUxeepmQBKV9
         b8CvZBbCJ8HGJYRzTI1H0Ff1KY02SudRjqFQpifcHwyQb701UoR/fcJ+TGcRVnNrLdkw
         cqoYF0WNq/JVQcmKM6ag8AKRRtJ6jSM8uW0E9fjkI8FWxoOJKcsAEUopVyWPNAsYbr9A
         CYKzuEruW1BF/7VP+9Ds2R8X9a1xEjmPeNxrMiZuATM0wFPFHIcQo2aCyVJcoGJFIZcl
         6LfvA7qzjEdiK0Lzvp+8GEdeOQnUpJjfvh2m8Qi+PhN6cRhCeqo0OT9H9bA9ODlMyUWu
         bDzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=wWUWqMB+sxzUrOj2hwcNcJgBnFaIDbzdce5wlkTDShI=;
        b=UPlq97btNUOGEE/20vwWqYu6bRHzfbXUxa4Wn8RAXG7JUvlgeNd7fqJzbdlOW9iYky
         VJDV11ejCZXfs+WyOPHEWPZqasm/dabKPSUAZXmSkTiojmGhEqgWbiY4Ufi7SW2MK9EN
         eO3IB9BcNaZeVAC7L1Akgxl0wpXQffnUCVB7h1n2xqovdW7xHA6+Wb5WAwE6Tzb26Y4F
         w8Gtb+cBnxE99RZcyRjavsO4AsA86/MJpRx3h2HgoTJ84rXz6PUWJZMGu32T5PqTLqL/
         ClrG1Nc0zsncvHxtzJdEMBMqpPuqmuRvnJ8kXem8KwIMjalsvNSdK5DxPoLBkLJSyxLI
         +vNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id o7si16678288pgq.459.2019.07.23.15.11.46
        for <linux-mm@kvack.org>;
        Tue, 23 Jul 2019 15:11:47 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id E2B522AA6CE;
	Wed, 24 Jul 2019 08:11:43 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hq2zU-0003lk-Ea; Wed, 24 Jul 2019 08:10:36 +1000
Date: Wed, 24 Jul 2019 08:10:36 +1000
From: Dave Chinner <david@fromorbit.com>
To: Jens Axboe <axboe@kernel.dk>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] psi: annotate refault stalls from IO submission
Message-ID: <20190723221036.GY7777@dread.disaster.area>
References: <20190722201337.19180-1-hannes@cmpxchg.org>
 <20190723000226.GV7777@dread.disaster.area>
 <20190723190438.GA22541@cmpxchg.org>
 <2d80cfdb-f5e0-54f1-29a3-a05dee5b94eb@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2d80cfdb-f5e0-54f1-29a3-a05dee5b94eb@kernel.dk>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=0o9FgrsRnhwA:10
	a=7-415B0cAAAA:8 a=RvhrQjGMwq6Bl1CCUxgA:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 01:34:50PM -0600, Jens Axboe wrote:
> On 7/23/19 1:04 PM, Johannes Weiner wrote:
> > CCing Jens for bio layer stuff
> > 
> > On Tue, Jul 23, 2019 at 10:02:26AM +1000, Dave Chinner wrote:
> >> Even better: If this memstall and "refault" check is needed to
> >> account for bio submission blocking, then page cache iteration is
> >> the wrong place to be doing this check. It should be done entirely
> >> in the bio code when adding pages to the bio because we'll only ever
> >> be doing page cache read IO on page cache misses. i.e. this isn't
> >> dependent on adding a new page to the LRU or not - if we add a new
> >> page then we are going to be doing IO and so this does not require
> >> magic pixie dust at the page cache iteration level
> > 
> > That could work. I had it at the page cache level because that's
> > logically where the refault occurs. But PG_workingset encodes
> > everything we need from the page cache layer and is available where
> > the actual stall occurs, so we should be able to push it down.
> > 
> >> e.g. bio_add_page_memstall() can do the working set check and then
> >> set a flag on the bio to say it contains a memstall page. Then on
> >> submission of the bio the memstall condition can be cleared.
> > 
> > A separate bio_add_page_memstall() would have all the problems you
> > pointed out with the original patch: it's magic, people will get it
> > wrong, and it'll be hard to verify and notice regressions.
> > 
> > How about just doing it in __bio_add_page()? PG_workingset is not
> > overloaded - when we see it set, we can generally and unconditionally
> > flag the bio as containing userspace workingset pages.
> > 
> > At submission time, in conjunction with the IO direction, we can
> > clearly tell whether we are reloading userspace workingset data,
> > i.e. stalling on memory.
> > 
> > This?
> 
> Not vehemently opposed to it, even if it sucks having to test page flags
> in the hot path.

That's kinda why I suggested the bio_add_page_memstall() variant for
the page cache read IO paths where this check would be required.

Not fussed either way, this is much cleaner and easier to maintain
IMO....

-Dave.
-- 
Dave Chinner
david@fromorbit.com

