Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1216B0007
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 02:24:25 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d1-v6so3036301pfo.16
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 23:24:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z7-v6si2910036plo.388.2018.08.02.23.24.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 23:24:23 -0700 (PDT)
Date: Fri, 3 Aug 2018 08:24:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 2/2] mm: harden alloc_pages code paths against bogus nodes
Message-ID: <20180803062419.GE27245@dhcp22.suse.cz>
References: <20180801200418.1325826-1-jeremy.linton@arm.com>
 <20180801200418.1325826-3-jeremy.linton@arm.com>
 <20180802073147.GA10808@dhcp22.suse.cz>
 <5ed35dfa-5f02-55cb-9b84-b944394e1a5a@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5ed35dfa-5f02-55cb-9b84-b944394e1a5a@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeremy Linton <jeremy.linton@arm.com>
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, vbabka@suse.cz, Punit.Agrawal@arm.com, Lorenzo.Pieralisi@arm.com, linux-arm-kernel@lists.infradead.org, bhelgaas@google.com, linux-kernel@vger.kernel.org

On Thu 02-08-18 22:17:49, Jeremy Linton wrote:
> Hi,
> 
> On 08/02/2018 02:31 AM, Michal Hocko wrote:
> > On Wed 01-08-18 15:04:18, Jeremy Linton wrote:
> > > Its possible to crash __alloc_pages_nodemask by passing it
> > > bogus node ids. This is caused by NODE_DATA() returning null
> > > (hopefully) when the requested node is offline. We can
> > > harded against the basic case of a mostly valid node, that
> > > isn't online by checking for null and failing prepare_alloc_pages.
> > > 
> > > But this then suggests we should also harden NODE_DATA() like this
> > > 
> > > #define NODE_DATA(nid)         ( (nid) < MAX_NUMNODES ? node_data[(nid)] : NULL)
> > > 
> > > eventually this starts to add a bunch of generally uneeded checks
> > > in some code paths that are called quite frequently.
> > 
> > But the page allocator is really a hot path and people will not be happy
> > to have yet another branch there. No code should really use invalid numa
> > node ids in the first place.
> > 
> > If I remember those bugs correctly then it was the arch code which was
> > doing something wrong. I would prefer that code to be fixed instead.
> 
> Yes, I think the consensus is that 2/2 should be dropped.
> 
> The arch code is being fixed (both cases) this patch set is just an attempt
> to harden this code path against future failures like that so that we get
> some warnings/ugly messages rather than early boot failures.

Hmm, this is a completely different story. We do have VM_{BUG,WARN}_ON
which are noops for most configurations. It is primarily meant to be
enabled for developers or special debug kernels. If you have an example
when such an early splat in the log would safe a lot of head scratching
then this would sound like a reasonable justification to add
	VM_WARN_ON(!NODE_DATA(nid))
into the page allocator, me thinks. But considering that would should
get NULL ptr splat anyway then I am not really so sure. But maybe we are
in a context where warning would get into the log while a blow up would
just make the whole machine silent...
-- 
Michal Hocko
SUSE Labs
