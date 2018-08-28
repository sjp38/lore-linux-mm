Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9AEBC6B451B
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 04:18:40 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k16-v6so485559ede.6
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 01:18:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z32-v6si681926edb.348.2018.08.28.01.18.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 01:18:39 -0700 (PDT)
Date: Tue, 28 Aug 2018 10:18:37 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 2/2] mm: thp: fix transparent_hugepage/defrag = madvise
 || always
Message-ID: <20180828081837.GG10223@dhcp22.suse.cz>
References: <20180820032204.9591-1-aarcange@redhat.com>
 <20180820032204.9591-3-aarcange@redhat.com>
 <20180821115057.GY29735@dhcp22.suse.cz>
 <20180821214049.GG13047@redhat.com>
 <20180822090214.GF29735@dhcp22.suse.cz>
 <20180822155250.GP13047@redhat.com>
 <20180823105253.GB29735@dhcp22.suse.cz>
 <20180828075321.GD10223@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180828075321.GD10223@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

[CC Stefan Priebe who has reported the same/similar issue on openSUSE
 mailing list recently - the thread starts http://lkml.kernel.org/r/20180820032204.9591-1-aarcange@redhat.com]

On Tue 28-08-18 09:53:21, Michal Hocko wrote:
> On Thu 23-08-18 12:52:53, Michal Hocko wrote:
> > On Wed 22-08-18 11:52:50, Andrea Arcangeli wrote:
> > > On Wed, Aug 22, 2018 at 11:02:14AM +0200, Michal Hocko wrote:
> > [...]
> > > > I still have to digest the __GFP_THISNODE thing but I _think_ that the
> > > > alloc_pages_vma code is just trying to be overly clever and
> > > > __GFP_THISNODE is not a good fit for it. 
> > > 
> > > My option 2 did just that, it removed __GFP_THISNODE but only for
> > > MADV_HUGEPAGE and in general whenever reclaim was activated by
> > > __GFP_DIRECT_RECLAIM. That is also signal that the user really wants
> > > THP so then it's less bad to prefer THP over NUMA locality.
> > > 
> > > For the default which is tuned for short lived allocation, preferring
> > > local memory is most certainly better win for short lived allocation
> > > where THP can't help much, this is why I didn't remove __GFP_THISNODE
> > > from the default defrag policy.
> > 
> > Yes I agree.
> 
> I finally got back to this again. I have checked your patch and I am
> really wondering whether alloc_pages_vma is really the proper place to
> play these tricks. We already have that mind blowing alloc_hugepage_direct_gfpmask
> and it should be the proper place to handle this special casing. So what
> do you think about the following. It should be essentially the same
> thing. Aka use __GFP_THIS_NODE only when we are doing an optimistic THP
> allocation. Madvise signalizes you know what you are doing and THP has
> the top priority. If you care enough about the numa placement then you
> should better use mempolicy.

Now the patch is still untested but it compiles at least.
---
