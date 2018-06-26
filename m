Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8C31A6B0008
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 14:55:34 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o11-v6so667546edr.11
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 11:55:34 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b11-v6si1124881edd.235.2018.06.26.11.55.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Jun 2018 11:55:33 -0700 (PDT)
Date: Tue, 26 Jun 2018 14:57:24 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] fs: fsnotify: account fsnotify metadata to kmemcg
Message-ID: <20180626185724.GA3958@cmpxchg.org>
References: <20180625230659.139822-1-shakeelb@google.com>
 <20180625230659.139822-2-shakeelb@google.com>
 <CAOQ4uxiV75+X3dMLS93iXqwmSU6eKPOUocdkXiR7MQZhEjotQg@mail.gmail.com>
 <CALvZod5ARMZL+eD8-mrxeBvxJcuVPXaCwWEgUyQw85xXWxHauA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod5ARMZL+eD8-mrxeBvxJcuVPXaCwWEgUyQw85xXWxHauA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Amir Goldstein <amir73il@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.com>, Greg Thelen <gthelen@google.com>, Roman Gushchin <guro@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>

On Tue, Jun 26, 2018 at 11:00:53AM -0700, Shakeel Butt wrote:
> On Mon, Jun 25, 2018 at 10:49 PM Amir Goldstein <amir73il@gmail.com> wrote:
> >
> ...
> >
> > The verb 'unuse' takes an argument memcg and 'uses' it - too weird.
> > You can use 'override'/'revert' verbs like override_creds or just call
> > memalloc_use_memcg(old_memcg) since there is no reference taken
> > anyway in use_memcg and no reference released in unuse_memcg.
> >
> > Otherwise looks good to me.
> >
> 
> Thanks for your feedback. Just using memalloc_use_memcg(old_memcg) and
> ignoring the return seems more simple. I will wait for feedback from
> other before changing anything.

We're not nesting calls to memalloc_use_memcg(), right? So we don't
have to return old_memcg and don't have to pass anything to unuse, it
can always set current->active_memcg to NULL.
