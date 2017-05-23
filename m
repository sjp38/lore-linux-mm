Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 38B9A6B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 02:49:47 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id o52so14640093wrb.10
        for <linux-mm@kvack.org>; Mon, 22 May 2017 23:49:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 20si1326022wmq.37.2017.05.22.23.49.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 May 2017 23:49:46 -0700 (PDT)
Date: Tue, 23 May 2017 08:49:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: dm ioctl: Restore __GFP_HIGH in copy_params()
Message-ID: <20170523064944.GA12818@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1705181338090.132717@chino.kir.corp.google.com>
 <1508444.i5EqlA1upv@js-desktop.svl.corp.google.com>
 <20170519074647.GC13041@dhcp22.suse.cz>
 <alpine.LRH.2.02.1705191934340.17646@file01.intranet.prod.int.rdu2.redhat.com>
 <20170522093725.GF8509@dhcp22.suse.cz>
 <alpine.LRH.2.02.1705220759001.27401@file01.intranet.prod.int.rdu2.redhat.com>
 <20170522120937.GI8509@dhcp22.suse.cz>
 <alpine.LRH.2.02.1705221026430.20076@file01.intranet.prod.int.rdu2.redhat.com>
 <20170522150321.GM8509@dhcp22.suse.cz>
 <20170522180415.GA25340@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170522180415.GA25340@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Snitzer <snitzer@redhat.com>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Junaid Shahid <junaids@google.com>, David Rientjes <rientjes@google.com>, Alasdair Kergon <agk@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, andreslc@google.com, gthelen@google.com, vbabka@suse.cz, linux-kernel@vger.kernel.org

On Mon 22-05-17 14:04:15, Mike Snitzer wrote:
> On Mon, May 22 2017 at 11:03am -0400,
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Mon 22-05-17 10:52:44, Mikulas Patocka wrote:
> > > 
> > > 
> > > On Mon, 22 May 2017, Michal Hocko wrote:
> > [...] 
> > > > I am not sure I understand. OOM killer is invoked for _all_ allocations
> > > > <= PAGE_ALLOC_COSTLY_ORDER that do not have __GFP_NORETRY as long as the
> > > > OOM killer is not disabled (oom_killer_disable) and that only happens
> > > > from the PM suspend path which makes sure that no userspace is active at
> > > > the time. AFAIU this is a userspace triggered path and so the later
> > > > shouldn't apply to it and GFP_KERNEL should be therefore sufficient.
> > > > Relying to a portion of memory reserves to prevent from deadlock seems
> > > > fundamentaly broken  to me.
> > > > 
> > > 
> > > The lvm2 was designed this way - it is broken, but there is not much that 
> > > can be done about it - fixing this would mean major rewrite. The only 
> > > thing we can do about it is to lower the deadlock probability with 
> > > __GFP_HIGH (or PF_MEMALLOC that was used some times ago).
> 
> Yes, lvm2 was originally designed to to have access to memory reserves
> to ensure forward progress.  But if the mm subsystem has improved to
> allow for the required progress without lvm2 trying to stake a claim on
> those reserves then we'll gladly avoid (ab)using them.
> 
> > But let me repeat. GFP_KERNEL allocation for order-0 page will not fail.
> 
> OK, but will it be serviced immediately?  Not failing isn't useful if it
> never completes.

Well, GFP_KERNEL will not guarantee an immediate success of course.
There is nothing like that. Nor __GFP_HIGH will guarantee that, though,
because reserves can get easily depleted by some workloads. You would
have to use a dedicated memory pool to accomplish what you really need.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
