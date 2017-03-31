Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 991796B0038
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 04:46:56 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l95so14857257wrc.12
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 01:46:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 136si2512408wmw.28.2017.03.31.01.46.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 31 Mar 2017 01:46:55 -0700 (PDT)
Date: Fri, 31 Mar 2017 10:46:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 7/9] net: use kvmalloc with __GFP_REPEAT rather than open
 coded variant
Message-ID: <20170331084652.GL27098@dhcp22.suse.cz>
References: <20170306103032.2540-1-mhocko@kernel.org>
 <20170306103327.2766-1-mhocko@kernel.org>
 <20170306103327.2766-3-mhocko@kernel.org>
 <CALvZod73-ddnbMAWXF9QpXMcpjZMLreLXheUo-CgcB7s_5iBnQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod73-ddnbMAWXF9QpXMcpjZMLreLXheUo-CgcB7s_5iBnQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Eric Dumazet <edumazet@google.com>, Vlastimil Babka <vbabka@suse.cz>

On Thu 30-03-17 16:21:43, Shakeel Butt wrote:
> On Mon, Mar 6, 2017 at 2:33 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > From: Michal Hocko <mhocko@suse.com>
> >
> > fq_alloc_node, alloc_netdev_mqs and netif_alloc* open code kmalloc
> > with vmalloc fallback. Use the kvmalloc variant instead. Keep the
> > __GFP_REPEAT flag based on explanation from Eric:
> > "
> > At the time, tests on the hardware I had in my labs showed that
> > vmalloc() could deliver pages spread all over the memory and that was a
> > small penalty (once memory is fragmented enough, not at boot time)
> > "
> >
> > The way how the code is constructed means, however, that we prefer to go
> > and hit the OOM killer before we fall back to the vmalloc for requests
> > <=32kB (with 4kB pages) in the current code. This is rather disruptive for
> > something that can be achived with the fallback. On the other hand
> > __GFP_REPEAT doesn't have any useful semantic for these requests. So the
> > effect of this patch is that requests smaller than 64kB will fallback to
> 
> I am a bit confused about this 64kB, shouldn't it be <=32kB (with 4kB
> pages & PAGE_ALLOC_COSTLY_ORDER = 3)?

You are right. I just forgot to update wording. "mm: support
__GFP_REPEAT in kvmalloc_node for >32kB" was fixed but this one stayed
in place.

s@smaller than 64kB@which fit into 32kB@

Andrew could you update the changelog please?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
