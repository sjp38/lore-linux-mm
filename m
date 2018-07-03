Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5E08D6B0007
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 16:40:28 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id x6-v6so1506724wrl.6
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 13:40:28 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id y42-v6si1548978wrc.336.2018.07.03.13.40.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 13:40:25 -0700 (PDT)
Date: Tue, 3 Jul 2018 21:39:02 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v8 03/17] mm: Assign id to every memcg-aware shrinker
Message-ID: <20180703203901.GV30522@ZenIV.linux.org.uk>
References: <153063036670.1818.16010062622751502.stgit@localhost.localdomain>
 <153063054586.1818.6041047871606697364.stgit@localhost.localdomain>
 <20180703152723.GB21590@bombadil.infradead.org>
 <CALvZod7xAP9AjRWp2XX1uJBkuOprYKCf7hzAXNTdw89dc-n4OA@mail.gmail.com>
 <20180703174744.GB4834@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180703174744.GB4834@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Shakeel Butt <shakeelb@google.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, stummala@codeaurora.org, gregkh@linuxfoundation.org, Stephen Rothwell <sfr@canb.auug.org.au>, Roman Gushchin <guro@fb.com>, mka@chromium.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Chris Wilson <chris@chris-wilson.co.uk>, longman@redhat.com, Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, jbacik@fb.com, Guenter Roeck <linux@roeck-us.net>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, lirongqing@baidu.com, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Jul 03, 2018 at 10:47:44AM -0700, Matthew Wilcox wrote:
> On Tue, Jul 03, 2018 at 08:46:28AM -0700, Shakeel Butt wrote:
> > On Tue, Jul 3, 2018 at 8:27 AM Matthew Wilcox <willy@infradead.org> wrote:
> > > This will actually reduce the size of each shrinker and be more
> > > cache-efficient when calling the shrinkers.  I think we can also get
> > > rid of the shrinker_rwsem eventually, but let's leave it for now.
> > 
> > Can you explain how you envision shrinker_rwsem can be removed? I am
> > very much interested in doing that.
> 
> Sure.  Right now we have 3 uses of shrinker_rwsem -- two for adding and
> removing shrinkers to the list and one for walking the list.  If we switch
> to an IDR then we can use a spinlock for adding/removing shrinkers and
> the RCU read lock for looking up an entry in the IDR each iteration of
> the loop.
> 
> We'd need to stop the shrinker from disappearing underneath us while we
> drop the RCU lock, so we'd need a refcount in the shrinker, and to free
> the shrinkers using RCU.  We do similar things for other data structures,
> so this is all pretty well understood.

<censored>
struct super_block {
...
        struct shrinker s_shrink;       /* per-sb shrinker handle */
...
}
<censored>

What was that about refcount in the shrinker and taking over the lifetime
rules of the objects it might be embedded into, again?
