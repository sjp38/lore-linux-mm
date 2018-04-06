Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB6C16B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 14:49:49 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id x27so1112756ywj.9
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 11:49:49 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p71-v6sor3559183yba.119.2018.04.06.11.49.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Apr 2018 11:49:48 -0700 (PDT)
MIME-Version: 1.0
References: <2cb713cd-0b9b-594c-31db-b4582f8ba822@meituan.com>
 <20180406080324.160306-1-gthelen@google.com> <20180406080714.GG8286@dhcp22.suse.cz>
In-Reply-To: <20180406080714.GG8286@dhcp22.suse.cz>
From: Greg Thelen <gthelen@google.com>
Date: Fri, 06 Apr 2018 18:49:35 +0000
Message-ID: <CAHH2K0YyAK2jBaLv0r7B5wfyyq0OZFpRyqcW92_H_hpLrU_A-A@mail.gmail.com>
Subject: Re: [PATCH] writeback: safer lock nesting
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wang Long <wanglong19@meituan.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, npiggin@gmail.com, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Fri, Apr 6, 2018 at 1:07 AM Michal Hocko <mhocko@kernel.org> wrote:

> On Fri 06-04-18 01:03:24, Greg Thelen wrote:
> [...]
> > diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> > index d4d04fee568a..d51bae5a53e2 100644
> > --- a/fs/fs-writeback.c
> > +++ b/fs/fs-writeback.c
> > @@ -746,10 +746,11 @@ int inode_congested(struct inode *inode, int
cong_bits)
> >       if (inode && inode_to_wb_is_valid(inode)) {
> >               struct bdi_writeback *wb;
> >               bool locked, congested;
> > +             unsigned long flags;
> >
> > -             wb = unlocked_inode_to_wb_begin(inode, &locked);
> > +             wb = unlocked_inode_to_wb_begin(inode, &locked, &flags);

> Wouldn't it be better to have a cookie (struct) rather than 2 parameters
> and let unlocked_inode_to_wb_end DTRT?

Nod.  I'll post a V2 patch with that change.

> >               congested = wb_congested(wb, cong_bits);
> > -             unlocked_inode_to_wb_end(inode, locked);
> > +             unlocked_inode_to_wb_end(inode, locked, flags);
> >               return congested;
> >       }
> --
> Michal Hocko
> SUSE Labs
