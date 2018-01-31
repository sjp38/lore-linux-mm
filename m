Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4AEA86B0005
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 03:19:19 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v14so1817838wmd.3
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 00:19:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y13si5423317wrc.2.2018.01.31.00.19.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Jan 2018 00:19:18 -0800 (PST)
Date: Wed, 31 Jan 2018 09:19:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [netfilter-core] kernel panic: Out of memory and no killable
 processes... (2)
Message-ID: <20180131081916.GO21609@dhcp22.suse.cz>
References: <20180129165722.GF5906@breakpoint.cc>
 <20180129182811.fze4vrb5zd5cojmr@node.shutemov.name>
 <20180129223522.GG5906@breakpoint.cc>
 <20180130075226.GL21609@dhcp22.suse.cz>
 <20180130081127.GH5906@breakpoint.cc>
 <20180130082817.cbax5qj4mxancx4b@node.shutemov.name>
 <CACT4Y+bFKwoxopr1dwnc7OHUoHy28ksVguqtMY6tD=aRh-7LyQ@mail.gmail.com>
 <20180130095739.GV21609@dhcp22.suse.cz>
 <20180130140104.GE21609@dhcp22.suse.cz>
 <20180130112745.934883e37e696ab7f875a385@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180130112745.934883e37e696ab7f875a385@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Florian Westphal <fw@strlen.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Miller <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev <netdev@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Yang Shi <yang.s@alibaba-inc.com>, syzkaller-bugs@googlegroups.com, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, guro@fb.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue 30-01-18 11:27:45, Andrew Morton wrote:
> On Tue, 30 Jan 2018 15:01:04 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > > Well, this is not about syzkaller, it merely pointed out a potential
> > > DoS... And that has to be addressed somehow.
> > 
> > So how about this?
> > ---
> 
> argh ;)

doh, those hardwired moves...

> > >From d48e950f1b04f234b57b9e34c363bdcfec10aeee Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Tue, 30 Jan 2018 14:51:07 +0100
> > Subject: [PATCH] net/netfilter/x_tables.c: make allocation less aggressive
> > 
> > syzbot has noticed that xt_alloc_table_info can allocate a lot of
> > memory. This is an admin only interface but an admin in a namespace
> > is sufficient as well. eacd86ca3b03 ("net/netfilter/x_tables.c: use
> > kvmalloc() in xt_alloc_table_info()") has changed the opencoded
> > kmalloc->vmalloc fallback into kvmalloc. It has dropped __GFP_NORETRY on
> > the way because vmalloc has simply never fully supported __GFP_NORETRY
> > semantic. This is still the case because e.g. page tables backing the
> > vmalloc area are hardcoded GFP_KERNEL.
> > 
> > Revert back to __GFP_NORETRY as a poors man defence against excessively
> > large allocation request here. We will not rule out the OOM killer
> > completely but __GFP_NORETRY should at least stop the large request
> > in most cases.
> > 
> > Fixes: eacd86ca3b03 ("net/netfilter/x_tables.c: use kvmalloc() in xt_alloc_table_info()")
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  net/netfilter/x_tables.c | 8 +++++++-
> >  1 file changed, 7 insertions(+), 1 deletion(-)
> > 
> > diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> > index d8571f414208..a5f5c29bcbdc 100644
> > --- a/net/netfilter/x_tables.c
> > +++ b/net/netfilter/x_tables.c
> > @@ -1003,7 +1003,13 @@ struct xt_table_info *xt_alloc_table_info(unsigned int size)
> >  	if ((SMP_ALIGN(size) >> PAGE_SHIFT) + 2 > totalram_pages)
> >  		return NULL;
> 
> offtopic: preceding comment here is "prevent them from hitting BUG() in
> vmalloc.c".  I suspect this is ancient code and vmalloc sure as heck
> shouldn't go BUG with this input.  And it should be using `sz' ;)

Yeah, we do not BUG but rather fail instead. See __vmalloc_node_range.
My excavation tools pointed me to "VM: Rework vmalloc code to support mapping of arbitray pages"
by Christoph back in 2002. So yes, we can safely remove it finally. Se
below.
