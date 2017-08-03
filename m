Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 31AF66B0673
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 04:11:55 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z48so986883wrc.4
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 01:11:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 75si1100700wrb.356.2017.08.03.01.11.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Aug 2017 01:11:53 -0700 (PDT)
Date: Thu, 3 Aug 2017 10:11:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: suspicious __GFP_NOMEMALLOC in selinux
Message-ID: <20170803081152.GC12521@dhcp22.suse.cz>
References: <20170802105018.GA2529@dhcp22.suse.cz>
 <CAGH-Kgt_9So8bDe=yDF3yLZHDfDgeXsnBEu_X6uE_nQnoi=5Vg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGH-Kgt_9So8bDe=yDF3yLZHDfDgeXsnBEu_X6uE_nQnoi=5Vg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Moore <pmoore@redhat.com>
Cc: Jeff Vander Stoep <jeffv@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, selinux@tycho.nsa.gov, Mel Gorman <mgorman@suse.de>

[CC Mel]

On Wed 02-08-17 17:45:56, Paul Moore wrote:
> On Wed, Aug 2, 2017 at 6:50 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > Hi,
> > while doing something completely unrelated to selinux I've noticed a
> > really strange __GFP_NOMEMALLOC usage pattern in selinux, especially
> > GFP_ATOMIC | __GFP_NOMEMALLOC doesn't make much sense to me. GFP_ATOMIC
> > on its own allows to access memory reserves while the later flag tells
> > we cannot use memory reserves at all. The primary usecase for
> > __GFP_NOMEMALLOC is to override a global PF_MEMALLOC should there be a
> > need.
> >
> > It all leads to fa1aa143ac4a ("selinux: extended permissions for
> > ioctls") which doesn't explain this aspect so let me ask. Why is the
> > flag used at all? Moreover shouldn't GFP_ATOMIC be actually GFP_NOWAIT.
> > What makes this path important to access memory reserves?
> 
> [NOTE: added the SELinux list to the CC line, please include that list
> when asking SELinux questions]

Sorry about that. Will keep it in mind for next posts
 
> The GFP_ATOMIC|__GFP_NOMEMALLOC use in SELinux appears to be limited
> to security/selinux/avc.c, and digging a bit, I'm guessing commit
> fa1aa143ac4a copied the combination from 6290c2c43973 ("selinux: tag
> avc cache alloc as non-critical") and the avc_alloc_node() function.

Thanks for the pointer. That makes much more sense now. Back in 2012 we
really didn't have a good way to distinguish non sleeping and atomic
with reserves allocations.
 
> I can't say that I'm an expert at the vm subsystem and the variety of
> different GFP_* flags, but your suggestion of moving to GFP_NOWAIT in
> security/selinux/avc.c seems reasonable and in keeping with the idea
> behind commit 6290c2c43973.

What do you think about the following? I haven't tested it but it should
be rather straightforward.
---
