Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id EBCCF6B0005
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 19:03:33 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id v9-v6so4508811pff.4
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 16:03:33 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a1-v6si6167003pgg.326.2018.08.03.16.03.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 03 Aug 2018 16:03:31 -0700 (PDT)
Date: Fri, 3 Aug 2018 16:03:18 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Use special value SHRINKER_REGISTERING instead
 list_empty() check
Message-ID: <20180803230318.GB23284@bombadil.infradead.org>
References: <153331055842.22632.9290331685041037871.stgit@localhost.localdomain>
 <20180803155120.0d65511b46c100565b4f8a2c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180803155120.0d65511b46c100565b4f8a2c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, vdavydov.dev@gmail.com, mhocko@suse.com, aryabinin@virtuozzo.com, ying.huang@intel.com, penguin-kernel@I-love.SAKURA.ne.jp, shakeelb@google.com, jbacik@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 03, 2018 at 03:51:20PM -0700, Andrew Morton wrote:
> On Fri, 03 Aug 2018 18:36:14 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> > The patch introduces a special value SHRINKER_REGISTERING to use instead
> > of list_empty() to detect a semi-registered shrinker.
> 
> All this isn't terribly nice.  Why can't we avoid installing the
> shrinker into the idr until it is fully initialized?

I haven't reviewed the current state of the code in question, but the
IDR allows you to store a NULL in order to allocate an ID.  One should
then either call idr_remove() in order to release the ID or idr_replace()
once the object has been fully initialised.

Another way to potentially accomplish the same thing is to use
idr_alloc_u32 which will assign the ID immediately before inserting
the pointer into the IDR.  This only works if the caller can initialise
everything but the ID, and can handle an ENOMEM.
