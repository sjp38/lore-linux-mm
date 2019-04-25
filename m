Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8767DC4321A
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:26:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB09B20644
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:26:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB09B20644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E84DE6B0005; Thu, 25 Apr 2019 11:26:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0C2C6B000D; Thu, 25 Apr 2019 11:26:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD5046B000E; Thu, 25 Apr 2019 11:26:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6916B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 11:26:14 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id i203so15088oih.16
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 08:26:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=uFOCO1ItOKWZcZ5F0rbLdP7zIsx0CA40Iqoc/tiShvA=;
        b=NmqgFPcofwH6pFwysFM65Lj8yB1ObUHcGRStrq0Z9X7c06QfNGLCYmQa1d3LiGjPOc
         1zMK+Zpyk/ZUNRh8A/VYwRPsMw+G2Ro7lrGfEwZl03nGWO4N/CK3POOObYCDy/qdVb3/
         Hz1Il8cqmLPf0Ug0d+lCxkFyKBcn1+SlFhi4qRz5AVTPTrHlNxV9FIwWJkse9K+0zbLu
         lqaa+u5/hQfJR9ByuvlW/uo5so8/Cyfe9KY2rTAjUp1p87m0ksh2NFHAYYgI7+VOIJq8
         GjS/kykrBdsf62OzW7gSnD5zztj2df9D9XtP/N7m6lOlXoLKdJV0PCyI8/A6R3z9jein
         aeAQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=agruenba@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVDzqoZOnzRYUDX75MZHax6O1Z7+Y6Lr9WgkJFbiYHDJp23QlgN
	9XtXJJD/Lsz6iduPvHMPrqY9arEeuxclqLYEycik3zYCa13AIuO2HKGN09HEvbBK2heLCv2BnlM
	CNBbOfsFgxoimiDp/lPzmxyRbH5Vm3/5BbRpwV3I1ahVCfxkh+yODuHAy7/cD1bR3OA==
X-Received: by 2002:a9d:ec3:: with SMTP id 61mr25578916otj.43.1556205974260;
        Thu, 25 Apr 2019 08:26:14 -0700 (PDT)
X-Received: by 2002:a9d:ec3:: with SMTP id 61mr25578864otj.43.1556205973352;
        Thu, 25 Apr 2019 08:26:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556205973; cv=none;
        d=google.com; s=arc-20160816;
        b=I/yXWYUsPtyRrdf1OrRVElH4cePaqg++P1XzSEXfQdD013YLkOOUc9TtXaN53i/SP3
         77SAPApwAFQLIbThrmZdoZNVOqocbfA3e88Q8xdw7ZSnLVfulrHWdEHgpLvI9LX4jnO2
         R8d8UuuRVG7wmljRmE6HSRaw9ktYtLZzxrxuwBdxRKFfZmP3Cy3oreKbtz9YI53dznbv
         GGpC8EiePyEr2+UEDUywZgzt8Inbsupimdw0xZ2RWOI4IHZqYGDL0bck0xRX0rFP3cgs
         2FXl0i2p0CIKSs3Bvi/plkwwsU5gE8DMyvXvEu65uvgT9nFxZv660HJ1FjFALvolsIBL
         jVhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=uFOCO1ItOKWZcZ5F0rbLdP7zIsx0CA40Iqoc/tiShvA=;
        b=ufaeJuQo85YKRr02WupD3XBcHxqll7ZLPwzpLOPlRM+Pb3qbcSEE+pXghdjOGp2w4G
         ed2bRmq8nxxLF6Om9+B5xeisrP40UnIC8A8nB6a/eQi+mAadtLxtqH/nJNNqqmRcIhoc
         flaAUZgPmfJgMR6gUznxf97rzCs/D8QOaIdYIPfviAwL6/HJyH2w6wONTPBZkLV4tjcF
         9JdvpArpYNW5F0x0B19OpmMtwrcCEctgh0xPICYzJD1MR69yWDOctOQVL414/WiahoOZ
         Z/lASvsgPldhL8e18ZpbBzoI4qfelbecGaSxO/W8CbtuBl1c0jBG+h5uMoplnRtYDF8d
         +eBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w19sor10276709oiw.2.2019.04.25.08.26.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 08:26:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwZOItgZVqRXw5Yg2/10aRXjbFFLX1rDfapPu/j4WsnrJ0kcaQVVrzTwTwDgb3w4DqAQ+gGMMv1oCHLTJfrG1o=
X-Received: by 2002:a54:4f02:: with SMTP id e2mr3405871oiy.10.1556205972845;
 Thu, 25 Apr 2019 08:26:12 -0700 (PDT)
MIME-Version: 1.0
References: <20190424171804.4305-1-agruenba@redhat.com> <20190425083252.GB21215@quack2.suse.cz>
In-Reply-To: <20190425083252.GB21215@quack2.suse.cz>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Thu, 25 Apr 2019 17:26:01 +0200
Message-ID: <CAHc6FU73mVtQpoDSQVCH7ob+jN+G=Ri9xsw64AosRMbtO0-2Mg@mail.gmail.com>
Subject: Re: [PATCH 1/2] iomap: Add a page_prepare callback
To: Jan Kara <jack@suse.cz>
Cc: cluster-devel <cluster-devel@redhat.com>, Christoph Hellwig <hch@lst.de>, 
	Bob Peterson <rpeterso@redhat.com>, Dave Chinner <david@fromorbit.com>, 
	Ross Lagerwall <ross.lagerwall@citrix.com>, Mark Syms <Mark.Syms@citrix.com>, 
	=?UTF-8?B?RWR3aW4gVMO2csO2aw==?= <edvin.torok@citrix.com>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Apr 2019 at 10:32, Jan Kara <jack@suse.cz> wrote:
> On Wed 24-04-19 19:18:03, Andreas Gruenbacher wrote:
> > Add a page_prepare calback that's called before a page is written to.  This
> > will be used by gfs2 to start a transaction in page_prepare and end it in
> > page_done.  Other filesystems that implement data journaling will require the
> > same kind of mechanism.
> >
> > Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
>
> Thanks for the patch. Some comments below.
>
> > diff --git a/fs/iomap.c b/fs/iomap.c
> > index 97cb9d486a7d..abd9aa76dbd1 100644
> > --- a/fs/iomap.c
> > +++ b/fs/iomap.c
> > @@ -684,6 +684,10 @@ iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
> >               status = __block_write_begin_int(page, pos, len, NULL, iomap);
> >       else
> >               status = __iomap_write_begin(inode, pos, len, page, iomap);
> > +
> > +     if (likely(!status) && iomap->page_prepare)
> > +             status = iomap->page_prepare(inode, pos, len, page, iomap);
> > +
> >       if (unlikely(status)) {
> >               unlock_page(page);
> >               put_page(page);
>
> So this gets called after a page is locked. Is it OK for GFS2 to acquire
> sd_log_flush_lock under page lock? Because e.g. gfs2_write_jdata_pagevec()
> seems to acquire these locks the other way around so that could cause ABBA
> deadlocks?

Good catch, the callback indeed needs to happen earlier.

Thanks,
Andreas

