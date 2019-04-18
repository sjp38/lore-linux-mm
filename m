Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56632C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 18:03:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E238B218A1
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 18:03:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="Pi+d5jcD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E238B218A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43ABF6B0005; Thu, 18 Apr 2019 14:03:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C0AE6B0006; Thu, 18 Apr 2019 14:03:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 288786B0007; Thu, 18 Apr 2019 14:03:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id E98A56B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 14:03:30 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id d38so1476189otb.22
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 11:03:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=mE/aKnKM07J0Pu0N2LzFy/Q/VzfI3mw7PzAs98ACEDg=;
        b=HyRiV2ypowNZrG36e6meRph0rndE3a4hpQdNo1FKa891Ey9M5a+N+CVrZKCtdvSqR7
         SK5rmxMrP2CDEc/L6fIYmcTmGoN1jkRqQEBPDkfkW0V/eHNl4dndcgh5BnjRGdupFvuD
         xtQDG/LiXXNK4Clbkhrf64axzI5kf17Q+EdG3f0ZikJ7JmfLHYIfJsvefuDCT92vMicG
         V0wKLXhP1JtFLWNNAdxi8NqStnkB+t1/ac/TXyth8OVOrIyMq/sM47liB4NQp0m5p5WS
         y82+pOQP3FHVyTBn5dWlE7RQ8a+O17xkSrpcs/3wOKh1dvbuq8bV8kAYvn4LQr2mXPsn
         ZwTA==
X-Gm-Message-State: APjAAAXHVC6XuakgxaAGyFGxBAx0jON6neziWzp2/rJFlhGsv2UfTgdY
	T/XB+aQuaNN/lqk2Kkk9636CtBrw4ZlWi31Xwd6A2Qp9lJ1v3UEmTKBhLJyZgFWtsT/hrpS4L2g
	zAYsUBDE3TWAzmHwW0OQKf/EtgqINUYWMnQwJhqGhF06l4FAW2nM7GVnRs08Tixz/MA==
X-Received: by 2002:aca:c154:: with SMTP id r81mr2618990oif.160.1555610610404;
        Thu, 18 Apr 2019 11:03:30 -0700 (PDT)
X-Received: by 2002:aca:c154:: with SMTP id r81mr2618922oif.160.1555610609310;
        Thu, 18 Apr 2019 11:03:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555610609; cv=none;
        d=google.com; s=arc-20160816;
        b=mEp7wQg58gTaL3fqoS+Se5T8o1DfO+G9wbp+LkUWD1fH6wjWrvwBSMC7ZiJ12xiHh9
         cDUAoZpFUJlvNZ/pnpBl8sDe+BsbRsAkbBbLYNmqtYqJSTM6abuPokbewr5t6eyTqpjm
         Cxt9ybFwH1raCUzt7Xb0HRKc2NHticpgpTzs9h5Q9frK2diPOD+5rRvBUsKTupXLWiJM
         Ot5kKMol42H83A2aOwXrRpdKdVQTvCFU6GMmrzTTnwV2FsyQg4XrPRyepKUet+Y9kjVR
         9U9Ah5NKuGivc/0JKKXjcN3CJPoy44rt3yVEGMxj77GQ0DGelbZldhW5CgIt1zhGniYq
         37uQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=mE/aKnKM07J0Pu0N2LzFy/Q/VzfI3mw7PzAs98ACEDg=;
        b=rh2UT8j2EA+izGAhCqNqS7FPq1VK5VmrKeiI1RJ57LluY6X5PP6vJJNDQCSy7mrUMQ
         /uv4VgiHorxmLN2svQBjEV4Y23Jgc+6Nh3O/o21/YWLCbudDQw3EALBvCuU3axMRuBYR
         tzZKB/QS8tr1iuFWhN9cEBAttuTZ7njos3Q4pSQ17BJcTxwnBzcNDFgp7TvrpxQlkY/C
         YnrG/bZmZcWaiWpPrFCL6rxy2THZuJWu656X1lcRKwIsaU6eSKZ0PpO9+ip8f6BxMTdR
         FenFICMUjp5MpWAXZR1l11dJTPbgscSzkLTnlxqF1dj2st1keMkvvXsJPgd2CoO9qbxU
         iNgA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Pi+d5jcD;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x3sor1264778otb.164.2019.04.18.11.03.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Apr 2019 11:03:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Pi+d5jcD;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=mE/aKnKM07J0Pu0N2LzFy/Q/VzfI3mw7PzAs98ACEDg=;
        b=Pi+d5jcDSHcAWLBXnKRmKYoO1iabyeSTCoyHSoTOFhkKyRX8hG7BC/wJxV3ZiaaTHg
         gqUwMreZZXfYu6yxSY7fNS7+AsxCZBLdai0E/tgX6dakt1Vg7YlSVn+Kd4PHdtbWvxpF
         TSE8bBAh2jy9I7OZP0MbdtJ8NCo7BAmZBkwOAOr+qoYXbL1jhwkEAvy/iZ54jbMkgpV4
         rBamBDXT4Dgdgo3L1ust6B79WCBZ4JuMx34GdC915WYRLYth1m5lgCn2Db3Xc95wXzsu
         UUa6wvLnoXjP1x2Yymhffr1xJqHpgJqMCmXfQUe0Pi5RFu42SttM5KWp/xKnctdKTUYZ
         OPrg==
X-Google-Smtp-Source: APXvYqx4tO5lZ9wTPWxuvQfWFmrPptbNCa+xEdfDv7AiLwjobEZcCsrg/NKC/qicGh9+cjnVUqPevHsybbd7Ng30nHg=
X-Received: by 2002:a9d:27e3:: with SMTP id c90mr60419177otb.214.1555610608522;
 Thu, 18 Apr 2019 11:03:28 -0700 (PDT)
MIME-Version: 1.0
References: <20190411210834.4105-1-jglisse@redhat.com> <2c124cc4-b97e-ee28-2926-305bc6bc74bd@plexistor.com>
 <20190416185922.GA12818@kmo-pixel> <CAPcyv4jLrQ6evLAJzsASh=H6Tzx8E1oiF+YR3L2fOpbZYNUWGg@mail.gmail.com>
 <20190416194936.GD21526@redhat.com> <CAPcyv4i-YHH+dH8za1i1aMcHzQXfovVSrRFp_nfa-KYN-XhAvw@mail.gmail.com>
 <20190417222858.GA4146@redhat.com> <20190418104205.GA28541@quack2.suse.cz>
In-Reply-To: <20190418104205.GA28541@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 18 Apr 2019 11:03:16 -0700
Message-ID: <CAPcyv4iSyM2r5fv=p4B=h=1sR8Zok3gxb1BVsQOy6FHmQtjGCg@mail.gmail.com>
Subject: Re: [PATCH v1 00/15] Keep track of GUPed pages in fs and block
To: Jan Kara <jack@suse.cz>
Cc: Jerome Glisse <jglisse@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, 
	Boaz Harrosh <boaz@plexistor.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, 
	Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Thumshirn <jthumshirn@suse.de>, 
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>, Ming Lei <ming.lei@redhat.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Matthew Wilcox <willy@infradead.org>, Steve French <sfrench@samba.org>, 
	linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, 
	Yan Zheng <zyan@redhat.com>, Sage Weil <sage@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, 
	Alex Elder <elder@kernel.org>, ceph-devel@vger.kernel.org, 
	Eric Van Hensbergen <ericvh@gmail.com>, Latchesar Ionkov <lucho@ionkov.net>, Mike Marshall <hubcap@omnibond.com>, 
	Martin Brandenburg <martin@omnibond.com>, devel@lists.orangefs.org, 
	Dominique Martinet <asmadeus@codewreck.org>, v9fs-developer@lists.sourceforge.net, 
	Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, 
	=?UTF-8?Q?Ernesto_A=2E_Fern=C3=A1ndez?= <ernesto.mnd.fernandez@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 3:42 AM Jan Kara <jack@suse.cz> wrote:
> > Except that this solution (biasing everyone in bio) would _more complex_
> > it is only conceptualy appealing. The changes are on the other hand much
> > deeper and much riskier but you decided to ignore that and focus on some-
> > thing i was just giving as an example.
>
> Yeah, after going and reading several places like fs/iomap.c, fs/mpage.c,
> drivers/md/dm-io.c I agree with you. The places that are not doing direct
> IO usually just don't hold any page reference that could be directly
> attributed to the bio (and they don't drop it when bio finishes). They
> rather use other means (like PageLocked, PageWriteback) to make sure the
> page stays alive so mandating gup-pin reference for all pages attached to a
> bio would require a lot of reworking of places that are not related to our
> problem and currently work just fine. So I withdraw my suggestion. Nice in
> theory, too much work in practice ;).

Is it though? We already have BIO_NO_PAGE_REF, so it seems it would be
a useful cleanup to have all locations that don't participate in page
references use that existing flag and then teach all other locations
to use gup-pinned pages.

