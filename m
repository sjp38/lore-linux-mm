Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DBE716B0269
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 02:20:11 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id j14-v6so1482186edr.2
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 23:20:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n38-v6si3534746edn.443.2018.08.02.23.20.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 23:20:10 -0700 (PDT)
Date: Fri, 3 Aug 2018 08:20:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 1/2] slub: Avoid trying to allocate memory on offline nodes
Message-ID: <20180803062008.GD27245@dhcp22.suse.cz>
References: <20180801200418.1325826-1-jeremy.linton@arm.com>
 <20180801200418.1325826-2-jeremy.linton@arm.com>
 <20180802091554.GE10808@dhcp22.suse.cz>
 <c6caddbf-e275-219e-12b6-538a53ced17d@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c6caddbf-e275-219e-12b6-538a53ced17d@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeremy Linton <jeremy.linton@arm.com>
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, vbabka@suse.cz, Punit.Agrawal@arm.com, Lorenzo.Pieralisi@arm.com, linux-arm-kernel@lists.infradead.org, bhelgaas@google.com, linux-kernel@vger.kernel.org

On Thu 02-08-18 22:21:53, Jeremy Linton wrote:
> Hi,
> 
> On 08/02/2018 04:15 AM, Michal Hocko wrote:
> > On Wed 01-08-18 15:04:17, Jeremy Linton wrote:
> > [...]
> > > @@ -2519,6 +2519,8 @@ static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
> > >   		if (unlikely(!node_match(page, searchnode))) {
> > >   			stat(s, ALLOC_NODE_MISMATCH);
> > >   			deactivate_slab(s, page, c->freelist, c);
> > > +			if (!node_online(searchnode))
> > > +				node = NUMA_NO_NODE;
> > >   			goto new_slab;
> > 
> > This is inherently racy. Numa node can get offline at any point after
> > you check it here. Making it race free would involve some sort of
> > locking and I am not really convinced this is a good idea.
> 
> I spent some time looking/thinking about this, and i'm pretty sure its not
> creating any new problems. But OTOH, I think the node_online() check is
> probably a bit misleading as what we really want to assure is that
> node<MAX_NUMNODES and that there is going to be a valid entry in NODE_DATA()
> so we don't deference null.

Exactly. And we do rely that the user of the allocator doesn't really
use bogus parameters. This is not a function to be used for untrusted or
unsanitized inputs.

-- 
Michal Hocko
SUSE Labs
