Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 483E9C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 18:32:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF41720449
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 18:32:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF41720449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 603696B0269; Tue, 16 Apr 2019 14:32:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B33C6B026B; Tue, 16 Apr 2019 14:32:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A2C46B026D; Tue, 16 Apr 2019 14:32:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 27B006B0269
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 14:32:37 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id a188so18710341qkf.0
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 11:32:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=POvqWVxa2Qt6s/QzlKuu32gfPCRTcLlkzzX2YOEFBlc=;
        b=C2al1D/v0E79kg9OPntAfdNKl7w29IP/Fs6XOPT4BzjI4mJxZvUtn3yt+r3oN1r3q/
         qMKoInQ2VQ+tsP8RurT+5j51Zywci3whKnj+aAWa9qVnQBQ4wua7sqHFsYwl+7QE7WgH
         uT7M2vWuoroJ4IcVW1cEbWho0kiC2+SQbuYwTD7Cl77rURgRXkUj3uFhg1OM2EbfU0GC
         XVrPpx+HDJuYDE9pOdIV1KZH1djkbAyuwbis+cwvVwnO53azn9cso1QlHnkuUyB/yUC/
         gDTKpiPlCbG4MXan5Upf5rx+wa9XGJX/e68ceDYPxACLUMQ6Iv4xNOXrkjSrrLoabfRL
         DYUg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWJMHVP64gnOaSmM7VY5cbZ7VIhVfrNemSC4pYLxbxHL3NSTLKr
	7Cs+gzQOPKzduMVjtIOjkK3bT+B/PQP0EnJPVnHCj7CSY/S4EIO6LXsjMhzrpAwyU8RCrJ/7J/K
	2gxwJ9/fUjBSBuDYSg+O9YDekzT4T6Nhh3qxbBOnS8lr/HtOt/qTXRv0QTJ9omjrgOA==
X-Received: by 2002:ac8:5493:: with SMTP id h19mr52468984qtq.23.1555439556878;
        Tue, 16 Apr 2019 11:32:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyR0vttEx8YtnP4WJhwpQiC0Psu3dbysSsuUMFjz2JqTcMZhfhdXHUNwLItB4yii5+QPvZ6
X-Received: by 2002:ac8:5493:: with SMTP id h19mr52468905qtq.23.1555439556023;
        Tue, 16 Apr 2019 11:32:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555439556; cv=none;
        d=google.com; s=arc-20160816;
        b=hvqDXtEGA48CAaHhBIAf2COhKIMjEKJTuDciy9MFMWQYiY8Xk3OvmVZbXRrDhj+ROi
         hBANC261tXNdfqd4+DOH+g9AcBxvfKGWgDRrG5TJHA0sTU+9Xw4jtKn08EPlB7dZbok/
         jwz1M2DFgHEyjsXpMulqcGSYUYcXALNmPvJzjCEWMzqM42+/k2rGAPGZBjcHaCOOntww
         AhFa79RE9ZcUQVTbmrAXBc9Sz4M4C/KMvacMpDZkg2muXnsPWZHlLVQ3/KZUZRjIivuA
         rhA3AzebhenkHqpBb4L4+FBI5DTESGa1VN7QO/WxVynYhV/jMKdIc2wToqY+KsPfIRC0
         W17g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=POvqWVxa2Qt6s/QzlKuu32gfPCRTcLlkzzX2YOEFBlc=;
        b=KsnWIfhTqWs1vBV6i2OeywN/AW7lTKPUVTe5yqpOmZN9tlqpgkCj4gJa+8/ZqlAqqU
         G0EMnrofRZuPo/glQCjFMxsAsVi2bgmfOIIMHr0HSgwmdR40fyJpjDP8DoBQxSG3hDNA
         9E1aLQ3TMQpZ0b9zv3bTJ2YQqxKBtb2u7EeeyVAxXHE3TLN0WHz9IYfbo8Ik+pmSdzlY
         lH0cV4uwJsvUBOVBjJoikK8ZnCbwEwv77mPjDLTEnnJHClXK8m/31auTDwtZyL7CfDOY
         UzW7bW9Qj/SlKovGyNF3OCdPW1C8yFCYvTG/6Upm0Kyb41d+gqBpiY+yzIUBWcDcoc0/
         Cndw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h4si1727175qta.351.2019.04.16.11.32.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 11:32:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8C77630018F6;
	Tue, 16 Apr 2019 18:32:34 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C0FA360142;
	Tue, 16 Apr 2019 18:32:30 +0000 (UTC)
Date: Tue, 16 Apr 2019 14:32:29 -0400
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
Message-ID: <20190416183228.GA21526@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <20190411210834.4105-11-jglisse@redhat.com>
 <20190415145952.GE13684@quack2.suse.cz>
 <20190416002203.GA3158@redhat.com>
 <20190416165206.GC17148@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190416165206.GC17148@quack2.suse.cz>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Tue, 16 Apr 2019 18:32:35 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 06:52:06PM +0200, Jan Kara wrote:
> On Mon 15-04-19 20:22:04, Jerome Glisse wrote:
> > On Mon, Apr 15, 2019 at 04:59:52PM +0200, Jan Kara wrote:
> > > Hi Jerome!
> > > 
> > > On Thu 11-04-19 17:08:29, jglisse@redhat.com wrote:
> > > > From: Jérôme Glisse <jglisse@redhat.com>
> > > > 
> > > > We want to keep track of how we got a reference on page added to bio_vec
> > > > ie wether the page was reference through GUP (get_user_page*) or not. So
> > > > add a flag to bio_add_page()/bio_add_pc_page()/__bio_add_page() to that
> > > > effect.
> > > 
> > > Thanks for writing this patch set! Looking through patches like this one,
> > > I'm a bit concerned. With so many bio_add_page() callers it's difficult to
> > > get things right and not regress in the future. I'm wondering whether the
> > > things won't be less error-prone if we required that all page reference
> > > from bio are gup-like (not necessarily taken by GUP, if creator of the bio
> > > gets to struct page he needs via some other means (e.g. page cache lookup),
> > > he could just use get_gup_pin() helper we'd provide).  After all, a page
> > > reference in bio means that the page is pinned for the duration of IO and
> > > can be DMAed to/from so it even makes some sense to track the reference
> > > like that. Then bio_put() would just unconditionally do put_user_page() and
> > > we won't have to propagate the information in the bio.
> > > 
> > > Do you think this would be workable and easier?
> > 
> > Thinking again on this, i can drop that patch and just add a new
> > bio_add_page_from_gup() and then it would be much more obvious that
> > only very few places need to use that new version and they are mostly
> > obvious places. It is usualy GUP then right away add the pages to bio
> > or bvec.
> 
> Yes, that's another option. Probably second preferred by me after my own
> proposal ;)
> 
> > We can probably add documentation around GUP explaining that if you
> > want to build a bio or bvec from GUP you must pay attention to which
> > function you use.
> 
> Yes, although we both know how careful people are in reading
> documentation...

Yes i know this is a sad state, but if enough people see comments in
enough places we should end up with more eyes aware of the gotcha and
hopefully increase the likelyhood of catching any new user.

> 
> > Also pages going in a bio are not necessarily written too, they can
> > be use as source (writting to block) or as destination (reading from
> > block). So having all of them with refcount bias as GUP would muddy
> > the water somemore between pages we can no longer clean (ie GUPed)
> > and those that are just being use in regular read or write operation.
> 
> Why would the difference matter here?

Restricting GUP like status to GUP insure that we only ever back-off
because of GUP and not because of some innocuous I/O.

I am working on a v2 that just add a new variant to add page, but i
will have to run (x)fstest before re-posting.

I also have the scatterlist convertion mostly ready:

https://cgit.freedesktop.org/~glisse/linux/log/?h=gup-scatterlist-v1

After that GUP is mostly isolated to individual driver and much easier
to track and update.

Cheers,
Jérôme

