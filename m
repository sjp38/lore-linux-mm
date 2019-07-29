Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87473C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 18:42:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38C72206BA
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 18:42:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="IQmmqup/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38C72206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C51D58E0005; Mon, 29 Jul 2019 14:42:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C02668E0002; Mon, 29 Jul 2019 14:42:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF0C88E0005; Mon, 29 Jul 2019 14:42:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F03C8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 14:42:22 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id p12so68427305iog.19
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 11:42:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=3tfpxcMIOawO8s0nF6u5AxpRiYOClgINgvc5ma6ttZw=;
        b=pO+YuJehuXqK7tuP3s8bk3H58PqB24/rn9nAok2i90rq+p08qY+1sXap100lfI2wpW
         tcF6Q5Ru95k4P4QRO2oNuTeap9i1RG6Wtbco7Ec+8bAScfbofXSq0Rj522yB+wmRVxpD
         hKtL69a0Iq5jk8bV7OvRAX5yYSN9LXFNsrQlRp59lAnOorCUORbcW/AfQr8nBNoLC1cT
         fnVZYPeeoruqlDYFRjhaJW7qYY5O2W0Jzi4vfHiGvOSmFtoBmhUM+Ksp2WjWhZiWxJPj
         linTM1/Irdug4ktzzoR7OkLU1Q5NQUGBxInD80S7pUGCseXRtLbEkL4YscfddXddBut2
         3Uww==
X-Gm-Message-State: APjAAAWaWrjAnBMy0CLtXY0jNn77j7HkSooo6IJem2ziviJIWMG6nJi0
	d4q7bBYC8Pw0T5hdDgCM8mzkxftt/Kbji69Tgwicy2+RuUit3wJOGu027Bm6Rr+49B+MNBLcYqX
	q2MzSrr+ADxdoLgT4EuVi91EW6hKN4KXyQsPoJ5YSFA9XW7XPfCdqC6xHA6SO+/C6Tw==
X-Received: by 2002:a5d:94d0:: with SMTP id y16mr64142128ior.123.1564425742366;
        Mon, 29 Jul 2019 11:42:22 -0700 (PDT)
X-Received: by 2002:a5d:94d0:: with SMTP id y16mr64142097ior.123.1564425741712;
        Mon, 29 Jul 2019 11:42:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564425741; cv=none;
        d=google.com; s=arc-20160816;
        b=EHt1YxfJvLThwm0kPsR/MvdJ3urb+ncy5hMM3omSi5h140WRqaO5nlWwaXvlqNobDj
         vz+0+LYjFbxcmKZtpkRJ8Ui8JI9mpuYintYlw1745FugmB3FfkR7Cw1QvPxECidZQao9
         B9d+mRgIKzgHhbOAfHkrPSx2G+xRRD64jswE5XsXSjcn7Y/EAVTk6AOfGTAEv63jGAcw
         7NdNThmk4hRYCXE+vY9w8OsrbGPrgWSdZGKHNo96o4dDLMIHfbOdbfQ7GV8AvM+Ltfw5
         ga9ez/vdW69HaYIHJHQifc2PNcV/vF5kG9JoF+9N5gSk1SgXnxZdGomXAm6pEgsgKAD1
         zRgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=3tfpxcMIOawO8s0nF6u5AxpRiYOClgINgvc5ma6ttZw=;
        b=l/l+Mv/0uAUHjgV0E4PzhtvGUKn/erbfOoz/KGePqVIBlXwd1Olv8Q/OGImdNETEME
         Tx79SPVn5LPvOT7Vus1hEUjtBM80g8ugjKfoolKAsLffY0cec6Ksi8vxm7PtUOD4WeWU
         8vZ3VleMpBvBjtmin3i/uflfM0rCA06WTGhDWEF7C1S6tF6HPOaWDjMonunnelbucNp5
         qXBTPHr48hIL6EpXNULkna6r4rcN7k+/yHgHgZAmHegJWXywzf6agRgKcOm1J/F8K3Mf
         dJijdvCnuSLJ0BpyHiEUFvF6FADapOU7QSh67PVMbFDM70XFqNyhEmyyuJooeR8c6J6A
         8mNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="IQmmqup/";
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o124sor41624336iof.20.2019.07.29.11.42.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 11:42:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="IQmmqup/";
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3tfpxcMIOawO8s0nF6u5AxpRiYOClgINgvc5ma6ttZw=;
        b=IQmmqup/6r9M4vGzFNJ2eQeqgw7xlIoAUs5jeMBIFXwMw1/6E8KZwGF59gU1R/s1wr
         od8n0zVv12PnonheCchmyOFja2Rj5CqOQgVE6IuSCXp0atpMNpN4A4t4/7Vf5jI1f1tC
         bqmDTxp9EjXqdrgmgE7jOAMpjGGp01BzpAfRmS/bOjpScIYhwcfWKhJCbOf4mGM/MuOx
         kfDC4rfXTjw6TLq0kV/0cEZZi4Hv/UOPJ9FqlF/1RHxu+j97c80UihRGIktDhfVOQUtm
         u+Knabw655Ohtf9vz38yQiZVVGmgt0OllVIj/2aK5dgiGvZqqDwcxin29m4BabmpHLuu
         rFwg==
X-Google-Smtp-Source: APXvYqwjLiqzT6+l8biMGbT+ubzfDFZQP3pdxi7Bs2LEIu59aazQJHsn2226HIPI6J8GkYWgkqquogjLf6r6kCe70Dg=
X-Received: by 2002:a6b:c38b:: with SMTP id t133mr38575856iof.162.1564425741290;
 Mon, 29 Jul 2019 11:42:21 -0700 (PDT)
MIME-Version: 1.0
References: <20190726224810.79660-1-henryburns@google.com> <20190726224810.79660-2-henryburns@google.com>
 <CA+VK+GPC+akF0qGrKFivtNneweEfdC9uEx=QgmztB4M_xvMeKQ@mail.gmail.com>
In-Reply-To: <CA+VK+GPC+akF0qGrKFivtNneweEfdC9uEx=QgmztB4M_xvMeKQ@mail.gmail.com>
From: Henry Burns <henryburns@google.com>
Date: Mon, 29 Jul 2019 11:41:45 -0700
Message-ID: <CAGQXPTi8+EanC2ygr4W7qDN1bnas_3utxFkSCj4Xdzo4H134nw@mail.gmail.com>
Subject: Re: [PATCH] mm/z3fold.c: Fix z3fold_destroy_pool() race condition
To: Jonathan Adams <jwadams@google.com>
Cc: Vitaly Vul <vitaly.vul@sony.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Shakeel Butt <shakeelb@google.com>, David Howells <dhowells@redhat.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Al Viro <viro@zeniv.linux.org.uk>, 
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The constraint from the zpool use of z3fold_destroy_pool() is there
are no outstanding handles to memory (so no active allocations), but
it is possible for there to be outstanding work on either of the two
wqs in the pool.

Calling z3fold_deregister_migration() before the workqueues are drained
means that there can be allocated pages referencing a freed inode,
causing any thread in compaction to be able to trip over the bad
pointer in PageMovable().

Fixes: 1f862989b04a ("mm/z3fold.c: support page migration")

Signed-off-by: Henry Burns <henryburns@google.com>

> Reviewed-by: Shakeel Butt <shakeelb@google.com>
> Reviewed-by: Jonathan Adams <jwadams@google.com>
>
> > Cc: <stable@vger.kernel.org>
> > ---
> >  mm/z3fold.c | 5 ++++-
> >  1 file changed, 4 insertions(+), 1 deletion(-)
> >
> > diff --git a/mm/z3fold.c b/mm/z3fold.c
> > index 43de92f52961..ed19d98c9dcd 100644
> > --- a/mm/z3fold.c
> > +++ b/mm/z3fold.c
> > @@ -817,16 +817,19 @@ static struct z3fold_pool *z3fold_create_pool(const char *name, gfp_t gfp,
> >  static void z3fold_destroy_pool(struct z3fold_pool *pool)
> >  {
> >         kmem_cache_destroy(pool->c_handle);
> > -       z3fold_unregister_migration(pool);
> >
> >         /*
> >          * We need to destroy pool->compact_wq before pool->release_wq,
> >          * as any pending work on pool->compact_wq will call
> >          * queue_work(pool->release_wq, &pool->work).
> > +        *
> > +        * There are still outstanding pages until both workqueues are drained,
> > +        * so we cannot unregister migration until then.
> >          */
> >
> >         destroy_workqueue(pool->compact_wq);
> >         destroy_workqueue(pool->release_wq);
> > +       z3fold_unregister_migration(pool);
> >         kfree(pool);
> >  }
> >
> > --
> > 2.22.0.709.g102302147b-goog
> >

