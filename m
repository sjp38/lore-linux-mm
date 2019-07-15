Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7426AC7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 14:57:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43AB1205ED
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 14:57:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43AB1205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFD036B0005; Mon, 15 Jul 2019 10:57:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CAE676B0006; Mon, 15 Jul 2019 10:57:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9D7B6B0007; Mon, 15 Jul 2019 10:57:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 836C96B0005
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 10:57:58 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id q9so10597872pgv.17
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 07:57:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=JDrG3DvP88tJtXq1tLcEdWrEbM7z4JJMwwLIDigy/P8=;
        b=tgLm9B0dYLleIX2rQBTO7SND9cKdDbOJ9RsWYl0V9Z7qTDW8MSa1QpWV5SXKh3rh41
         eDjmEUMzf9fTR+lQbaF6qKfo/fOPmRF86MSEXQ+J7J78xw649f9rkyvxCwdiGQyQNP43
         ES8M2ODDpb+rL8rnavy222vmdSa8uqXfIhAUjYR7HkN08NgdjabErVzMeJMko+Hcui6g
         60kaMFCog3sG5haW0t0Pz/rLgqKx/MB0oR2pKDgTdGKjlLhhWi29jQL1v6veEDUTiR5W
         wsHx4jkxRJqwQ9FA4SP7DclbqUN/XgRqBgDiyZlj0PgjFJ6Vk/mXQXPte1cMGIMcpZim
         WtZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWUUMYMzu+hFG/hak/yD85shQl4VRSr+NC6PVDtMPO1LHfHKBqd
	js+NLlVCSDQszGWLpjl5N+GvMF6Cq/l+gcgF5afH8WRI5CNdWWvy9ao9QgV5pzB51FG++Su+dZH
	XRjkhcVp+fWJMebELQrlJSmImNndFoKqeDwi7VICGwqgo65TNg7CTzTIujsxLSQcJpQ==
X-Received: by 2002:a17:902:6a87:: with SMTP id n7mr28447661plk.336.1563202678193;
        Mon, 15 Jul 2019 07:57:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3KtbAbTN2pZo424b9r5xVEgyiwiHVQN+q7f2cH1dANkG+89oVuh/iAZVIotUScYAlS1Z+
X-Received: by 2002:a17:902:6a87:: with SMTP id n7mr28447581plk.336.1563202677235;
        Mon, 15 Jul 2019 07:57:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563202677; cv=none;
        d=google.com; s=arc-20160816;
        b=tgLSx+6DODcQAwRWW3476wRn1QVIG45JcOUHgG4I+WwzEYVuZ+pgrIRYQwPiV8UFHy
         W13iNqZGwwrbx0TnYN7SclYGT8U6pqwK2GcLVaLwjYriSkG4eAt2hF1P+ID1Gld8O6p/
         stAYEF0oJ9cPHc+T5mpEa7KbDy2mmPKZZ1dZozwqdLCxmRJjSxkJvYNx9Wa/9+8m9fEi
         JSgHyHm7mVWc7/8GTs7u1pXKim5I2TjCWnMuBUd65sHtRfL6wOXFH/QjnSvSACSAenMH
         U+s09Z2J4MKLmqwEq3nyIijSRGBUC9jIs5FQzAnLdhNDeH1JNyHbql/9qap08tbl/scj
         SFeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=JDrG3DvP88tJtXq1tLcEdWrEbM7z4JJMwwLIDigy/P8=;
        b=WkIxnh2+qen5BjLjZ26Z/p3E3SS/Di+7N862TtEEaEKv4mC/9Xwm62Sv6hsV8X31h5
         0HRrIzhmNlG3Gm+hp+caIT2QqvYOkt9WKclKjHxImX6tk8TNFTAslgkmM8QSaxwvhqxx
         +FvcMUqDY+Mc6iNcuGxaQQOZ97Tgf1QamAeGgSO8ybXfF9hWlr4Ct7h/CgLakOR2GHwm
         iVC5upxhkoFzL4UdpjE4aFRodSF548G37tpnr+ZyqL2ltJxPiEBV+IWvBGTolA8pnxuC
         BW4fSKYeKsWFWokDq9sscvfc1g8B3Fs5f3i28tr8nMhuRv4neQNCSt4weKpAOnSYjA1T
         6kRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id g31si15447834pld.8.2019.07.15.07.57.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 07:57:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 15 Jul 2019 07:57:56 -0700
X-IronPort-AV: E=Sophos;i="5.63,493,1557212400"; 
   d="scan'208";a="342406193"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga005-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 15 Jul 2019 07:57:56 -0700
Message-ID: <5efe30658033c1b22a36438758236d4f4aa8c345.camel@linux.intel.com>
Subject: Re: [PATCH v1 0/6] mm / virtio: Provide support for paravirtual
 waste page treatment
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: David Hildenbrand <david@redhat.com>, Dave Hansen
 <dave.hansen@intel.com>,  Alexander Duyck <alexander.duyck@gmail.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
 "Michael S. Tsirkin" <mst@redhat.com>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>,
 Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com, Rik van Riel
 <riel@surriel.com>,  Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 lcapitulino@redhat.com, wei.w.wang@intel.com, Andrea Arcangeli
 <aarcange@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>,
 dan.j.williams@intel.com
Date: Mon, 15 Jul 2019 07:57:56 -0700
In-Reply-To: <91a0d964-7fb7-f25e-bf2b-6a7531b96afd@redhat.com>
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
	 <ff133df4-6291-bece-3d8d-dc3f12f398cf@redhat.com>
	 <8fea71ba-2464-ead8-3802-2241805283cc@intel.com>
	 <CAKgT0UdAj4Kq8qHKkaiB3z08gCQh-jovNpos45VcGHa_v5aFGg@mail.gmail.com>
	 <bc4bb663-585b-bee0-1310-b149382047d0@intel.com>
	 <91a0d964-7fb7-f25e-bf2b-6a7531b96afd@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-07-15 at 11:41 +0200, David Hildenbrand wrote:
> On 25.06.19 20:22, Dave Hansen wrote:
> > On 6/25/19 10:00 AM, Alexander Duyck wrote:
> > > Basically what we are doing is inflating the memory size we can report
> > > by inserting voids into the free memory areas. In my mind that matches
> > > up very well with what "aeration" is. It is similar to balloon in
> > > functionality, however instead of inflating the balloon we are
> > > inflating the free_list for higher order free areas by creating voids
> > > where the madvised pages were.
> > 
> > OK, then call it "free page auto ballooning" or "auto ballooning" or
> > "allocator ballooning".  s390 calls them "unused pages".
> > 
> > Any of those things are clearer and more meaningful than "page aeration"
> > to me.
> > 
> 
> Alex, if you want to generalize the approach, and not call it "hinting",
> what about something similar to "page recycling".
> 
> Would also fit the "waste" example and would be clearer - at least to
> me. Well, "bubble" does not apply anymore ...
> 

I am fine with "page hinting". I have already gone through and started the
rename. The problem with "page recycling" is that is actually pretty
similar to the name we had in the networking space for how the NICs will
recycle the Rx buffers.

For now I am going through and replacing instances of Aerated with Hinted,
and aeration with page_hinting. I should have a new patch set ready in a
couple days assuming no unforeseen issues.

Thanks.

- Alex

