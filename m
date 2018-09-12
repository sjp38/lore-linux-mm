Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 023FA8E0004
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 15:22:55 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id t26-v6so1557881pfh.0
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 12:22:54 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id d2-v6si1888348plr.127.2018.09.12.12.22.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 12:22:53 -0700 (PDT)
Date: Wed, 12 Sep 2018 12:22:35 -0700
From: Liu Bo <bo.liu@linux.alibaba.com>
Subject: Re: ext4 hang and per-memcg dirty throttling
Message-ID: <20180912192234.gsl2ikg572aigiit@US-160370MP2.local>
Reply-To: bo.liu@linux.alibaba.com
References: <20180912001054.bu3x3xwukusnsa26@US-160370MP2.local>
 <20180912121130.GF7782@quack2.suse.cz>
 <20180912150717.GD8476@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180912150717.GD8476@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, fengguang.wu@intel.com, tj@kernel.org, cgroups@vger.kernel.org, gthelen@google.com, linux-mm@kvack.org, yang.shi@linux.alibaba.com

On Wed, Sep 12, 2018 at 11:07:17AM -0400, Theodore Y. Ts'o wrote:
> On Wed, Sep 12, 2018 at 02:11:30PM +0200, Jan Kara wrote:
> > 
> > Yes, I guess you're speaking about the one Chris Mason mentioned [1].
> > Essentially it's a priority inversion where jbd2 thread gets blocked behind
> > writeback done on behalf of a heavily restricted process. It actually is
> > not related to dirty throttling or anything like that. And the solution for
> > this priority inversion is to use unwritten extents for writeback
> > unconditionally as I wrote in that thread. The core of this is implemented
> > and hidden behind dioread_nolock mount option but it needs some serious
> > polishing work and testing...
> > 
> > [1] https://marc.info/?l=linux-fsdevel&m=151688776319077
> 
> I've actually be considering making dioread_nolock the default when
> page_size == block_size.
> 
> Arguments in favor:
> 
> 1)  Improves AIO latency in some circumstances
> 2)  Improves parallel DIO read performance
> 3)  Should address the block-cg throttling priority inversion problem
> 
> Arguments against:
> 
> 1)  Hasn't seen much usage outside of Google (where it makes a big
>     difference for fast flash workloads; see (1) and (2) above)
> 2)  Dioread_nolock only works when page_size == block_size; so this
>     implies we would be using a different codepath depending on
>     the block size.
> 3)  generic/500 (dm-thin ENOSPC hitter with concurrent discards)
>     fails with dioread_nolock, but not in the 4k workload
> 
> Liu, can you try out mount -o dioread_nolock and see if this address
> your problem, if so, maybe this is the development cycle where we
> finally change the default.
> 

I've confirmed that "mount -o dioread_nolock" fixed the hang, I can do
further testing (maybe in production environment) if that's needed.

Many thanks to both you and Jan.

thanks,
-liubo
