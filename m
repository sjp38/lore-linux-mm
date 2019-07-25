Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B780CC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 17:19:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 676252238C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 17:19:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 676252238C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D44766B0006; Thu, 25 Jul 2019 13:19:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCDDF6B0007; Thu, 25 Jul 2019 13:19:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBDA08E0002; Thu, 25 Jul 2019 13:19:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 957EC6B0006
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 13:19:54 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id x1so42950801qkn.6
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 10:19:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=5u3LjMGnob/eh7dErEU98DnSWYn59krPNcbtYSmpfxg=;
        b=qormw5z0KeOi+3vr7m4Zi9mGNTCRv9JmAIHBCKJZL8VptAmtbyiqz+DZgWAaxSunbb
         HUb78qdxjLZ7moXmdu5Gj5VMCZcDUNcSrBREuxjVJR37Hmv+B7dDDKmjQ33hDPa5IB3a
         BPqH8r9bQ4bHm2v01QqJkjVf4XSwdHJmW0OwgBJoPPfxPbeC2gC9Jf9G72Cxv65iu7BW
         SPvDXlRcBsTXILUcmAqJ9GcV2cnyaZcggyGJdVz6cgvGkiU9UIuhhAB0AGa1yW/AJrmy
         lMOqJP8C09/utr0k6ajwIhpccMSqP3hw00b44O50DqF8/I28xPCFcLuK4Re+9wG+lfbt
         Y0LA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWi4LFgWXNDgmn2HSbVVOSQXi7BPw/oy5XaSJ++7PKHGK46WFGF
	Byzsrj52MSohb6cj3GQbzdBNOte+xlc03SEPIHyAsCYLylozI4yiWmhezRaAqCmF0Zn3qxC31zy
	DVDe3lTsS6qRwbU1P2zKleZZE8fGFiY3N3I5KAMsfvEm2J2i/MDGL2Hc9jq+Lk1T8dQ==
X-Received: by 2002:a37:c81:: with SMTP id 123mr61344744qkm.474.1564075194332;
        Thu, 25 Jul 2019 10:19:54 -0700 (PDT)
X-Received: by 2002:a37:c81:: with SMTP id 123mr61344700qkm.474.1564075193568;
        Thu, 25 Jul 2019 10:19:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564075193; cv=none;
        d=google.com; s=arc-20160816;
        b=0k4hIdRiHCDdDN66KZCsD93F7fR6bGF87jA6xX/wrncYFNbbmLZOdN+c8tiXeWZ5I+
         +MPu1BEVeYMx/ceh4gGVXNf92RVhJkOp30OgGr808bUKL7HXetAGaZtfas/4c73tMgU+
         eioKcxRdErCqx0Jw0yybCG5uNMqX7PtVIvAsJPdWTM+I3MmahOW0d76vswHKUIL0TO2G
         iP+D7utFFRAK+OnkjWoNQr34Orr7fGpM4U3fz+XBJCtkOkiHRHujqL5cbfSJMb4s8yly
         o7/QLgkSnyxVvVWch/pQkQ9/TRSXqfX5C68JChyDwLbntptwY5imOBRMghmZw4WzGmWn
         dgaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=5u3LjMGnob/eh7dErEU98DnSWYn59krPNcbtYSmpfxg=;
        b=zNtLKC1YG8nvdd88KuZ7+7G4j/b00hwB8vXw1XWtWDmV4GX7xskTwbBqonsIpUniVm
         2Dm4M04dd7tpKZn+FT3NaJyjtCzuq9NYS2ir8Xm7ddB7ytocon/l5SfqlnEYjdBctR2z
         01GfPD+Za7tfAI1pFgKBXQFZVFz1+QtBm30GrUyQjtWfu+tHStTdQG4hm3n/PXHPeAs8
         m94JuCiWSJfOMWwpH46fElJacBlUCcQEtG2CXWcGn/UzWopRF8VW2NxBRYFr8peeFZeb
         H0i6H6y28h67SmJ4TJAdlQ43CzefIKU/epGkMRpPj16WtuFKGJEGCp/icm/w8M1QP+Pp
         JolA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i7sor66942906qtb.37.2019.07.25.10.19.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 10:19:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzh6iVjr6MjlWT59KW8JoNnu8DTc4nuzePg5RGcXEbwv4teTePt1g4kYdzGbH7yQSr7ND0zdg==
X-Received: by 2002:ac8:2379:: with SMTP id b54mr64138089qtb.168.1564075193014;
        Thu, 25 Jul 2019 10:19:53 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id w25sm20020746qto.87.2019.07.25.10.19.47
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 10:19:52 -0700 (PDT)
Date: Thu, 25 Jul 2019 13:19:45 -0400
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
Message-ID: <20190725131821-mutt-send-email-mst@kernel.org>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <20190724171050.7888.62199.stgit@localhost.localdomain>
 <20190724173403-mutt-send-email-mst@kernel.org>
 <ada4e7d932ebd436d00c46e8de699212e72fd989.camel@linux.intel.com>
 <fed474fe-93f4-a9f6-2e01-75e8903edd81@redhat.com>
 <bc162a5eaa58ac074c8ad20cb23d579aa04d0f43.camel@linux.intel.com>
 <20190725111303-mutt-send-email-mst@kernel.org>
 <96b1ac42dccbfbb5dd17210e6767ca2544558390.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <96b1ac42dccbfbb5dd17210e6767ca2544558390.camel@linux.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 09:16:21AM -0700, Alexander Duyck wrote:
> On Thu, 2019-07-25 at 11:16 -0400, Michael S. Tsirkin wrote:
> > On Thu, Jul 25, 2019 at 08:05:30AM -0700, Alexander Duyck wrote:
> > > On Thu, 2019-07-25 at 07:35 -0400, Nitesh Narayan Lal wrote:
> > > > On 7/24/19 6:03 PM, Alexander Duyck wrote:
> > > > > On Wed, 2019-07-24 at 17:38 -0400, Michael S. Tsirkin wrote:
> > > > > > On Wed, Jul 24, 2019 at 10:12:10AM -0700, Alexander Duyck wrote:
> > > > > > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > > > > 
> > > > > > > Add support for what I am referring to as "bubble hinting". Basically the
> > > > > > > idea is to function very similar to how the balloon works in that we
> > > > > > > basically end up madvising the page as not being used. However we don't
> > > > > > > really need to bother with any deflate type logic since the page will be
> > > > > > > faulted back into the guest when it is read or written to.
> > > > > > > 
> > > > > > > This is meant to be a simplification of the existing balloon interface
> > > > > > > to use for providing hints to what memory needs to be freed. I am assuming
> > > > > > > this is safe to do as the deflate logic does not actually appear to do very
> > > > > > > much other than tracking what subpages have been released and which ones
> > > > > > > haven't.
> > > > > > > 
> > > > > > > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > > > BTW I wonder about migration here.  When we migrate we lose all hints
> > > > > > right?  Well destination could be smarter, detect that page is full of
> > > > > > 0s and just map a zero page. Then we don't need a hint as such - but I
> > > > > > don't think it's done like that ATM.
> > > > > I was wondering about that a bit myself. If you migrate with a balloon
> > > > > active what currently happens with the pages in the balloon? Do you
> > > > > actually migrate them, or do you ignore them and just assume a zero page?
> > > > > I'm just reusing the ram_block_discard_range logic that was being used for
> > > > > the balloon inflation so I would assume the behavior would be the same.
> > > > I agree, however, I think it is worth investigating to see if enabling hinting
> > > > adds some sort of overhead specifically in this kind of scenarios. What do you
> > > > think?
> > > 
> > > I suspect that the hinting/reporting would probably improve migration
> > > times based on the fact that from the sound of things it would just be
> > > migrated as a zero page.
> > > 
> > > I don't have a good setup for testing migration though and I am not that
> > > familiar with trying to do a live migration. That is one of the reasons
> > > why I didn't want to stray too far from the existing balloon code as that
> > > has already been tested with migration so I would assume as long as I am
> > > doing almost the exact same thing to hint the pages away it should behave
> > > exactly the same.
> > > 
> > > > > > I also wonder about interaction with deflate.  ATM deflate will add
> > > > > > pages to the free list, then balloon will come right back and report
> > > > > > them as free.
> > > > > I don't know how likely it is that somebody who is getting the free page
> > > > > reporting is likely to want to also use the balloon to take up memory.
> > > > I think it is possible. There are two possibilities:
> > > > 1. User has a workload running, which is allocating and freeing the pages and at
> > > > the same time, user deflates.
> > > > If these new pages get used by this workload, we don't have to worry as you are
> > > > already handling that by not hinting the free pages immediately.
> > > > 2. Guest is idle and the user adds up some memory, for this situation what you
> > > > have explained below does seems reasonable.
> > > 
> > > Us hinting on pages that are freed up via deflate wouldn't be too big of a
> > > deal. I would think that is something we could look at addressing as more
> > > of a follow-on if we ever needed to since it would just add more
> > > complexity.
> > > 
> > > Really what I would like to see is the balloon itself get updated first to
> > > perhaps work with variable sized pages first so that we could then have
> > > pages come directly out of the balloon and go back into the freelist as
> > > hinted, or visa-versa where hinted pages could be pulled directly into the
> > > balloon without needing to notify the host.
> > 
> > Right, I agree. At this point the main thing I worry about is that
> > the interfaces only support one reporter, since a page flag is used.
> > So if we ever rewrite existing hinting to use the new mm
> > infrastructure then we can't e.g. enable both types of hinting.
> 
> Does it make sense to have multiple types of hinting active at the same
> time though? That kind of seems wasteful to me. Ideally we should be able
> to provide the hints and have them feed whatever is supposed to be using
> them. So for example I could probably look at also clearing the bitmaps
> when migration is in process.
> 
> Also, I am wonder if the free page hints would be redundant with the form
> of page hinting/reporting that I have since we should be migrating a much
> smaller footprint anyway if the pages have been madvised away before we
> even start the migration.

Good points.

> > FWIW Nitesh's RFC does not have this limitation.
> 
> Yes, but there are also limitations to his approach. For example the fact
> that the bitmap it maintains is back to being a hint rather then being
> very exact. As a result you could end up walking the bitmap for a while
> clearing bits without ever finding a free page.

For sure.

> > I intend to think about this over the weekend.
> 
> Sounds good. I'll try to get the stuff you have pointed out so far
> addressed and hopefully have v3 ready to go next week.
> 
> Thanks.
> 
> - Alex

