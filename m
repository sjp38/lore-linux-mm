Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCD65C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 22:54:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BD0D20896
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 22:54:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="TDdvtQWH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BD0D20896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E676E6B000D; Wed, 12 Jun 2019 18:54:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E16F56B000E; Wed, 12 Jun 2019 18:54:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDF3D6B0010; Wed, 12 Jun 2019 18:54:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id A4D896B000D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 18:54:32 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id n19so8412932ota.14
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:54:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Bdl55fUd9OUfrgwift11oOf2CuCyNYJsaQ/2pJqMiX8=;
        b=hLoBxHN87nAQkrhXJQAOjCLxDRQlkXB2QIMtUNbEhrwJiYNG+QwNLDhZLjOsE9jnQe
         HcrVyPcDMDCtCoe5PhjUjRd7A8Mwp5vp/LHZc+vQtTZkUUt3myKq7S/OEAqe/aPdVbTQ
         h0yeLJKrUTa6MKpWkU//PHfTABbqBrvKZEFcRLADgJsuZLWtUvdYnfxvaIjgXlw60xpZ
         avACdnAbVnK39afpHemPbXen9Km6QwH8WRquRp29jYr0bxQG0MTELPOOSQpD2RPy68+X
         RpKZLWcJR175Hvjy+tXk4BPAntox3oqBHEr8O55lYwp0HTM3Sob+6QYijRM+Tsg9BrsK
         fntg==
X-Gm-Message-State: APjAAAU2brMXyxiZNaOvLUBDWwWcln3k0YYDnSkITvKL9/3iLMoJtEdT
	2b5F6oWgd9T3gznC3ozd6/Cyeb4+PzK8bBj/s3BigRr0bKK+p21hDMGpNXxzDuUyQENJRFkBU7a
	v1QDUq/w1uPqIj2cEex4zDU7H1tGC6PCwELn8OPvROklmfqTXenScZi7zrxYk4qyIdg==
X-Received: by 2002:aca:d552:: with SMTP id m79mr1005608oig.3.1560380072247;
        Wed, 12 Jun 2019 15:54:32 -0700 (PDT)
X-Received: by 2002:aca:d552:: with SMTP id m79mr1005575oig.3.1560380071279;
        Wed, 12 Jun 2019 15:54:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560380071; cv=none;
        d=google.com; s=arc-20160816;
        b=gRAla4SCKUZUmBtVWal7gqU+0h197wXdCo6Y2bcIzYpJjcxP8Rlo5a6adE7s/P2rUD
         K9R8Xz7flGvrH1s66+lRtXqo6xJMyCjjXEJ6LtWbpzlhaN64z14GFKbHFe3QOeJf4Qs0
         uBMIerLsvwoH9UV72yqwb7IZolkDcTfy4CZmimD/SOXZMYseQhRRnNHA3NVWLghi3IIx
         dTpDBTW5J72Z/7rlc3BPDyM2r4CsSIW6fCvYiiN6MGuAJ/mZ7sjf7OiXLHXW/x5ngwC1
         +wqL8/0Qz1UMkP6m9WRNX8Pg3HWRnL9MOMGyrW05LiDk7skXJhCZ1/ecEf4NM3874NUu
         hmwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Bdl55fUd9OUfrgwift11oOf2CuCyNYJsaQ/2pJqMiX8=;
        b=nbw7lpjRfQUBY7FDfY/3PpM7YGzwdJk7YPgU1o+IYF3cjW+C9lJK4HzTASo9eZJiOL
         tE+uE/rWd6n/0mQ6fO+noogPCZ4D0YYvw3K5iI+wADO1laDM+PvIliBmUYF/lSAlJg6O
         TlTU5Fts0WeXClknB8sZXNuklBLU2mv6Erf6LkjagUHF5cIvyq04pXjAQhLNrGmC1rFY
         fKnzCRNbcC9N1NQd+IUpVCCol4Mx/ejr07PT+/Nsk1mQ6mjdNFFWw/8tna5+vR8GALze
         L/zzFa6BNz5rlzRk5gXuH+J3QcqVCzFZw6mY07GAk1T7D0+BeOsk1RVzlBMWss+URB1L
         T9Zg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=TDdvtQWH;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k22sor620674oib.65.2019.06.12.15.54.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 15:54:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=TDdvtQWH;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Bdl55fUd9OUfrgwift11oOf2CuCyNYJsaQ/2pJqMiX8=;
        b=TDdvtQWHOWeWDi3ya4dvSfYwmH6uUyvwLhp+t3pFlfqs6fcjGtEhlIbrtaKLrkMypK
         3r/atyNnqdAwbVWCWb36k5W6rbANKEH05Zq/fvFhnbIMRVlG9MdVxZaKROsDcGxg5fsD
         xcJSZa1UHKrohPWZiLJYsIJPKe+yEk1iAWtIe7q0UI4HOt2ZVPruDMChcmE8v+JbGquZ
         zGgFJZ9TyYotfWPDbv2PbDOKp3zl5e1hmsd/9uCbz4MhdDtoN1em2rz6Z08xQRdK7PRW
         lz+4KI6GRAFXU1BeCj1XGUxgC4Zn//as5jdjihKbG8sNr4JMjs+LswufzA5pgK5q8yPQ
         G1VQ==
X-Google-Smtp-Source: APXvYqw1FP7LujPNDjxfvPPdcXEEv7BpZu0ZvkIEpv2DDnh9DqFnd/FGbL1Cg5TXidb34VUmG/D3LrKYdijZM5Cv9VY=
X-Received: by 2002:aca:ec82:: with SMTP id k124mr1023354oih.73.1560380070925;
 Wed, 12 Jun 2019 15:54:30 -0700 (PDT)
MIME-Version: 1.0
References: <20190606104203.GF7433@quack2.suse.cz> <20190606195114.GA30714@ziepe.ca>
 <20190606222228.GB11698@iweiny-DESK2.sc.intel.com> <20190607103636.GA12765@quack2.suse.cz>
 <20190607121729.GA14802@ziepe.ca> <20190607145213.GB14559@iweiny-DESK2.sc.intel.com>
 <20190612102917.GB14578@quack2.suse.cz> <20190612114721.GB3876@ziepe.ca>
 <20190612120907.GC14578@quack2.suse.cz> <20190612191421.GM3876@ziepe.ca> <20190612221336.GA27080@iweiny-DESK2.sc.intel.com>
In-Reply-To: <20190612221336.GA27080@iweiny-DESK2.sc.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Jun 2019 15:54:19 -0700
Message-ID: <CAPcyv4gkksnceCV-p70hkxAyEPJWFvpMezJA1rEj6TEhKAJ7qQ@mail.gmail.com>
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
To: Ira Weiny <ira.weiny@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Jan Kara <jack@suse.cz>, "Theodore Ts'o" <tytso@mit.edu>, 
	Jeff Layton <jlayton@kernel.org>, Dave Chinner <david@fromorbit.com>, 
	Matthew Wilcox <willy@infradead.org>, linux-xfs <linux-xfs@vger.kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, John Hubbard <jhubbard@nvidia.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	linux-ext4 <linux-ext4@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 3:12 PM Ira Weiny <ira.weiny@intel.com> wrote:
>
> On Wed, Jun 12, 2019 at 04:14:21PM -0300, Jason Gunthorpe wrote:
> > On Wed, Jun 12, 2019 at 02:09:07PM +0200, Jan Kara wrote:
> > > On Wed 12-06-19 08:47:21, Jason Gunthorpe wrote:
> > > > On Wed, Jun 12, 2019 at 12:29:17PM +0200, Jan Kara wrote:
> > > >
> > > > > > > The main objection to the current ODP & DAX solution is that very
> > > > > > > little HW can actually implement it, having the alternative still
> > > > > > > require HW support doesn't seem like progress.
> > > > > > >
> > > > > > > I think we will eventually start seein some HW be able to do this
> > > > > > > invalidation, but it won't be universal, and I'd rather leave it
> > > > > > > optional, for recovery from truely catastrophic errors (ie my DAX is
> > > > > > > on fire, I need to unplug it).
> > > > > >
> > > > > > Agreed.  I think software wise there is not much some of the devices can do
> > > > > > with such an "invalidate".
> > > > >
> > > > > So out of curiosity: What does RDMA driver do when userspace just closes
> > > > > the file pointing to RDMA object? It has to handle that somehow by aborting
> > > > > everything that's going on... And I wanted similar behavior here.
> > > >
> > > > It aborts *everything* connected to that file descriptor. Destroying
> > > > everything avoids creating inconsistencies that destroying a subset
> > > > would create.
> > > >
> > > > What has been talked about for lease break is not destroying anything
> > > > but very selectively saying that one memory region linked to the GUP
> > > > is no longer functional.
> > >
> > > OK, so what I had in mind was that if RDMA app doesn't play by the rules
> > > and closes the file with existing pins (and thus layout lease) we would
> > > force it to abort everything. Yes, it is disruptive but then the app didn't
> > > obey the rule that it has to maintain file lease while holding pins. Thus
> > > such situation should never happen unless the app is malicious / buggy.
> >
> > We do have the infrastructure to completely revoke the entire
> > *content* of a FD (this is called device disassociate). It is
> > basically close without the app doing close. But again it only works
> > with some drivers. However, this is more likely something a driver
> > could support without a HW change though.
> >
> > It is quite destructive as it forcibly kills everything RDMA related
> > the process(es) are doing, but it is less violent than SIGKILL, and
> > there is perhaps a way for the app to recover from this, if it is
> > coded for it.
>
> I don't think many are...  I think most would effectively be "killed" if this
> happened to them.
>
> >
> > My preference would be to avoid this scenario, but if it is really
> > necessary, we could probably build it with some work.
> >
> > The only case we use it today is forced HW hot unplug, so it is rarely
> > used and only for an 'emergency' like use case.
>
> I'd really like to avoid this as well.  I think it will be very confusing for
> RDMA apps to have their context suddenly be invalid.  I think if we have a way
> for admins to ID who is pinning a file the admin can take more appropriate
> action on those processes.   Up to and including killing the process.

Can RDMA context invalidation, "device disassociate", be inflicted on
a process from the outside? Identifying the pid of a pin holder only
leaves SIGKILL of the entire process as the remediation for revoking a
pin, and I assume admins would use the finer grained invalidation
where it was available.

