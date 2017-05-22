Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C5274831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 11:03:25 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b84so25892936wmh.0
        for <linux-mm@kvack.org>; Mon, 22 May 2017 08:03:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h77si5211386wmd.111.2017.05.22.08.03.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 May 2017 08:03:24 -0700 (PDT)
Date: Mon, 22 May 2017 17:03:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] dm ioctl: Restore __GFP_HIGH in copy_params()
Message-ID: <20170522150321.GM8509@dhcp22.suse.cz>
References: <20170518185040.108293-1-junaids@google.com>
 <20170518190406.GB2330@dhcp22.suse.cz>
 <alpine.DEB.2.10.1705181338090.132717@chino.kir.corp.google.com>
 <1508444.i5EqlA1upv@js-desktop.svl.corp.google.com>
 <20170519074647.GC13041@dhcp22.suse.cz>
 <alpine.LRH.2.02.1705191934340.17646@file01.intranet.prod.int.rdu2.redhat.com>
 <20170522093725.GF8509@dhcp22.suse.cz>
 <alpine.LRH.2.02.1705220759001.27401@file01.intranet.prod.int.rdu2.redhat.com>
 <20170522120937.GI8509@dhcp22.suse.cz>
 <alpine.LRH.2.02.1705221026430.20076@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1705221026430.20076@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Junaid Shahid <junaids@google.com>, David Rientjes <rientjes@google.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, andreslc@google.com, gthelen@google.com, vbabka@suse.cz, linux-kernel@vger.kernel.org

On Mon 22-05-17 10:52:44, Mikulas Patocka wrote:
> 
> 
> On Mon, 22 May 2017, Michal Hocko wrote:
[...] 
> > I am not sure I understand. OOM killer is invoked for _all_ allocations
> > <= PAGE_ALLOC_COSTLY_ORDER that do not have __GFP_NORETRY as long as the
> > OOM killer is not disabled (oom_killer_disable) and that only happens
> > from the PM suspend path which makes sure that no userspace is active at
> > the time. AFAIU this is a userspace triggered path and so the later
> > shouldn't apply to it and GFP_KERNEL should be therefore sufficient.
> > Relying to a portion of memory reserves to prevent from deadlock seems
> > fundamentaly broken  to me.
> > 
> 
> The lvm2 was designed this way - it is broken, but there is not much that 
> can be done about it - fixing this would mean major rewrite. The only 
> thing we can do about it is to lower the deadlock probability with 
> __GFP_HIGH (or PF_MEMALLOC that was used some times ago).

But let me repeat. GFP_KERNEL allocation for order-0 page will not fail.
If you need non-failing semantic then just make it clear by adding
__GFP_NOFAIL rather than __GFP_HIGH. Memory reserves are a scarce
resource and there are users which might really need it from atomic
contexts.

Anyway, this is not the code I am maintaining so I will not argue more
and won't nack the patch. But is smells like a pure cargo cult, to be
honest.

If you really insist, though, I would just ask to have a more detailed
explanation why it is _believed_ the flag is needed because the vague
"Use __GFP_HIGH to avoid low memory issues when a device is suspended
and the ioctl is needed to resume it." doesn't really clarify much to be
honest.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
