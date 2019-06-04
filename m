Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6CC8C46470
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 12:18:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7418924B14
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 12:18:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="anXrne3z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7418924B14
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06D386B0010; Tue,  4 Jun 2019 08:18:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01D156B026B; Tue,  4 Jun 2019 08:18:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E73FA6B026C; Tue,  4 Jun 2019 08:18:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id AD3FF6B0010
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 08:18:32 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id i3so13878560plb.8
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 05:18:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=izP2xVkH+lJ1XiJaz25EL/2sjI5XZqFKPi8rAth3/y8=;
        b=Ze/7XGgEqpWCu4KhFqVTocRAWNUuJagptiYA02sxQ2dnPkArSVVKpLbPubiOjth+XF
         NOQciYLpW7NrPmAmTnYzWNirlJB81SQSdEoo02LF7ZfzEOZJVdDQ4numsZERObhzsk91
         7O14Q38fzBaAHHmdMToDqOMq6YB5OFVbt1H8SzRp7bDzoDAdJUYH3TD0JMIL5JQeVCth
         6oIOhm+wiI/ZbQpC2xqOlaob3h+bYf4piH6MeLrPXfQtFWvPdhDRzyK3/z6DBz/brWCQ
         pa/jVm2kmi4SG0XwSRO64jmIU6AM724M2Ye05HwCaNIZ2Trwt1OnQT/bYEeF18OLER5Y
         QhIg==
X-Gm-Message-State: APjAAAXy4mXTxM9aXz4eOjQipTbC8xV6oWFHRvXBjDLzzkxx+HSqxKjT
	eNitznxkl/qxwFeuUtpcLXm8ykDMcPyIu2IacaJrMhYuChNJCJycLpAEchEA3hkCKjpIVwz0BIo
	ZEK1wt0Plw3dpPU+0ikE2fuCyG6hij1Bi42cyHBSUJHBKEAZ0Xaz6mwfYnkVU6/W0cg==
X-Received: by 2002:a63:474a:: with SMTP id w10mr17373337pgk.352.1559650712209;
        Tue, 04 Jun 2019 05:18:32 -0700 (PDT)
X-Received: by 2002:a63:474a:: with SMTP id w10mr17373223pgk.352.1559650711087;
        Tue, 04 Jun 2019 05:18:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559650711; cv=none;
        d=google.com; s=arc-20160816;
        b=o85Pk3y9RMgA8zuXe/7ok1SeexsSOJGA/hq3disjgCkkQIHCgQjnuQ+PpQQcQT+HTG
         73EgVeheBUxL1zUPJFBR5XLzPXn+DzKKAr1ghl1Be0JGMI9wZKcUesNdvSfYFvg/E+Kw
         d0oQuw3J0JiGaPp5nIcT07zRXWK8+pABVclk3cT9NHWAXrx5aYjlfHv1C2ekXr39dZ7l
         cQrDrhyWCkkhVdbZpObJyVDjdDilyj8lbZog/QEyJjPgurUIm7ojSyv0Yknph9CEjvjP
         nCKVsz2nztB8WB0DnUi6lg2SD3Lb3ZgETJjPHNGm9SYCi8OwS/1QvJydRZwpSerRS4KZ
         hysw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=izP2xVkH+lJ1XiJaz25EL/2sjI5XZqFKPi8rAth3/y8=;
        b=tkEF0E3vh5Ukl3KTj19JTlEiLET2qWaTc0vaTM4pMUV7kziC1iXqLJe4WDcQby/BFC
         LdApacCPIi4T19D7zDKZBV8CT5gQTJGhRC+zYPWiI+pcREjxzii5lUK/Z8KtSo1dBz+g
         1q4IQK4T/OpHH7e3hXqFE05rMgl74rdoRQO/MsXUMPcLatHhCUJ7IodJPsZb7qyyDz1t
         jyu1KpfpQ/TTlmxPWxMioQlZiV7+bjPds5kOBe04xKRPG7+8/RvXLFUclRgu+c9yyneG
         haB+kavei2HbRI3UNvV0snSTy/1yvxgFpJgpmlJYkBT/f1/nSsU0JucD3+JqgTndCxhH
         eOCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=anXrne3z;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s65sor13972445pfb.30.2019.06.04.05.18.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 05:18:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=anXrne3z;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=izP2xVkH+lJ1XiJaz25EL/2sjI5XZqFKPi8rAth3/y8=;
        b=anXrne3zDdmEVildSzDwGKYMdshtpWiEi/bSjfUgHwDoCg62X8GEgJ1oLKPrpJDBTp
         sCO27Nd8vGOH1LG/aPfklMvFylAFcLd0duV9qTE0Uw2bgUkgehc21vjcK8KjtBKBSIeh
         hbrrSVL1q8qPT28KLxALn+5w5v0FjrGnKuEQGLgwne0GhOjJGw91IA05Yw5AYbDH2v2V
         eAfpEy7jnKgsdj8ID/iHcGjtOrlCN+u9PocCqqNSQrn/Xx8uaOQ0ef5ELA37nbSJameE
         4YvdhcrfbGwQSFgLEIgyOhrMQbK4CtUaCUAqm4fpOOKP+JqNZLGloD+rwiN3Vuf1ojqO
         poUA==
X-Google-Smtp-Source: APXvYqz1BnXRogJ38HsJg+YXXm2v0kW8wf81Q7/M4AVfD5zoRhp7qhUtn8D86raEkRJz58lLKdDFOynhTkL7EDkBRUg=
X-Received: by 2002:a63:1919:: with SMTP id z25mr35448936pgl.440.1559650710127;
 Tue, 04 Jun 2019 05:18:30 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com> <c829f93b19ad6af1b13be8935ce29baa8e58518f.1559580831.git.andreyknvl@google.com>
 <20190603174619.GC11474@ziepe.ca>
In-Reply-To: <20190603174619.GC11474@ziepe.ca>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 4 Jun 2019 14:18:19 +0200
Message-ID: <CAAeHK+xy-dx4dLDLLj9dRzRNSVG9H5nDPPnjpYF38qKZNNCh_g@mail.gmail.com>
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

On Mon, Jun 3, 2019 at 7:46 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Mon, Jun 03, 2019 at 06:55:14PM +0200, Andrey Konovalov wrote:
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > ib_uverbs_(re)reg_mr() use provided user pointers for vma lookups (through
> > e.g. mlx4_get_umem_mr()), which can only by done with untagged pointers.
> >
> > Untag user pointers in these functions.
> >
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> >  drivers/infiniband/core/uverbs_cmd.c | 4 ++++
> >  1 file changed, 4 insertions(+)
> >
> > diff --git a/drivers/infiniband/core/uverbs_cmd.c b/drivers/infiniband/core/uverbs_cmd.c
> > index 5a3a1780ceea..f88ee733e617 100644
> > +++ b/drivers/infiniband/core/uverbs_cmd.c
> > @@ -709,6 +709,8 @@ static int ib_uverbs_reg_mr(struct uverbs_attr_bundle *attrs)
> >       if (ret)
> >               return ret;
> >
> > +     cmd.start = untagged_addr(cmd.start);
> > +
> >       if ((cmd.start & ~PAGE_MASK) != (cmd.hca_va & ~PAGE_MASK))
> >               return -EINVAL;
>
> I feel like we shouldn't thave to do this here, surely the cmd.start
> should flow unmodified to get_user_pages, and gup should untag it?
>
> ie, this sort of direction for the IB code (this would be a giant
> patch, so I didn't have time to write it all, but I think it is much
> saner):

Hi Jason,

ib_uverbs_reg_mr() passes cmd.start to mlx4_get_umem_mr(), which calls
find_vma(), which only accepts untagged addresses. Could you explain
how your patch helps?

Thanks!

>
> diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
> index 54628ef879f0ce..7b3b736c87c253 100644
> --- a/drivers/infiniband/core/umem.c
> +++ b/drivers/infiniband/core/umem.c
> @@ -193,7 +193,7 @@ EXPORT_SYMBOL(ib_umem_find_best_pgsz);
>   * @access: IB_ACCESS_xxx flags for memory being pinned
>   * @dmasync: flush in-flight DMA when the memory region is written
>   */
> -struct ib_umem *ib_umem_get(struct ib_udata *udata, unsigned long addr,
> +struct ib_umem *ib_umem_get(struct ib_udata *udata, void __user *addr,
>                             size_t size, int access, int dmasync)
>  {
>         struct ib_ucontext *context;
> @@ -201,7 +201,7 @@ struct ib_umem *ib_umem_get(struct ib_udata *udata, unsigned long addr,
>         struct page **page_list;
>         unsigned long lock_limit;
>         unsigned long new_pinned;
> -       unsigned long cur_base;
> +       void __user *cur_base;
>         struct mm_struct *mm;
>         unsigned long npages;
>         int ret;
> diff --git a/drivers/infiniband/core/uverbs_cmd.c b/drivers/infiniband/core/uverbs_cmd.c
> index 5a3a1780ceea4d..94389e7f12371f 100644
> --- a/drivers/infiniband/core/uverbs_cmd.c
> +++ b/drivers/infiniband/core/uverbs_cmd.c
> @@ -735,7 +735,8 @@ static int ib_uverbs_reg_mr(struct uverbs_attr_bundle *attrs)
>                 }
>         }
>
> -       mr = pd->device->ops.reg_user_mr(pd, cmd.start, cmd.length, cmd.hca_va,
> +       mr = pd->device->ops.reg_user_mr(pd, u64_to_user_ptr(cmd.start),
> +                                        cmd.length, cmd.hca_va,
>                                          cmd.access_flags,
>                                          &attrs->driver_udata);
>         if (IS_ERR(mr)) {
> diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
> index 4d033796dcfcc2..bddbb952082fc5 100644
> --- a/drivers/infiniband/hw/mlx5/mr.c
> +++ b/drivers/infiniband/hw/mlx5/mr.c
> @@ -786,7 +786,7 @@ static int mr_cache_max_order(struct mlx5_ib_dev *dev)
>  }
>
>  static int mr_umem_get(struct mlx5_ib_dev *dev, struct ib_udata *udata,
> -                      u64 start, u64 length, int access_flags,
> +                      void __user *start, u64 length, int access_flags,
>                        struct ib_umem **umem, int *npages, int *page_shift,
>                        int *ncont, int *order)
>  {
> @@ -1262,8 +1262,8 @@ struct ib_mr *mlx5_ib_reg_dm_mr(struct ib_pd *pd, struct ib_dm *dm,
>                                  attr->access_flags, mode);
>  }
>
> -struct ib_mr *mlx5_ib_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
> -                                 u64 virt_addr, int access_flags,
> +struct ib_mr *mlx5_ib_reg_user_mr(struct ib_pd *pd, void __user *start,
> +                                 u64 length, u64 virt_addr, int access_flags,
>                                   struct ib_udata *udata)
>  {
>         struct mlx5_ib_dev *dev = to_mdev(pd->device);
> diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
> index ec6446864b08e9..b3c8eaaa35c760 100644
> --- a/include/rdma/ib_verbs.h
> +++ b/include/rdma/ib_verbs.h
> @@ -2464,8 +2464,8 @@ struct ib_device_ops {
>         struct ib_mr *(*reg_user_mr)(struct ib_pd *pd, u64 start, u64 length,
>                                      u64 virt_addr, int mr_access_flags,
>                                      struct ib_udata *udata);
> -       int (*rereg_user_mr)(struct ib_mr *mr, int flags, u64 start, u64 length,
> -                            u64 virt_addr, int mr_access_flags,
> +       int (*rereg_user_mr)(struct ib_mr *mr, int flags, void __user *start,
> +                            u64 length, u64 virt_addr, int mr_access_flags,
>                              struct ib_pd *pd, struct ib_udata *udata);
>         int (*dereg_mr)(struct ib_mr *mr, struct ib_udata *udata);
>         struct ib_mr *(*alloc_mr)(struct ib_pd *pd, enum ib_mr_type mr_type,

