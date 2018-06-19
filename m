Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A7A136B0005
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 15:51:30 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id x6-v6so510688wrl.6
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 12:51:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z21-v6sor270165wma.48.2018.06.19.12.51.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Jun 2018 12:51:28 -0700 (PDT)
MIME-Version: 1.0
References: <20180619051327.149716-1-shakeelb@google.com> <20180619051327.149716-4-shakeelb@google.com>
 <20180619162741.GC27423@cmpxchg.org> <20180619174040.GA4304@castle.DHCP.thefacebook.com>
In-Reply-To: <20180619174040.GA4304@castle.DHCP.thefacebook.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 19 Jun 2018 12:51:15 -0700
Message-ID: <CALvZod5_0_LuqWpri=uviE5hHhTMPT0VQOZDgHtTtLhvcCtb3A@mail.gmail.com>
Subject: Re: [PATCH 3/3] fs, mm: account buffer_head to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.com>, Greg Thelen <gthelen@google.com>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>

On Tue, Jun 19, 2018 at 10:41 AM Roman Gushchin <guro@fb.com> wrote:
>
> On Tue, Jun 19, 2018 at 12:27:41PM -0400, Johannes Weiner wrote:
> > On Mon, Jun 18, 2018 at 10:13:27PM -0700, Shakeel Butt wrote:
> > > The buffer_head can consume a significant amount of system memory and
> > > is directly related to the amount of page cache. In our production
> > > environment we have observed that a lot of machines are spending a
> > > significant amount of memory as buffer_head and can not be left as
> > > system memory overhead.
> > >
> > > Charging buffer_head is not as simple as adding __GFP_ACCOUNT to the
> > > allocation. The buffer_heads can be allocated in a memcg different from
> > > the memcg of the page for which buffer_heads are being allocated. One
> > > concrete example is memory reclaim. The reclaim can trigger I/O of pages
> > > of any memcg on the system. So, the right way to charge buffer_head is
> > > to extract the memcg from the page for which buffer_heads are being
> > > allocated and then use targeted memcg charging API.
> > >
> > > Signed-off-by: Shakeel Butt <shakeelb@google.com>
> > > Cc: Jan Kara <jack@suse.cz>
> > > Cc: Greg Thelen <gthelen@google.com>
> > > Cc: Michal Hocko <mhocko@kernel.org>
> > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> > > Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > ---
> > >  fs/buffer.c                | 14 +++++++++++++-
> > >  include/linux/memcontrol.h |  7 +++++++
> > >  mm/memcontrol.c            | 21 +++++++++++++++++++++
> > >  3 files changed, 41 insertions(+), 1 deletion(-)
> > >
> > > diff --git a/fs/buffer.c b/fs/buffer.c
> > > index 8194e3049fc5..26389b7a3cab 100644
> > > --- a/fs/buffer.c
> > > +++ b/fs/buffer.c
> > > @@ -815,10 +815,17 @@ struct buffer_head *alloc_page_buffers(struct page *page, unsigned long size,
> > >     struct buffer_head *bh, *head;
> > >     gfp_t gfp = GFP_NOFS;
> > >     long offset;
> > > +   struct mem_cgroup *old_memcg;
> > > +   struct mem_cgroup *memcg = get_mem_cgroup_from_page(page);
> > >
> > >     if (retry)
> > >             gfp |= __GFP_NOFAIL;
> > >
> > > +   if (memcg) {
> > > +           gfp |= __GFP_ACCOUNT;
> > > +           old_memcg = memalloc_memcg_save(memcg);
> > > +   }
> >
> > Please move the get_mem_cgroup_from_page() call out of the
> > declarations and down to right before the if (memcg) branch.
> >
> > >     head = NULL;
> > >     offset = PAGE_SIZE;
> > >     while ((offset -= size) >= 0) {
> > > @@ -835,6 +842,11 @@ struct buffer_head *alloc_page_buffers(struct page *page, unsigned long size,
> > >             /* Link the buffer to its page */
> > >             set_bh_page(bh, page, offset);
> > >     }
> > > +out:
> > > +   if (memcg) {
> > > +           memalloc_memcg_restore(old_memcg);
> > > +#ifdef CONFIG_MEMCG
> > > +           css_put(&memcg->css);
> > > +#endif
> >
> > Please add a put_mem_cgroup() ;)
>
> I've added such helper by commit 8a34a8b7fd62 ("mm, oom: cgroup-aware OOM killer").
> It's in the mm tree.
>

I was using mem_cgroup_put() defined by Roman's patch but there were a
lot of build failure reports where someone was taking this series
without Roman's series or applying the series out of order. Andrew
asked me to keep it like this and then he will convert these callsites
into mem_cgroup_put() after making making sure Roman's series is
applied in mm tree. I will recheck with him, how he wants to handle it
now.

thanks,
Shakeel
