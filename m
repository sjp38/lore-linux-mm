Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6812C282DA
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 15:24:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 377EB20818
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 15:24:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 377EB20818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B64196B0003; Mon, 15 Apr 2019 11:24:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B11A26B0006; Mon, 15 Apr 2019 11:24:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A004F6B0007; Mon, 15 Apr 2019 11:24:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7FF986B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 11:24:45 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id f89so16479585qtb.4
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 08:24:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=uFR+BZCufjH1A36gcMRkjwnccFNgSbXdmrPRGNlfa7g=;
        b=FvFLytCsGi+yVSzuQGB29g5zKqfh9YAgACpuj3021PZPyGZXq4onTnXWRgAicWLw0U
         6gTr+RdDIw1xN1e79wExB04NZFlcl0UjTBgtIgcoBY0+cJeIuaQrk0wXGcWEzIkr0ciY
         YFXL4KD3mhS2OTfREmBsH52NB5lo7jV/ur4EZUDrHsjgSMFRcUg+sy+SXWZgR75gXFAO
         +8wyEdbpb6bmI4QgDvj35dAiFzX8mo7lLBY5bTMQantmQjGR7t7IBkprLP0oj60qx7Nn
         iX3Pp5aUS9Y3+uZyDPzqOm+sMRax9Y0ur2IclTN5lCnu5edWPatOijokh+u7LcPhmXLa
         5O9w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWaJkxxEXu1XZvHz6xGo8EEXa+g5co85TzEAcwPW9PJAj5RpOSl
	GWXU+9kN9kqUjpR9EsUEb3E3EXpB4u/brO/n3bFD+kjE5fH9JzzWuSa7dgSv3zNr4T2ua2bPQB/
	YNNvpKMrQnpM9jUPz6CAv1qksPP0CvOQ/71XmnpQorh4FsBqYUtGtJ20o/I3t3+Ad6A==
X-Received: by 2002:a0c:9246:: with SMTP id 6mr60707225qvz.194.1555341885252;
        Mon, 15 Apr 2019 08:24:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFAK86b1Jz0KBzhBxS0Gx4V6w+sY2+OHicXvROzL6D1b7MSKeTDzW7x58HmA016txBBe6x
X-Received: by 2002:a0c:9246:: with SMTP id 6mr60707169qvz.194.1555341884670;
        Mon, 15 Apr 2019 08:24:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555341884; cv=none;
        d=google.com; s=arc-20160816;
        b=ox3+BxlErSqYZg8iYto/F0di8ZxpNNfd3LQAulChAqJanrsu9qAwT54ZPf1a9uN2+D
         j6iVUapUx/KRZaAtkP5dMsBmuUVldcbvJIJPyrIUiplr4etS0RsF91jwmpAHZcvz6rcL
         csgPM1YzazBjVoBlTNsIEOLeD739cZAiMECwRcGm/LehhlldIgzjg5D8CIsWViSdFYag
         Kh6U9M9WPZ8fGtTfPdy4WwO86+GKZj8RC+uEL5ysvrTEG7+ivX5XLtOShmhTYbdOP93p
         QrTDfVfAbMKjFgxEgYLoZXvczO3q+2WGcNkZ3ZjJ1AtveIsx+23IOSMVr/KBw3jrH9Q3
         AvFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=uFR+BZCufjH1A36gcMRkjwnccFNgSbXdmrPRGNlfa7g=;
        b=qvI5VkaqqB+J9y5SlZzYpyRpvU7/ljeLRybFbRInUBA2g28jtlYQNn0uaLRIAdglwW
         L/FtoPcvnlt/YVC2UW/t4tofgmM+Lui0J3L5D5LT6HN7cH3Koz3CxBV9Yj7P0E3/QXXd
         GvjbCjMPNIzWhW7gbxMBBhykp42T52OcC8ZbrlwXxj7bNDY0Li7BEzy6wvr4mEPI+sUT
         f4zdHQN4taQ6w0UU3Jxo8YZaRmypIoeIPXOp/4qt2ZxbpCheiavyQWDA/3LHzmcnpGUZ
         5Vj/yTAIZFrixI/K8Bcmm4M7570TixdnfxlcbnSZIHIFWrm4MA17G/KLG1ldG+zAA5p5
         IMsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a30si2329574qvb.13.2019.04.15.08.24.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 08:24:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BBDC330BC67C;
	Mon, 15 Apr 2019 15:24:38 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 350F9608C0;
	Mon, 15 Apr 2019 15:24:35 +0000 (UTC)
Date: Mon, 15 Apr 2019 11:24:33 -0400
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
Message-ID: <20190415152433.GB3436@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <20190411210834.4105-11-jglisse@redhat.com>
 <20190415145952.GE13684@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190415145952.GE13684@quack2.suse.cz>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Mon, 15 Apr 2019 15:24:43 +0000 (UTC)
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

It might be workable but i am not sure it is any simpler. bio_add_page*()
does not take page reference it is up to the caller to take the proper
page reference so the complexity would be push there (just in a different
place) so i don't think it would be any simpler. This means that we would
have to update more code than this patchset does.

This present patch is just a coccinelle semantic patch and even if it
is scary to see that many call site, they are not that many that need
to worry about the GUP parameter and they all are in patch 11, 12, 13
and 14.

So i believe this patchset is simpler than converting everyone to take
a GUP like page reference. Also doing so means we loose the information
about GUP kind of defeat the purpose. So i believe it would be better
to limit special reference to GUP only pages.

Cheers,
Jérôme

