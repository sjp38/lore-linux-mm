Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E87FDC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 23:24:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 976E62184E
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 23:24:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 976E62184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 453A16B0003; Thu, 28 Mar 2019 19:24:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 402446B0006; Thu, 28 Mar 2019 19:24:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CC7B6B0007; Thu, 28 Mar 2019 19:24:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 079556B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 19:24:09 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id f89so524049qtb.4
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 16:24:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=cKhHjSUXMzj+FAHbo9o70nX/JY0CWssrU9IIop80g3Y=;
        b=ngJQXX1hMjY6dqx8TTw//QLUAYWcmvWt/jJCJeY4MVi3leEQmdNyvd+LH5anSkqvsi
         Oppb+yg2uSv0TisRLRxNgpwVyV0b4NNJbxyGgHkxN7Q8u1Ouq62h/Mm4M2TFGqVFkQJ6
         JrkonEMFSlAFMPR+p0Dgj+SodsW2nCV7TgQKOX6E2dPaJah9qeUaJ3uEYnsmvbSu6iDh
         2syDe4/WSkW3z906woMTHlQpdmB3xjkrnoKJLepCqcX+HFcJkSj1k0SCb9MEm4fllx24
         F1DxWiH6bjemOiUJeWz53iPoDn7OB2yb2Buq2fxOTfoFplCodRv2MogyWd79v7XjpRuW
         BZsQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUvOAh/PKl4vUT0I3sPCCz7o+FgqPa2P4ru8L5p0vMXYcAa8n7M
	GXymrN6NzMWjGQrAIF8nQjJBdPmEadC8cxW3YbgiI8eUpBmd9idFftEVGEmxDTBWKBtOODoe1NI
	Wju44xf/HDKnhqrfK82qU+bEoyULJDouvoXyZgEm7mTNIdIEG/E+UAGBtB8RD5h7KSA==
X-Received: by 2002:aed:2572:: with SMTP id w47mr37310601qtc.21.1553815448781;
        Thu, 28 Mar 2019 16:24:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy08T42epQ+mAUHrotGT0085jW24ExI1xXVr0evbceYkCZFwtuj2AOU5wbzFXOOiaN4WbsW
X-Received: by 2002:aed:2572:: with SMTP id w47mr37310578qtc.21.1553815448300;
        Thu, 28 Mar 2019 16:24:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553815448; cv=none;
        d=google.com; s=arc-20160816;
        b=E29PDfNYR8/jWXs/dpeskYNn8ovkQy9b3p02cPKZwpJur9ymO4pro0DE2JjjI44kMj
         +tDUo9XvKud6KQcJFFEC96gaDHACtCU1Y/7x3LZ2PsA+SfgzXv+i8jMzCX5Mr0LOe540
         62dNfZqfmdp+hyBSKYrE8MF6jzecNF99fFlaHrXCNhqfHcpkSeENCyFzArlSYe+NM8up
         HuNYiv+RRVehZAoJjks/MZdMpRZ1sY+SeIcX24skoaohX5f/Z5B+8ysZ67OCKGfcrs1D
         TF6gN6mpOsv+u59S7f6Wk6qGXAJsfycoDlt3Xb7zIWU5R6ioKDuf0mL7EN+oKHaYLv8R
         VMyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=cKhHjSUXMzj+FAHbo9o70nX/JY0CWssrU9IIop80g3Y=;
        b=bvrH8MkrYWgIA6/LCZRLRTXo2SUF9qTLN5I2Fij3udo9aHXiQjM3fYP1jJqYl13f9U
         Lrc+Mds02o+CzAvd4OiW8/cE7F0KPl8zl9ynOgpQKMI60YKa/QCIrNG9ERXGA5F3dexg
         /K6KEZu1//IpR3VKfr4DOWyHISzH4tZZQzuuTxiXfDeOA4h/h6K1RGH0heXGb88NOn+Z
         S6Cp4A5md7UX3LrUkjIq6bnv6iTCgprMjntXA2SBISfCC+6zHbmlWYAta7exII7huuN0
         VZpN11MF2udWATQMvGqGcbNLaZdGBzbGTseSfErHDkO74m8YsuRRw+LvsSeGdTJYk6g9
         Po/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i3si251564qtb.22.2019.03.28.16.24.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 16:24:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6E5A6859FF;
	Thu, 28 Mar 2019 23:24:07 +0000 (UTC)
Received: from redhat.com (ovpn-121-118.rdu2.redhat.com [10.10.121.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 978C519C5A;
	Thu, 28 Mar 2019 23:24:06 +0000 (UTC)
Date: Thu, 28 Mar 2019 19:24:04 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 10/11] mm/hmm: add helpers for driver to safely take
 the mmap_sem v2
Message-ID: <20190328232404.GK13560@redhat.com>
References: <20190325144011.10560-11-jglisse@redhat.com>
 <9df742eb-61ca-3629-a5f4-8ad1244ff840@nvidia.com>
 <20190328213047.GB13560@redhat.com>
 <a16efd42-3e2b-1b72-c205-0c2659de2750@nvidia.com>
 <20190328220824.GE13560@redhat.com>
 <068db0a8-fade-8ed1-3b9d-c29c27797301@nvidia.com>
 <20190328224032.GH13560@redhat.com>
 <0b698b36-da17-434b-b8e7-4a91ac6c9d82@nvidia.com>
 <20190328230543.GI13560@redhat.com>
 <9e414b8c-0f98-a2f7-4f46-d335c015fc1b@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <9e414b8c-0f98-a2f7-4f46-d335c015fc1b@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 28 Mar 2019 23:24:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 04:20:37PM -0700, John Hubbard wrote:
> On 3/28/19 4:05 PM, Jerome Glisse wrote:
> > On Thu, Mar 28, 2019 at 03:43:33PM -0700, John Hubbard wrote:
> >> On 3/28/19 3:40 PM, Jerome Glisse wrote:
> >>> On Thu, Mar 28, 2019 at 03:25:39PM -0700, John Hubbard wrote:
> >>>> On 3/28/19 3:08 PM, Jerome Glisse wrote:
> >>>>> On Thu, Mar 28, 2019 at 02:41:02PM -0700, John Hubbard wrote:
> >>>>>> On 3/28/19 2:30 PM, Jerome Glisse wrote:
> >>>>>>> On Thu, Mar 28, 2019 at 01:54:01PM -0700, John Hubbard wrote:
> >>>>>>>> On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
> >>>>>>>>> From: Jérôme Glisse <jglisse@redhat.com>
> >>>> [...]
> >>>> OK, so let's either drop this patch, or if merge windows won't allow that,
> >>>> then *eventually* drop this patch. And instead, put in a hmm_sanity_check()
> >>>> that does the same checks.
> >>>
> >>> RDMA depends on this, so does the nouveau patchset that convert to new API.
> >>> So i do not see reason to drop this. They are user for this they are posted
> >>> and i hope i explained properly the benefit.
> >>>
> >>> It is a common pattern. Yes it only save couple lines of code but down the
> >>> road i will also help for people working on the mmap_sem patchset.
> >>>
> >>
> >> It *adds* a couple of lines that are misleading, because they look like they
> >> make things safer, but they don't actually do so.
> > 
> > It is not about safety, sorry if it confused you but there is nothing about
> > safety here, i can add a big fat comment that explains that there is no safety
> > here. The intention is to allow the page fault handler that potential have
> > hundred of page fault queue up to abort as soon as it sees that it is pointless
> > to keep faulting on a dying process.
> > 
> > Again if we race it is _fine_ nothing bad will happen, we are just doing use-
> > less work that gonna be thrown on the floor and we are just slowing down the
> > process tear down.
> > 
> 
> In addition to a comment, how about naming this thing to indicate the above 
> intention?  I have a really hard time with this odd down_read() wrapper, which
> allows code to proceed without really getting a lock. It's just too wrong-looking.
> If it were instead named:
> 
> 	hmm_is_exiting()

What about: hmm_lock_mmap_if_alive() ?


> 
> and had a comment about why racy is OK, then I'd be a lot happier. :)

Will add fat comment.

Cheers,
Jérôme

