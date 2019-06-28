Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED67BC4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 17:10:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A44552083B
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 17:10:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="UnNjKOhD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A44552083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 436EB6B0003; Fri, 28 Jun 2019 13:10:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E7378E0003; Fri, 28 Jun 2019 13:10:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2AFD48E0002; Fri, 28 Jun 2019 13:10:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 005CB6B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 13:10:24 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id l7so3173711otj.16
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 10:10:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=qddKJwRb2cnRQ/FqFwYrdLbb8wYT8FUIpp0K6iYqKlE=;
        b=g2Gcdi59nBktNSWaJNUu52ic7ngV5p753/EygVbC2JYboFaJa8DT4MQCCs83vHdoqn
         S2G69U48feWhi7Cbt891nDBQKTS2wd4tgS2IEq9iV88ptZRJrzpdJ35ZNp7JSgTZmSS7
         k10eHHXuiZ7Jl7jki/pOHVvkGGkDZ4Zsyki+IniyT4hiG/p0vARn9hvCoNj32o+SvJjb
         RPwLHKdJXS4WofUQtZgc39DuqsUOdTb38o/nNfxdHHJ2aOJpPRR2R83HlITYn38hdOv+
         yyiQ+axZBlmrf+o7Sj7QrsWzNp/gZk9JDMqLurkLMmy6B5CU8w8YQkZyVF4BSNth5wEK
         raIQ==
X-Gm-Message-State: APjAAAV0Yv/d2jGkV3ojNrNBX6DQMlGGWsgJWJPYw447+fuFuDvNKky3
	r3R/skyXjGf5WoLbYfqoXAyDaJ91RoRBNMlYVPvf4Na1F9wLmOEI0DTM/0XPSbW+Cgo8F+EZjp6
	suI13rQnCF0aRa5kWERRTWN6gP20hUtL3iWq4Zg344K3eKscXaE7KQLw5wp/N4cNKLw==
X-Received: by 2002:a9d:4599:: with SMTP id x25mr8817012ote.219.1561741824599;
        Fri, 28 Jun 2019 10:10:24 -0700 (PDT)
X-Received: by 2002:a9d:4599:: with SMTP id x25mr8816974ote.219.1561741823984;
        Fri, 28 Jun 2019 10:10:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561741823; cv=none;
        d=google.com; s=arc-20160816;
        b=DJDGqaEY8qCW8DdJqFeJs22aswd0uy2wj/if28BzdYqfKGqV2Ga1WzHlCix/dlYwk7
         +YWuFJqjQ/x/MOKCKucSaLdhSCwvRPit4waqbL7jNEM2t9qAzosSuWoKlohr0sIFFDS8
         i6QrMd/61ETaOsrfqT39gV/PXtdgj2LhZ2Qd8DaDMjGYxT+0E3zD56+22bRwHZuKFkZb
         t42M0aA4iI3cDghi9OVPd7bJ9BLh5oOGoL02s1AH4VWzF8odXaRw61KOeujpsqjOZDkt
         AVyOsqJHriHs/6MAipGrJ6ZA7/J+PQWpcXQSSxqxk3EzzczYFLtrJb1oEvuJB7XvmtgT
         sc6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=qddKJwRb2cnRQ/FqFwYrdLbb8wYT8FUIpp0K6iYqKlE=;
        b=YWX9Jig0p43fnKu9BUTwS9bbAE9YXBnEM1QARkrxKYYCdwE3P5NZb4c2F0fO5IhwM1
         NRudcJZf/hJxadT8U1xfZ45GPgryxGledkX48kNjbI2gfmjXl1i5q9ZWb+TOA7P4BDI5
         nkUZiWVSIhUOR9fVBcgq6jD5p62Yj1kFKg6veNYrNcIBTMXWJnyMi0Bd87Fx+qE0V0xk
         5O06zxs9qpXHmJAQZ47ndFFHuHU7RPQ+fhH84IOJDRxphWS23V76d2DnJ7U9ZudWGtTn
         2da9Bt8kcnusl9JAkKxaqAi1JqZNSnKt56aSsOJudECdightGwla6gT8YP2nWW33iJnI
         M+WA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=UnNjKOhD;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y10sor1545779ote.136.2019.06.28.10.10.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Jun 2019 10:10:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=UnNjKOhD;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qddKJwRb2cnRQ/FqFwYrdLbb8wYT8FUIpp0K6iYqKlE=;
        b=UnNjKOhDg6JhNrF0ffG6CmZkREW7rw22qwft9R1X5G1Y463lGz745qKb1Cpvvz1sEl
         zLMecGaZR5ynK6GE8f7Ml3Ex/6APldy0qkkzEaBAkhcBHC+GivS+i5qPLFaYjJ5IxfYg
         Ix0HdpLCjBnqAz9m39WW1jharT+5YOHNU4YfrM8Ah8R+FrEe4b6pxjgCmbbqGgh3sqcB
         2VYQ2agoAbSDUL/b0JhCGJa4iHWfU4XJrqUvTFK2MBTunnoIIjMYIkxDb4U+7zHLnerF
         GdJi7b5u2PxxVuLRhm8fJldQb7CTmEb8WCfsS3hc/y78yAwulmlFeUWonzJRUQpwECvp
         g/gw==
X-Google-Smtp-Source: APXvYqziEb+tNzkKv17KjDDhi4UpD13NUfzT1yqPT34PEQGi0shpxcj8jFfercRLfAyVoLhNe8H8Bkb71Cnf2tL/n+k=
X-Received: by 2002:a9d:7a9a:: with SMTP id l26mr8124495otn.71.1561741823760;
 Fri, 28 Jun 2019 10:10:23 -0700 (PDT)
MIME-Version: 1.0
References: <20190626122724.13313-1-hch@lst.de> <20190626122724.13313-17-hch@lst.de>
 <20190628153827.GA5373@mellanox.com> <CAPcyv4joSiFMeYq=D08C-QZSkHz0kRpvRfseNQWrN34Rrm+S7g@mail.gmail.com>
 <20190628170219.GA3608@mellanox.com> <CAPcyv4ja9DVL2zuxuSup8x3VOT_dKAOS8uBQweE9R81vnYRNWg@mail.gmail.com>
In-Reply-To: <CAPcyv4ja9DVL2zuxuSup8x3VOT_dKAOS8uBQweE9R81vnYRNWg@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 28 Jun 2019 10:10:12 -0700
Message-ID: <CAPcyv4iWTe=vOXUqkr_CguFrFRqgA7hJSt4J0B3RpuP-Okz0Vw@mail.gmail.com>
Subject: Re: [PATCH 16/25] device-dax: use the dev_pagemap internal refcount
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Ben Skeggs <bskeggs@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>, 
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, 
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, 
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 10:08 AM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Fri, Jun 28, 2019 at 10:02 AM Jason Gunthorpe <jgg@mellanox.com> wrote:
> >
> > On Fri, Jun 28, 2019 at 09:27:44AM -0700, Dan Williams wrote:
> > > On Fri, Jun 28, 2019 at 8:39 AM Jason Gunthorpe <jgg@mellanox.com> wrote:
> > > >
> > > > On Wed, Jun 26, 2019 at 02:27:15PM +0200, Christoph Hellwig wrote:
> > > > > The functionality is identical to the one currently open coded in
> > > > > device-dax.
> > > > >
> > > > > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > > > > Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> > > > >  drivers/dax/dax-private.h |  4 ----
> > > > >  drivers/dax/device.c      | 43 ---------------------------------------
> > > > >  2 files changed, 47 deletions(-)
> > > >
> > > > DanW: I think this series has reached enough review, did you want
> > > > to ack/test any further?
> > > >
> > > > This needs to land in hmm.git soon to make the merge window.
> > >
> > > I was awaiting a decision about resolving the collision with Ira's
> > > patch before testing the final result again [1]. You can go ahead and
> > > add my reviewed-by for the series, but my tested-by should be on the
> > > final state of the series.
> >
> > The conflict looks OK to me, I think we can let Andrew and Linus
> > resolve it.
> >
>
> Andrew's tree effectively always rebases since it's a quilt series.
> I'd recommend pulling Ira's patch out of -mm and applying it with the
> rest of hmm reworks. Any other git tree I'd agree with just doing the
> late conflict resolution, but I'm not clear on what's the best
> practice when conflicting with -mm.

Regardless the patch is buggy. If you want to do the conflict
resolution it should be because the DEVICE_PUBLIC removal effectively
does the same fix otherwise we're knowingly leaving a broken point in
the history.

