Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0EE8D6B72D0
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 00:49:47 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id i14so9193133edf.17
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 21:49:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e28sor10530770edb.24.2018.12.04.21.49.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 21:49:45 -0800 (PST)
MIME-Version: 1.0
References: <1543892757-4323-1-git-send-email-kernelfans@gmail.com>
 <alpine.DEB.2.21.1812031946140.97328@chino.kir.corp.google.com> <CAFgQCTsikqQERh2MgsrupdVzp0TyF4dDQPjJkN9g3DTq4DB9hw@mail.gmail.com>
In-Reply-To: <CAFgQCTsikqQERh2MgsrupdVzp0TyF4dDQPjJkN9g3DTq4DB9hw@mail.gmail.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Wed, 5 Dec 2018 13:49:34 +0800
Message-ID: <CAFgQCTttgfuPJZHqGDSF5hLpLWDm2+_+UiyK+ScKgxs6qD-KCQ@mail.gmail.com>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node offline
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Tue, Dec 4, 2018 at 3:16 PM Pingfan Liu <kernelfans@gmail.com> wrote:
>
> On Tue, Dec 4, 2018 at 11:53 AM David Rientjes <rientjes@google.com> wrote:
> >
> > On Tue, 4 Dec 2018, Pingfan Liu wrote:
> >
> > > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > > index 76f8db0..8324953 100644
> > > --- a/include/linux/gfp.h
> > > +++ b/include/linux/gfp.h
> > > @@ -453,6 +453,8 @@ static inline int gfp_zonelist(gfp_t flags)
> > >   */
> > >  static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
> > >  {
> > > +     if (unlikely(!node_online(nid)))
> > > +             nid = first_online_node;
> > >       return NODE_DATA(nid)->node_zonelists + gfp_zonelist(flags);
> > >  }
> > >
> >
> > So we're passing the node id from dev_to_node() to kmalloc which
> > interprets that as the preferred node and then does node_zonelist() to
> > find the zonelist at allocation time.
> >
> > What happens if we fix this in alloc_dr()?  Does anything else cause
> > problems?
> >
> I think it is better to fix it mm, since it can protect any new
> similar bug in future. While fixing in alloc_dr() just work at present
>
> > And rather than using first_online_node, would next_online_node() work?
> >
> What is the gain? Is it for memory pressure on node0?
>
Maybe I got your point now.  Do you try to give a cheap assumption on
nearest neigh of this node?

Thanks,
Pingfan
