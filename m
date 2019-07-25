Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9916DC76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 20:37:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E317218EA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 20:37:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E317218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED3066B0003; Thu, 25 Jul 2019 16:37:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E857A6B0005; Thu, 25 Jul 2019 16:37:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4DAB8E0002; Thu, 25 Jul 2019 16:37:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9CBC96B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 16:37:04 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id s22so26965245plp.5
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 13:37:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=9VxVWkjz8i8Ba3093MQa2NFKzuRKZz1r56kvqf7p+BU=;
        b=LEfU6ehM/FGqBqc1Gi0468z38Q/BeUMMKQ2OrAWHJwJAa8ukoKXAWRFg78USPqlx88
         Un/FD2Q0iytOQwUtpn10+4JkyCZrfikoID3iLAj7QI7L7vD1LtaW4cw3DHMFmBdKl0Mw
         Q2wIApBVfzN3MB5QnULbQnWohJyENZWc/YjPx79GjR/qZ3iIlSCzwRbvD3M9GTHp91wl
         OntxHDZclo16tXQTKktSBgaRgiyKskZdYwPWiq/2XERO+rnf5upv8/8O++q9f2tno4K5
         yxVOJMkTrqgTgqIsRhnQFlSncsN5pPNm4QT51h6JG+MfFj+EmpdSF91NtRjCtIdRA3JM
         DDWQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXIMcTXu75l0xETNsA+8HzK1HX6uq8NXu/eyTcvxzqD7C99mgAj
	ak5dwTUDBFjwp3qtdONWWQFpHTOfP5w2Jy2r+H2fknz1hcP3EKo4l0ATRcGev5lppD1kl4LbJxs
	AOlMPNAOMXIBtcA9Xb0fsG3OTE3HgohGQApoC4GIOgMNl2I7qkmMYFV3GWk5efPjDEA==
X-Received: by 2002:a17:90a:9bc5:: with SMTP id b5mr95188811pjw.109.1564087024260;
        Thu, 25 Jul 2019 13:37:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxkWvyDjN/AN7ve4UMuh3Q7Ajr2kaLwZ9+yXr2hfW8ztTQkWy3oLydathG6QAwEnNEYxvmE
X-Received: by 2002:a17:90a:9bc5:: with SMTP id b5mr95188760pjw.109.1564087023391;
        Thu, 25 Jul 2019 13:37:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564087023; cv=none;
        d=google.com; s=arc-20160816;
        b=mo5UFvk5XcZ2CaMYn/sTbbVWYZ5mM20OOYX2/mCoph+7FsZxkz8ZoLR9YZYp2VzvH6
         UuwvGidEtxDpIc+yG9bU/XGmzrwYAjdXv7sxfkK3jx5D4GU7KRX0zHcPMZq6LRNhd8fp
         b45yIkJqbzKCVK2bNsqlcrcIJTapuKwJJayYcFD1XffuEqwFVh1EDnu9HmUZnc8zZlx1
         1mX3SVpMZ6W+CJc9HarEFMUg8+POl7k27okKE/8/NWIkQPVzYglfDPNf+vJwu/+ihOTU
         K9X61EUnPMpFUzdGatsys6AQ8+ogiUOmQ4N0shZl8O//7eGTT4lsDfx9/IV1aoweZ0vJ
         Fz+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=9VxVWkjz8i8Ba3093MQa2NFKzuRKZz1r56kvqf7p+BU=;
        b=lKc48kEtPxgZ7q9/10F8YMZJyCt46m/XEAqyBu3N3BtlAmycscnps+H3+sO79q6keS
         WW8c+M2yCFUo4njaUO7BGkfD4IozFW4Zs9DHtYWeu27h6J8+4efT0i0ZIepgLAWWW0FA
         1U1YS6TyL4XILxnnRhi7KyxBSGV+G6h3hNdlnGF9g/Mre4vyE9PQ9I5HD4fxeVQwnga1
         2ql9S1L3DfTtkV7OaYDTqI1/ywwFdfuvpTnd7nA3YuvYY1vVxpHhsRyjsoKoIJCWfdlq
         iyDYPBzMJvQ6CZlDrQkh/Y8MLatlK30SuU0Q9AU7ArK5a1tspSHZARLtPbIfl/5EwBd+
         qaYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id b14si17138116pgi.587.2019.07.25.13.37.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 13:37:03 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jul 2019 13:37:02 -0700
X-IronPort-AV: E=Sophos;i="5.64,308,1559545200"; 
   d="scan'208";a="161090207"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga007-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jul 2019 13:37:02 -0700
Message-ID: <5f78cccab8273cb759538ef6e088886a507ce438.camel@linux.intel.com>
Subject: Re: [PATCH v2 4/5] mm: Introduce Hinted pages
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: David Hildenbrand <david@redhat.com>, Alexander Duyck
	 <alexander.duyck@gmail.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
 "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew
 Morton <akpm@linux-foundation.org>, Yang Zhang <yang.zhang.wz@gmail.com>, 
 pagupta@redhat.com, Rik van Riel <riel@surriel.com>, Konrad Rzeszutek Wilk
 <konrad.wilk@oracle.com>, lcapitulino@redhat.com, wei.w.wang@intel.com,
 Andrea Arcangeli <aarcange@redhat.com>, Paolo Bonzini
 <pbonzini@redhat.com>, dan.j.williams@intel.com,  Matthew Wilcox
 <willy@infradead.org>
Date: Thu, 25 Jul 2019 13:37:02 -0700
In-Reply-To: <c200d5cf-90f7-9dca-5061-b6e0233ca089@redhat.com>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
	 <20190724170259.6685.18028.stgit@localhost.localdomain>
	 <a9f52894-52df-cd0c-86ac-eea9fbe96e34@redhat.com>
	 <CAKgT0Ud-UNk0Mbef92hDLpWb2ppVHsmd24R9gEm2N8dujb4iLw@mail.gmail.com>
	 <f0ac7747-0e18-5039-d341-5dfda8d5780e@redhat.com>
	 <b3568a5422d0f6b88f7c5cb46577db1a43057c04.camel@linux.intel.com>
	 <c200d5cf-90f7-9dca-5061-b6e0233ca089@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-07-25 at 20:32 +0200, David Hildenbrand wrote:
> On 25.07.19 19:38, Alexander Duyck wrote:
> > On Thu, 2019-07-25 at 18:48 +0200, David Hildenbrand wrote:
> > > On 25.07.19 17:59, Alexander Duyck wrote:
> > > > On Thu, Jul 25, 2019 at 1:53 AM David Hildenbrand <david@redhat.com> wrote:
> > > > > On 24.07.19 19:03, Alexander Duyck wrote:
> > > > > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > 
> > <snip>
> > 
> > > > > Can't we reuse one of the traditional page flags for that, not used
> > > > > along with buddy pages? E.g., PG_dirty: Pages that were not hinted yet
> > > > > are dirty.
> > > > 
> > > > Reusing something like the dirty bit would just be confusing in my
> > > > opinion. In addition it looks like Xen has also re-purposed PG_dirty
> > > > already for another purpose.
> > > 
> > > You brought up waste page management. A dirty bit for unprocessed pages
> > > fits perfectly in this context. Regarding XEN, as long as it's not used
> > > along with buddy pages, no issue.
> > 
> > I would rather not have to dirty all pages that aren't hinted. That starts
> > to get too invasive. Ideally we only modify pages if we are hinting on
> > them. That is why I said I didn't like the use of a dirty bit. What we
> > want is more of a "guaranteed clean" bit.
> 
> Not sure if that is too invasive, but fair enough.
> 
> > > FWIW, I don't even thing PG_offline matches to what you are using it
> > > here for. The pages are not logically offline. They were simply buddy
> > > pages that were hinted. (I'd even prefer a separate page type for that
> > > instead - if we cannot simply reuse one of the other flags)
> > > 
> > > "Offline pages" that are not actually offline in the context of the
> > > buddy is way more confusing.
> > 
> > Right now offline and hinted are essentially the same thing since the
> > effect is identical.
> 
> No they are not the same thing. Regarding virtio-balloon: You are free
> to reuse any hinted pages immediate. Offline pages (a.k.a. inflated) you
> might not generally reuse before deflating.

Okay, so it sounds like your perspective is a bit different than mine. I
was thinking of it from the perspective of the host OS where in either
case the guest has set the page as MADV_DONTNEED. You are looking at it
from the guest perspective where Offline means the guest cannot use it.

> > There may be cases in the future where that is not the case, but with the
> > current patch set they both result in the pages being evicted from the
> > guest.
> > 
> > > > If anything I could probably look at seeing if the PG_private flags
> > > > are available when a page is in the buddy allocator which I suspect
> > > > they probably are since the only users I currently see appear to be
> > > > SLOB and compound pages. Either that or maybe something like PG_head
> > > > might make sense since once we start allocating them we are popping
> > > > the head off of the boundary list.
> > > 
> > > Would also be fine with me.
> > 
> > Actually I may have found an even better bit if we are going with the
> > "reporting" name. I could probably use "PG_uptodate" since it looks like
> > most of its uses are related to filesystems. I will wait till I hear from
> > Matthew on what bits would be available for use before I update things.
> 
> Also fine with me. In the optimal case we (in my opinion)
> a) Don't reuse PG_offline
> b) Don't use another page type

That is fine. I just need to determine the exact flag to use then. I'll do
some more research and wait to see if anyone else from MM comunity has
input or suggestions on the page flag to be used. From what I can tell it
looks like there are a bunch of flag bits that are unused as far as the
buddy pages are concerned so I should have a few to choose from.

