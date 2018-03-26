Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id B1E0A6B0009
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 11:35:06 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id t10-v6so13184380plr.12
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 08:35:06 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h11-v6si14763588plk.720.2018.03.26.08.35.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 26 Mar 2018 08:35:05 -0700 (PDT)
Date: Mon, 26 Mar 2018 08:34:37 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 02/10] mm: Maintain memcg-aware shrinkers in
 mcg_shrinkers array
Message-ID: <20180326153437.GF10912@bombadil.infradead.org>
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
 <152163848990.21546.2153496613786165374.stgit@localhost.localdomain>
 <20180324184516.rogvydnnupr7ah2l@esperanza>
 <448bb904-a861-c2ae-0d3f-427e6a26f61e@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <448bb904-a861-c2ae-0d3f-427e6a26f61e@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 26, 2018 at 06:20:55PM +0300, Kirill Tkhai wrote:
> On 24.03.2018 21:45, Vladimir Davydov wrote:
> > Why don't you simply use idr instead of ida? With idr you wouldn't need
> > the array mapping shrinker id to shrinker ptr. AFAIU you need this
> > mapping to look up the shrinker by id in shrink_slab. The latter doesn't
> > seem to be a hot path so using idr there should be acceptable. Since we
> > already have shrinker_rwsem, which is taken for reading by shrink_slab,
> > we wouldn't even need any additional locking for it.
> 
> The reason is ida may allocate memory, and since list_lru_add() can't fail,
> we can't do that there. If we allocate all the ida memory at the time of
> memcg creation (i.e., preallocate it), this is not different to the way
> the bitmap makes.
> 
> While bitmap has the agvantage, since it's simplest data structure (while
> ida has some radix tree overhead).

That would be true if you never wanted to resize the bitmap, but of
course you do, so you have your own interactions with RCU to contend with.
So you have the overhead of the RCU head, and you have your own code to
handle resizing which may have subtle errors.
