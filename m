Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D86E1C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 22:18:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B6E520684
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 22:18:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B6E520684
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC9278E0003; Wed,  6 Mar 2019 17:18:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C77D68E0002; Wed,  6 Mar 2019 17:18:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8DC48E0003; Wed,  6 Mar 2019 17:18:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7668C8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 17:18:23 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id h70so15141143pfd.11
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 14:18:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ViR43OCDei/FCEapfg1mwqWT4tE0ChRVkiXPmWsMAJU=;
        b=mzwsASlLE7dFjISRq9m8BO8GqfbhWyJfZwlG+lQD75Qgrt3NWVkHjQarnbytVCZFBE
         MeMwezYHcKzhLLQNoxItb/aPLQfmg/nuPRvb6E05UG+lJKVB8Y/hyNWOJ+NaZ8O4+Rm5
         RN1ihJ6deMqDjB6RinTwJ+d9V/4yfLFPw7zLIQ+TRpx2GKA3zt10x1nis62HBS2zbZb1
         KQXrGc+TrLWXUg5L8kQkRoz0tX95fiKIOAUAqqP81kJ04zR7hn5oZmojlmly+hGT4Lig
         oujg7OEXRsPjEA4SYGmV/UHeAvQ2mliDX50M6f6/1kRXdmp0xglC6wCWOq1xBHKuOmw5
         X4qg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAV+B0+2NbYyKN7Y2l/zl8Op/ZSD9Tn+vtvUcyuLA8TgV3zFkv4O
	OtBGpopD+hmFik7CCGbuUapTCGdHc1mZYK40kcJjKDhOgWBn8dBBb+kseOUwQ4uyP5+te88vsF0
	1juAw59yM+sBFPwkR7Ov/Bv1P3dK1qkjG+k8gF7KY6XlYPeAwoASKdnrFB8qgk2fBkQ==
X-Received: by 2002:aa7:83cb:: with SMTP id j11mr9579896pfn.117.1551910703057;
        Wed, 06 Mar 2019 14:18:23 -0800 (PST)
X-Google-Smtp-Source: APXvYqzQD/G+76Pt+IHNNCGu7RA69O3v57GZAjWcHwjTm3CIcSBWggbI9P7BUKaGsMy1+5opYgM6
X-Received: by 2002:aa7:83cb:: with SMTP id j11mr9579820pfn.117.1551910702067;
        Wed, 06 Mar 2019 14:18:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551910702; cv=none;
        d=google.com; s=arc-20160816;
        b=jzyXRQSezRoQ3Qw1D6kyxAuFM+PRd4MKx0Dip/SgU9Gzj0MFp+PtbVHIJOr1tDCTZ6
         QuOQUeTuakP6p8EgHLbIqZk/kUP47ewnqEthjfss+MV5EDB4KXIN118NnmG0gKfYPBZd
         B9zqOEijQuvT4Mp+pW7/j2Ee15+Mp4ZiaMks+jSzYr3ObTtx7IZRrtWcc+iuJgP7kudI
         R0hai/GMlI8RcRp+X+yMGAH2xB4fQH+RV6SWZMBVx6YonyctQZ8ItEjmftErn0IhKFjs
         TF8NJ6fIe5OtYtYtGPwKcFWnzh2AiH+xBgvehzO1gjHRTBjN7YCxQw6COIMIDZJ3kSuM
         jzog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=ViR43OCDei/FCEapfg1mwqWT4tE0ChRVkiXPmWsMAJU=;
        b=hoAaS7QyWKfjdNXT67PzutUBVxF6DDFiiSEdKK8rSqbl0ZVRlhihcj1G9pm5Ib/F6E
         WGmO/drwJmcpStRUM4KUhoLSycpHyJUw0HStVP9jyHdS0Q3KwjyZ6acldZ2D8nzuDbAm
         1xmzIAUmx18QrPNHvBzsxyKEpTvrDQuV8k97yiSlErH/t3PzEJqChLyGr/bZH+fjyTju
         HvgP4knGlyh2GtGKko/8TZW94UgqiaRZd4yvYJi/5acH4svP6xe1XRlVK/QFpQV+Jr92
         Qe1DSb5mRnASWLqwtD3H7Mj1aZzzKr/LHpf6asOGDeNyoJeX4YgqhVUxWzP4770D3UeL
         5ZTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b39si2650224pla.381.2019.03.06.14.18.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 14:18:22 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 502CB5B86;
	Wed,  6 Mar 2019 22:18:21 +0000 (UTC)
Date: Wed, 6 Mar 2019 14:18:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ralph Campbell
 <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, linux-fsdevel
 <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
Message-Id: <20190306141820.d60e47d6e173d6ec171f52cf@linux-foundation.org>
In-Reply-To: <20190306154903.GA3230@redhat.com>
References: <CAPcyv4gkYTZ-_Et1ZriAcoHwhtPEftOt2LnR_kW+hQM5-0G4HA@mail.gmail.com>
	<20190129212150.GP3176@redhat.com>
	<CAPcyv4hZMcJ6r0Pw5aJsx37+YKx4qAY0rV4Ascc9LX6eFY8GJg@mail.gmail.com>
	<20190130030317.GC10462@redhat.com>
	<CAPcyv4jS7Y=DLOjRHbdRfwBEpxe_r7wpv0ixTGmL7kL_ThaQFA@mail.gmail.com>
	<20190130183616.GB5061@redhat.com>
	<CAPcyv4hB4p6po1+-hJ4Podxoan35w+T6uZJzqbw=zvj5XdeNVQ@mail.gmail.com>
	<20190131041641.GK5061@redhat.com>
	<CAPcyv4gb+r==riKFXkVZ7gGdnKe62yBmZ7xOa4uBBByhnK9Tzg@mail.gmail.com>
	<20190305141635.8134e310ba7187bc39532cd3@linux-foundation.org>
	<20190306154903.GA3230@redhat.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Mar 2019 10:49:04 -0500 Jerome Glisse <jglisse@redhat.com> wrote:

> On Tue, Mar 05, 2019 at 02:16:35PM -0800, Andrew Morton wrote:
> > On Wed, 30 Jan 2019 21:44:46 -0800 Dan Williams <dan.j.williams@intel.com> wrote:
> > 
> > > >
> > > > > Another way to help allay these worries is commit to no new exports
> > > > > without in-tree users. In general, that should go without saying for
> > > > > any core changes for new or future hardware.
> > > >
> > > > I always intend to have an upstream user the issue is that the device
> > > > driver tree and the mm tree move a different pace and there is always
> > > > a chicken and egg problem. I do not think Andrew wants to have to
> > > > merge driver patches through its tree, nor Linus want to have to merge
> > > > drivers and mm trees in specific order. So it is easier to introduce
> > > > mm change in one release and driver change in the next. This is what
> > > > i am doing with ODP. Adding things necessary in 5.1 and working with
> > > > Mellanox to have the ODP HMM patch fully tested and ready to go in
> > > > 5.2 (the patch is available today and Mellanox have begin testing it
> > > > AFAIK). So this is the guideline i will be following. Post mm bits
> > > > with driver patches, push to merge mm bits one release and have the
> > > > driver bits in the next. I do hope this sound fine to everyone.
> > > 
> > > The track record to date has not been "merge HMM patch in one release
> > > and merge the driver updates the next". If that is the plan going
> > > forward that's great, and I do appreciate that this set came with
> > > driver changes, and maintain hope the existing exports don't go
> > > user-less for too much longer.
> > 
> > Decision time.  Jerome, how are things looking for getting these driver
> > changes merged in the next cycle?
> 
> nouveau is merge already.

Confused.  Nouveau in mainline is dependent upon "mm/hmm: allow to
mirror vma of a file on a DAX backed filesystem"?  That can't be the
case?

> > 
> > Dan, what's your overall take on this series for a 5.1-rc1 merge?
> > 
> > Jerome, what would be the risks in skipping just this [09/10] patch?
> 
> As nouveau is a new user it does not regress anything but for RDMA
> mlx5 (which i expect to merge new window) it would regress that
> driver.

Also confused.  How can omitting "mm/hmm: allow to mirror vma of a file
on a DAX backed filesystem" from 5.1-rc1 cause an mlx5 regression?

