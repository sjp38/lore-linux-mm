Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 249FFC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 17:07:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D198D20872
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 17:07:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D198D20872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 863C26B026A; Tue, 16 Apr 2019 13:07:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8135E6B026B; Tue, 16 Apr 2019 13:07:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 729AE6B026C; Tue, 16 Apr 2019 13:07:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4F6EF6B026A
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 13:07:33 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id z34so20047757qtz.14
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 10:07:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=e1Ppl8twF+5kfyw/w1yLnVnhkqL3hBef2gCfWOpWUwM=;
        b=Tw1a8/2mxaBIit6lJoscnovWFeWIgQLlnR412ukDAH5v0hILyZj71cwQRGzT3aZdue
         Fboqvud11DaNvOYmxFjEFvWRbLio9MqtWJ/HLSJzAX2/z1dwy+VvWHMDkbE/3APIP/6u
         RICxZEHRqnrTcUujwaMtdpSpCVelQxQS34gTc1rNfWXTR1ZZbiWMWRfSNEwHJRHuHxBg
         TJqiYS7L6I4V8xUMftlxkVCtLF6DlFIr6D2S5CbslRdO8FRT3cwanKIplhib8UDOYxki
         8osnxdokvPStBeoIEZCdcl7mpus+dZQh9PXydkKgcpbn8xjQRuc7ARsnqPY/saPRIMAV
         mUmA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUkuPdXxzLgbKs7YwF+L3NTIuErtuC4KhKb5QWLd4P4GezGu7sy
	PdZv34vn8sdelV4PZ2xpykBTPKhL4JK9u4tNDC5L6Rr9BtF9yHzPfNVIHPWLhekOtYhWTNM4Fd2
	aPY7+jBrcwtXJE5m/YgpYyvOV3q0BjnWcbaxbzO8JtgvZoQvX/JECV9lWf5aYAWjHqA==
X-Received: by 2002:ae9:e40f:: with SMTP id q15mr62925794qkc.301.1555434453083;
        Tue, 16 Apr 2019 10:07:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhRsdZHtcrxXsrQ/ya584gPJmen6HEHWgzvYnkyXGro6FET2t5q852N7tWjmxsvD+ILImW
X-Received: by 2002:ae9:e40f:: with SMTP id q15mr62925565qkc.301.1555434450485;
        Tue, 16 Apr 2019 10:07:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555434450; cv=none;
        d=google.com; s=arc-20160816;
        b=hvaui3xB/G/o0p4Rj9AzUsQFC57XhNsahkKAHS82lgJamw7fXNiFpraojtf9LAbbz8
         OEQko+6LSeTGSheA5MUm6P4oP1ycoCiFuq7GJXVXASJvnzU5YsOlB2i/+x7pWn/EMhaW
         DfCeHiOZVLrwcWcwTLTu/2rqlMBu2r65FkVHRKnS8rifl4nf8TmRvvivBaVxSqCSkoCC
         U73I6+NQIrXDtmAK4xwg8iwuzIn8euPMpvqBWuV/PXU8Xua2ojrWPopvFu4U+fjKHKYb
         ciKL8rUPvxVt2+skHBwJbFuVAJVfJCK3bMBGKqx7eCKv/Nl6tQp4M7TjiYg3PHe0TpWL
         PdVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=e1Ppl8twF+5kfyw/w1yLnVnhkqL3hBef2gCfWOpWUwM=;
        b=WX2mrgCfBjynFWfyj+u5F8wNq0p3FuETvHcfmAud7pa0sOoILQIkk0LFzbJY7BTjpT
         GiW0/Rk0I7ebLjDQGnLAOlZSItllNr4c2uNX+GPVF/Cu31su0TiMYM89LUhxGS2n9AoR
         fcyzzZ3716anHVc8cPqBDWa6RbColSw3s2MQ0JFvGeT+z2GtZLRmy//fNPgxdEFHnVFE
         fEbyDijH2obewdDu0bnZwA397JulcMBwRP4XetKiY4288NVghQ2diJiY4CtK9xUKqkgA
         PYoTxGrf5hbPxOH88xr9Fi6oVt7sMLUDhB4NDQgbOfNHafxB5h0UXLjc0DVha0PStQxE
         y3Tw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z16si2390664qtb.329.2019.04.16.10.07.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 10:07:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6F60F88317;
	Tue, 16 Apr 2019 17:07:29 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D0B2419C71;
	Tue, 16 Apr 2019 17:07:25 +0000 (UTC)
Date: Tue, 16 Apr 2019 13:07:24 -0400
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
Message-ID: <20190416170723.GC3254@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <20190411210834.4105-11-jglisse@redhat.com>
 <20190415145952.GE13684@quack2.suse.cz>
 <20190415152433.GB3436@redhat.com>
 <20190416164658.GB17148@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190416164658.GB17148@quack2.suse.cz>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Tue, 16 Apr 2019 17:07:29 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 06:46:58PM +0200, Jan Kara wrote:
> On Mon 15-04-19 11:24:33, Jerome Glisse wrote:
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
> > It might be workable but i am not sure it is any simpler. bio_add_page*()
> > does not take page reference it is up to the caller to take the proper
> > page reference so the complexity would be push there (just in a different
> > place) so i don't think it would be any simpler. This means that we would
> > have to update more code than this patchset does.
> 
> I agree that the amount of work in this patch set is about the same
> (although you don't have to pass the information about reference type in
> the biovec so you save the complexities there). But for the future the
> rule that "bio references must be gup-pins" is IMO easier to grasp for
> developers and you can reasonably assert it in bio_add_page().
> 
> > This present patch is just a coccinelle semantic patch and even if it
> > is scary to see that many call site, they are not that many that need
> > to worry about the GUP parameter and they all are in patch 11, 12, 13
> > and 14.
> > 
> > So i believe this patchset is simpler than converting everyone to take
> > a GUP like page reference. Also doing so means we loose the information
> > about GUP kind of defeat the purpose. So i believe it would be better
> > to limit special reference to GUP only pages.
> 
> So what's the difference whether the page reference has been acquired via
> GUP or via some other means? I don't think that really matters. If say
> infiniband introduced new ioctl() that takes file descriptor, offset, and
> length and just takes pages from page cache and attaches them to their RDMA
> scatter-gather lists, then they'd need to use 'pin' references anyway...
> 
> Then why do we work on differentiating between GUP pins and other page
> references?  Because it matters what the reference is going to be used for
> and what is it's lifetime. And generally GUP references are used to do IO
> to/from page and may even be controlled by userspace so that's why we need
> to make them different. But in principle the 'gup-pin' reference is not about
> the fact that the reference has been obtained from GUP but about the fact
> that it is used to do IO. Hence I think that the rule "bio references must
> be gup-pins" makes some sense.

It will break things like page protection i am working on (KSM for file
back page). Pages can go through bio for mundane reasons (crypto, network,
gpu, ...) that have nothing to do with I/O for fs and do not have to block
any of the fs operation. If we GUP bias all those pages then we will
effectively make the situation worse in that pages will have a high likely-
hood to always look GUPed while it is just going through some bio for one
of those mundane reasons (and page is not being written to just use as
a source).

I understand why conceptualy it looks appealing but we would be loosing
information here. I really want to be able to determine if a page is GUPed
or not. If we GUP bias everyone in bio then we loose that.

Also i want to point out that the complexity of biasing all page in bio
are much bigger than this patchset it will require changes to all call
site of bio_add_page*() at very least.

Cheers,
Jérôme

