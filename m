Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5E2916B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 01:40:37 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id w13so82314117wmw.0
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 22:40:37 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id kk10si80331669wjc.3.2017.01.03.22.40.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 22:40:35 -0800 (PST)
Date: Wed, 4 Jan 2017 01:40:24 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [LSF/MM TOPIC] plans for future swap changes
Message-ID: <20170104064024.GA3676@cmpxchg.org>
References: <20161228145732.GE11470@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161228145732.GE11470@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>

Hi,

On Wed, Dec 28, 2016 at 03:57:32PM +0100, Michal Hocko wrote:
> This is something I would be interested to discuss even though I am not
> working on it directly. Sorry if I hijacked the topic from those who
> planned to post them.
> 
> It seems that the time to reconsider our approach to the swap storage is
> come already and there are multiple areas to discuss. I would be
> interested at least in the following
> 1) anon/file balancing. Johannes has posted some work already and I am
>    really interested in the future plans for it.

They needed some surgery to work on top of the node-LRU rewrite. I've
restored performance on the benchmarks I was using and will post them
after some more cleaning up and writing changelogs for the new pieces.

> 2) swap trashing detection is something that we are lacking for a long
>    time and it would be great if we could do something to help
>    situations when the machine is effectively out of memory but still
>    hopelessly trying to swap in and out few pages while the machine is
>    basically unusable. I hope that 1) will give us some bases but I am
>    not sure how much we will need on top.

Yes, this keeps biting us quite frequently. Not with swap so much as
page cache, but it's the same problem: while we know all the thrashing
*events*, we don't know how much they truly cost us. I've started
drafting a thrashing quantification patch based on feedback from the
Kernel Summit, attaching it below. It's unbelievably crude and needs
more thought on sampling/decaying, as well as on filtering out swapins
that happen after pressure has otherwise subsided. But it does give me
a reasonable-looking thrashing ratio under memory pressure.

> 3) optimizations for the swap out paths - Tim Chen and other guys from
>    Intel are already working on this. I didn't get time to review this
>    closely - mostly because I am not closely familiar with the swapout
>    code and it takes quite some time to get into all subtle details.
>    I mainly interested in what are the plans in this area and how they
>    should be coordinated with other swap related changes
> 4) Do we want the native THP swap in/out support?

Shaohua had some opinions on this, he might be interested in joining
this discussion. CCing him.

---
