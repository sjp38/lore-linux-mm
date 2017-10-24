Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B8F26B0033
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 11:45:31 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w105so11937951wrc.20
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 08:45:31 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 96si342771edr.425.2017.10.24.08.45.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 24 Oct 2017 08:45:21 -0700 (PDT)
Date: Tue, 24 Oct 2017 11:45:11 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171024154511.GA32340@cmpxchg.org>
References: <20171006075900.icqjx5rr7hctn3zd@dhcp22.suse.cz>
 <CALvZod7YN4JCG7Anm2FViyZ0-APYy+nxEd3nyxe5LT_P0FC9wg@mail.gmail.com>
 <20171009062426.hmqedtqz5hkmhnff@dhcp22.suse.cz>
 <xr93a810xl77.fsf@gthelen.svl.corp.google.com>
 <20171009202613.GA15027@cmpxchg.org>
 <20171010091430.giflzlayvjblx5bu@dhcp22.suse.cz>
 <20171010141733.GB16710@cmpxchg.org>
 <20171010142434.bpiqmsbb7gttrlcb@dhcp22.suse.cz>
 <20171012190312.GA5075@cmpxchg.org>
 <20171013063555.pa7uco43mod7vrkn@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171013063555.pa7uco43mod7vrkn@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Oct 13, 2017 at 08:35:55AM +0200, Michal Hocko wrote:
> On Thu 12-10-17 15:03:12, Johannes Weiner wrote:
> > All I'm saying is that, when the syscall-context fails to charge, we
> > should do mem_cgroup_oom() to set up the async OOM killer, let the
> > charge succeed over the hard limit - since the OOM killer will most
> > likely get us back below the limit - then mem_cgroup_oom_synchronize()
> > before the syscall returns to userspace.
> 
> OK, then we are on the same page now. Your initial wording didn't
> mention async OOM killer. This makes more sense. Although I would argue
> that we can retry the charge as long as out_of_memory finds a victim.
> This would return ENOMEM to the pathological cases where no victims
> could be found.

I think that's much worse because it's even harder to test and verify
your applications against.

If syscalls can return -ENOMEM on OOM, they should do so reliably.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
