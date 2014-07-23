Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id CC06D6B0037
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 11:07:09 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id ho1so2397731wib.4
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 08:07:09 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id l8si5669751wie.64.2014.07.23.08.06.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 23 Jul 2014 08:06:39 -0700 (PDT)
Date: Wed, 23 Jul 2014 11:06:08 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140723150608.GF1725@cmpxchg.org>
References: <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
 <20140715082545.GA9366@dhcp22.suse.cz>
 <20140715121935.GB9366@dhcp22.suse.cz>
 <20140718071246.GA21565@dhcp22.suse.cz>
 <20140718144554.GG29639@cmpxchg.org>
 <CAJfpegt9k+YULet3vhmG3br7zSiHy-DRL+MiEE=HRzcs+mLzbw@mail.gmail.com>
 <20140719173911.GA1725@cmpxchg.org>
 <20140722150825.GA4517@dhcp22.suse.cz>
 <CAJfpegscT-ptQzq__uUV2TOn7Uvs6x4FdWGTQb9Fe9MEJr2KjA@mail.gmail.com>
 <20140723143847.GB16721@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140723143847.GB16721@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Miklos Szeredi <miklos@szeredi.hu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Jul 23, 2014 at 04:38:47PM +0200, Michal Hocko wrote:
> On Tue 22-07-14 17:44:43, Miklos Szeredi wrote:
> > On Tue, Jul 22, 2014 at 5:08 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > > On Sat 19-07-14 13:39:11, Johannes Weiner wrote:
> > >> On Fri, Jul 18, 2014 at 05:12:54PM +0200, Miklos Szeredi wrote:
> > >> > On Fri, Jul 18, 2014 at 4:45 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > >> >
> > >> > > I assumed the source page would always be new, according to this part
> > >> > > in fuse_try_move_page():
> > >> > >
> > >> > >         /*
> > >> > >          * This is a new and locked page, it shouldn't be mapped or
> > >> > >          * have any special flags on it
> > >> > >          */
> > >> > >         if (WARN_ON(page_mapped(oldpage)))
> > >> > >                 goto out_fallback_unlock;
> > >> > >         if (WARN_ON(page_has_private(oldpage)))
> > >> > >                 goto out_fallback_unlock;
> > >> > >         if (WARN_ON(PageDirty(oldpage) || PageWriteback(oldpage)))
> > >> > >                 goto out_fallback_unlock;
> > >> > >         if (WARN_ON(PageMlocked(oldpage)))
> > >> > >                 goto out_fallback_unlock;
> > >> > >
> > >> > > However, it's in the page cache and I can't really convince myself
> > >> > > that it's not also on the LRU.  Miklos, I have trouble pinpointing
> > >> > > where oldpage is instantiated exactly and what state it might be in -
> > >> > > can it already be on the LRU?
> > >> >
> > >> > oldpage comes from ->readpages() (*NOT* ->readpage()), i.e. readahead.
> > >> >
> > >> > AFAICS it is added to the LRU in read_cache_pages(), so it looks like
> > >> > it is definitely on the LRU at that point.
> > >
> > > OK, so my understanding of the code was wrong :/ and staring at it for
> > > quite a while didn't help much. The fuse code is so full of indirection
> > > it makes my head spin.
> > 
> > Definitely needs a rewrite.  But forget the complexities for the
> > moment and just consider this single case:
> > 
> >  ->readpages() is called to do some readahead, pages are locked, added
> > to the page cache and, AFAICS, charged to a memcg (in
> > add_to_page_cache_lru()).
> > 
> >  - fuse sends a READ request to userspace and it gets a reply with
> > splice(... SPLICE_F_MOVE).  What this means that a bunch of pages of
> > indefinite origin are to replace (if possible) the pages already in
> > the page cache.  If not possible, for some reason, it falls back to
> > copying the contents.  So, AFAICS, the oldpage and the newpage can be
> > charged to a different memcg.

Can the new page be anything else than previous page cache?  The pipe
buffer stealing code truncates them, but at that point they would
already be charged as cache.

> OK, thanks for the clarification. I had this feeling but couldn't wrap
> my head around the indirection of the code.
> 
> It seems that checkig PageCgroupUsed(new) and bail out early in
> mem_cgroup_migrate should just work, no?

If the new page is already charged as page cache, we could just drop
the call to mem_cgroup_migrate() altogether.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
