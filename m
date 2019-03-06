Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CE66C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 16:03:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D970E206DD
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 16:03:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D970E206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 505738E0021; Wed,  6 Mar 2019 11:03:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B5698E0015; Wed,  6 Mar 2019 11:03:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37CA68E0021; Wed,  6 Mar 2019 11:03:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 082258E0015
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 11:03:28 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id c9so11841982qte.11
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 08:03:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pest1m1b9CmneJ1W5aPd3c9Rts1c8Ypuq0wfFY1rK0Q=;
        b=kM9fk7QPLqwW/odHeZg8PM2PChatdXFRoZu1KYwVVx2HyaiWi1mCdP6WgaYL3zJoI/
         E72sdtaDH9UvZv+6nMbuPf5tqw4aNxqQzH0DSx+WWYm48QBj8DOfy6ja2/TuewAwoSQp
         GrcgbCW93wzUQ7ULnsRR1l7FG9Ur/E396bjWucn24qpxrfKsIUcH9BbBrGLqKnG1dPg+
         DM7qzm/DcCIgDIIRkz9sFKKrDgZ8MzqrvHo5WDPXP+w3cL+Plwdu1X+OAZL6rgUhyGHt
         qi7KSqB7AS4M4RBMu6jsKCIlqmvLwidc0IE+Jf/6KE5MDjQlCiRY2wlUZ4takcK8dcA4
         Ub5w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX86AOgjhCBP4o3WCRQ5L0WIIPPAN15gJEnRw/d3gkhk6xSyg46
	iSrBW9fIZixbnot1Q04hDT7SysSM5rmKjbKu7Gp6br53IRaLO7RV6PTO0PiDm1XNFJj33lchS2D
	noTzJdnU2+OKNZAOkNupvAiryDR8aWPqPMiKH2ifPW0WKI8yJxclnUaLbPcmzrh4e/g==
X-Received: by 2002:aed:3b58:: with SMTP id q24mr6466939qte.227.1551888207804;
        Wed, 06 Mar 2019 08:03:27 -0800 (PST)
X-Google-Smtp-Source: APXvYqw4rc+99s82FIrifSLMI3R1y3tJwdKLdXd8yg3Ij9mbEb+LfChCreqcD/s92gWA/HdST3cH
X-Received: by 2002:aed:3b58:: with SMTP id q24mr6466848qte.227.1551888207003;
        Wed, 06 Mar 2019 08:03:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551888207; cv=none;
        d=google.com; s=arc-20160816;
        b=NWH4rLcftwlRdL4HO5eTgTFIXCMiJ3K5Fkkbi9qofbwtW3bq3Xk2iKeplzkqWMxYHA
         PX3TmbhfGNa/T9DGBUdcav3wenl8E4eO1Oc5lbXKE8EeMeyTBs72X5UiR65GukuNuhb4
         a7oFFjKQFkZfgaDE8FOkr2aAf0F6zzeqvasCps3/Kx3vvXKkSqTEdZ9JzGkEDkJHJau9
         zHOt8WUg+CpRwPhjdBn2tflZ70F39SxpZ4B2hJNh25l2bFYyBM7+xdSa4PTMvTko7Pt0
         AQ46rafqXAgUhasDswxwrDHxRh6UEe1XNJOheNcFYdhLxiIk2gSWN6sFbhVtpkkOeO7t
         DmOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pest1m1b9CmneJ1W5aPd3c9Rts1c8Ypuq0wfFY1rK0Q=;
        b=zDDKjKHBioPAEEhkmeZTgveO/bTzj7IXb0bDNWRm7oNNe8SGQ4i0nayCUyw0T2vVri
         GY5RHiHOzSGZM8cL3O2gYne7+/lipp7gFp8c049yNRP166lc6yo9Sh23JqYK3s6AR858
         mDfrckVKaVvvyNYMEycVESSLUiG+haoyZzE+O7RxXWwNeIcLbqI1RJRBqjNJ5ATKl0o4
         xoK4GOortX+reMirEdJVe6Bt79W7Lte7VQSB1jKAjUSQcLe4BvloKlM6Jl9VT6mG5p3i
         89z6+5B8ud2EpEkkFiPVczAOAURKSGYycyG2J1VcBGYhEdJNqDu/n8ex8DhFqQe4aSIF
         Ecvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n6si1213315qvk.222.2019.03.06.08.03.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 08:03:26 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2734D307E044;
	Wed,  6 Mar 2019 16:03:26 +0000 (UTC)
Received: from redhat.com (ovpn-125-142.rdu2.redhat.com [10.10.125.142])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 4F8621001DF0;
	Wed,  6 Mar 2019 16:03:25 +0000 (UTC)
Date: Wed, 6 Mar 2019 11:03:23 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
Message-ID: <20190306160323.GD3230@redhat.com>
References: <20190130030317.GC10462@redhat.com>
 <CAPcyv4jS7Y=DLOjRHbdRfwBEpxe_r7wpv0ixTGmL7kL_ThaQFA@mail.gmail.com>
 <20190130183616.GB5061@redhat.com>
 <CAPcyv4hB4p6po1+-hJ4Podxoan35w+T6uZJzqbw=zvj5XdeNVQ@mail.gmail.com>
 <20190131041641.GK5061@redhat.com>
 <CAPcyv4gb+r==riKFXkVZ7gGdnKe62yBmZ7xOa4uBBByhnK9Tzg@mail.gmail.com>
 <20190305141635.8134e310ba7187bc39532cd3@linux-foundation.org>
 <CAA9_cmd2Z62Z5CSXvne4rj3aPSpNhS0Gxt+kZytz0bVEuzvc=A@mail.gmail.com>
 <20190306155126.GB3230@redhat.com>
 <CAPcyv4iB+7LF-ZOF1VXE+g2hS7Gb=+RbGAmTiGWDsaikEuXGYw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iB+7LF-ZOF1VXE+g2hS7Gb=+RbGAmTiGWDsaikEuXGYw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Wed, 06 Mar 2019 16:03:26 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 06, 2019 at 07:57:30AM -0800, Dan Williams wrote:
> On Wed, Mar 6, 2019 at 7:51 AM Jerome Glisse <jglisse@redhat.com> wrote:
> >
> > On Tue, Mar 05, 2019 at 08:20:10PM -0800, Dan Williams wrote:
> > > On Tue, Mar 5, 2019 at 2:16 PM Andrew Morton <akpm@linux-foundation.org> wrote:
> > > >
> > > > On Wed, 30 Jan 2019 21:44:46 -0800 Dan Williams <dan.j.williams@intel.com> wrote:
> > > >
> > > > > >
> > > > > > > Another way to help allay these worries is commit to no new exports
> > > > > > > without in-tree users. In general, that should go without saying for
> > > > > > > any core changes for new or future hardware.
> > > > > >
> > > > > > I always intend to have an upstream user the issue is that the device
> > > > > > driver tree and the mm tree move a different pace and there is always
> > > > > > a chicken and egg problem. I do not think Andrew wants to have to
> > > > > > merge driver patches through its tree, nor Linus want to have to merge
> > > > > > drivers and mm trees in specific order. So it is easier to introduce
> > > > > > mm change in one release and driver change in the next. This is what
> > > > > > i am doing with ODP. Adding things necessary in 5.1 and working with
> > > > > > Mellanox to have the ODP HMM patch fully tested and ready to go in
> > > > > > 5.2 (the patch is available today and Mellanox have begin testing it
> > > > > > AFAIK). So this is the guideline i will be following. Post mm bits
> > > > > > with driver patches, push to merge mm bits one release and have the
> > > > > > driver bits in the next. I do hope this sound fine to everyone.
> > > > >
> > > > > The track record to date has not been "merge HMM patch in one release
> > > > > and merge the driver updates the next". If that is the plan going
> > > > > forward that's great, and I do appreciate that this set came with
> > > > > driver changes, and maintain hope the existing exports don't go
> > > > > user-less for too much longer.
> > > >
> > > > Decision time.  Jerome, how are things looking for getting these driver
> > > > changes merged in the next cycle?
> > > >
> > > > Dan, what's your overall take on this series for a 5.1-rc1 merge?
> > >
> > > My hesitation would be drastically reduced if there was a plan to
> > > avoid dangling unconsumed symbols and functionality. Specifically one
> > > or more of the following suggestions:
> > >
> > > * EXPORT_SYMBOL_GPL on all exports to avoid a growing liability
> > > surface for out-of-tree consumers to come grumble at us when we
> > > continue to refactor the kernel as we are wont to do.
> > >
> > > * A commitment to consume newly exported symbols in the same merge
> > > window, or the following merge window. When that goal is missed revert
> > > the functionality until such time that it can be consumed, or
> > > otherwise abandoned.
> > >
> > > * No new symbol exports and functionality while existing symbols go unconsumed.
> > >
> > > These are the minimum requirements I would expect my work, or any
> > > core-mm work for that matter, to be held to, I see no reason why HMM
> > > could not meet the same.
> >
> > nouveau use all of this and other driver patchset have been posted to
> > also use this API.
> >
> > > On this specific patch I would ask that the changelog incorporate the
> > > motivation that was teased out of our follow-on discussion, not "There
> > > is no reason not to support that case." which isn't a justification.
> >
> > mlx5 wants to use HMM without DAX support it would regress mlx5. Other
> > driver like nouveau also want to access DAX filesystem. So yes there is
> > no reason not to support DAX filesystem. Why do you not want DAX with
> > mirroring ? You want to cripple HMM ? Why ?
> 
> There is a misunderstanding... my request for this patch was to update
> the changelog to describe the merits of DAX mirroring to replace the
> "There is no reason not to support that case." Otherwise someone
> reading this changelog in a year will wonder what the motivation was.

So what about:

HMM mirroring allow device to mirror process address onto device
there is no reason for that mirroring to not work if the virtual
address are the result of an mmap of a file on DAX enabled file-
system.

