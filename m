Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E928B6B0010
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 15:08:11 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g9-v6so3366421wrq.7
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 12:08:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k1-v6sor1175861wrp.87.2018.06.26.12.08.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Jun 2018 12:08:10 -0700 (PDT)
MIME-Version: 1.0
References: <20180625230659.139822-1-shakeelb@google.com> <20180625230659.139822-2-shakeelb@google.com>
 <CAOQ4uxiV75+X3dMLS93iXqwmSU6eKPOUocdkXiR7MQZhEjotQg@mail.gmail.com>
 <CALvZod5ARMZL+eD8-mrxeBvxJcuVPXaCwWEgUyQw85xXWxHauA@mail.gmail.com> <20180626185724.GA3958@cmpxchg.org>
In-Reply-To: <20180626185724.GA3958@cmpxchg.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 26 Jun 2018 12:07:57 -0700
Message-ID: <CALvZod5aEHcLs3j+AiuC1FppD-AakWhdZdQhzmTSSrktn2Gu0Q@mail.gmail.com>
Subject: Re: [PATCH 1/2] fs: fsnotify: account fsnotify metadata to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Amir Goldstein <amir73il@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.com>, Greg Thelen <gthelen@google.com>, Roman Gushchin <guro@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>

On Tue, Jun 26, 2018 at 11:55 AM Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> On Tue, Jun 26, 2018 at 11:00:53AM -0700, Shakeel Butt wrote:
> > On Mon, Jun 25, 2018 at 10:49 PM Amir Goldstein <amir73il@gmail.com> wrote:
> > >
> > ...
> > >
> > > The verb 'unuse' takes an argument memcg and 'uses' it - too weird.
> > > You can use 'override'/'revert' verbs like override_creds or just call
> > > memalloc_use_memcg(old_memcg) since there is no reference taken
> > > anyway in use_memcg and no reference released in unuse_memcg.
> > >
> > > Otherwise looks good to me.
> > >
> >
> > Thanks for your feedback. Just using memalloc_use_memcg(old_memcg) and
> > ignoring the return seems more simple. I will wait for feedback from
> > other before changing anything.
>
> We're not nesting calls to memalloc_use_memcg(), right? So we don't
> have to return old_memcg and don't have to pass anything to unuse, it
> can always set current->active_memcg to NULL.

For buffer_head, the allocation is done with GFP_NOFS. So, I think
there is no chance of nesting. The fsnotify uses GFP_KERNEL but based
on my limited understanding of fsnotify, there should not be any
nesting i.e. the allocation triggering reclaim which trigger fsnotify
events. Though I would like Amir or Jan to confirm there is no nesting
possible.

thanks,
Shakeel
