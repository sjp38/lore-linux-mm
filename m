Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 712EDC41517
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 15:05:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 359D12238C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 15:05:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 359D12238C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE5676B026D; Thu, 25 Jul 2019 11:05:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C961C6B026E; Thu, 25 Jul 2019 11:05:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BAD5E8E0002; Thu, 25 Jul 2019 11:05:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 83C036B026D
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 11:05:32 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id i33so26456570pld.15
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 08:05:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=MQtOCjNTjeC+aAVmT+GbP0Jx38uT+9osjVco6+koPGY=;
        b=dZlNHzecyPBeKcd/1PbTDYsvq6oln4V09oA8PJXZrnBXzVIMdGzlTJnWz6A5/+nbQf
         NW1qXMN5aUYHyJULkllQ9lLZf6MJmNHriwZnsHyJ2FmTGKcIofwbi8NQFbHI3vT6lq/8
         WB/C0gE3snj/pmy3KBh5bybwE1BkkpYpKcUj9xI4UDwKmBHjz7NPI0rS0TWtghYpspik
         G5tPsEec9zAXMGiGZDnkgX7tyQ2CFTkgaJpSPntEyXa4eY4rpzWpo7YK3TgTONyV6yWw
         vAMckPWVrCPuusuhe5PVGM/vlMEzkkfpNgct7ud9VsQ7LnClrrumwybksjans4rofaQz
         fHBg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXviLrnWoCIn/yERrxuyckFuw7N62IUVardihOR9fpvbPwy7lw5
	6A529ZWBvHjHfSBttjt3JAqFuRDgSPw/bWqR0ckHw4dhqaP6Fz7T0V76yX30qhAcF1WBFUCrHke
	fRIkOO72P6Ne6N4aC87jUXt/g8RUWdKf6SoAAPTS7ytsdlqt59t6pqTTsX6TNnMDvKg==
X-Received: by 2002:a63:4f58:: with SMTP id p24mr1430683pgl.50.1564067132118;
        Thu, 25 Jul 2019 08:05:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxCmyFGvTkopdULwFkGH1Ctfe6rWrf7iuclhF3nlHwaz9xAGnTj69VAoxyjhXYsjlPZwKX
X-Received: by 2002:a63:4f58:: with SMTP id p24mr1430615pgl.50.1564067131247;
        Thu, 25 Jul 2019 08:05:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564067131; cv=none;
        d=google.com; s=arc-20160816;
        b=e5iAzTiOksWF0RQXhnB/W7582wf67SpDp1lhcSZQHa7GRpua+Jf0IMqC/7RIS+VcDM
         OG6dNTGujbLzLuQrCV4dsjpaZQgodZQNPfBss3YU2YrJXUV0aEdm1BELVUtzk7s4GtKi
         16JF7C/+V1gKTMF/CQvCcmo+7FUFf6Lz9zXs3Bu+ao5Fk9YMVUo0OlAxRBpQyPLM/Eac
         Q2DQPIAdgQlukTILHBDYi2zxxPjazAsbatKtGoTcQ13Y9D6U57/y60aucbn97fPDhsZV
         jw5U89o4Iij3/dXw4b/i51tTKQXw50RoW4xRvf77WUIcZAyowKZdfeG32RnX1AKDQvVT
         7Ilg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=MQtOCjNTjeC+aAVmT+GbP0Jx38uT+9osjVco6+koPGY=;
        b=QYQ6sUFVECb5DQMnA4f+3YZFmH+A4zka/RJAXsyUGaiFGI4ABjxma5OXEojq/jZq5L
         W86BYw9rFTGbd9/6ccAHvTrNnUFI1Ro2iMcQCfYJJlNOEbIKoo5ChxSZO00GhsJqrub8
         x/detfmQ0AOidifyIhhXxLYiT7phidfySeNJquLBhYe0K38LQ9TVJKwBzpvCojQVkapr
         oHqewQoRjqp1H5BQy0EB69HZGr0jbmM8//tV9XAIvxoXzTXuwDm3Wb0XAcJDleuCX7kw
         ZfKbZbsfbI4WgxEXMhipk+4SHdI+d0JC+pGYeO/ldZ86hFNAdukltfKvpz2RzPbyacIs
         xOGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id g5si17100042plt.271.2019.07.25.08.05.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 08:05:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jul 2019 08:05:30 -0700
X-IronPort-AV: E=Sophos;i="5.64,307,1559545200"; 
   d="scan'208";a="321690255"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga004-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jul 2019 08:05:30 -0700
Message-ID: <bc162a5eaa58ac074c8ad20cb23d579aa04d0f43.camel@linux.intel.com>
Subject: Re: [PATCH v2 QEMU] virtio-balloon: Provide a interface for "bubble
 hinting"
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>, "Michael S. Tsirkin"
	 <mst@redhat.com>, Alexander Duyck <alexander.duyck@gmail.com>
Cc: kvm@vger.kernel.org, david@redhat.com, dave.hansen@intel.com, 
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org,  yang.zhang.wz@gmail.com, pagupta@redhat.com,
 riel@surriel.com,  konrad.wilk@oracle.com, lcapitulino@redhat.com,
 wei.w.wang@intel.com,  aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com
Date: Thu, 25 Jul 2019 08:05:30 -0700
In-Reply-To: <fed474fe-93f4-a9f6-2e01-75e8903edd81@redhat.com>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
	 <20190724171050.7888.62199.stgit@localhost.localdomain>
	 <20190724173403-mutt-send-email-mst@kernel.org>
	 <ada4e7d932ebd436d00c46e8de699212e72fd989.camel@linux.intel.com>
	 <fed474fe-93f4-a9f6-2e01-75e8903edd81@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-07-25 at 07:35 -0400, Nitesh Narayan Lal wrote:
> On 7/24/19 6:03 PM, Alexander Duyck wrote:
> > On Wed, 2019-07-24 at 17:38 -0400, Michael S. Tsirkin wrote:
> > > On Wed, Jul 24, 2019 at 10:12:10AM -0700, Alexander Duyck wrote:
> > > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > 
> > > > Add support for what I am referring to as "bubble hinting". Basically the
> > > > idea is to function very similar to how the balloon works in that we
> > > > basically end up madvising the page as not being used. However we don't
> > > > really need to bother with any deflate type logic since the page will be
> > > > faulted back into the guest when it is read or written to.
> > > > 
> > > > This is meant to be a simplification of the existing balloon interface
> > > > to use for providing hints to what memory needs to be freed. I am assuming
> > > > this is safe to do as the deflate logic does not actually appear to do very
> > > > much other than tracking what subpages have been released and which ones
> > > > haven't.
> > > > 
> > > > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > BTW I wonder about migration here.  When we migrate we lose all hints
> > > right?  Well destination could be smarter, detect that page is full of
> > > 0s and just map a zero page. Then we don't need a hint as such - but I
> > > don't think it's done like that ATM.
> > I was wondering about that a bit myself. If you migrate with a balloon
> > active what currently happens with the pages in the balloon? Do you
> > actually migrate them, or do you ignore them and just assume a zero page?
> > I'm just reusing the ram_block_discard_range logic that was being used for
> > the balloon inflation so I would assume the behavior would be the same.
> I agree, however, I think it is worth investigating to see if enabling hinting
> adds some sort of overhead specifically in this kind of scenarios. What do you
> think?

I suspect that the hinting/reporting would probably improve migration
times based on the fact that from the sound of things it would just be
migrated as a zero page.

I don't have a good setup for testing migration though and I am not that
familiar with trying to do a live migration. That is one of the reasons
why I didn't want to stray too far from the existing balloon code as that
has already been tested with migration so I would assume as long as I am
doing almost the exact same thing to hint the pages away it should behave
exactly the same.

> > > I also wonder about interaction with deflate.  ATM deflate will add
> > > pages to the free list, then balloon will come right back and report
> > > them as free.
> > I don't know how likely it is that somebody who is getting the free page
> > reporting is likely to want to also use the balloon to take up memory.
> I think it is possible. There are two possibilities:
> 1. User has a workload running, which is allocating and freeing the pages and at
> the same time, user deflates.
> If these new pages get used by this workload, we don't have to worry as you are
> already handling that by not hinting the free pages immediately.
> 2. Guest is idle and the user adds up some memory, for this situation what you
> have explained below does seems reasonable.

Us hinting on pages that are freed up via deflate wouldn't be too big of a
deal. I would think that is something we could look at addressing as more
of a follow-on if we ever needed to since it would just add more
complexity.

Really what I would like to see is the balloon itself get updated first to
perhaps work with variable sized pages first so that we could then have
pages come directly out of the balloon and go back into the freelist as
hinted, or visa-versa where hinted pages could be pulled directly into the
balloon without needing to notify the host.

