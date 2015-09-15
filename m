Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3D0FC6B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 12:12:36 -0400 (EDT)
Received: by lanb10 with SMTP id b10so110426371lan.3
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 09:12:35 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id dt5si14615546lac.34.2015.09.15.09.12.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 09:12:34 -0700 (PDT)
Date: Tue, 15 Sep 2015 18:12:18 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3 2/2] memcg: punt high overage reclaim to
 return-to-userland path
Message-ID: <20150915161218.GA12032@cmpxchg.org>
References: <20150913185940.GA25369@htj.duckdns.org>
 <20150913190008.GB25369@htj.duckdns.org>
 <20150915074724.GE2858@cmpxchg.org>
 <20150915155355.GH2905@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150915155355.GH2905@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

On Tue, Sep 15, 2015 at 11:53:55AM -0400, Tejun Heo wrote:
> Hello, Johannes.
> 
> On Tue, Sep 15, 2015 at 09:47:24AM +0200, Johannes Weiner wrote:
> > Why can't we simply fail NOWAIT allocations when the high limit is
> > breached? We do the same for the max limit.
> 
> Because that can lead to continued systematic failures of NOWAIT
> allocations.  For that to work, we'll have to add async reclaimaing.
> 
> > As I see it, NOWAIT allocations are speculative attempts on available
> > memory. We should be able to just fail them and have somebody that is
> > allowed to reclaim try again, just like with the max limit.
> 
> Yes, but the assumption is that even back-to-back NOWAIT allocations
> won't continue to fail indefinitely.

But they have been failing indefinitely forever once you hit the hard
limit in the past. There was never an async reclaim provision there.

I can definitely see that the unconstrained high limit breaching needs
to be fixed one way or another, I just don't quite understand why you
chose to go for new semantics. Is there a new or a specific usecase
you had in mind when you chose deferred reclaim over simply failing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
