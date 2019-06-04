Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BD0EC28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 13:09:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D7A223EAB
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 13:09:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Lkz8dpKP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D7A223EAB
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B69666B0010; Tue,  4 Jun 2019 09:09:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B41E16B026B; Tue,  4 Jun 2019 09:09:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0A1C6B026C; Tue,  4 Jun 2019 09:09:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 66FBD6B0010
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 09:09:39 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 5so16093292pff.11
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 06:09:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=zBLpk28DZpa5o94Q/0/LiLBGCkVoEs9cAD1KugSM2WY=;
        b=c05VQA49fY8Vlrchw0XO9EiZZ6s3A31JvAdpThanmNa2vgsqLCpg3ZdHn7VXmmahj7
         qtJa2Fnf/eV7cbRbIZ8XTCuH0LwmG8bo24G+7E0UkQfFONfhERautpvo8VJRXS7xLbfx
         t/6GqB4b71bdM3UMmYcqqJh+5zSZLMYV1lZUyDgqlfdjwwcTeq/uCoWIICtPmxIXHFr2
         l1JlUVusdUg8/g1PON2ms267RMPYfcyiurGP1tkcdp/4avcYh8g3fFalbwENe/KjpUXQ
         8OhxgkGjqb6D5vfBTnDplY3GbErPcwUOCXIJpvrHya3FXBaMog+xKlqMpCyB1mSmCVJB
         zJwg==
X-Gm-Message-State: APjAAAXYIh9acfWyhggDsUUM+4I8nlI7GWq+/0xHN73SYeQJmIfMilfX
	qJxdKoyZ5OBL/FQGBe4I4yoARkfJLk5n0G5fdCCICbwpGKfRnfPOni5GAme4AdMir610N8fz1fz
	vv51dx1QeyGYvosotDW06m2LVTV24/oYu6dMvs88JAJF0EUI6o/d6jWGZ2DfqaCt16A==
X-Received: by 2002:a62:5cc6:: with SMTP id q189mr38082927pfb.114.1559653778996;
        Tue, 04 Jun 2019 06:09:38 -0700 (PDT)
X-Received: by 2002:a62:5cc6:: with SMTP id q189mr38082816pfb.114.1559653778091;
        Tue, 04 Jun 2019 06:09:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559653778; cv=none;
        d=google.com; s=arc-20160816;
        b=TUJJAhOEYN5mkxqjPKX9ug8zPnw2QLHnl8QtrCkpnrtOQzIBhwzn9nl9BaQZKIaUq+
         Y2ik77TjvYT4BJmBfiZACVdaa5Ydacrn12KMYqMuPEBianwc3AqGoZ4SkSe5ZdJInLO6
         B9qX5BNM53hJtPrgWoxO9HI506xYOXuBqprQFJOqkSdMJ/zE0+iKKY2wkejXi8GijgZh
         e6G+Ot5VttX2vuhpkvM1Kiq44i4GnHluTP8YaoS+O/0xlwpQA9tSz8sqyKZWMWN/Aibg
         gGY/lIx7Xj005dc1sAz/85Fs0NqLzdtuAYv2qlQhZ9roqel9GiSZiOb/h1scvp4tbixs
         9cdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=zBLpk28DZpa5o94Q/0/LiLBGCkVoEs9cAD1KugSM2WY=;
        b=cNJgDd39MijCBqjMQ8mixI9+jmJO6w2zTF8oVkf5tjMgoX4BOcP1xI5+c3KS6zvcEb
         oUL+eh/VWUPt6U6HGgWk46WL9ntesCCpbdtKwy/GVGd8tiQ7iESXuIFeberSKMB2eP6Z
         N1+O9ZX+UcoSpayS8y9GZHqZ4cmoQwLCe+Uvd4A3sPcJESD2IHs/Z1mrdLhx0lJJOMuN
         bm7/qZOLNIXi4v94GnbZHjX8wg6xd5lZ8m7GKYD89HjGLF4Ix6/R42b8/wrwKUGlQ5xQ
         DjnZrMFcd4x3xD0S7gy3y5BX4IT21+QfXKyoNuYcMURkxMGcd9k7ENzCx+DUHsd8kWMW
         hfjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Lkz8dpKP;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t25sor20150611pfh.57.2019.06.04.06.09.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 06:09:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Lkz8dpKP;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=zBLpk28DZpa5o94Q/0/LiLBGCkVoEs9cAD1KugSM2WY=;
        b=Lkz8dpKPRyddE/5l1SxtFW2tJDVJSIsNFYCOD1eigwQMuFNNmYLAz8pfUb/eNChwZF
         OH2h9RaIuTJvzD4zfwI4In+YKCusdO0C+/wNdpvUvPZXC2iOOrHIqrrS+koi+fxYqD+r
         iK2Zgy43Tahmq3qaqGtP4n+xMyhj8Yk3JvazolAsNKLfjKj1GXO3dAAQy063Hi2tMAsN
         GhJY2yKC3BApNCj1AkvEe/6mz6FyJyIhhdR95z/RQ7El5pARzqaaKppkgNvLbKRJzKwz
         N+Va7sAICkGdL463idSaVxKwCH7V2NZvNaXeQHS+go3oLu7b/Bj32cawMXuwRC+DSWx3
         9rBw==
X-Google-Smtp-Source: APXvYqwE+yY3fi9MHe5pAmjH6ujV7dnKQuJJ2mvTpcdW82/qczftH0mUauffZu6ryTn350uiR7ngmmR4ga1rtqlB5p8=
X-Received: by 2002:aa7:8491:: with SMTP id u17mr25575697pfn.93.1559653777333;
 Tue, 04 Jun 2019 06:09:37 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com> <c829f93b19ad6af1b13be8935ce29baa8e58518f.1559580831.git.andreyknvl@google.com>
 <20190603174619.GC11474@ziepe.ca> <CAAeHK+xy-dx4dLDLLj9dRzRNSVG9H5nDPPnjpYF38qKZNNCh_g@mail.gmail.com>
 <20190604122714.GA15385@ziepe.ca> <CAAeHK+xyqwuJyviGhvU7L1wPZQF7Mf9g2vgKSsYmML3fV6NrXg@mail.gmail.com>
 <20190604130207.GD15385@ziepe.ca>
In-Reply-To: <20190604130207.GD15385@ziepe.ca>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 4 Jun 2019 15:09:26 +0200
Message-ID: <CAAeHK+xBxDB-OBuzPDcNaTHCNJqu6djHwqoVGSYpxG33w-YR9g@mail.gmail.com>
Subject: Re: [PATCH v16 12/16] IB, arm64: untag user pointers in ib_uverbs_(re)reg_mr()
To: Jason Gunthorpe <jgg@ziepe.ca>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, 
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

On Tue, Jun 4, 2019 at 3:02 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Tue, Jun 04, 2019 at 02:45:32PM +0200, Andrey Konovalov wrote:
> > On Tue, Jun 4, 2019 at 2:27 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > >
> > > On Tue, Jun 04, 2019 at 02:18:19PM +0200, Andrey Konovalov wrote:
> > > > On Mon, Jun 3, 2019 at 7:46 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > > > >
> > > > > On Mon, Jun 03, 2019 at 06:55:14PM +0200, Andrey Konovalov wrote:
> > > > > > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > > > > > pass tagged user pointers (with the top byte set to something else other
> > > > > > than 0x00) as syscall arguments.
> > > > > >
> > > > > > ib_uverbs_(re)reg_mr() use provided user pointers for vma lookups (through
> > > > > > e.g. mlx4_get_umem_mr()), which can only by done with untagged pointers.
> > > > > >
> > > > > > Untag user pointers in these functions.
> > > > > >
> > > > > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > > > > >  drivers/infiniband/core/uverbs_cmd.c | 4 ++++
> > > > > >  1 file changed, 4 insertions(+)
> > > > > >
> > > > > > diff --git a/drivers/infiniband/core/uverbs_cmd.c b/drivers/infiniband/core/uverbs_cmd.c
> > > > > > index 5a3a1780ceea..f88ee733e617 100644
> > > > > > +++ b/drivers/infiniband/core/uverbs_cmd.c
> > > > > > @@ -709,6 +709,8 @@ static int ib_uverbs_reg_mr(struct uverbs_attr_bundle *attrs)
> > > > > >       if (ret)
> > > > > >               return ret;
> > > > > >
> > > > > > +     cmd.start = untagged_addr(cmd.start);
> > > > > > +
> > > > > >       if ((cmd.start & ~PAGE_MASK) != (cmd.hca_va & ~PAGE_MASK))
> > > > > >               return -EINVAL;
> > > > >
> > > > > I feel like we shouldn't thave to do this here, surely the cmd.start
> > > > > should flow unmodified to get_user_pages, and gup should untag it?
> > > > >
> > > > > ie, this sort of direction for the IB code (this would be a giant
> > > > > patch, so I didn't have time to write it all, but I think it is much
> > > > > saner):
> > > >
> > > > Hi Jason,
> > > >
> > > > ib_uverbs_reg_mr() passes cmd.start to mlx4_get_umem_mr(), which calls
> > > > find_vma(), which only accepts untagged addresses. Could you explain
> > > > how your patch helps?
> > >
> > > That mlx4 is just a 'weird duck', it is not the normal flow, and I
> > > don't think the core code should be making special consideration for
> > > it.
> >
> > How do you think we should do untagging (or something else) to deal
> > with this 'weird duck' case?
>
> mlx4 should handle it around the call to find_vma like other patches
> do, ideally as part of the cast from a void __user * to the unsigned
> long that find_vma needs

So essentially what we had a few versions ago
(https://lkml.org/lkml/2019/4/30/785) plus changing unsigned longs to
__user * across all IB code? I think the second part is something
that's not related to this series and needs to be done separately. I
can move untagging back to mlx4_get_umem_mr() though.

Catalin, you've initially asked to to move untagging out of
mlx4_get_umem_mr(), do you have any comments on this?

>
> Jason

