Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 35AD66B0006
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 18:46:22 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id m198so3106163pga.4
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 15:46:22 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id bh7-v6si3424664plb.704.2018.03.08.15.46.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Mar 2018 15:46:18 -0800 (PST)
Date: Thu, 8 Mar 2018 15:46:18 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Removing GFP_NOFS
Message-ID: <20180308234618.GE29073@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org


Do we have a strategy for eliminating GFP_NOFS?

As I understand it, our intent is to mark the areas in individual
filesystems that can't be reentered with memalloc_nofs_save()/restore()
pairs.  Once they're all done, then we can replace all the GFP_NOFS
users with GFP_KERNEL.

How will we know when we're done and can kill GFP_NOFS?  I was thinking
that we could put a warning in slab/page_alloc that fires when __GFP_IO
is set, __GFP_FS is clear and PF_MEMALLOC_NOFS is clear.  That would
catch every place that uses GFP_NOFS without using memalloc_nofs_save().

Unfortunately (and this is sort of the point), there's a lot of places
which use GFP_NOFS as a precaution; that is, they can be called from
places which both are and aren't in a nofs path.  So we'd have to pass
in GFP flags.  Which would be a lot of stupid churn.

I don't have a good solution here.  Maybe this is a good discussion
topic for LSFMM, or maybe there's already a good solution I'm overlooking.
