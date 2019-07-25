Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FC2FC41517
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 16:16:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27A6520679
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 16:16:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27A6520679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B51A56B000A; Thu, 25 Jul 2019 12:16:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B023B8E0005; Thu, 25 Jul 2019 12:16:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F06A8E0002; Thu, 25 Jul 2019 12:16:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 692696B000A
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 12:16:23 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f25so31151410pfk.14
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 09:16:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=S3kFICFzajaKLhxsqbaRIoJ9kJHYVP61xK+xtSgzRkY=;
        b=LrxYB7nvIi5/eW+lMu5yqHlnoqiHwHtZRMkF3Ty97zsVX2NWDNT1G0Vy91FYCnZAi6
         IKaF2ogJIgEf2Nngs8fidwcZcoRgoQ6+kJroMbpvrn79auFcoFA9Dj27Chlzr+s5PpRL
         IOVy7RZxOJtNNACA5rL5iFWAjTifewrTDbPoY32n7fwuROIQ8f1KYlwNvJ8sIzOhKFlW
         +3061SMBxOpI6eiRpreCkbhnwRvqsqDJ2/2tqdyyDF+tvwdg0LqbuVFy1nh/D+13jgsV
         qPbfSM3Av7kmIsXi5L/qLxfY0r83a6dKZMRyx4A0+FrLS/58EFe5aJOQfoeKGGgyfTYz
         38Hw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWbKKN9iVOOjlto35aTLldr8aDW4BH5jhJ5y1uVGFFMEtjaD4Hb
	vNJ0IBh1BlkmMsoZR+DWKSP7WKwhO4yj/nVqXN3GfOgpWWvNlZs7/BEaxwrVdCEoE+hXbykF/hK
	YFLNSZe/16Lf3JfmtRb1PkJsYtF1yb5XnIkYxXQwsmDSfTV40TL+VSKLJLKA2QnLj7Q==
X-Received: by 2002:a17:902:2a68:: with SMTP id i95mr93407810plb.167.1564071383009;
        Thu, 25 Jul 2019 09:16:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwbt3O84ZWCA+kHb4D/axJ7vdN9ofJa6qPtjFx+BK4o2zh/dFrp3PcSWogt1lm0L9gVZMdY
X-Received: by 2002:a17:902:2a68:: with SMTP id i95mr93407732plb.167.1564071382075;
        Thu, 25 Jul 2019 09:16:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564071382; cv=none;
        d=google.com; s=arc-20160816;
        b=MRMLaEGB1T/2HU7bMblud6x+YzErWXMqBLsdZS+IfdRjM3qpbiXhQwo6ISF15CijNu
         Fl9oRSIsqJOGb+f56zSt01UY3fULn/oxGzeUM2XfuWlGnLNPRKseRjeWpwkdSWDzIQOk
         VHw//mckBpp0Qtd16z+aAGin3LWIqnLcuw2hk49D58jasr0TgcFuFz0KVGN3FGouWMIy
         UaKZetZ8Z63tMnsbORf5WTKppHfdLUdZgE3z0Wk8jYiYnLxT6eokfVrLb3B4gW8JGjVE
         SWsOF790+qUt/WAWscr7P+yBA053P25pfZbJZDH9WVuHVKHxhLwTVN0CendYwe11S4LE
         pUPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=S3kFICFzajaKLhxsqbaRIoJ9kJHYVP61xK+xtSgzRkY=;
        b=euoFKPrm3P0W20H4hxOi06QpYNMenH8GdNSUe0LQQYV/z0DCQwSK5u9e5KGYl562cr
         kBuGPzVTolWUtOxqToPDo3I1VdX6f6J+vtOt/GBCQrUbOSS4l7qRzz2GO4OGcOvrG/+l
         6DI6rj6gZ7L2vL+8FSJUEOy1Pn/k9Zmvbmick+ScltFfCzSWQr5iLXWvoEq9OTlGqHKx
         NGek4EOMt1IMT9MzLL7+vzCeFHAv2ZGVPjzmp9jpj2/eaR6M6aSDykx/2Ae1ud8R8LSv
         sTo57a2KdQ2j7KBzz3fui1OqsCYR9pD4s0/4vw9AuCE67S5qGApHkBdbUoYYXW1lnMvw
         OiGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id s29si18061100pfd.147.2019.07.25.09.16.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 09:16:22 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jul 2019 09:16:21 -0700
X-IronPort-AV: E=Sophos;i="5.64,307,1559545200"; 
   d="scan'208";a="164225983"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga008-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jul 2019 09:16:21 -0700
Message-ID: <96b1ac42dccbfbb5dd17210e6767ca2544558390.camel@linux.intel.com>
Subject: Re: [PATCH v2 QEMU] virtio-balloon: Provide a interface for "bubble
 hinting"
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, Alexander Duyck
	 <alexander.duyck@gmail.com>, kvm@vger.kernel.org, david@redhat.com, 
	dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	akpm@linux-foundation.org, yang.zhang.wz@gmail.com, pagupta@redhat.com, 
	riel@surriel.com, konrad.wilk@oracle.com, lcapitulino@redhat.com, 
	wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com, 
	dan.j.williams@intel.com
Date: Thu, 25 Jul 2019 09:16:21 -0700
In-Reply-To: <20190725111303-mutt-send-email-mst@kernel.org>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
	 <20190724171050.7888.62199.stgit@localhost.localdomain>
	 <20190724173403-mutt-send-email-mst@kernel.org>
	 <ada4e7d932ebd436d00c46e8de699212e72fd989.camel@linux.intel.com>
	 <fed474fe-93f4-a9f6-2e01-75e8903edd81@redhat.com>
	 <bc162a5eaa58ac074c8ad20cb23d579aa04d0f43.camel@linux.intel.com>
	 <20190725111303-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-07-25 at 11:16 -0400, Michael S. Tsirkin wrote:
> On Thu, Jul 25, 2019 at 08:05:30AM -0700, Alexander Duyck wrote:
> > On Thu, 2019-07-25 at 07:35 -0400, Nitesh Narayan Lal wrote:
> > > On 7/24/19 6:03 PM, Alexander Duyck wrote:
> > > > On Wed, 2019-07-24 at 17:38 -0400, Michael S. Tsirkin wrote:
> > > > > On Wed, Jul 24, 2019 at 10:12:10AM -0700, Alexander Duyck wrote:
> > > > > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > > > 
> > > > > > Add support for what I am referring to as "bubble hinting". Basically the
> > > > > > idea is to function very similar to how the balloon works in that we
> > > > > > basically end up madvising the page as not being used. However we don't
> > > > > > really need to bother with any deflate type logic since the page will be
> > > > > > faulted back into the guest when it is read or written to.
> > > > > > 
> > > > > > This is meant to be a simplification of the existing balloon interface
> > > > > > to use for providing hints to what memory needs to be freed. I am assuming
> > > > > > this is safe to do as the deflate logic does not actually appear to do very
> > > > > > much other than tracking what subpages have been released and which ones
> > > > > > haven't.
> > > > > > 
> > > > > > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > > BTW I wonder about migration here.  When we migrate we lose all hints
> > > > > right?  Well destination could be smarter, detect that page is full of
> > > > > 0s and just map a zero page. Then we don't need a hint as such - but I
> > > > > don't think it's done like that ATM.
> > > > I was wondering about that a bit myself. If you migrate with a balloon
> > > > active what currently happens with the pages in the balloon? Do you
> > > > actually migrate them, or do you ignore them and just assume a zero page?
> > > > I'm just reusing the ram_block_discard_range logic that was being used for
> > > > the balloon inflation so I would assume the behavior would be the same.
> > > I agree, however, I think it is worth investigating to see if enabling hinting
> > > adds some sort of overhead specifically in this kind of scenarios. What do you
> > > think?
> > 
> > I suspect that the hinting/reporting would probably improve migration
> > times based on the fact that from the sound of things it would just be
> > migrated as a zero page.
> > 
> > I don't have a good setup for testing migration though and I am not that
> > familiar with trying to do a live migration. That is one of the reasons
> > why I didn't want to stray too far from the existing balloon code as that
> > has already been tested with migration so I would assume as long as I am
> > doing almost the exact same thing to hint the pages away it should behave
> > exactly the same.
> > 
> > > > > I also wonder about interaction with deflate.  ATM deflate will add
> > > > > pages to the free list, then balloon will come right back and report
> > > > > them as free.
> > > > I don't know how likely it is that somebody who is getting the free page
> > > > reporting is likely to want to also use the balloon to take up memory.
> > > I think it is possible. There are two possibilities:
> > > 1. User has a workload running, which is allocating and freeing the pages and at
> > > the same time, user deflates.
> > > If these new pages get used by this workload, we don't have to worry as you are
> > > already handling that by not hinting the free pages immediately.
> > > 2. Guest is idle and the user adds up some memory, for this situation what you
> > > have explained below does seems reasonable.
> > 
> > Us hinting on pages that are freed up via deflate wouldn't be too big of a
> > deal. I would think that is something we could look at addressing as more
> > of a follow-on if we ever needed to since it would just add more
> > complexity.
> > 
> > Really what I would like to see is the balloon itself get updated first to
> > perhaps work with variable sized pages first so that we could then have
> > pages come directly out of the balloon and go back into the freelist as
> > hinted, or visa-versa where hinted pages could be pulled directly into the
> > balloon without needing to notify the host.
> 
> Right, I agree. At this point the main thing I worry about is that
> the interfaces only support one reporter, since a page flag is used.
> So if we ever rewrite existing hinting to use the new mm
> infrastructure then we can't e.g. enable both types of hinting.

Does it make sense to have multiple types of hinting active at the same
time though? That kind of seems wasteful to me. Ideally we should be able
to provide the hints and have them feed whatever is supposed to be using
them. So for example I could probably look at also clearing the bitmaps
when migration is in process.

Also, I am wonder if the free page hints would be redundant with the form
of page hinting/reporting that I have since we should be migrating a much
smaller footprint anyway if the pages have been madvised away before we
even start the migration.

> FWIW Nitesh's RFC does not have this limitation.

Yes, but there are also limitations to his approach. For example the fact
that the bitmap it maintains is back to being a hint rather then being
very exact. As a result you could end up walking the bitmap for a while
clearing bits without ever finding a free page.

> I intend to think about this over the weekend.

Sounds good. I'll try to get the stuff you have pointed out so far
addressed and hopefully have v3 ready to go next week.

Thanks.

- Alex

