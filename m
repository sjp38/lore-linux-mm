Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7815C28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 12:45:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DC5224C0A
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 12:45:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="E/mvMDTE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DC5224C0A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 317366B0010; Tue,  4 Jun 2019 08:45:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EEEF6B026B; Tue,  4 Jun 2019 08:45:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DD216B026C; Tue,  4 Jun 2019 08:45:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id DAAA46B0010
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 08:45:45 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d19so13934801pls.1
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 05:45:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=SX1wXsAGfUFN70h44peTZcKIMqGr5ZE+ZDyQc1zQL5o=;
        b=DtTQU6YkjArfF/Z1v/5Yn+NzDlvO/3o0xIHDYIN1uo58oyCH8LDjQVevND3IzEJNiZ
         nJxDOGtrnLdSCh+htf15/9OwMKpGxlGMEtUwYOnqVuRggF48idzJ+xZuFs1e3nKl1vsC
         x2CuyIxFd2Cvw7HuKt1gvGXi4sdYc9ItjA9hceTFbGbawVNPtfFEhrhKRAijvMGqArv/
         F7IgLK/uTwCRdAm7yaLNg9lEuKvqSMoFRMVwJ3x5B41Y6xB5wCRsk7yQYTEbpFhpGdZO
         LMHeyZBrW3wJh2yf6F3880TMgRmlkiwvklpxA37TXUVlOm/Js++wht+9O4Wt6yfdrIf3
         wrmw==
X-Gm-Message-State: APjAAAXSBaC2t0g8XcGYU1brpMiKPyOjNO5fnL5Gnz3/MJFFoFtYMLGl
	0i2SbJJ7dF5oZKQaEjSeOA2ml3z4Mv/anwuR8MuL/pMuxQmSHa+pb6edtpv0ZyDFSNzHwTEsEnb
	7hUS1qaBoSciFQgQP2pz7jWD1bgausu3tCOwEMtDJXaGwarqOgQAgsaa8+6iobLqqsw==
X-Received: by 2002:a17:902:8648:: with SMTP id y8mr37491870plt.30.1559652345494;
        Tue, 04 Jun 2019 05:45:45 -0700 (PDT)
X-Received: by 2002:a17:902:8648:: with SMTP id y8mr37491786plt.30.1559652344775;
        Tue, 04 Jun 2019 05:45:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559652344; cv=none;
        d=google.com; s=arc-20160816;
        b=u771pXk4nhX4KzfVmslCWDUlj7t8DrLQOlRGkaXmkBIJpRhx4fN61vOt5sibfQlU7D
         QvAmb85IRtYE901/j0zcZiY1cK+yFVTKGTL0ODd+CtgImzXIRs5EG2A0sOqAVGsoCDGZ
         y1AYfD8sBREZz+A5H5A+S43im7/Hf891hBYdZbo50TT2k0CQVlg5Ty0pZcVNUGC0AelH
         Z7bmHIss4fcZm393fW4NgDakDbl/vBvv/elGMITdrJV6es+8br7RcXbCh1L4hir0a5Cb
         0/e8owOOL4Qv3swmmRsSvow+jmbqghUcTwZBu96O2aRtCWYd2dgm3v475l6wo2G3u0Fg
         Sv5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=SX1wXsAGfUFN70h44peTZcKIMqGr5ZE+ZDyQc1zQL5o=;
        b=Jz3SQ4bqBnYvzOeHR8YfD/mnaD0bkt1W3983hGIByzIswPpYyOLc6XSqdlCMhsOC8F
         FDQ1gx6BOn6fufiiP5ydZ6xOm+1GlQmu07ep7V3v5M6Y2GLjgP+GxOtzAXy/X3n0uXYl
         xtKX+rKS0F/kNWRBwT53i915k+O7KrQ+4I7r0vRQU4WNJavA6bqNLKJZ4BBCSDVPbBkg
         JfxgicJl9tn81DU+y+qmRnlbnyJjhjDyAj89vUysuhfqJtSvkEhzINyaEODHmf+LSh9a
         bEniQBLsIqwAjf+derlcA9fTMtuLeYQYRSoYxuYGONazi06Z/SHovXp9Uf1xLIH+ZL3I
         fzOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="E/mvMDTE";
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t10sor11077014pjv.1.2019.06.04.05.45.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 05:45:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="E/mvMDTE";
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=SX1wXsAGfUFN70h44peTZcKIMqGr5ZE+ZDyQc1zQL5o=;
        b=E/mvMDTExggwag20QOMbkhKP75T7Pk+0ZF0pcXUr5AaTNbmr23JwDn0UqrTqxdl5Je
         krdUOdiGs3h2/gebELEz8jqrOUeDCDUC2JEOV4V8ITgtQF1Ax7woXAnTfQ5gsE1sKCk5
         73PDFS4epP+6c23bo89e7xnteUzAo/q7k0cXafuB0juxjfStepuJz67jDdEHof0O7Ctq
         rV/upWmgoM7X7JZZHSCmqQbuzKuvYpbwxz+61v3PWpNyw0Pr5WN0hOaTsMwrna556VUE
         CzT1IMUxqM0c1X/8hXFuS/fU+Fq0VdvtOqB87v2sTCjXWa4vVxnoJGfUoTWZKlqF7TqV
         Xbpw==
X-Google-Smtp-Source: APXvYqzZt2kMUXJ9WHlwmRLt2vrbUVohOpQLy3RY96eqdlAIdJcx5KC4nxWy0iNPEMefwexAGDMOHmuMZCiVo+DqZfo=
X-Received: by 2002:a17:90a:2488:: with SMTP id i8mr28955959pje.123.1559652343964;
 Tue, 04 Jun 2019 05:45:43 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com> <c829f93b19ad6af1b13be8935ce29baa8e58518f.1559580831.git.andreyknvl@google.com>
 <20190603174619.GC11474@ziepe.ca> <CAAeHK+xy-dx4dLDLLj9dRzRNSVG9H5nDPPnjpYF38qKZNNCh_g@mail.gmail.com>
 <20190604122714.GA15385@ziepe.ca>
In-Reply-To: <20190604122714.GA15385@ziepe.ca>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 4 Jun 2019 14:45:32 +0200
Message-ID: <CAAeHK+xyqwuJyviGhvU7L1wPZQF7Mf9g2vgKSsYmML3fV6NrXg@mail.gmail.com>
Subject: Re: [PATCH v16 12/16] IB, arm64: untag user pointers in ib_uverbs_(re)reg_mr()
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Alexander Deucher <Alexander.Deucher@amd.com>, Christian Koenig <Christian.Koenig@amd.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, 
	Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 4, 2019 at 2:27 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Tue, Jun 04, 2019 at 02:18:19PM +0200, Andrey Konovalov wrote:
> > On Mon, Jun 3, 2019 at 7:46 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > >
> > > On Mon, Jun 03, 2019 at 06:55:14PM +0200, Andrey Konovalov wrote:
> > > > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > > > pass tagged user pointers (with the top byte set to something else other
> > > > than 0x00) as syscall arguments.
> > > >
> > > > ib_uverbs_(re)reg_mr() use provided user pointers for vma lookups (through
> > > > e.g. mlx4_get_umem_mr()), which can only by done with untagged pointers.
> > > >
> > > > Untag user pointers in these functions.
> > > >
> > > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > > >  drivers/infiniband/core/uverbs_cmd.c | 4 ++++
> > > >  1 file changed, 4 insertions(+)
> > > >
> > > > diff --git a/drivers/infiniband/core/uverbs_cmd.c b/drivers/infiniband/core/uverbs_cmd.c
> > > > index 5a3a1780ceea..f88ee733e617 100644
> > > > +++ b/drivers/infiniband/core/uverbs_cmd.c
> > > > @@ -709,6 +709,8 @@ static int ib_uverbs_reg_mr(struct uverbs_attr_bundle *attrs)
> > > >       if (ret)
> > > >               return ret;
> > > >
> > > > +     cmd.start = untagged_addr(cmd.start);
> > > > +
> > > >       if ((cmd.start & ~PAGE_MASK) != (cmd.hca_va & ~PAGE_MASK))
> > > >               return -EINVAL;
> > >
> > > I feel like we shouldn't thave to do this here, surely the cmd.start
> > > should flow unmodified to get_user_pages, and gup should untag it?
> > >
> > > ie, this sort of direction for the IB code (this would be a giant
> > > patch, so I didn't have time to write it all, but I think it is much
> > > saner):
> >
> > Hi Jason,
> >
> > ib_uverbs_reg_mr() passes cmd.start to mlx4_get_umem_mr(), which calls
> > find_vma(), which only accepts untagged addresses. Could you explain
> > how your patch helps?
>
> That mlx4 is just a 'weird duck', it is not the normal flow, and I
> don't think the core code should be making special consideration for
> it.

How do you think we should do untagging (or something else) to deal
with this 'weird duck' case?

>
> Jason

