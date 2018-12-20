Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8507B8E0002
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 07:44:25 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c53so2255882edc.9
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 04:44:25 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b12si2798685edb.125.2018.12.20.04.44.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 04:44:23 -0800 (PST)
Date: Thu, 20 Dec 2018 13:44:19 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv2 2/3] mm/numa: build zonelist when alloc for device on
 offline node
Message-ID: <20181220124419.GD9104@dhcp22.suse.cz>
References: <1545299439-31370-1-git-send-email-kernelfans@gmail.com>
 <1545299439-31370-3-git-send-email-kernelfans@gmail.com>
 <20181220113547.GC9104@dhcp22.suse.cz>
 <CAFgQCTvxNGTKD+DP_LxF86WoVnCHnPkWoSqdGeXQxXNVYD_orw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFgQCTvxNGTKD+DP_LxF86WoVnCHnPkWoSqdGeXQxXNVYD_orw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>

On Thu 20-12-18 20:26:28, Pingfan Liu wrote:
> On Thu, Dec 20, 2018 at 7:35 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Thu 20-12-18 17:50:38, Pingfan Liu wrote:
> > [...]
> > > @@ -453,7 +456,12 @@ static inline int gfp_zonelist(gfp_t flags)
> > >   */
> > >  static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
> > >  {
> > > -     return NODE_DATA(nid)->node_zonelists + gfp_zonelist(flags);
> > > +     if (unlikely(!possible_zonelists[nid])) {
> > > +             WARN_ONCE(1, "alloc from offline node: %d\n", nid);
> > > +             if (unlikely(build_fallback_zonelists(nid)))
> > > +                     nid = first_online_node;
> > > +     }
> > > +     return possible_zonelists[nid] + gfp_zonelist(flags);
> > >  }
> >
> > No, please don't do this. We do not want to make things work magically
> 
> For magically, if you mean directly replies on zonelist instead of on
> pgdat struct, then it is easy to change

No, I mean that we _know_ which nodes are possible. Platform is supposed
to tell us. We should just do the intialization properly. What we do now
instead is a pile of hacks that fit magically together. And that should
be changed.

> > and we definitely do not want to put something like that into the hot
> 
> But  the cose of "unlikely" can be ignored, why can it not be placed
> in the path?

unlikely will simply put the code outside of the hot path. The condition
is still there. There are people desperately fighting to get every
single cycle out of the page allocator. Now you want them to pay a
branch which is relevant only for few obscure HW setups.

> > path. We definitely need zonelists to be build transparently for all
> > possible nodes during the init time.
> 
> That is the point, whether the all nodes should be instanced at boot
> time, or not be instanced until there is requirement.

And that should be done at init time. We have all the information
necessary at that time.
-- 
Michal Hocko
SUSE Labs
