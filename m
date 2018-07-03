Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C29056B0266
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 13:48:39 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t20-v6so1268988pgu.9
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 10:48:39 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d41-v6si1506997pla.162.2018.07.03.10.48.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 03 Jul 2018 10:48:38 -0700 (PDT)
Date: Tue, 3 Jul 2018 10:47:44 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v8 03/17] mm: Assign id to every memcg-aware shrinker
Message-ID: <20180703174744.GB4834@bombadil.infradead.org>
References: <153063036670.1818.16010062622751502.stgit@localhost.localdomain>
 <153063054586.1818.6041047871606697364.stgit@localhost.localdomain>
 <20180703152723.GB21590@bombadil.infradead.org>
 <CALvZod7xAP9AjRWp2XX1uJBkuOprYKCf7hzAXNTdw89dc-n4OA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod7xAP9AjRWp2XX1uJBkuOprYKCf7hzAXNTdw89dc-n4OA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, stummala@codeaurora.org, gregkh@linuxfoundation.org, Stephen Rothwell <sfr@canb.auug.org.au>, Roman Gushchin <guro@fb.com>, mka@chromium.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Chris Wilson <chris@chris-wilson.co.uk>, longman@redhat.com, Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, jbacik@fb.com, Guenter Roeck <linux@roeck-us.net>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, lirongqing@baidu.com, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Jul 03, 2018 at 08:46:28AM -0700, Shakeel Butt wrote:
> On Tue, Jul 3, 2018 at 8:27 AM Matthew Wilcox <willy@infradead.org> wrote:
> > This will actually reduce the size of each shrinker and be more
> > cache-efficient when calling the shrinkers.  I think we can also get
> > rid of the shrinker_rwsem eventually, but let's leave it for now.
> 
> Can you explain how you envision shrinker_rwsem can be removed? I am
> very much interested in doing that.

Sure.  Right now we have 3 uses of shrinker_rwsem -- two for adding and
removing shrinkers to the list and one for walking the list.  If we switch
to an IDR then we can use a spinlock for adding/removing shrinkers and
the RCU read lock for looking up an entry in the IDR each iteration of
the loop.

We'd need to stop the shrinker from disappearing underneath us while we
drop the RCU lock, so we'd need a refcount in the shrinker, and to free
the shrinkers using RCU.  We do similar things for other data structures,
so this is all pretty well understood.
