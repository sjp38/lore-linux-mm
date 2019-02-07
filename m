Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBF7FC169C4
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 03:13:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70A3F218D9
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 03:13:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="u0M4bGcw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70A3F218D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F24ED8E0012; Wed,  6 Feb 2019 22:13:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED2ED8E0002; Wed,  6 Feb 2019 22:13:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE99F8E0012; Wed,  6 Feb 2019 22:13:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id B1EE68E0002
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 22:13:29 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id q11so7968338otl.23
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 19:13:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=wJGn1wJcx1sUVcnHWCYzvVKZidnL377KOH3WegpZNcw=;
        b=TAHPgWj3/rpXoZ/JfmBCmMTIDMAzEBanK4M+wjlJXQrnVFVXpJx127c19MyEeOFcil
         dWiPAA29S6RsI7NhIOWa9UXolgUXdk7Qy+hLBip1iDd+XCEGeorLW82lwkePzjJYs7th
         gn02yQ9IfDQvR2Ujkyj+1A5q306GR/Y+Wn8deB7yMJ2ffRT3L1VXVEFVSrTHrYJQKpqr
         taUs12wGWhY3G+XxerIL06E6B3K2p/j34KQJJe9wWy+NgsiBwapS1eLyOh7qGmb6Eatr
         fpRvDUxjDXkE8tpxQio77m2AkLxKhNdt3H+jqcDQ/GvR4oS1m5r8Q+k8wck8I6mK6IOZ
         5Crg==
X-Gm-Message-State: AHQUAuYjTuDAEanxfrRBLjvkBXAf/PNh+snoCiKOvYLh9JTJHx0FoYXi
	3DRkFwRZGgUtraYxvAW6T2oyk/af65Bbd/YAhLMIcFSmeX70SGsggYOgkniY7u45PZcT2i6kBla
	T/uodyuOc0/nd8zfw97gdReT2gsAAp0OE5iM+kTItWt8U7zMXynV7JMK2Dl0Cn6/TQ6NDsP8j28
	/xB4bHhMHEKKPwfhVftczLNAByqJa8wUhVQiWW4UOfNN02ukggqeSO4amplufhZCY+TkYjL7SXD
	105ocXdeaKq/6FzPDtFTzZvo8/qLhs+/ulKVoUPMxFmYkwW+2ybWirIFV8iG0uUu6dYeteS76r0
	nuDsSJhCD5ABFZcRBPU8KSUkYDB8uDiY6oO9iTxbtXFkBP94X1tXoXFlyzEr6ekqh8LJhMNqHKF
	j
X-Received: by 2002:a9d:4687:: with SMTP id z7mr7899278ote.350.1549509209312;
        Wed, 06 Feb 2019 19:13:29 -0800 (PST)
X-Received: by 2002:a9d:4687:: with SMTP id z7mr7899254ote.350.1549509208536;
        Wed, 06 Feb 2019 19:13:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549509208; cv=none;
        d=google.com; s=arc-20160816;
        b=d9NGDp7c3FhJC+dFTTyQDjn5GQV/F1GeRgA4eEiVtcXGUjaSVgREyxZTXKZ/anY1jN
         gs7YNFofSAADavqVszKQUnB5kPly/RCAd4EUGbbVEvMKGsqfpAFWydzqEW13vrJRSQ1J
         FZoKCGgZd7jCeMh1ZfT/NqZQErQ/dBwVdobsWzTD/DUggzVTAvYAr7eQM4dSt/jUEBon
         eli2yfXL/y9UJqPTARnSRj2AIZGf5w+O2misSZhJdVFNH2OMDXO4UYo3aeDQ3OgAt5gp
         ScdJJ06p2jbZPhpDrBAZcNMkyUWubaG6OELWupsG4sz02ygOEjP8buOZzdtSpHX3xZmR
         77lA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=wJGn1wJcx1sUVcnHWCYzvVKZidnL377KOH3WegpZNcw=;
        b=D8kK1N37BB+Zj6BJPxcxRyWDSAtID0ElYc78z+rh/rDKdh7mKPb4YmECdLhQPXaZ6P
         DMjdxF5bQiWwXs/rMFru+hAn2cd/ZTIqmxbJDYa9G+nuhubzRqijOoQw7zSM9lLelhpd
         rr6sVdV3ZCr0tQVoiPm5u6/FVMWRGkwvq3SPD3Ckm8FaBFX0i3O++WWfaaf/WE6D5vnl
         3ClS1SLOixiUEQhWoyD+qLmD5rGMm8EtG1upxQWF/2jRRPAlD8zbqKkKcZEUiQnRtzP3
         dgHO5tSMhCi8mqGAPB9KxvOdIHIRsecUsdPdd5FxUBpOC3IgasWUqIfLliBiRvTui38V
         FaCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=u0M4bGcw;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d8sor2280394oif.171.2019.02.06.19.13.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 19:13:28 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=u0M4bGcw;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=wJGn1wJcx1sUVcnHWCYzvVKZidnL377KOH3WegpZNcw=;
        b=u0M4bGcw7Gr265bgs8lzYG+W0Y0dEUfuTw9TX/NGqjkOVFRopFhriGytmZqkOJKETt
         B0SaRMR9BDwS9/PiraQLHycM0zoXw6lBxmFN+tsxY9XYIBgGZF+yGxpHEM5lSj6ZULUQ
         FrKSDLqS65OHhHobiNFfc7nnHN2xEPX5f0vdTP9NL0RA1xgW3nuxk002aAyKJjYwvZ5w
         n1cMLnPtLOTW5A0DYCpDQv8ehw5uAgp4e7ad5SBwdKUA4CEZZGPfDVWGDQdUguazLLwF
         oOsgmSBwNWj0T5lolrQugpOKOD/3szZb00E4xzN+D4SzKHtpcdZJCgU3lqR0lvxpLf6X
         itRg==
X-Google-Smtp-Source: AHgI3IZ4Co/4mgFaH7uvLWdPVlBF4hsMLOafkliShAGWpKqScvMOYlhDAzRAowMuOE1X0hGj2bPWAJglK9Uw9UPyTyg=
X-Received: by 2002:aca:240a:: with SMTP id n10mr1318891oic.73.1549509208127;
 Wed, 06 Feb 2019 19:13:28 -0800 (PST)
MIME-Version: 1.0
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
 <20190206095000.GA12006@quack2.suse.cz> <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org> <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard> <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com> <658363f418a6585a1ffc0038b86c8e95487e8130.camel@redhat.com>
In-Reply-To: <658363f418a6585a1ffc0038b86c8e95487e8130.camel@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 6 Feb 2019 19:13:16 -0800
Message-ID: <CAPcyv4hPmwXv6xGpyWGs-zx3xswAnzF0HGX6Kx3t=LSysDRZog@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
To: Doug Ledford <dledford@redhat.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Dave Chinner <david@fromorbit.com>, 
	Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, 
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org, 
	linux-rdma <linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, 
	Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 6, 2019 at 6:42 PM Doug Ledford <dledford@redhat.com> wrote:
>
> On Wed, 2019-02-06 at 14:44 -0800, Dan Williams wrote:
> > On Wed, Feb 6, 2019 at 2:25 PM Doug Ledford <dledford@redhat.com> wrote:
> > > Can someone give me a real world scenario that someone is *actually*
> > > asking for with this?
> >
> > I'll point to this example. At the 6:35 mark Kodi talks about the
> > Oracle use case for DAX + RDMA.
> >
> > https://youtu.be/ywKPPIE8JfQ?t=395
>
> I watched this, and I see that Oracle is all sorts of excited that their
> storage machines can scale out, and they can access the storage and it
> has basically no CPU load on the storage server while performing
> millions of queries.  What I didn't hear in there is why DAX has to be
> in the picture, or why Oracle couldn't do the same thing with a simple
> memory region exported directly to the RDMA subsystem, or why reflink or
> any of the other features you talk about are needed.  So, while these
> things may legitimately be needed, this video did not tell me about
> how/why they are needed, just that RDMA is really, *really* cool for
> their use case and gets them 0% CPU utilization on their storage
> servers.  I didn't watch the whole thing though.  Do they get into that
> later on?  Do they get to that level of technical discussion, or is this
> all higher level?

They don't. The point of sharing that video was illustrating that RDMA
to persistent memory use case. That 0% cpu utilization is because the
RDMA target is not page-cache / anonymous on the storage box it's
directly to a file offset in DAX / persistent memory. A solution to
truncate lets that use case use more than just Device-DAX or ODP
capable adapters. That said, I need to let Ira jump in here because
saying layout leases solves the problem is not true, it's just the
start of potentially solving the problem. It's not clear to me what
the long tail of work looks like once the filesystem raises a
notification to the RDMA target process.

