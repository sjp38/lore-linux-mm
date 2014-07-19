Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id D4F9B6B0035
	for <linux-mm@kvack.org>; Sat, 19 Jul 2014 13:39:24 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id x12so4739837wgg.4
        for <linux-mm@kvack.org>; Sat, 19 Jul 2014 10:39:24 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id h4si10400756wie.14.2014.07.19.10.39.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 19 Jul 2014 10:39:22 -0700 (PDT)
Date: Sat, 19 Jul 2014 13:39:11 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140719173911.GA1725@cmpxchg.org>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
 <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
 <20140715082545.GA9366@dhcp22.suse.cz>
 <20140715121935.GB9366@dhcp22.suse.cz>
 <20140718071246.GA21565@dhcp22.suse.cz>
 <20140718144554.GG29639@cmpxchg.org>
 <CAJfpegt9k+YULet3vhmG3br7zSiHy-DRL+MiEE=HRzcs+mLzbw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJfpegt9k+YULet3vhmG3br7zSiHy-DRL+MiEE=HRzcs+mLzbw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Jul 18, 2014 at 05:12:54PM +0200, Miklos Szeredi wrote:
> On Fri, Jul 18, 2014 at 4:45 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > I assumed the source page would always be new, according to this part
> > in fuse_try_move_page():
> >
> >         /*
> >          * This is a new and locked page, it shouldn't be mapped or
> >          * have any special flags on it
> >          */
> >         if (WARN_ON(page_mapped(oldpage)))
> >                 goto out_fallback_unlock;
> >         if (WARN_ON(page_has_private(oldpage)))
> >                 goto out_fallback_unlock;
> >         if (WARN_ON(PageDirty(oldpage) || PageWriteback(oldpage)))
> >                 goto out_fallback_unlock;
> >         if (WARN_ON(PageMlocked(oldpage)))
> >                 goto out_fallback_unlock;
> >
> > However, it's in the page cache and I can't really convince myself
> > that it's not also on the LRU.  Miklos, I have trouble pinpointing
> > where oldpage is instantiated exactly and what state it might be in -
> > can it already be on the LRU?
> 
> oldpage comes from ->readpages() (*NOT* ->readpage()), i.e. readahead.
> 
> AFAICS it is added to the LRU in read_cache_pages(), so it looks like
> it is definitely on the LRU at that point.

I see, thanks!

Then we need charge migration to lock the page like I proposed.  But
it's not enough: we also need to exclude isolation and putback while
we uncharge it, and make sure that if it was on the LRU it's moved to
the correct lruvec (the root memcg's):

---
