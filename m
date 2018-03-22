Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id D95066B0006
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 05:50:50 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id u1-v6so3788157pls.5
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 02:50:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u59-v6si1342151plb.177.2018.03.22.02.50.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Mar 2018 02:50:49 -0700 (PDT)
Date: Thu, 22 Mar 2018 10:50:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/vmscan: fix unsequenced modification and access
 warning
Message-ID: <20180322095044.GA23100@dhcp22.suse.cz>
References: <20170510065328.9215-1-nick.desaulniers@gmail.com>
 <20170510071511.GA31466@dhcp22.suse.cz>
 <CAH7mPvh0qG2R30ToKV=dX3YNc+0BQtnCH3cQUANJWmVdbn6sXw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAH7mPvh0qG2R30ToKV=dX3YNc+0BQtnCH3cQUANJWmVdbn6sXw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Desaulniers <nick.desaulniers@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, Minchan Kim <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, paullawrence@google.com

On Wed 21-03-18 14:37:04, Nick Desaulniers wrote:
> Sorry to dig up an old thread but a coworker was asking about this
> patch. This is essentially the code that landed in commit
> f2f43e566a02a3bdde0a65e6a2e88d707c212a29 "mm/vmscan.c: fix unsequenced
> modification and access warning".
> 
> Is .reclaim_idx still correct in the case of try_to_free_pages()?

Yes, it gets initialized from the given gfp_mask. sc.gfp_mask might be
sllightly different but that doesn't change the reclaim_idx because we
only drop __GFP_{FS,IO} which do not have any zone modification effects.

> It
> looks like reclaim_idx is based on the original gfp_mask in
> __node_reclaim(), but in try_to_free_pages() it looks like it may have
> been based on current_gfp_context()? (The sequencing is kind of
> ambiguous, thus fixed in my patch)
> 
> Was there a bug in the original try_to_free_pages() pre commit
> f2f43e566a0, or is .reclaim_idx supposed to be different between
> try_to_free_pages() and __node_reclaim()?

I do not think there was any real bug.
-- 
Michal Hocko
SUSE Labs
