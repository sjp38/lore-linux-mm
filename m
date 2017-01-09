Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A32716B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 04:58:31 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id t20so13536119wju.5
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 01:58:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gj1si16007802wjb.239.2017.01.09.01.58.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Jan 2017 01:58:30 -0800 (PST)
Date: Mon, 9 Jan 2017 10:58:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: weird allocation pattern in alloc_ila_locks
Message-ID: <20170109095828.GE7495@dhcp22.suse.cz>
References: <20170106095115.GG5556@dhcp22.suse.cz>
 <20170106100433.GH5556@dhcp22.suse.cz>
 <20170106121642.GJ5556@dhcp22.suse.cz>
 <1483740889.9712.44.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170107092746.GC5047@dhcp22.suse.cz>
 <CANn89iL7JTkV_r9Wqqcrsz1GJmTfWtxD1TUV1YOKsv3rwN-+vQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANn89iL7JTkV_r9Wqqcrsz1GJmTfWtxD1TUV1YOKsv3rwN-+vQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <edumazet@google.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Tom Herbert <tom@herbertland.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Sat 07-01-17 10:37:41, Eric Dumazet wrote:
> On Sat, Jan 7, 2017 at 1:27 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Fri 06-01-17 14:14:49, Eric Dumazet wrote:
> 
> >> I believe the intent was to get NUMA spreading, a bit like what we have
> >> in alloc_large_system_hash() when hashdist == HASHDIST_DEFAULT
> >
> > Hmm, I am not sure this works as expected then. Because it is more
> > likely that all pages backing the vmallocked area will come from the
> > local node than spread around more nodes. Or did I miss your point?
> 
> Well, you missed that vmalloc() is aware of NUMA policies.

You are right. I have missed that alloc_page ends up using
alloc_pages_current for CONFIG_NUMA rather than alloc_pages_node.

> If current process has requested interleave on 2 nodes (as it is done
> at boot time on a dual node system),
> then vmalloc() of 8 pages will allocate 4 pages on each node.

On the other hand alloc_ila_locks does go over a single page when
lockdep is enabled and I am wondering whether doing this NUMA subtle
magic is any win...

Also this seems to be an init code so I assume a modprobe would have to
set a non-default policy to make use of it. Does anybody do that out
there?

alloc_bucket_locks is a bit more complicated because it is not only
called from the init context. But considering that rhashtable_shrink is
called from the worker context - so no mem policy can be assumed then I
am wondering whether the code really works as expected. To me it sounds
like it is trying to be clever while the outcome doesn't really do what
it is intended.

Would you mind if I just convert it to kvmalloc and make it easier to
understand?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
