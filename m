Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C7596B0006
	for <linux-mm@kvack.org>; Sat,  4 Aug 2018 20:03:19 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id q21-v6so5967348pff.21
        for <linux-mm@kvack.org>; Sat, 04 Aug 2018 17:03:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 67-v6si9964461pfc.21.2018.08.04.17.03.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 04 Aug 2018 17:03:17 -0700 (PDT)
Date: Sat, 4 Aug 2018 17:03:05 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Use special value SHRINKER_REGISTERING instead
 list_empty() check
Message-ID: <20180805000305.GC3183@bombadil.infradead.org>
References: <153331055842.22632.9290331685041037871.stgit@localhost.localdomain>
 <20180803155120.0d65511b46c100565b4f8a2c@linux-foundation.org>
 <843169c5-a47a-e6cd-7412-611e72eb20ba@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <843169c5-a47a-e6cd-7412-611e72eb20ba@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, vdavydov.dev@gmail.com, mhocko@suse.com, aryabinin@virtuozzo.com, ying.huang@intel.com, penguin-kernel@I-love.SAKURA.ne.jp, shakeelb@google.com, jbacik@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Aug 04, 2018 at 09:42:05PM +0300, Kirill Tkhai wrote:
> This is exactly the thing the patch makes. Instead of inserting a shrinker pointer
> to idr, it inserts a fake value SHRINKER_REGISTERING there. The patch makes impossible
> to dereference a shrinker unless it's completely registered. 

-       id = idr_alloc(&shrinker_idr, shrinker, 0, 0, GFP_KERNEL);
+       id = idr_alloc(&shrinker_idr, SHRINKER_REGISTERING, 0, 0, GFP_KERNEL);

Instead:

+       id = idr_alloc(&shrinker_idr, NULL, 0, 0, GFP_KERNEL);

... and the rest of your patch becomes even simpler.
