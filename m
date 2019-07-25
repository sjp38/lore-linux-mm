Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73159C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 15:16:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 343EA2238C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 15:16:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 343EA2238C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C19DC8E0003; Thu, 25 Jul 2019 11:16:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA3A38E0002; Thu, 25 Jul 2019 11:16:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6BEE8E0003; Thu, 25 Jul 2019 11:16:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8107D8E0002
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 11:16:16 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id e39so44650093qte.8
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 08:16:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=ZdiHhR4VNqoS2oGhLtlrAzJdPT34WmJrjIOqzk+fdxs=;
        b=kfBkyDhYhdGNQ2bR37bhNnH7vLPOjzrTRQlWjz88sNoWq+aqwONVn6lMnaGYCkQpQL
         zbdIRj7VblKjw1IBamRdIYDPxnHMQeyL/s65VzUOHWPiuK+F2JdP4ggq9SOUuaQED/we
         mjWJ2uqITaDU/K/OU5hIuh5//0TLNOlVz0Dlh3pWfYFzdrAL1O4SVAYYx3OhSalnq44G
         hzB0BDwCP89mbKy4VgARWODirhlNy1gl3iPQmdqhNMssPo4uMNAo1jNuJYcClxou/3kJ
         I5ZtA2AH5ZsGHzX58Xvm9vXCdflQN+2o6ykoOVssDhEl6Qqs+UVKTyjRCVqe00WE4KZP
         2JIA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVrLsnkU4REAhnajin3Oz2YDPZ2H6wfXIkSDmW47YLk3woM5gM7
	/Ibbt0yEpxXyj5bCN0Epq3K5kbQd1EbJmyhJurHi4Y/rl7Py/9L8pyyEjuMgsVEoUpZSP6p5NO7
	5Z4uVrJ8JYwdHbV0YV+POU0txcpK5hngldEyNACrqGY6OoQBWqH9RhN6TxUnLtYE+qA==
X-Received: by 2002:aed:3fb0:: with SMTP id s45mr63858438qth.136.1564067776240;
        Thu, 25 Jul 2019 08:16:16 -0700 (PDT)
X-Received: by 2002:aed:3fb0:: with SMTP id s45mr63858383qth.136.1564067775504;
        Thu, 25 Jul 2019 08:16:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564067775; cv=none;
        d=google.com; s=arc-20160816;
        b=jWLZvBQBAUZC9xcFDcAr1yG2cPcRKh9bGVVM1tPln1EJzHypKv9n56Og6IrI6EsDUj
         HJDO1n8E8+7sq9sdmBBoFuGbOHMvp5MA1cL+OYUsWCpY1d9mGa6ok/6Z6r0vAHhWSCAh
         dbA6TTFe5bwFrIN1OUuvMa7M6tH0kyjgiRPv2/UpL3W73RwzE78yNTvYIoawEKroQEal
         7yZWDc7U/Gjrp0gQwmNxaaYRK1E4jyv357bwa8XM9JMAMbTZHVtcjC4JDUjLn7R8txBf
         pcoV+IMQtwCYnR4wiRREgfZIIYApa8Xv13Nuwn+9IMZhcv7MEhJ3HDJA9ybVo72ZVeBC
         i8wQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=ZdiHhR4VNqoS2oGhLtlrAzJdPT34WmJrjIOqzk+fdxs=;
        b=igrGdLzwrXkzrJc+yEY8I0/0yZ7DZTDPYrhNLBECVf8bpwDqSy0t4+f9s495UXIjKa
         WGKqU8POQllZRjEpm5kWdVbMjaPorNatn9H0jt7Lm6rGQD96UYv5jM/Ip+Vy0sIFCNBo
         3knCiWNf5j52cJziK8jW1e+PNMle4cEVWWQ/PkbdMkJbe/n22BcICp/SFpnNfPDNQXiF
         /gvQws9qcglo2lBP0pNOaoXM+LYkUppqx4dUbbQBkSi2sk2PgME+NhB1N7wALZOtz5lB
         ZajkWdNMpDU9ju48V5J92uP91wdPzvSIAy+tI4PCD50f4LLSvqxENvu/RBPtDvNJHAcm
         3Exw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y9sor35376802qvs.7.2019.07.25.08.16.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 08:16:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwFku9i4X43MNZ9lYKIh3Nr6w+4NA8mbRF4pCiLAscXi2J3VGACd6fYxy3mBTaTgPH5+LbeGA==
X-Received: by 2002:a0c:96f3:: with SMTP id b48mr64327202qvd.80.1564067775207;
        Thu, 25 Jul 2019 08:16:15 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id f133sm24309846qke.62.2019.07.25.08.16.09
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 08:16:14 -0700 (PDT)
Date: Thu, 25 Jul 2019 11:16:06 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>, kvm@vger.kernel.org,
	david@redhat.com, dave.hansen@intel.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, yang.zhang.wz@gmail.com,
	pagupta@redhat.com, riel@surriel.com, konrad.wilk@oracle.com,
	lcapitulino@redhat.com, wei.w.wang@intel.com, aarcange@redhat.com,
	pbonzini@redhat.com, dan.j.williams@intel.com
Subject: Re: [PATCH v2 QEMU] virtio-balloon: Provide a interface for "bubble
 hinting"
Message-ID: <20190725111303-mutt-send-email-mst@kernel.org>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <20190724171050.7888.62199.stgit@localhost.localdomain>
 <20190724173403-mutt-send-email-mst@kernel.org>
 <ada4e7d932ebd436d00c46e8de699212e72fd989.camel@linux.intel.com>
 <fed474fe-93f4-a9f6-2e01-75e8903edd81@redhat.com>
 <bc162a5eaa58ac074c8ad20cb23d579aa04d0f43.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bc162a5eaa58ac074c8ad20cb23d579aa04d0f43.camel@linux.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 08:05:30AM -0700, Alexander Duyck wrote:
> On Thu, 2019-07-25 at 07:35 -0400, Nitesh Narayan Lal wrote:
> > On 7/24/19 6:03 PM, Alexander Duyck wrote:
> > > On Wed, 2019-07-24 at 17:38 -0400, Michael S. Tsirkin wrote:
> > > > On Wed, Jul 24, 2019 at 10:12:10AM -0700, Alexander Duyck wrote:
> > > > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > > 
> > > > > Add support for what I am referring to as "bubble hinting". Basically the
> > > > > idea is to function very similar to how the balloon works in that we
> > > > > basically end up madvising the page as not being used. However we don't
> > > > > really need to bother with any deflate type logic since the page will be
> > > > > faulted back into the guest when it is read or written to.
> > > > > 
> > > > > This is meant to be a simplification of the existing balloon interface
> > > > > to use for providing hints to what memory needs to be freed. I am assuming
> > > > > this is safe to do as the deflate logic does not actually appear to do very
> > > > > much other than tracking what subpages have been released and which ones
> > > > > haven't.
> > > > > 
> > > > > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > BTW I wonder about migration here.  When we migrate we lose all hints
> > > > right?  Well destination could be smarter, detect that page is full of
> > > > 0s and just map a zero page. Then we don't need a hint as such - but I
> > > > don't think it's done like that ATM.
> > > I was wondering about that a bit myself. If you migrate with a balloon
> > > active what currently happens with the pages in the balloon? Do you
> > > actually migrate them, or do you ignore them and just assume a zero page?
> > > I'm just reusing the ram_block_discard_range logic that was being used for
> > > the balloon inflation so I would assume the behavior would be the same.
> > I agree, however, I think it is worth investigating to see if enabling hinting
> > adds some sort of overhead specifically in this kind of scenarios. What do you
> > think?
> 
> I suspect that the hinting/reporting would probably improve migration
> times based on the fact that from the sound of things it would just be
> migrated as a zero page.
> 
> I don't have a good setup for testing migration though and I am not that
> familiar with trying to do a live migration. That is one of the reasons
> why I didn't want to stray too far from the existing balloon code as that
> has already been tested with migration so I would assume as long as I am
> doing almost the exact same thing to hint the pages away it should behave
> exactly the same.
> 
> > > > I also wonder about interaction with deflate.  ATM deflate will add
> > > > pages to the free list, then balloon will come right back and report
> > > > them as free.
> > > I don't know how likely it is that somebody who is getting the free page
> > > reporting is likely to want to also use the balloon to take up memory.
> > I think it is possible. There are two possibilities:
> > 1. User has a workload running, which is allocating and freeing the pages and at
> > the same time, user deflates.
> > If these new pages get used by this workload, we don't have to worry as you are
> > already handling that by not hinting the free pages immediately.
> > 2. Guest is idle and the user adds up some memory, for this situation what you
> > have explained below does seems reasonable.
> 
> Us hinting on pages that are freed up via deflate wouldn't be too big of a
> deal. I would think that is something we could look at addressing as more
> of a follow-on if we ever needed to since it would just add more
> complexity.
> 
> Really what I would like to see is the balloon itself get updated first to
> perhaps work with variable sized pages first so that we could then have
> pages come directly out of the balloon and go back into the freelist as
> hinted, or visa-versa where hinted pages could be pulled directly into the
> balloon without needing to notify the host.

Right, I agree. At this point the main thing I worry about is that
the interfaces only support one reporter, since a page flag is used.
So if we ever rewrite existing hinting to use the new mm
infrastructure then we can't e.g. enable both types of hinting.

FWIW Nitesh's RFC does not have this limitation.

I intend to think about this over the weekend.

-- 
MST

