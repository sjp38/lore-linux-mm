Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2944DC5B579
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:44:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE3EF21738
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:44:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="zI1Rfkj7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE3EF21738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BFD96B0003; Fri, 28 Jun 2019 14:44:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 770928E0007; Fri, 28 Jun 2019 14:44:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65F858E0002; Fri, 28 Jun 2019 14:44:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f77.google.com (mail-ot1-f77.google.com [209.85.210.77])
	by kanga.kvack.org (Postfix) with ESMTP id 3950B6B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 14:44:48 -0400 (EDT)
Received: by mail-ot1-f77.google.com with SMTP id q16so3312578otn.11
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 11:44:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=BNY+UkoJVrKxCjM2c24Xgrzfzfk/Z55i3p1E82IfUT4=;
        b=OmuQLQK3T4TJCIFo/lDGugNu3ujUwmlZtuhq6LndvG0k4lR+PaFgyEVQ4HXMGC81br
         yUJVwsFCR7+IUSTGqXvGYgs4xvHYAyLEh+2zDwuANKiDZwsjC7Zy52LN86RENrcDs0Fy
         h4wuG/jQvoRq921wJ6Iw73qBuaUvltqQ/EBCuI7UoQ6E/A7i1QlPw9PMzRBZMCT2hdk6
         OJCxxD2v59obW+1UTJqfR2SHss/GhdM8iMwg2oCfM6/OkWdZu15Sr7igvssZN31TuV4d
         +Nu2/4gCyBYsdyFNptovjyTURXM4puysOVDEEeJ6YmZZawJfaizi3yli6YQLFFETEGOc
         Rpyg==
X-Gm-Message-State: APjAAAVddHOnHGP9ogFsyl1h7lHo2gQ1yL24MhxpPM5PkwCA40HFtWqw
	gy1QpLxo9hgL6v23H4DCtJeryfj8twqov4ewojH+4evXS6hyh4lm9wYlhAiC1TQD26eQzmmyIOS
	hrIZqBACEhMc4Yp0TSztmiPQmaSQxhco4ufiOGNSon0LIPHBky0hME7IGDlJOEZzj1g==
X-Received: by 2002:aca:edc6:: with SMTP id l189mr2349652oih.86.1561747487784;
        Fri, 28 Jun 2019 11:44:47 -0700 (PDT)
X-Received: by 2002:aca:edc6:: with SMTP id l189mr2349620oih.86.1561747487024;
        Fri, 28 Jun 2019 11:44:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561747487; cv=none;
        d=google.com; s=arc-20160816;
        b=eDN1q4zfVcicGJZJnh/DEXESrqZp/QSZIaSk/lJBvOq8+u0iPXiBHrxueKewhlWo76
         bob2t/fzj7KlxBuMba5ctInkSprfMaJm1zJGHUUMdYWwlR1XUOS56Qhs40MR5gI1w1+1
         7Qdtun3QVAAGk5Vcu4Vv7nqVTJs4YeMx7qU42d1nhleYOGPsrnvRbmu2HxcKlsLkUGcQ
         c0h9DXT96UOA2gcq9kpDtJWeLe2W9oWdAW+xXTxVQRebIuPe/qM/6NWGNjOv6m0gAW37
         qootupqxsMGjffI+bLXyv9JkT+O2WC++7OU459rloDDwz5R8dSTIsDfqVHjF5UajOrGd
         MavQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=BNY+UkoJVrKxCjM2c24Xgrzfzfk/Z55i3p1E82IfUT4=;
        b=laUfZfRr22jc+7JIW1JSogAyvbMFJ9KdJybmkNhWJ3glpDttwYVgjXRio10d3l3BJc
         D5DyGpM9Obpz744F6qLljQr1ia5LlnQxDevbuXmVMRsJZxrnrI88QRvfWp2IJvUqm6Fb
         rI9y43uSpBQIlnw3w1o88hiK1vgNm4YNxtsGORymWFV+xl3yk5PB3zb966424cAlC8HI
         psisEeOff75cLgGjM5bDyRssQYDUIlnd36qx8tYw8NWsio8jDVCLxFTcHv3TP431+Mwu
         lRDR4p6HSQWWazplxPLkhnpDJiKXTenTQMs8R+YdtN9HtGpZHfi2Humgzv668hSpITaS
         Zqrg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=zI1Rfkj7;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l1sor1659257otk.47.2019.06.28.11.44.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Jun 2019 11:44:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=zI1Rfkj7;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=BNY+UkoJVrKxCjM2c24Xgrzfzfk/Z55i3p1E82IfUT4=;
        b=zI1Rfkj72TaacEJj7GZa9aQH2dQpodMnoVTwnXEaBlMSZNhY5OVVCjVG5znvL8YDvw
         /w4yi2CZ3bmDcg8+jo0W3xW8odrHcZ2aCHGJ87xs+2ltcljxDeJN66gvtxIzrVxNLxkg
         pL7hur4fQE0hdbPpJ33d47KRUWZSM8qnBIPWODQs6LDS5RSktDpzI29k0ILuZRejss34
         xnFlTPIYvocsrjjzZCQI/0Yj+GNH//C0I7LZJ/r3XYMiRT+Tq5iZQhNf2bG7bpRfCfUN
         VI7eLoWpW+vIxkXl125Fq7E2Z95KiI815ewg7Kq0wfihaAtAnAzS1E/XQAxSbE8m8Iyo
         kZOQ==
X-Google-Smtp-Source: APXvYqy1WcVZusxQT3gsMqR8FxlPuXMWtxZvhAO+zU3jLT7QJNrvbdWUjpng3sXAK8TgdSWU7HjEXIzdeabvXlDD8go=
X-Received: by 2002:a9d:7b48:: with SMTP id f8mr9063478oto.207.1561747486699;
 Fri, 28 Jun 2019 11:44:46 -0700 (PDT)
MIME-Version: 1.0
References: <20190626122724.13313-1-hch@lst.de> <20190626122724.13313-17-hch@lst.de>
 <20190628153827.GA5373@mellanox.com> <CAPcyv4joSiFMeYq=D08C-QZSkHz0kRpvRfseNQWrN34Rrm+S7g@mail.gmail.com>
 <20190628170219.GA3608@mellanox.com> <CAPcyv4ja9DVL2zuxuSup8x3VOT_dKAOS8uBQweE9R81vnYRNWg@mail.gmail.com>
 <CAPcyv4iWTe=vOXUqkr_CguFrFRqgA7hJSt4J0B3RpuP-Okz0Vw@mail.gmail.com> <20190628182922.GA15242@mellanox.com>
In-Reply-To: <20190628182922.GA15242@mellanox.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 28 Jun 2019 11:44:35 -0700
Message-ID: <CAPcyv4g+zk9pnLcj6Xvwh-svKM+w4hxfYGikcmuoBAFGCr-HAw@mail.gmail.com>
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

On Fri, Jun 28, 2019 at 11:29 AM Jason Gunthorpe <jgg@mellanox.com> wrote:
>
> On Fri, Jun 28, 2019 at 10:10:12AM -0700, Dan Williams wrote:
> > On Fri, Jun 28, 2019 at 10:08 AM Dan Williams <dan.j.williams@intel.com> wrote:
> > >
> > > On Fri, Jun 28, 2019 at 10:02 AM Jason Gunthorpe <jgg@mellanox.com> wrote:
> > > >
> > > > On Fri, Jun 28, 2019 at 09:27:44AM -0700, Dan Williams wrote:
> > > > > On Fri, Jun 28, 2019 at 8:39 AM Jason Gunthorpe <jgg@mellanox.com> wrote:
> > > > > >
> > > > > > On Wed, Jun 26, 2019 at 02:27:15PM +0200, Christoph Hellwig wrote:
> > > > > > > The functionality is identical to the one currently open coded in
> > > > > > > device-dax.
> > > > > > >
> > > > > > > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > > > > > > Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> > > > > > >  drivers/dax/dax-private.h |  4 ----
> > > > > > >  drivers/dax/device.c      | 43 ---------------------------------------
> > > > > > >  2 files changed, 47 deletions(-)
> > > > > >
> > > > > > DanW: I think this series has reached enough review, did you want
> > > > > > to ack/test any further?
> > > > > >
> > > > > > This needs to land in hmm.git soon to make the merge window.
> > > > >
> > > > > I was awaiting a decision about resolving the collision with Ira's
> > > > > patch before testing the final result again [1]. You can go ahead and
> > > > > add my reviewed-by for the series, but my tested-by should be on the
> > > > > final state of the series.
> > > >
> > > > The conflict looks OK to me, I think we can let Andrew and Linus
> > > > resolve it.
> > >
> > > Andrew's tree effectively always rebases since it's a quilt series.
> > > I'd recommend pulling Ira's patch out of -mm and applying it with the
> > > rest of hmm reworks. Any other git tree I'd agree with just doing the
> > > late conflict resolution, but I'm not clear on what's the best
> > > practice when conflicting with -mm.
>
> What happens depends on timing as things arrive to Linus. I promised
> to send hmm.git early, so I understand that Andrew will quilt rebase
> his tree to Linus's and fix the conflict in Ira's patch before he
> sends it.
>
> > Regardless the patch is buggy. If you want to do the conflict
> > resolution it should be because the DEVICE_PUBLIC removal effectively
> > does the same fix otherwise we're knowingly leaving a broken point in
> > the history.
>
> I'm not sure I understand your concern, is there something wrong with
> CH's series as it stands? hmm is a non-rebasing git tree, so as long
> as the series is correct *when I apply it* there is no broken history.
>
> I assumed the conflict resolution for Ira's patch was to simply take
> the deletion of the if block from CH's series - right?
>
> If we do need to take Ira's patch into hmm.git it will go after CH's
> series (and Ira will have to rebase/repost it), so I think there is
> nothing to do at this moment - unless you are saying there is a
> problem with the series in CH's git tree?

There is a problem with the series in CH's tree. It removes the
->page_free() callback from the release_pages() path because it goes
too far and removes the put_devmap_managed_page() call.

