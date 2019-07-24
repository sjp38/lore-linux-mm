Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C0C5C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 22:08:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF3D021880
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 22:08:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF3D021880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 447598E0010; Wed, 24 Jul 2019 18:08:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F7DF8E0002; Wed, 24 Jul 2019 18:08:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E6008E0010; Wed, 24 Jul 2019 18:08:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 090F18E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 18:08:38 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id q26so42824002qtr.3
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:08:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=gF6WF5oKZcAh8lsxIGa4A4qCFkeXLAddUJBeCVn/yGw=;
        b=VSKkj8cfU2KqN7rZXTx9zhbEJc94qg2MAfQ/RU6waSHnGEtTJv29oLn9RgeMOAVcZ2
         ZFnuHTSYiiWvra6ttQtHq6KTPQNGC+r/uLLvqY38gc/3uvCn2fAmcfGF3jb8NJavWxxE
         WD1sJ8macZ46IzynkejkFHvMVdZIlDzbgOhGvEGEXxKwk/7UJbTuxTJ8vNEmgqazk0+x
         LDBChkZuIwLvEsmtrqGgxt6B11N97krxHLFyVxKbkUdMRbd8XhQgJwqUiX3iCzsJWStz
         1gil1qQGE5x2fRMh7ZH1l2eRn2UxjgioHq5de8n7sqkAXyqaNVoWYPxc/7AsgQfYElO/
         kI3w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUHMcCpjU7vx9KF/pNEgyPo9KPNBPIM9FZbyUa3AJrOpi6LDKHI
	PYK3hnjVTzX4t/pRrFx9ogAbZaMbvgII/KltRtRy45H/FUfaaQXgvpu+wYqEemgbNj8F34K2rFj
	3df9HjzYh0VEIcrp/4MNGD9QeS+21YCwJ+y7Mu4qCC185KR+X2bB+EobcJAJhRhu9Yg==
X-Received: by 2002:a37:6f82:: with SMTP id k124mr55574963qkc.463.1564006117798;
        Wed, 24 Jul 2019 15:08:37 -0700 (PDT)
X-Received: by 2002:a37:6f82:: with SMTP id k124mr55574912qkc.463.1564006117237;
        Wed, 24 Jul 2019 15:08:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564006117; cv=none;
        d=google.com; s=arc-20160816;
        b=KSd2IknzCLXOC9siOBwapTYq+kVHH9s29HltaAS6u7al0AWHR/4VJWapN/z2+YZljM
         dFGLgV9EF6yJhwSQFgfWoc2To8M9jIAkDV2vAdRNoeJTgY/rD/2AKijcRkz6X5ZT9eA4
         CPMXKkkeU/2ziB6y8/PDxskV5/pGjfzvj8h9wu5ZDP+ODP5eQWNR3MmF6XUIRZLz4BI8
         6ngTu5R9YsjPzC2mQnWngXZOZ1IG+h5wFk6vI/KplLOPQZ6Q15XlPKWHBxhm6znBHHow
         iv7Q6F33ZbfgsoRfQJcD+t5bkodgEuozYw2wyC6daDKH/TtbkxXcv1koYL5aij6O68AP
         QDqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=gF6WF5oKZcAh8lsxIGa4A4qCFkeXLAddUJBeCVn/yGw=;
        b=cOwN5Y3y1+4yMpPjg9eM6+WsOqpp5B5uBp2XgZOy97CoDMaY0sJXf8lsLxuleJ47XB
         yjtknNj8cAZI9Y70eD+1gibeXs6C1yVyL6uJH/4RF/OPVO8sxgcVj9X8iWUN3mjmHJwB
         hCetGVZG5OmvptOF847wXWCVu/YX60mkcggGYJ3ZLBS1slumf8sXqpa5oAKU2VF9moh0
         mGT/SbV/e+F5mjJHhJ7+HUAe6XZ2ug33DQwZ0lMmurPcwb0T8wvCGX6rNzlfWdi+w1AL
         dGfqyJfV+DYC/NJ6NJAbJJ8m9qBOxZyvJa0DnHMPrZd+ahud9bIw5azrQt8lVP0h42N9
         LRNg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w84sor27370746qkb.44.2019.07.24.15.08.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 15:08:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxVJCQ2dlAvvn87eBVVAsdbP4o5lFQJIQ8dJsrhL7h4rGVMj3kyCjifB4jGqlYkUi6EmUay0w==
X-Received: by 2002:a37:4781:: with SMTP id u123mr51143171qka.263.1564006116973;
        Wed, 24 Jul 2019 15:08:36 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id i62sm22082669qke.52.2019.07.24.15.08.31
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 15:08:35 -0700 (PDT)
Date: Wed, 24 Jul 2019 18:08:28 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, nitesh@redhat.com,
	kvm@vger.kernel.org, david@redhat.com, dave.hansen@intel.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, yang.zhang.wz@gmail.com,
	pagupta@redhat.com, riel@surriel.com, konrad.wilk@oracle.com,
	lcapitulino@redhat.com, wei.w.wang@intel.com, aarcange@redhat.com,
	pbonzini@redhat.com, dan.j.williams@intel.com
Subject: Re: [PATCH v2 QEMU] virtio-balloon: Provide a interface for "bubble
 hinting"
Message-ID: <20190724180552-mutt-send-email-mst@kernel.org>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <20190724171050.7888.62199.stgit@localhost.localdomain>
 <20190724173403-mutt-send-email-mst@kernel.org>
 <ada4e7d932ebd436d00c46e8de699212e72fd989.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ada4e7d932ebd436d00c46e8de699212e72fd989.camel@linux.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 03:03:56PM -0700, Alexander Duyck wrote:
> On Wed, 2019-07-24 at 17:38 -0400, Michael S. Tsirkin wrote:
> > On Wed, Jul 24, 2019 at 10:12:10AM -0700, Alexander Duyck wrote:
> > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > 
> > > Add support for what I am referring to as "bubble hinting". Basically the
> > > idea is to function very similar to how the balloon works in that we
> > > basically end up madvising the page as not being used. However we don't
> > > really need to bother with any deflate type logic since the page will be
> > > faulted back into the guest when it is read or written to.
> > > 
> > > This is meant to be a simplification of the existing balloon interface
> > > to use for providing hints to what memory needs to be freed. I am assuming
> > > this is safe to do as the deflate logic does not actually appear to do very
> > > much other than tracking what subpages have been released and which ones
> > > haven't.
> > > 
> > > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > 
> > BTW I wonder about migration here.  When we migrate we lose all hints
> > right?  Well destination could be smarter, detect that page is full of
> > 0s and just map a zero page. Then we don't need a hint as such - but I
> > don't think it's done like that ATM.
> 
> I was wondering about that a bit myself. If you migrate with a balloon
> active what currently happens with the pages in the balloon? Do you
> actually migrate them, or do you ignore them and just assume a zero page?

Ignore and assume zero page.

> I'm just reusing the ram_block_discard_range logic that was being used for
> the balloon inflation so I would assume the behavior would be the same.
> 
> > I also wonder about interaction with deflate.  ATM deflate will add
> > pages to the free list, then balloon will come right back and report
> > them as free.
> 
> I don't know how likely it is that somebody who is getting the free page
> reporting is likely to want to also use the balloon to take up memory.

Why not?

> However hinting on a page that came out of deflate might make sense when
> you consider that the balloon operates on 4K pages and the hints are on 2M
> pages. You are likely going to lose track of it all anyway as you have to
> work to merge the 4K pages up to the higher order page.

Right - we need to fix inflate/deflate anyway.
When we do, we can do whatever :)

-- 
MST

