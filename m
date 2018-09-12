Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5EAC68E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 11:07:27 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id 189-v6so2096152ybz.11
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 08:07:27 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id w189-v6si335008ywb.276.2018.09.12.08.07.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 12 Sep 2018 08:07:25 -0700 (PDT)
Date: Wed, 12 Sep 2018 11:07:17 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: ext4 hang and per-memcg dirty throttling
Message-ID: <20180912150717.GD8476@thunk.org>
References: <20180912001054.bu3x3xwukusnsa26@US-160370MP2.local>
 <20180912121130.GF7782@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180912121130.GF7782@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Liu Bo <bo.liu@linux.alibaba.com>, linux-ext4@vger.kernel.org, fengguang.wu@intel.com, tj@kernel.org, cgroups@vger.kernel.org, gthelen@google.com, linux-mm@kvack.org, yang.shi@linux.alibaba.com

On Wed, Sep 12, 2018 at 02:11:30PM +0200, Jan Kara wrote:
> 
> Yes, I guess you're speaking about the one Chris Mason mentioned [1].
> Essentially it's a priority inversion where jbd2 thread gets blocked behind
> writeback done on behalf of a heavily restricted process. It actually is
> not related to dirty throttling or anything like that. And the solution for
> this priority inversion is to use unwritten extents for writeback
> unconditionally as I wrote in that thread. The core of this is implemented
> and hidden behind dioread_nolock mount option but it needs some serious
> polishing work and testing...
> 
> [1] https://marc.info/?l=linux-fsdevel&m=151688776319077

I've actually be considering making dioread_nolock the default when
page_size == block_size.

Arguments in favor:

1)  Improves AIO latency in some circumstances
2)  Improves parallel DIO read performance
3)  Should address the block-cg throttling priority inversion problem

Arguments against:

1)  Hasn't seen much usage outside of Google (where it makes a big
    difference for fast flash workloads; see (1) and (2) above)
2)  Dioread_nolock only works when page_size == block_size; so this
    implies we would be using a different codepath depending on
    the block size.
3)  generic/500 (dm-thin ENOSPC hitter with concurrent discards)
    fails with dioread_nolock, but not in the 4k workload

Liu, can you try out mount -o dioread_nolock and see if this address
your problem, if so, maybe this is the development cycle where we
finally change the default.

						- Ted
