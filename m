Return-Path: <SRS0=2YS/=UB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4ACFC282DC
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 14:26:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61866217D4
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 14:26:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="V7g/OmJ0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61866217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B45F6B0266; Sun,  2 Jun 2019 10:26:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93E286B0269; Sun,  2 Jun 2019 10:26:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 805936B026A; Sun,  2 Jun 2019 10:26:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6012A6B0266
	for <linux-mm@kvack.org>; Sun,  2 Jun 2019 10:26:18 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id u10so12923961itb.5
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 07:26:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0NnMrNgChDThp4n9xCVB05bwVuzU9lQHfTAesCIcClI=;
        b=HZ3cpdW9rhUvuEpNGwbT/1kCVZ6QznIulOIfU/MW9INVFsx1F2S6hmY9bw8YwBdNTv
         SLHM5InqoS8axcH2PC3qukhA6DSfKF3S+pxfX7YEKLSSBPijia+YICTnsMfZ4YYfhooA
         OLTEhbHJQ0rcMrCbNKFcOFKOJDIDWEIAk4wYQNBx3LAllFjSWWm/s5dej6m3KTHNSnPy
         wyh9T3ot/vCv/J35VHYa5C+wmleMbTCBy2nXOWO3DnlxBcCyL7EIsCnEMgKVACK015Eu
         6HlJpgFwcRigArNbdOzipcfNPqknn3uS+Oz1Q/FSVBbO/HDqRT94EI82RkfmOLPw7MSr
         POsQ==
X-Gm-Message-State: APjAAAXeXFtADFcMHYzZjSfa3rYiPcMX8yzkxQKHOCpK+NNHjtU2X7+m
	1vsJB/L5W1NYAzk6u1VH5mSqy2CouyPpZYIEw0y0A3uio6obDzwQtWNmj+xBnbxVnAyIdZ82ibq
	YLevTL+gKrxzolKVreT3TcLBp8wiMNA2WniHa7UoRIrFjllHBLm23rQI2XGYJQfhhjQ==
X-Received: by 2002:a24:47c2:: with SMTP id t185mr12154323itb.97.1559485578123;
        Sun, 02 Jun 2019 07:26:18 -0700 (PDT)
X-Received: by 2002:a24:47c2:: with SMTP id t185mr12154305itb.97.1559485577332;
        Sun, 02 Jun 2019 07:26:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559485577; cv=none;
        d=google.com; s=arc-20160816;
        b=l3HuD4XnW/cH/nrQp2/gLa2hHKgqf7JC863jmpyP+YP/+16oJau3eT20WP77fWyckB
         lM2qdne41t2p39qFHhiGaN3AZztIdq93aoYM83fUt37PwPF0aEsQOalXiZUm0gZp1lID
         WlwfHkpTDy9U96KvXiCBFdvAZj5P5kdasFaIBmWVXxAWgIZE9euGsXxKAF0C4Fz6ZkVI
         mouW5p9uZbV6j18Fuh0ge8DQwR8/3Jg/gc7aQilGbvjg4Ilb76cfceDUR966xcTineUP
         QVTt1XWfFuVDbrzZkXzisqY/89HnQqbnQZXbTTyNPnRw4EUscqepfrOIZk9n9TxPvSXD
         on/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0NnMrNgChDThp4n9xCVB05bwVuzU9lQHfTAesCIcClI=;
        b=bwDtF3If9abu15PG4GWvwmU7p9rIxKgeQnqe1JfGsBJpAzP5Coq//UtpcMFz3A2uye
         ylqvI4fuhC9Ofyi+YG2HghMeAF7hYeuNA5oelFJgHMWCQT7Ccyga8txKySXObzlYPKzH
         jce3kHx4NAAJjzwmnCHHQIbhPGGddyP0J0cRFjerk+gxOK6PO+2VWToVGGvAp651oa1R
         OoNIt8hNnxiy+iFkCdees8cwkB3uQRo0oWM9fLs6AEqY7jQ7jG4tA/ZSJAUEQTNnGThu
         HHMw+jBUE5DM2CCQXDrRyo4NjlUuG4uPu9JOpkmRBbsIJDu3DOKa5mHngMpbF4aUWxYF
         QjFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="V7g/OmJ0";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p18sor8445017jac.5.2019.06.02.07.26.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 02 Jun 2019 07:26:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="V7g/OmJ0";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0NnMrNgChDThp4n9xCVB05bwVuzU9lQHfTAesCIcClI=;
        b=V7g/OmJ0qgWe6Km0O69C7KqpDZfnm3TC/b4Egd94pU8nnoSKYO95y+RGku3JpMsL4l
         K4Y75sWLM981Sjd4n/JSiRWdEO9NqK/xpphMoCwcBOgn67aUIZKZAK+CTrUK5RBCwH44
         ve6Hmyzc7ZdkCJ9zr8HeQQXkjFzsNhst+xGmfcMAJbuoMJdh8+ksHJNmMnc2g/hqsbod
         0JmKK9G2OB6gDraBMrs9Iy3z6CJXYDLd5qKlMrR0fgEDB7eJNz/doBmGj0x/5Q2BBywH
         87DKyymaeHZ9vro4TmymAlbukYbu2bg7/J/A7cyIvUEHEsHrk0aD2f0MgaM5hAZRLfJK
         EcIA==
X-Google-Smtp-Source: APXvYqxW5KwZqugw16qt4fR1EK8AJpUfc/i/BNDwTq9buRz5HBiATrhb6yZr7KC7qaNRNSHKV0Fjzq4GckUg6Q3BOs8=
X-Received: by 2002:a02:7420:: with SMTP id o32mr13765421jac.117.1559485577058;
 Sun, 02 Jun 2019 07:26:17 -0700 (PDT)
MIME-Version: 1.0
References: <1559467380-8549-1-git-send-email-laoar.shao@gmail.com>
 <1559467380-8549-4-git-send-email-laoar.shao@gmail.com> <20190602135852.GA24957@bharath12345-Inspiron-5559>
In-Reply-To: <20190602135852.GA24957@bharath12345-Inspiron-5559>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Sun, 2 Jun 2019 22:25:40 +0800
Message-ID: <CALOAHbDUdutd8WhoBRyL_o-=J+a5ViOw7-c-WQr5MRxDbO-W+A@mail.gmail.com>
Subject: Re: [PATCH v3 3/3] mm/vmscan: shrink slab in node reclaim
To: Bharath Vedartham <linux.bhar@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 2, 2019 at 9:58 PM Bharath Vedartham <linux.bhar@gmail.com> wrote:
>
> On Sun, Jun 02, 2019 at 05:23:00PM +0800, Yafang Shao wrote:
> > In the node reclaim, may_shrinkslab is 0 by default,
> > hence shrink_slab will never be performed in it.
> > While shrik_slab should be performed if the relcaimable slab is over
> > min slab limit.
> >
> > If reclaimable pagecache is less than min_unmapped_pages while
> > reclaimable slab is greater than min_slab_pages, we only shrink slab.
> > Otherwise the min_unmapped_pages will be useless under this condition.
> >
> > reclaim_state.reclaimed_slab is to tell us how many pages are
> > reclaimed in shrink slab.
> >
> > This issue is very easy to produce, first you continuously cat a random
> > non-exist file to produce more and more dentry, then you read big file
> > to produce page cache. And finally you will find that the denty will
> > never be shrunk.
> >
> > Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> > ---
> >  mm/vmscan.c | 24 ++++++++++++++++++++++++
> >  1 file changed, 24 insertions(+)
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index e0c5669..d52014f 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -4157,6 +4157,8 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
> >       p->reclaim_state = &reclaim_state;
> >
> >       if (node_pagecache_reclaimable(pgdat) > pgdat->min_unmapped_pages) {
> > +             sc.may_shrinkslab = (pgdat->min_slab_pages <
> > +                             node_page_state(pgdat, NR_SLAB_RECLAIMABLE));
> >               /*
> >                * Free memory by calling shrink node with increasing
> >                * priorities until we have enough memory freed.
> > @@ -4164,6 +4166,28 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
> >               do {
> >                       shrink_node(pgdat, &sc);
> >               } while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
> > +     } else {
> > +             /*
> > +              * If the reclaimable pagecache is not greater than
> > +              * min_unmapped_pages, only reclaim the slab.
> > +              */
> > +             struct mem_cgroup *memcg;
> > +             struct mem_cgroup_reclaim_cookie reclaim = {
> > +                     .pgdat = pgdat,
> > +             };
> > +
> > +             do {
> > +                     reclaim.priority = sc.priority;
> > +                     memcg = mem_cgroup_iter(NULL, NULL, &reclaim);
> > +                     do {
> > +                             shrink_slab(sc.gfp_mask, pgdat->node_id,
> > +                                         memcg, sc.priority);
> > +                     } while ((memcg = mem_cgroup_iter(NULL, memcg,
> > +                                                       &reclaim)));
> > +
> > +                     sc.nr_reclaimed += reclaim_state.reclaimed_slab;
> > +                     reclaim_state.reclaimed_slab = 0;
> > +             } while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
> >       }
> >
> >       p->reclaim_state = NULL;
> > --
> > 1.8.3.1
> >
>
> Hi Yafang,
>
> Just a few questions regarding this patch.
>
> Don't you want to check if the number of slab reclaimable pages is
> greater than pgdat->min_slab_pages before reclaiming from slab in your
> else statement? Where is the check to see whether number of
> reclaimable slab pages is greater than pgdat->min_slab_pages? It looks like your
> shrinking slab on the condition if (node_pagecache_reclaimable(pgdata) >
> min_unmapped_pages) is false, Not if (pgdat->min_slab_pages <
> node_page_state(pgdat, NR_SLAB_RECLAIMABLE))? What do you think?
>

Hi Bharath,

Because in  __node_reclaim(), if node_pagecache_reclaimable(pgdat) is
not greater than
pgdat->min_unmapped_pages, then reclaimable slab pages must be greater than
pgdat->min_slab_pages, so we don't need to check it again.

Pls. see the code in node_reclaim():
node_reclaim
    if (node_pagecache_reclaimable(pgdat) <= pgdat->min_unmapped_pages &&
        node_page_state(pgdat, NR_SLAB_RECLAIMABLE) <= pgdat->min_slab_pages)
        return NODE_RECLAIM_FULL;
    __node_reclaim();

> Also would it be better if we update sc.may_shrinkslab outside the if
> statement of checking min_unmapped_pages? I think it may look better?
>
> Would it be better if we move updating sc.may_shrinkslab outside the
> if statement where we check min_unmapped_pages and add a else if
> (sc.may_shrinkslab) rather than an else and then start shrinking the slab?
>

Because sc.may_shrinkslab  is used in shrink_node() only, while it will not be
used in the else statement, so we don't need to update sc.may_shrinkslab outside
the if statement.

Hope it could clarify.
Feel free to ask me it you still have any questions.

Thanks
Yafang

