Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DFA3C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 02:45:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D2A621871
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 02:45:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D2A621871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C22156B0007; Thu, 28 Mar 2019 22:45:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD0CF6B0008; Thu, 28 Mar 2019 22:45:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABF656B000C; Thu, 28 Mar 2019 22:45:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B07B6B0007
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 22:45:17 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e5so603554pgc.16
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 19:45:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=n2g2gZE/MhNi7nI6UCGVxkyvHL3xkteyl6AUacdA/M8=;
        b=o1V5KtlIpkS/pbBwI2Pi7yUpSW39xBIj8sHS/V7ymDx2z4RlwC6tqE7gOR3m7X1uK0
         BB5CUTZGqEt2/yN1yGmGpCCDXc8LNG7IEVgwA/v4LaZx4JPBBMGiqNiWHNqKyD/nk0XS
         u9i1geC5ECYhIv9UYBOa7j2bOM69wFN9EmI0TxuqeT534KbAO9cCYR0eivYpmfRsQ6vE
         ZBd8lEbJKoEeKO3IEfSG5BhGFqIZCGxsyQ/8KM9zxSDTMXHwFGFxmBJubJV/xB20ynp7
         M/IaCyaFPjRXEcTB1uSxOHm48EZWgJuQHWP+B4I2IomsTBZRNB9SFFGrLqR1Fdmn+JJl
         Ng+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW0ZIcM/pAHD3r9OZgtJegd3rU6eJQ7m+qhu2o17+KtuJBsyECH
	yvWXKYmseanCnpZX6nldl63HvOtI3dHKKMAmeL9BV5cu/qtQbGiqPVfDClGX1jTkrZMbQiGWqVf
	JSFA9ij+RsfAzuHKUtmdb2KLudjZFgZnXyZiWAuSz8IpApxcV0/1xH+mizwEjmpJqvg==
X-Received: by 2002:a63:bd42:: with SMTP id d2mr27032795pgp.319.1553827517049;
        Thu, 28 Mar 2019 19:45:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLVL/qn6621EFkHqBCqqf64SwDwQNopwxh+pyhwcZhpopJqzU+4RzKYAs/p4feJZeiOwzL
X-Received: by 2002:a63:bd42:: with SMTP id d2mr27032733pgp.319.1553827516196;
        Thu, 28 Mar 2019 19:45:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553827516; cv=none;
        d=google.com; s=arc-20160816;
        b=FaBPYcXawQLAdjd3PPkkvY3zYDouJFeMSuxR+alxL9C7IIeyxrAa3y2+H8HjHLy5sH
         1rAylTs3CK2lCkNA70wCXHngG5cvUEZLTWu4AS5RI7HH78uaEhs7Tq7Wkua7hRQECf9V
         mP39G3xwkrCQyGnvewAMyOWeZmKuVGtqjY4vBoJhUAIMtNQH5N5IC4iF54puoVrwz3U7
         VHOgyVfoXHb6+EHSryP9fjQHNZBGY70/pkR8y3B/l3ZGJMg+ttHFdf+tvvcBs6jI3qeL
         Qds4Mr2rZLC6jlmLT0aUOovtCtRir5rBCOWrqnE9kTLQvtb17awjYNaav3tqi66g6sWX
         u8Qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=n2g2gZE/MhNi7nI6UCGVxkyvHL3xkteyl6AUacdA/M8=;
        b=BHkskfRlR9Xsr4qgkmdNtWpyeiA05Hei2oYO0HG17egsDYZ5OvJEgc/S4oHifXqzre
         4CNQF4EpP3Yq+UVANPB5VndIRQAxmligEno/sUMbYCDL+K2cLiHq9b7qTTRpjEM3YIIF
         CDHfKZCULATnoQAwdGBSFKO4F25fz0+o2QesM6lsF4kxYNS8m8cypQPUSqvpcy+bPMP1
         YUknR2I6hrvc0F36TwoSaMYq/PuxKXU86Nz2U67bK5HkEJe40A+Zhyqzjx6lh3VUk1xY
         AHFaoaAEgGnB3H1y83aWrof5MqZwphO6dg/GZ6VDpOVEc3tp8jk8wb2YZnjNRuN3Bhjz
         z2cw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id l66si756436pgl.474.2019.03.28.19.45.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 19:45:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Mar 2019 19:45:15 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,282,1549958400"; 
   d="scan'208";a="156817100"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga004.fm.intel.com with ESMTP; 28 Mar 2019 19:45:15 -0700
Date: Thu, 28 Mar 2019 11:44:08 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 10/11] mm/hmm: add helpers for driver to safely take
 the mmap_sem v2
Message-ID: <20190328184408.GK31324@iweiny-DESK2.sc.intel.com>
References: <20190328213047.GB13560@redhat.com>
 <a16efd42-3e2b-1b72-c205-0c2659de2750@nvidia.com>
 <20190328220824.GE13560@redhat.com>
 <068db0a8-fade-8ed1-3b9d-c29c27797301@nvidia.com>
 <20190328224032.GH13560@redhat.com>
 <0b698b36-da17-434b-b8e7-4a91ac6c9d82@nvidia.com>
 <20190328230543.GI13560@redhat.com>
 <9e414b8c-0f98-a2f7-4f46-d335c015fc1b@nvidia.com>
 <20190328232404.GK13560@redhat.com>
 <c02bcb34-bb3c-c3c9-f070-050006390776@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <c02bcb34-bb3c-c3c9-f070-050006390776@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 04:34:04PM -0700, John Hubbard wrote:
> On 3/28/19 4:24 PM, Jerome Glisse wrote:
> > On Thu, Mar 28, 2019 at 04:20:37PM -0700, John Hubbard wrote:
> >> On 3/28/19 4:05 PM, Jerome Glisse wrote:
> >>> On Thu, Mar 28, 2019 at 03:43:33PM -0700, John Hubbard wrote:
> >>>> On 3/28/19 3:40 PM, Jerome Glisse wrote:
> >>>>> On Thu, Mar 28, 2019 at 03:25:39PM -0700, John Hubbard wrote:
> >>>>>> On 3/28/19 3:08 PM, Jerome Glisse wrote:
> >>>>>>> On Thu, Mar 28, 2019 at 02:41:02PM -0700, John Hubbard wrote:
> >>>>>>>> On 3/28/19 2:30 PM, Jerome Glisse wrote:
> >>>>>>>>> On Thu, Mar 28, 2019 at 01:54:01PM -0700, John Hubbard wrote:
> >>>>>>>>>> On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
> >>>>>>>>>>> From: Jérôme Glisse <jglisse@redhat.com>
> >>>>>> [...]
> >>>>>> OK, so let's either drop this patch, or if merge windows won't allow that,
> >>>>>> then *eventually* drop this patch. And instead, put in a hmm_sanity_check()
> >>>>>> that does the same checks.
> >>>>>
> >>>>> RDMA depends on this, so does the nouveau patchset that convert to new API.
> >>>>> So i do not see reason to drop this. They are user for this they are posted
> >>>>> and i hope i explained properly the benefit.
> >>>>>
> >>>>> It is a common pattern. Yes it only save couple lines of code but down the
> >>>>> road i will also help for people working on the mmap_sem patchset.
> >>>>>
> >>>>
> >>>> It *adds* a couple of lines that are misleading, because they look like they
> >>>> make things safer, but they don't actually do so.
> >>>
> >>> It is not about safety, sorry if it confused you but there is nothing about
> >>> safety here, i can add a big fat comment that explains that there is no safety
> >>> here. The intention is to allow the page fault handler that potential have
> >>> hundred of page fault queue up to abort as soon as it sees that it is pointless
> >>> to keep faulting on a dying process.
> >>>
> >>> Again if we race it is _fine_ nothing bad will happen, we are just doing use-
> >>> less work that gonna be thrown on the floor and we are just slowing down the
> >>> process tear down.
> >>>
> >>
> >> In addition to a comment, how about naming this thing to indicate the above 
> >> intention?  I have a really hard time with this odd down_read() wrapper, which
> >> allows code to proceed without really getting a lock. It's just too wrong-looking.
> >> If it were instead named:
> >>
> >> 	hmm_is_exiting()
> > 
> > What about: hmm_lock_mmap_if_alive() ?
> > 
> 
> That's definitely better, but I want to vote for just doing a check, not 
> taking any locks.
> 
> I'm not super concerned about the exact name, but I really want a routine that
> just checks (and optionally asserts, via WARN or BUG), and that's *all*. Then
> drivers can scatter that around like pixie dust as they see fit. Maybe right before
> taking a lock, maybe in other places. Decoupled from locking.

I agree.  Names matter and any function which is called *_down_read and could
potentially not take the lock should be called try_*_down_read.  Furthermore
users should be checking the return values from any try_*.

It is also odd that we are calling "down/up" on something which is not a
semaphore.  So the user here needs to _know_ that they are really getting the
lock on the mm which sits behind the scenes.  What John is proposing is more
explicit when reading driver code.

Ira

> 
> thanks,
> -- 
> John Hubbard
> NVIDIA
> 

