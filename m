Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 54E8E6B6D76
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 02:16:52 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e12so7781298edd.16
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 23:16:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id cw22-v6sor4418479ejb.29.2018.12.03.23.16.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 23:16:51 -0800 (PST)
MIME-Version: 1.0
References: <1543892757-4323-1-git-send-email-kernelfans@gmail.com> <alpine.DEB.2.21.1812031946140.97328@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.21.1812031946140.97328@chino.kir.corp.google.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 4 Dec 2018 15:16:39 +0800
Message-ID: <CAFgQCTsikqQERh2MgsrupdVzp0TyF4dDQPjJkN9g3DTq4DB9hw@mail.gmail.com>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node offline
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Tue, Dec 4, 2018 at 11:53 AM David Rientjes <rientjes@google.com> wrote:
>
> On Tue, 4 Dec 2018, Pingfan Liu wrote:
>
> > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > index 76f8db0..8324953 100644
> > --- a/include/linux/gfp.h
> > +++ b/include/linux/gfp.h
> > @@ -453,6 +453,8 @@ static inline int gfp_zonelist(gfp_t flags)
> >   */
> >  static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
> >  {
> > +     if (unlikely(!node_online(nid)))
> > +             nid = first_online_node;
> >       return NODE_DATA(nid)->node_zonelists + gfp_zonelist(flags);
> >  }
> >
>
> So we're passing the node id from dev_to_node() to kmalloc which
> interprets that as the preferred node and then does node_zonelist() to
> find the zonelist at allocation time.
>
> What happens if we fix this in alloc_dr()?  Does anything else cause
> problems?
>
I think it is better to fix it mm, since it can protect any new
similar bug in future. While fixing in alloc_dr() just work at present

> And rather than using first_online_node, would next_online_node() work?
>
What is the gain? Is it for memory pressure on node0?

Thanks,
Pingfan

> I'm thinking about this:
>
> diff --git a/drivers/base/devres.c b/drivers/base/devres.c
> --- a/drivers/base/devres.c
> +++ b/drivers/base/devres.c
> @@ -100,6 +100,8 @@ static __always_inline struct devres * alloc_dr(dr_release_t release,
>                                         &tot_size)))
>                 return NULL;
>
> +       if (unlikely(!node_online(nid)))
> +               nid = next_online_node(nid);
>         dr = kmalloc_node_track_caller(tot_size, gfp, nid);
>         if (unlikely(!dr))
>                 return NULL;
