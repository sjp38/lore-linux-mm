Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC97BC7618E
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 18:39:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84CF2206BA
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 18:39:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="tKzCUvFd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84CF2206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E77398E0003; Mon, 29 Jul 2019 14:39:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E27B78E0002; Mon, 29 Jul 2019 14:39:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D16B48E0003; Mon, 29 Jul 2019 14:39:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id B13D58E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 14:39:09 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id x24so68432878ioh.16
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 11:39:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=1FwMHPlbmAPxJQ/mJ/56Fjrh96L8HY/RcidjTcs4/fk=;
        b=lObq+7mODvrt0xedTPY+O6apeTW7akFPvTqcaWDMA3FZ/lqd3RmUvBIFBQS1jkpElZ
         1w2f2pcovOQ/gyMqZWM42Sz9HGg2Mdh9fLUYma31RQYN0oQP7hmx6uYEKgfieh6RAl7N
         tPBOhMxSg+txjhBEQf3VKOgV2hUSKd6oTN49anAaJYZCVU8ScP3Z5/Kcvq8/sLeF7iBb
         PZ9birJDZw/tHbMsRhxr3ukgMn4zNBYh/8alRLAKK5IswlTtYPm2hhBjhSuSmc31SNV4
         HwMLNmEtV/9tBTFJfcJztEswUKoS05EdwuZDxJkfZOb+IahVbU2VvijATUyWkKH6vUnK
         m8mQ==
X-Gm-Message-State: APjAAAUX1/tteCTTJJYvQebG0+uM3m073iqVlAqTjWyGurZH9hjSe5Es
	FxrD7Yf0btttwyaXMoInUz/ws7GT1wvm9xwVl2Ja/DSBvfFw/B99xu2dzBPAV0X4tAyOShltMzl
	6lWmtqSoJVWMlx1afW+dsfKMw1IVHK9eZntS0scTQuGbWZzTiZwHD2pVhLL7K5u3GRA==
X-Received: by 2002:a02:b68f:: with SMTP id i15mr85293374jam.107.1564425549444;
        Mon, 29 Jul 2019 11:39:09 -0700 (PDT)
X-Received: by 2002:a02:b68f:: with SMTP id i15mr85293317jam.107.1564425548628;
        Mon, 29 Jul 2019 11:39:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564425548; cv=none;
        d=google.com; s=arc-20160816;
        b=b/04TQVGVk02aZsCH80j53LlKvAHDCJeLdJDBltsYoU+C5V9FEs9Zd2euUafMT6j/t
         1Fmdk4zVZZVWO8RcaC62k8Sy7fsXPbhLGLSWbZBIwhFx0ZVSxe3yUAW9SpkYxtCNXV2S
         7it2MjbYcqBGXcgTg2k9xlvPnQc3jLhVdFB58etykeESHEU+PrOBec9R3yqkp4qJbgY9
         GtSVxJrRy8D8egpxjOYz+1NswQjXKn3/DKiFpb6w5CEK4uMtjTFJAzCtNedUC/fiWMPu
         u52kHzdHo4/hFqKFWGE7UQY6jtD5/krU0ZnDrKds/pLjlICfo/pNWAW8Fh6qmGF8IsAn
         /UCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=1FwMHPlbmAPxJQ/mJ/56Fjrh96L8HY/RcidjTcs4/fk=;
        b=xltBi1rwi7HQ/gNyI/jrObT3tqwVwrUbcKKSJ8TiSaoABzx+qSAuN6f2rZ42W/tvrV
         ho16VfJg6UqkMH+4s/8wDRLgsMEuDiRWJ8NG6dA9WgAH8G3+3nD2sU64QIHkao2caxW3
         tJ5xKLSWmLc/9GUV4QjUEi61SGJiu9Kwk0N5Tk5nS/qhQsds038fbCQ8v1ABPqNli6l+
         ED34xG0ZjK1BoVzWp+nQfsfQlCszEVPW+OQWPW9qvtaMyzNn6aN0E653tgnqHn13ocdw
         nGGrHscUdVa1N0E91wclCimBfPnNWGPgyHgJyL6VrDZVnMhQo2gAbgiBP/GVarPIoeBl
         xZTg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tKzCUvFd;
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l13sor42468488iok.112.2019.07.29.11.39.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 11:39:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tKzCUvFd;
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=1FwMHPlbmAPxJQ/mJ/56Fjrh96L8HY/RcidjTcs4/fk=;
        b=tKzCUvFdpAjThXn2UowV+bawmycTgopdxquIlC+dqdFlomKh47e7PWPAWXwPDhlEV0
         WGaL2Lf3K2nX3uFrFKxHvVy8tSxAc9k2gVTAD9NVYrqF8DkZZW7UipkFX9bjCJCenxdt
         8Yu/uW7CHfDxENOSQSV6rziYo0QM8mfjwOKxWkAT1Jf4g729nbl1Eezj6UAWOTn672O/
         z1GpzyJZZlnM6k4dWYNVDKijnjLKx/kofl9zYXDCLISx67v1pkIzpZOukDv0BLs20LUp
         KWxNi9rJdkEwe55x4UrQMFO2ktWdudcrVcoyNBOJlB/pjpy3BEx0u41fUVp5lz6G+xXW
         k4HA==
X-Google-Smtp-Source: APXvYqwOyvbINe7VjyObX3vCNtadyRi+XDTMas83pG4+8ZVxw9xxSxj0gKL6sLA3lpVp0q7URJsTTC8vSVXcO2bi+AM=
X-Received: by 2002:a5d:9e48:: with SMTP id i8mr101423232ioi.51.1564425548036;
 Mon, 29 Jul 2019 11:39:08 -0700 (PDT)
MIME-Version: 1.0
References: <20190726224810.79660-1-henryburns@google.com> <CA+VK+GM4AXrmZtv_narEU6pHO+NGrTc74iSSUNNbutZySfXjRw@mail.gmail.com>
In-Reply-To: <CA+VK+GM4AXrmZtv_narEU6pHO+NGrTc74iSSUNNbutZySfXjRw@mail.gmail.com>
From: Henry Burns <henryburns@google.com>
Date: Mon, 29 Jul 2019 11:38:32 -0700
Message-ID: <CAGQXPTgGJBiLVqAGWQZpSrTcWw4FnzDSkQWFOPhJ=TqtnQZPvw@mail.gmail.com>
Subject: Re: [PATCH] mm/z3fold.c: Fix z3fold_destroy_pool() ordering
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


If there is work queued on pool->compact_workqueue when it is called,
z3fold_destroy_pool() will do:

   z3fold_destroy_pool()
     destroy_workqueue(pool->release_wq)
     destroy_workqueue(pool->compact_wq)
       drain_workqueue(pool->compact_wq)
         do_compact_page(zhdr)
           kref_put(&zhdr->refcount)
             __release_z3fold_page(zhdr, ...)
               queue_work_on(pool->release_wq, &pool->work) *BOOM*

So compact_wq needs to be destroyed before release_wq.

Fixes: 5d03a6613957 ("mm/z3fold.c: use kref to prevent page free/compact race")

Signed-off-by: Henry Burns <henryburns@google.com>


> Reviewed-by: Shakeel Butt <shakeelb@google.com>
> Reviewed-by: Jonathan Adams <jwadams@google.com>
>
> > Cc: <stable@vger.kernel.org>
> > ---
> >  mm/z3fold.c | 9 ++++++++-
> >  1 file changed, 8 insertions(+), 1 deletion(-)
> >
> > diff --git a/mm/z3fold.c b/mm/z3fold.c
> > index 1a029a7432ee..43de92f52961 100644
> > --- a/mm/z3fold.c
> > +++ b/mm/z3fold.c
> > @@ -818,8 +818,15 @@ static void z3fold_destroy_pool(struct z3fold_pool *pool)
> >  {
> >         kmem_cache_destroy(pool->c_handle);
> >         z3fold_unregister_migration(pool);
> > -       destroy_workqueue(pool->release_wq);
> > +
> > +       /*
> > +        * We need to destroy pool->compact_wq before pool->release_wq,
> > +        * as any pending work on pool->compact_wq will call
> > +        * queue_work(pool->release_wq, &pool->work).
> > +        */
> > +
> >         destroy_workqueue(pool->compact_wq);
> > +       destroy_workqueue(pool->release_wq);
> >         kfree(pool);
> >  }
> >
> > --
> > 2.22.0.709.g102302147b-goog
> >

