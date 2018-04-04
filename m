Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1216E6B0006
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 10:43:00 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id o3-v6so12525747pls.11
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 07:43:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t83si4196965pfj.167.2018.04.04.07.42.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Apr 2018 07:42:59 -0700 (PDT)
Date: Wed, 4 Apr 2018 16:42:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180404144255.GK6312@dhcp22.suse.cz>
References: <20180403123514.GX5501@dhcp22.suse.cz>
 <20180403093245.43e7e77c@gandalf.local.home>
 <20180403135607.GC5501@dhcp22.suse.cz>
 <20180403101753.3391a639@gandalf.local.home>
 <20180403161119.GE5501@dhcp22.suse.cz>
 <20180403185627.6bf9ea9b@gandalf.local.home>
 <20180404062039.GC6312@dhcp22.suse.cz>
 <20180404085901.5b54fe32@gandalf.local.home>
 <20180404141052.GH6312@dhcp22.suse.cz>
 <20180404102527.763250b4@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180404102527.763250b4@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Wed 04-04-18 10:25:27, Steven Rostedt wrote:
> On Wed, 4 Apr 2018 16:10:52 +0200
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Wed 04-04-18 08:59:01, Steven Rostedt wrote:
> > [...]
> > > +       /*
> > > +        * Check if the available memory is there first.
> > > +        * Note, si_mem_available() only gives us a rough estimate of available
> > > +        * memory. It may not be accurate. But we don't care, we just want
> > > +        * to prevent doing any allocation when it is obvious that it is
> > > +        * not going to succeed.
> > > +        */
> > > +       i = si_mem_available();
> > > +       if (i < nr_pages)
> > > +               return -ENOMEM;
> > > +
> > > 
> > > Better?  
> > 
> > I must be really missing something here. How can that work at all for
> > e.g. the zone_{highmem/movable}. You will get false on the above tests
> > even when you will have hard time to allocate anything from your
> > destination zones.
> 
> You mean we will get true on the above tests?  Again, the current
> method is to just say screw it and try to allocate.

No, you will get false on that test. Say that you have a system with
large ZONE_MOVABLE. Now your kernel allocations can fit only into
!movable zones (say we have 1G for !movable and 3G for movable). Now say
that !movable zones are getting close to the edge while movable zones
are full of reclaimable pages. si_mem_available will tell you there is a
_lot_ of memory available while your GFP_KERNEL request will happily
consume the rest of !movable zones and trigger OOM. See?

[...]
> I'm looking for something where "yes" means "there may be enough, but
> there may not be, buyer beware", and "no" means "forget it, don't even
> start, because you just asked for more than possible".

We do not have _that_ something other than try to opportunistically
allocate and see what happens. Sucks? Maybe yes but I really cannot
think of an interface with sane semantic that would catch all the
different scenarios.
-- 
Michal Hocko
SUSE Labs
