Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E31BDC10F12
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 00:22:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9CE582084B
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 00:22:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9CE582084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 367056B0003; Mon, 15 Apr 2019 20:22:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 315896B0006; Mon, 15 Apr 2019 20:22:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DF0B6B0007; Mon, 15 Apr 2019 20:22:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id ECF496B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 20:22:12 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id c67so16323116qkg.5
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 17:22:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=xfdVG4aTmNhV0o2/aKEt+KXIaTnNxJ8gqYkvUNgyHOY=;
        b=LLpjX6N+KrkQuxsa9pHsZdPiPef8vtoBknYwM21MPdF5/PxztNVodQTKZmtGsLQ2wN
         cxmK1dvjvTw0zkLPxls3L5SPsOWypvUqO5FaOh7oiwkS4PjvMqYc7ElohFrUJViltQtv
         GdVUj5FVocKjsxst6wUWl1TOImmI29OEAI7qOaJHwpghUDs4UgPyT3sYekM1mk5tJpSm
         xt7IHAEHCVO2fTBOq/MCG6TJCpNGW6lByc4a7JJOICcyEXHlwosC/+Z96K7L0o0rku1j
         2b7RQc6/y1EEtc/APLzN2SlJWATM8dBtxRcxkWKECt8mF0TGlEjUUMX+NHrRLFBfE8ff
         po+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUpNC8+TO4NVUSTzLa1VKlc841K1ZzgsWhnQjAUOkrhwn9PQZ3+
	CE/RY1HoIAu9lvup/5CeO4PbUULJkdAKVLqAeJlOHxCS4qzqD6051Vd2x407NCuBHt9HkV0WNht
	gadCTLOSuKvnFWQhCJW7A75yntlGDEOdcdYcVVNBVJ6/BnNeZYCT3lBgBRmIczAcpqg==
X-Received: by 2002:ac8:28f4:: with SMTP id j49mr61635362qtj.310.1555374132691;
        Mon, 15 Apr 2019 17:22:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrJT/3z83JpQgjuJVzZ+QwusyrqSu4PzLYHDrG+xPQmEODpK5gbdTaU3wCGwnLF5lJgP0S
X-Received: by 2002:ac8:28f4:: with SMTP id j49mr61635331qtj.310.1555374132035;
        Mon, 15 Apr 2019 17:22:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555374132; cv=none;
        d=google.com; s=arc-20160816;
        b=WouXl8PdLL0flrc1QqpaVtT8/YqfKxAQ4f/9h5Uuj9NtJLw448nG20NjGTS/gJ5+Tv
         2+knL9gKoOSNY2t9cZU1K6QFuHjOwnL2HS224GwTj+EBZwK2B6KS1TmUdHC92Rmfar+t
         QIr9XBYz5zHgwBtWi7Rfppo8xb5dbU/GspyN52nPOd9PRqy7agkJD3prKwXgEM71uUbL
         xX+Xj8CwnkpiOjvCsVJRjNMNNC73uUTSS9F+hpyAxrPfDtojhtaA7tjCbuRgRvpR9FfD
         FT+VCkIY6sx6rb8g4ROH3Hxhz7WONqhvNDXRBlFJJA+ExTj3bkz+msTw74A2d6cMGPgv
         e0Cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=xfdVG4aTmNhV0o2/aKEt+KXIaTnNxJ8gqYkvUNgyHOY=;
        b=AHQUFsWpIu1iW680lo788zMjUPLq/K9MpjghHuHSIKNGYHC8k+4hpY+ughlsDtYFZh
         PdZ0kwhM48CdMc4y6XrG59yeoma2VMFGMLDdSHuc+4t94Are6TjUPno7mEJSb7Bj+gJo
         H/peSjzzqF8AjJHfCbAt48uTLehgjP+4hI1hQtVqN3seZV0AORzxiD2dBDULx8E80d+H
         reYTn449P+S9vzdbKw3qzrGWYMFM71eHFivIYM4DSmQ3RY+f9IXkHFu1bLfVeBw79Vtl
         96u/iW6Fnf8gHiKoFGFnaWerGpis3zC2AvPeidtfQqKs+OMZszKuJzCdNIOwIKRj7nEQ
         Lp3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 27si867315qvd.74.2019.04.15.17.22.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 17:22:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D0A8C59451;
	Tue, 16 Apr 2019 00:22:10 +0000 (UTC)
Received: from redhat.com (ovpn-121-42.rdu2.redhat.com [10.10.121.42])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 60EFC19C68;
	Tue, 16 Apr 2019 00:22:06 +0000 (UTC)
Date: Mon, 15 Apr 2019 20:22:04 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Jan Kara <jack@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org, linux-mm@kvack.org,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Ming Lei <ming.lei@redhat.com>, Dave Chinner <david@fromorbit.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v1 10/15] block: add gup flag to
 bio_add_page()/bio_add_pc_page()/__bio_add_page()
Message-ID: <20190416002203.GA3158@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <20190411210834.4105-11-jglisse@redhat.com>
 <20190415145952.GE13684@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190415145952.GE13684@quack2.suse.cz>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 16 Apr 2019 00:22:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 15, 2019 at 04:59:52PM +0200, Jan Kara wrote:
> Hi Jerome!
> 
> On Thu 11-04-19 17:08:29, jglisse@redhat.com wrote:
> > From: Jérôme Glisse <jglisse@redhat.com>
> > 
> > We want to keep track of how we got a reference on page added to bio_vec
> > ie wether the page was reference through GUP (get_user_page*) or not. So
> > add a flag to bio_add_page()/bio_add_pc_page()/__bio_add_page() to that
> > effect.
> 
> Thanks for writing this patch set! Looking through patches like this one,
> I'm a bit concerned. With so many bio_add_page() callers it's difficult to
> get things right and not regress in the future. I'm wondering whether the
> things won't be less error-prone if we required that all page reference
> from bio are gup-like (not necessarily taken by GUP, if creator of the bio
> gets to struct page he needs via some other means (e.g. page cache lookup),
> he could just use get_gup_pin() helper we'd provide).  After all, a page
> reference in bio means that the page is pinned for the duration of IO and
> can be DMAed to/from so it even makes some sense to track the reference
> like that. Then bio_put() would just unconditionally do put_user_page() and
> we won't have to propagate the information in the bio.
> 
> Do you think this would be workable and easier?

Thinking again on this, i can drop that patch and just add a new
bio_add_page_from_gup() and then it would be much more obvious that
only very few places need to use that new version and they are mostly
obvious places. It is usualy GUP then right away add the pages to bio
or bvec.

We can probably add documentation around GUP explaining that if you
want to build a bio or bvec from GUP you must pay attention to which
function you use.

Also pages going in a bio are not necessarily written too, they can
be use as source (writting to block) or as destination (reading from
block). So having all of them with refcount bias as GUP would muddy
the water somemore between pages we can no longer clean (ie GUPed)
and those that are just being use in regular read or write operation.

Cheers,
Jérôme

