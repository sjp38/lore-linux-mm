Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 88F0F6B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 14:22:54 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id c7so34926444wjb.7
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 11:22:54 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id q62si28021349wrb.280.2017.01.25.11.22.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 11:22:53 -0800 (PST)
Date: Wed, 25 Jan 2017 14:22:45 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v6] mm: Add memory allocation watchdog kernel thread.
Message-ID: <20170125192245.GA19321@cmpxchg.org>
References: <1478416501-10104-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170125181150.GA16398@cmpxchg.org>
 <20170125184548.GB32041@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170125184548.GB32041@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 25, 2017 at 07:45:49PM +0100, Michal Hocko wrote:
> On Wed 25-01-17 13:11:50, Johannes Weiner wrote:
> [...]
> > >From 6420cae52cac8167bd5fb19f45feed2d540bc11d Mon Sep 17 00:00:00 2001
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > Date: Wed, 25 Jan 2017 12:57:20 -0500
> > Subject: [PATCH] mm: page_alloc: __GFP_NOWARN shouldn't suppress stall
> >  warnings
> > 
> > __GFP_NOWARN, which is usually added to avoid warnings from callsites
> > that expect to fail and have fallbacks, currently also suppresses
> > allocation stall warnings. These trigger when an allocation is stuck
> > inside the allocator for 10 seconds or longer.
> > 
> > But there is no class of allocations that can get legitimately stuck
> > in the allocator for this long. This always indicates a problem.
> > 
> > Always emit stall warnings. Restrict __GFP_NOWARN to alloc failures.
> 
> Tetsuo has already suggested something like this and I didn't really
> like it because it makes the semantic of the flag confusing. The mask
> says to not warn while the kernel log might contain an allocation splat.
> You are right that stalling for 10s seconds means a problem on its own
> but on the other hand I can imagine somebody might really want to have
> clean logs and the last thing we want is to have another gfp flag for
> that purpose.

I don't think it's confusing. __GFP_NOWARN tells the allocator whether
an allocation failure can be handled or whether it constitutes a bug.

If we agree that stalling for 10s is a bug, then we should emit the
warnings. Tying this to whether the caller can handle an allocation
failure is non-sensical. Not warning about a bug because the user
would prefer clean logs is... somewhat out there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
