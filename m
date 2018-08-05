Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6EEFC6B0005
	for <linux-mm@kvack.org>; Sun,  5 Aug 2018 08:50:16 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d10-v6so6452392pll.22
        for <linux-mm@kvack.org>; Sun, 05 Aug 2018 05:50:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u11-v6si10396307pgg.683.2018.08.05.05.50.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 05 Aug 2018 05:50:14 -0700 (PDT)
Date: Sun, 5 Aug 2018 05:50:04 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Use special value SHRINKER_REGISTERING instead
 list_empty() check
Message-ID: <20180805125004.GD3183@bombadil.infradead.org>
References: <153331055842.22632.9290331685041037871.stgit@localhost.localdomain>
 <20180803155120.0d65511b46c100565b4f8a2c@linux-foundation.org>
 <843169c5-a47a-e6cd-7412-611e72eb20ba@virtuozzo.com>
 <20180805000305.GC3183@bombadil.infradead.org>
 <e5d67774-a006-e533-d928-64a4407cbb16@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e5d67774-a006-e533-d928-64a4407cbb16@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, vdavydov.dev@gmail.com, mhocko@suse.com, aryabinin@virtuozzo.com, ying.huang@intel.com, penguin-kernel@I-love.SAKURA.ne.jp, shakeelb@google.com, jbacik@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Aug 05, 2018 at 08:30:43AM +0300, Kirill Tkhai wrote:
> On 05.08.2018 03:03, Matthew Wilcox wrote:
> > On Sat, Aug 04, 2018 at 09:42:05PM +0300, Kirill Tkhai wrote:
> >> This is exactly the thing the patch makes. Instead of inserting a shrinker pointer
> >> to idr, it inserts a fake value SHRINKER_REGISTERING there. The patch makes impossible
> >> to dereference a shrinker unless it's completely registered. 
> > 
> > -       id = idr_alloc(&shrinker_idr, shrinker, 0, 0, GFP_KERNEL);
> > +       id = idr_alloc(&shrinker_idr, SHRINKER_REGISTERING, 0, 0, GFP_KERNEL);
> > 
> > Instead:
> > 
> > +       id = idr_alloc(&shrinker_idr, NULL, 0, 0, GFP_KERNEL);
> > 
> > ... and the rest of your patch becomes even simpler.
> 
> The patch, we are discussing at the moment, does *exactly* this:
> 
> https://lkml.org/lkml/2018/8/3/588
> 
> It looks like you missed this hunk in the patch.

No, it does this:

+       id = idr_alloc(&shrinker_idr, SHRINKER_REGISTERING, 0, 0, GFP_KERNEL);

I'm saying do this:

+       id = idr_alloc(&shrinker_idr, NULL, 0, 0, GFP_KERNEL);
