Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84389C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 10:24:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B2E72080D
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 10:24:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B2E72080D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1C0E8E00D2; Mon, 11 Feb 2019 05:24:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCB218E00C4; Mon, 11 Feb 2019 05:24:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A945F8E00D2; Mon, 11 Feb 2019 05:24:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 522AE8E00C4
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 05:24:07 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id y91so4336201edy.21
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 02:24:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=H6zbIdwGoK8RU0IXkIIbnACnweIagj89/QR+EVZZlnc=;
        b=By2fTU76wEM2rKPG9POZnsWWDAdCLcN1CkdAz7x9q2zRmlcJ9BtGKplVL/cEsJohhr
         GKkxuHuuSTWZ425W25TCYVykUOV6wUrChD+/4A4NrLkB1krrIpccsJ7bdAHWp0oPXMoj
         2sy9LyGDXzxHrH1judy9ty/g46KV3O2rPc9SK8EAte+pdDKw9mi96LPk+4Dew7zqNts5
         E9SH1ShdSDzEP1fHd4pRXNwiJfLQkECb/QtLaK2PKOq+lbs57FfjuB7fIHP/a7l7BAqK
         AQg/D1g7rR/oqqxvwbY6N76EY73GBsAv3G+qnxYLqrHoVWqQ9y33uFcihPf0fkNK2U8/
         50rA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAuZNugfRWZWwXEnEhL5P7Pvik48tsBTtAmllCwdurqMhy4PaeDQn
	36qMX6kIiT5dBAZgc8PwOTY8ppLlyyuMxug2+VB0qLpBZQfazx20/UvUXPopXWXSRg7hcc2CiDQ
	asBQ+YxWSf0CiQY9VWJVnmERxr+7j3L4lxoUtmxktrEcjF+aH93DO0KXfhSj8Vsy1mA==
X-Received: by 2002:a50:d551:: with SMTP id f17mr28049265edj.87.1549880646787;
        Mon, 11 Feb 2019 02:24:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYfVp0Iq1t3yhjIanqyDu2ZLqdhoT3ZQRJsaSwk0j4pF4F2XAV1POXJGKzQdtO/9cEUfovt
X-Received: by 2002:a50:d551:: with SMTP id f17mr28049190edj.87.1549880645346;
        Mon, 11 Feb 2019 02:24:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549880645; cv=none;
        d=google.com; s=arc-20160816;
        b=kAnUPTkE9020t5PYLvFH3irRJVmyJ5FeF9Z3tB9WDou/3z1MpagD4Hq9jcxx0ZOJ2K
         IQV1BFYVeMH8hF9BNOYFHRz5JqkHi2XQ7+CokGRNyd03pCe+1GDXZbERlIY+wcwA4orH
         bpdsc1bT1QB2YK/IpArXQp9iqB92wbfNFcdhTeqANjyHDaXWotWTqYS8TMG6Z+CsPnuZ
         /+j46gd2aQApu9UZ9U0hFCXPvl1hvUmakgXWEGOEpjLUbETsGQybfbujBZGpYcJHmFhB
         DCaPIIT5UZDAxXszMtvZA34LvqR01c69ahLF+6BEEOUqxDDnFCDuOSE9Eb8CGG/i7STo
         HtCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=H6zbIdwGoK8RU0IXkIIbnACnweIagj89/QR+EVZZlnc=;
        b=hlwgpbUQfHmkglvkHBnUxA1YPlyg71rZ7YMKerWLuv3hIfGH5Li0ZQBcXwDmdjQH6G
         KAhIXRlUB1A+vUVttnT6uAvC31YdOkUSW2wj/IdjwJFE2XP7vRKpLqxtKwNQJmR5xOSm
         lGbXVOicFeQ92yhGJlsFTy1UWq9i7hQyq2dq8KsIN490JL0N240egAO/bnjiJcsuVTjd
         OgxlnBJowmx8KrvIUXVPkrAJ/T3DV0/azYyU9gTXDfJGDKhdCvngBwE+o+AS0/B6Ti9X
         s0Z26EvHyR1TkFijC+APjTIJ+e4Bn/B0ocNpG1GxOuT9/zUUdfraaLNn+/zahiTg5tiA
         y0jg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u22si4461859edx.430.2019.02.11.02.24.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 02:24:05 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 77BAEAEE1;
	Mon, 11 Feb 2019 10:24:04 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 684271E09A8; Mon, 11 Feb 2019 11:24:02 +0100 (CET)
Date: Mon, 11 Feb 2019 11:24:02 +0100
From: Jan Kara <jack@suse.cz>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>,
	Christopher Lameter <cl@linux.com>,
	Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190211102402.GF19029@quack2.suse.cz>
References: <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard>
 <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
 <20190208044302.GA20493@dastard>
 <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 08-02-19 12:50:37, Dan Williams wrote:
> On Fri, Feb 8, 2019 at 3:11 AM Jan Kara <jack@suse.cz> wrote:
> >
> > On Fri 08-02-19 15:43:02, Dave Chinner wrote:
> > > On Thu, Feb 07, 2019 at 04:55:37PM +0000, Christopher Lameter wrote:
> > > > One approach that may be a clean way to solve this:
> > > > 3. Filesystems that allow bypass of the page cache (like XFS / DAX) will
> > > >    provide the virtual mapping when the PIN is done and DO NO OPERATIONS
> > > >    on the longterm pinned range until the long term pin is removed.
> > >
> > > So, ummm, how do we do block allocation then, which is done on
> > > demand during writes?
> > >
> > > IOWs, this requires the application to set up the file in the
> > > correct state for the filesystem to lock it down so somebody else
> > > can write to it.  That means the file can't be sparse, it can't be
> > > preallocated (i.e. can't contain unwritten extents), it must have zeroes
> > > written to it's full size before being shared because otherwise it
> > > exposes stale data to the remote client (secure sites are going to
> > > love that!), they can't be extended, etc.
> > >
> > > IOWs, once the file is prepped and leased out for RDMA, it becomes
> > > an immutable for the purposes of local access.
> > >
> > > Which, essentially we can already do. Prep the file, map it
> > > read/write, mark it immutable, then pin it via the longterm gup
> > > interface which can do the necessary checks.
> >
> > Hum, and what will you do if the immutable file that is target for RDMA
> > will be a source of reflink? That seems to be currently allowed for
> > immutable files but RDMA store would be effectively corrupting the data of
> > the target inode. But we could treat it similarly as swapfiles - those also
> > have to deal with writes to blocks beyond filesystem control. In fact the
> > similarity seems to be quite large there. What do you think?
> 
> This sounds so familiar...
> 
>     https://lwn.net/Articles/726481/
> 
> I'm not opposed to trying again, but leases was what crawled out
> smoking crater when this last proposal was nuked.

Umm, don't think this is that similar to daxctl() discussion. We are not
speaking about providing any new userspace API for this. Also I think the
situation about leases has somewhat cleared up with this discussion - ODP
hardware does not need leases since it can use MMU notifiers, for non-ODP
hardware it is difficult to handle leases as such hardware has only one big
kill-everything call and using that would effectively mean lot of work on
the userspace side to resetup everything to make things useful if workable
at all.

So my proposal would be:

1) ODP hardward uses gup_fast() like direct IO and uses MMU notifiers to do
its teardown when fs needs it.

2) Hardware not capable of tearing down pins from MMU notifiers will have
to use gup_longterm() (we may actually rename it to a more suitable name).
FS may just refuse such calls (for normal page cache backed file, it will
just return success but for DAX file it will do sanity checks whether the
file is fully allocated etc. like we currently do for swapfiles) but if
gup_longterm() returns success, it will provide the same guarantees as for
swapfiles. So the only thing that we need is some call from gup_longterm()
to a filesystem callback to tell it - this file is going to be used by a
third party as an IO buffer, don't touch it. And we can (and should)
probably refactor the handling to be shared between swapfiles and
gup_longterm().

								Honza


-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

