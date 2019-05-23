Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6ED4EC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 20:59:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F9752081C
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 20:59:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F9752081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CB186B02B3; Thu, 23 May 2019 16:59:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 655B56B02B4; Thu, 23 May 2019 16:59:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F6C76B02B5; Thu, 23 May 2019 16:59:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 255556B02B3
	for <linux-mm@kvack.org>; Thu, 23 May 2019 16:59:55 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id d198so2839046oih.6
        for <linux-mm@kvack.org>; Thu, 23 May 2019 13:59:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=fNxJ1WOfqg+BxXIDxqU/W8caWaNTwI7u8o0hj5zDNcU=;
        b=SbUxCd16Swx62i6+Xtg72Zw05rkjEd6hlXypMYXvskqmqhRVbedpw7FnmJ6LjlaweZ
         ImvBYhFbcvr17eEtWc8q+7MIdI4ByOZRmPNdhMVM2zYT627KRRMjIAx/Y+MVJvnt88Yp
         cy7xGxU598eT0tJA0LZ+A/nvJWFIdxU5hW1/sDkawPlYaeVwuewfEcNqizt6++yEqaqJ
         G/wUk0voHtUzZwQVzSVoU2iJ260f0ymyVOaZ9jwzFHpq7VHClKNYJ70iXRVvdfYOIcqX
         iQbX1QZxD4OVghPrWad9QO8G43Xk+NTVVQLQtEBR+7lUXV3hw52fjeJ9jAXMzMJUz2/t
         Vynw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUzVVRk775WufuLjnY+jebn/3B+dscIR6CfAGvpFh9cUEWDPQnH
	e4O0w04QWc5+Ku1YgqSns5zlQp8m77LS7glns42r6je4M02+cH32esKAldGp1mPqiKh+G+FEsNM
	D9rnmVMOsPPi89pM/9myzDWEOSl94BeeLcqfeSLMzE8e2WS/jK/Wo7YeCCfprf3VdzA==
X-Received: by 2002:a9d:70ce:: with SMTP id w14mr59054689otj.105.1558645194846;
        Thu, 23 May 2019 13:59:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzu76rHEKFOGfMSlwv+gSgjgoJBMypW1i+wFAB7Tp3iblf7J5C7Ch9h++EnHhSMTTgZ6Uvg
X-Received: by 2002:a9d:70ce:: with SMTP id w14mr59054633otj.105.1558645194035;
        Thu, 23 May 2019 13:59:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558645194; cv=none;
        d=google.com; s=arc-20160816;
        b=Go7x7K4LKwUne7dzN2XLVIWsPqYJ3BwCD5ZrauF5OOQfat+H0HdVT/kZ2WL5RV+5HB
         h+628yWSOMgs+ZyBnWaK9L6hpzG5xwuQqOwpQlXRv5gAV6eOkvaRMkcpnKEO4x0oXtZF
         tOD9DBWSYPyMHIdHD19mSkxdyVkfhv1jdI40M4kADwGBczVRPx6AxrUrQQHNiOn9YgwW
         3I6sE/8uixb4oGU7iUBPWKKbsrDiZoCDu908pHycNxXIBF/PiRvzMPL2S/N3bDkfhM9P
         TGUgkqJIjsD9mmaGg8/D6wk8Rc715A1JFsP/HFKeZ8DnjSwleh+o1me6k6mEmK3ycUaF
         cK4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=fNxJ1WOfqg+BxXIDxqU/W8caWaNTwI7u8o0hj5zDNcU=;
        b=UDhaR1pIjhMOVgSOrQ7UFCu6DsmkuI6bwYiPtqFHxiJpHvj8pkubxJht1gtn5kRWPj
         Cz3ZnqoFyNqEaGJkOMOaBv39G4pbZYJDHl+X71jtG5LoP/4cKTWikZ4cfb6UpsrOPMar
         smW2KY5+fPPBASuDJoug0+/TJxAJL9cizLqhGKqPukNSetcT9YuQStWjfdcevNvauTqt
         JhR2jVg+rPJvvU8iEXyPKhkkNDymQrc/N+3FYAsWqEwLYHa/BZUwVsr+jdbXCo/bBwbY
         UKWDAboY0AgqvPkXHAvPbTnFY4R6v/ey8JWd4ELi6thA9avwVu0YXOXxdF6qMZ27L39k
         dzQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w82si353414oib.169.2019.05.23.13.59.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 13:59:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CF2523082E3F;
	Thu, 23 May 2019 20:59:49 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id E799B66084;
	Thu, 23 May 2019 20:59:47 +0000 (UTC)
Date: Thu, 23 May 2019 16:59:46 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, linux-rdma@vger.kernel.org,
	linux-mm@kvack.org, Ralph Campbell <rcampbell@nvidia.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [RFC PATCH 00/11] mm/hmm: Various revisions from a locking/code
 review
Message-ID: <20190523205945.GA4170@redhat.com>
References: <20190523153436.19102-1-jgg@ziepe.ca>
 <6ee88cde-5365-9bbc-6c4d-7459d5c3ebe2@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <6ee88cde-5365-9bbc-6c4d-7459d5c3ebe2@nvidia.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 23 May 2019 20:59:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 12:04:16PM -0700, John Hubbard wrote:
> On 5/23/19 8:34 AM, Jason Gunthorpe wrote:
> > From: Jason Gunthorpe <jgg@mellanox.com>
> > 
> > This patch series arised out of discussions with Jerome when looking at the
> > ODP changes, particularly informed by use after free races we have already
> > found and fixed in the ODP code (thanks to syzkaller) working with mmu
> > notifiers, and the discussion with Ralph on how to resolve the lifetime model.
> > 
> > Overall this brings in a simplified locking scheme and easy to explain
> > lifetime model:
> > 
> >   If a hmm_range is valid, then the hmm is valid, if a hmm is valid then the mm
> >   is allocated memory.
> > 
> >   If the mm needs to still be alive (ie to lock the mmap_sem, find a vma, etc)
> >   then the mmget must be obtained via mmget_not_zero().
> > 
> > Locking of mm->hmm is shifted to use the mmap_sem consistently for all
> > read/write and unlocked accesses are removed.
> > 
> > The use unlocked reads on 'hmm->dead' are also eliminated in favour of using
> > standard mmget() locking to prevent the mm from being released. Many of the
> > debugging checks of !range->hmm and !hmm->mm are dropped in favour of poison -
> > which is much clearer as to the lifetime intent.
> > 
> > The trailing patches are just some random cleanups I noticed when reviewing
> > this code.
> > 
> > I expect Jerome & Ralph will have some design notes so this is just RFC, and
> > it still needs a matching edit to nouveau. It is only compile tested.
> > 
> 
> Thanks so much for doing this. Jerome has already absorbed these into his
> hmm-5.3 branch, along with Ralph's other fixes, so we can start testing,
> as well as reviewing, the whole set. We'll have feedback soon.
> 

I force pushed an updated branch with couple fix

https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-5.3

Seems to work ok so far, still doing testing.

Cheers,
Jérôme

