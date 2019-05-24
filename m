Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 034F2C282E3
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 16:59:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEFDD217D7
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 16:59:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="F+JKEfzZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEFDD217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F4F46B0269; Fri, 24 May 2019 12:59:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A6B16B026A; Fri, 24 May 2019 12:59:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 394AD6B026B; Fri, 24 May 2019 12:59:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0B1516B0269
	for <linux-mm@kvack.org>; Fri, 24 May 2019 12:59:21 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id k63so2015155oih.15
        for <linux-mm@kvack.org>; Fri, 24 May 2019 09:59:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=gEsvEvFjlwXN7UDcC7wBfcVN0ngYDlTviwk40lFh0VE=;
        b=PTecO+U+Qb+jCjKK+Iu9/r4+yLNzOoNa1ghVwQGnEfFiS/c1o9zsx6GFbPOH5tFpwP
         joqjO3TeofVw6FKyQGlQ/kC2//d3EAQGWY75Cd/bqhkDQab152WPbTrSX+kpHhtPBeGM
         4PBQ4B835t/ZEo/JX2uwoEHOG8BAGQoAmrMgC1jo4XNe+FioOyFyjpVd2+EOLFqzusDh
         +o529Tmrm0WQajnYsxg74qSwIRBSzMONwzekAlGD+x5gcYPBs+0YC1TRY9M3h9US9ZpZ
         qm/zAsblG7VdFdGalW+/sJy7gxNoedbXjcdw15XuA37SmTzeXjmxHCoPYdP+jLBOelqy
         z3dQ==
X-Gm-Message-State: APjAAAUF/h9jxVgBCw3x4WFEXUmuoLD68G70lAQwQrN3ChH4AjfKZ6+n
	3bg8rmqz8LBC1tTQNnAY6iUMeCnNlA7VW1txoeIMa6+NRFDL1DctJ0Is46iiP/hSnqoQM2UCex8
	pvlVqaNnVMLU5UbXbyUq+yv6pFBGXytj2n+GmCwkU8K0n4BPu2nHnuCRs+vIYPq0qRA==
X-Received: by 2002:aca:da45:: with SMTP id r66mr315464oig.24.1558717160431;
        Fri, 24 May 2019 09:59:20 -0700 (PDT)
X-Received: by 2002:aca:da45:: with SMTP id r66mr315393oig.24.1558717159679;
        Fri, 24 May 2019 09:59:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558717159; cv=none;
        d=google.com; s=arc-20160816;
        b=ubsD5ThiVvtJDmtkHsI1GxDzf6/LGyN3K4AN2lKWjw98uyqzuaT+rqAqG6kFYgBbHp
         6RPx4Vx5O6IzCvIhH8V+7sd4uLkYM2GCgKZXboY2b1ShR4sWg8PbAsFSR6akEZTKZfH0
         35QBqQJZhWXsDPsBwVzGhvzDf8BAGp3NAeBHv1ca9rR+2kFyRTxmJ6c0ljmFxPiJnRnG
         UMKu/T52LlXXKWPkSIo+WEDM2/pzchubPzmiB7Hw8erlqyvVsWpKUTAl0Lxy0l3tVrvx
         G5KIX8V5kvGg+ETuY/OWdgkaD1sJAKCG1Lm0WuRgYnosEqykIEO7Pi+gy/7lv5uFR5sg
         THZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=gEsvEvFjlwXN7UDcC7wBfcVN0ngYDlTviwk40lFh0VE=;
        b=zRG6TZIslwIACdp2qt0MQPA0zCf2j1/yc5YfNcyFcsFylB+oUpHhGHsW9tA1JxzTZv
         0f9BSaCAoNB6/ALO+KjlelfWspki1y1Uz5AvVWLabsMkaBZ5SCOjbfVphC9K0yDBmjPz
         JN2smsfJFRWk37WhTBznD3Q36dlUe1J3RwN0LRkOEI7mBg13GhOqR/EPJy3OKaeQtgOp
         e7MjlL7RCyMK8VPyZUV2i6vJ8C3irWjDQsmMppLTFSSitOAD3Fk91iX7bMIRzxcetc3x
         7EOfGXeIS6tUhffXC8Me3ml0Khh7hSBm+HAsqzRKsXXrZ/JW3A90YrcuT4vXUQQMjFgH
         U6oQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=F+JKEfzZ;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x2sor1407472otk.77.2019.05.24.09.59.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 09:59:19 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=F+JKEfzZ;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=gEsvEvFjlwXN7UDcC7wBfcVN0ngYDlTviwk40lFh0VE=;
        b=F+JKEfzZoisl55BG48UjSnmshBQgO9/0HkQVAr6Vyzhbpu8ZE5OYQdCLS2r7gg5Fet
         xsFTm/CY0rb9DvK2SU4u8wLrvEc5OpWNJcfbSDisSY2sMAlLWvWz1GZjZ2H3Uqu7oCCF
         IQMwHXKRFilGrj1cyLDjSwk6YUEP2rgdWgWYA=
X-Google-Smtp-Source: APXvYqyPbMvtr56mDew3jzxBkjA+50maDgvK6bd7zBN/VZAbXpM4qVtqYD8AqQh52rPXg2kktDPJwMkBLyw2j0YmSis=
X-Received: by 2002:a05:6830:16d2:: with SMTP id l18mr29769854otr.303.1558717159283;
 Fri, 24 May 2019 09:59:19 -0700 (PDT)
MIME-Version: 1.0
References: <20190523154149.GB12159@ziepe.ca> <20190523155207.GC5104@redhat.com>
 <20190523163429.GC12159@ziepe.ca> <20190523173302.GD5104@redhat.com>
 <20190523175546.GE12159@ziepe.ca> <20190523182458.GA3571@redhat.com>
 <20190523191038.GG12159@ziepe.ca> <20190524064051.GA28855@infradead.org>
 <20190524124455.GB16845@ziepe.ca> <20190524162709.GD21222@phenom.ffwll.local> <20190524165301.GD16845@ziepe.ca>
In-Reply-To: <20190524165301.GD16845@ziepe.ca>
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Date: Fri, 24 May 2019 18:59:07 +0200
Message-ID: <CAKMK7uHODeVX4DHdM-w2xkqCmN71MaQH1ZiRZcPN38Hhy0A-sQ@mail.gmail.com>
Subject: Re: RFC: Run a dedicated hmm.git for 5.3
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Dave Airlie <airlied@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, 
	Jerome Glisse <jglisse@redhat.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-rdma@vger.kernel.org, 
	Leon Romanovsky <leonro@mellanox.com>, Doug Ledford <dledford@redhat.com>, 
	Artemy Kovalyov <artemyko@mellanox.com>, Moni Shoua <monis@mellanox.com>, 
	Mike Marciniszyn <mike.marciniszyn@intel.com>, Kaike Wan <kaike.wan@intel.com>, 
	Dennis Dalessandro <dennis.dalessandro@intel.com>, Linux MM <linux-mm@kvack.org>, 
	dri-devel <dri-devel@lists.freedesktop.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 6:53 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Fri, May 24, 2019 at 06:27:09PM +0200, Daniel Vetter wrote:
> > Sure topic branch sounds fine, we do that all the time with various
> > subsystems all over. We have ready made scripts for topic branches and
> > applying pulls from all over, so we can even soak test everything in our
> > integration tree. In case there's conflicts or just to make sure
> > everything works, before we bake the topic branch into permanent history
> > (the main drm.git repo just can't be rebased, too much going on and too
> > many people involvd).
>
> We don't rebase rdma.git either for the same reasons and nor does
> netdev
>
> So the usual flow for a shared topic branch is also no-rebase -
> testing/etc needs to be done before things get applied to it.

Rebasing before it gets baked into any tree is still ok. And for
something like this we do need a test branch first, which might need a
fixup patch squashed in. On the drm side we have a drm-local
integration tree for this stuff (like linux-next, but without all the
other stuff that's not relevant for graphics). But yeah that's just
details, easy to figure out.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

