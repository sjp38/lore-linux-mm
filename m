Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 718B76B0012
	for <linux-mm@kvack.org>; Sat, 24 Mar 2018 14:45:21 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id m62-v6so1013862lfi.2
        for <linux-mm@kvack.org>; Sat, 24 Mar 2018 11:45:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x13sor950034ljj.87.2018.03.24.11.45.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 24 Mar 2018 11:45:19 -0700 (PDT)
Date: Sat, 24 Mar 2018 21:45:16 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 02/10] mm: Maintain memcg-aware shrinkers in
 mcg_shrinkers array
Message-ID: <20180324184516.rogvydnnupr7ah2l@esperanza>
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
 <152163848990.21546.2153496613786165374.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152163848990.21546.2153496613786165374.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org

On Wed, Mar 21, 2018 at 04:21:29PM +0300, Kirill Tkhai wrote:
> The patch introduces mcg_shrinkers array to keep memcg-aware
> shrinkers in order of their shrinker::id.
> 
> This allows to access the shrinkers dirrectly by the id,
> without iteration over shrinker_list list.

Why don't you simply use idr instead of ida? With idr you wouldn't need
the array mapping shrinker id to shrinker ptr. AFAIU you need this
mapping to look up the shrinker by id in shrink_slab. The latter doesn't
seem to be a hot path so using idr there should be acceptable. Since we
already have shrinker_rwsem, which is taken for reading by shrink_slab,
we wouldn't even need any additional locking for it.
