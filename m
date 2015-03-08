Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id C599E6B0038
	for <linux-mm@kvack.org>; Sun,  8 Mar 2015 14:11:32 -0400 (EDT)
Received: by qgdz60 with SMTP id z60so23825564qgd.5
        for <linux-mm@kvack.org>; Sun, 08 Mar 2015 11:11:32 -0700 (PDT)
Received: from mail-qg0-x230.google.com (mail-qg0-x230.google.com. [2607:f8b0:400d:c04::230])
        by mx.google.com with ESMTPS id b3si13055910qkb.89.2015.03.08.11.11.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Mar 2015 11:11:31 -0700 (PDT)
Received: by qgdz107 with SMTP id z107so23778599qgd.3
        for <linux-mm@kvack.org>; Sun, 08 Mar 2015 11:11:31 -0700 (PDT)
Date: Sun, 8 Mar 2015 14:11:29 -0400
From: Michal Hocko <mhocko@suse.cz>
Subject: RFC for small allocation failure mode transition plan (was: Re:
 [Lsf] common session about page allocator vs. FS/IO) It's time to put
 together the schedule)
Message-ID: <20150308181129.GA5751@dhcp22.suse.cz>
References: <1424395745.2603.27.camel@HansenPartnership.com>
 <20150223170842.GK24272@dhcp22.suse.cz>
 <20150302151941.GB26343@dhcp22.suse.cz>
 <1425309993.2187.3.camel@HansenPartnership.com>
 <20150302152858.GF26334@dhcp22.suse.cz>
 <20150302104154.3ae46eb7@tlielax.poochiereds.net>
 <1425311094.2187.11.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1425311094.2187.11.camel@HansenPartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>, lsf@lists.linux-foundation.org, Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org

On Mon 02-03-15 07:44:54, James Bottomley wrote:
> On Mon, 2015-03-02 at 10:41 -0500, Jeff Layton wrote:
> > On Mon, 2 Mar 2015 16:28:58 +0100
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > [Let's add people from the discussion on the CC]
> > > 
> > > On Mon 02-03-15 07:26:33, James Bottomley wrote:
> > > > On Mon, 2015-03-02 at 16:19 +0100, Michal Hocko wrote:
> > > > > On Mon 23-02-15 18:08:42, Michal Hocko wrote:
[...]
> > > > > > I would like to propose a common session (FS and MM, maybe IO as well)
> > > > > > about memory allocator guarantees and the current behavior of the
> > > > > > page allocator with different gfp flags - GFP_KERNEL being basically
> > > > > > __GFP_NOFAIL for small allocations. __GFP_NOFAIL allocations in general
> > > > > > - how they are used in fs/io code paths and what can the allocator do
> > > > > > to prevent from memory exhaustion. GFP_NOFS behavior when combined with
> > > > > > __GFP_NOFAIL and so on. It seems there was a disconnection between mm
> > > > > > and fs people and one camp is not fully aware of what others are doing
> > > > > > and why as it turned out during recent discussions.
> > > > > 
> > > > > James do you have any plans to put this on the schedule?
> > > > 
> > > > I was waiting to see if there was any other feedback, but if you feel
> > > > strongly it should happen, I can do it.
> > > 
> > > I think it would be helpful, but let's see what other involved in the
> > > discussion think.
> > 
> > It makes sense to me as a plenary discussion.
> > 
> > I was personally quite surprised to hear that small allocations
> > couldn't fail, and dismayed at how much time I've spent writing dead
> > error handling code. ;)
> > 
> > If we're keen to get rid of that behavior (and I think it really ought
> > to go, IMNSHO), then what might make sense is to add a Kconfig switch
> > that allows small allocations to fail as an interim step and see what
> > breaks when it's enabled.
> > 
> > Once we fix all of those places up, then we can see about getting
> > distros to turn it on, and eventually eliminate the Kconfig switch
> > altogether. It'll take a few years, but that's probably the least
> > disruptive approach.
> 
> OK, your wish is my command: it's filled up the last empty plenary slot
> on Monday morning.

I guess the following RFC patch should be good for the first part of the
topic - Small allocations implying __GFP_NOFAIL currently. I am CCing
linux-mm mailing list as well so that people not attending LSF/MM can
comment on the approach.

I hope people will find time to look at it before the session because I
am afraid two topics per one slot will be too dense otherwise. I also
hope this part will be less controversial and the primary point for
discussion will be on HOW TO GET RID OF the current behavior in a sane
way rather than WHY TO KEEP IT.
---
