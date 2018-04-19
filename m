Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0D1FD6B0006
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 16:25:20 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id o2-v6so3608971plk.0
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 13:25:20 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e12si3548186pgn.339.2018.04.19.13.25.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 19 Apr 2018 13:25:18 -0700 (PDT)
Date: Thu, 19 Apr 2018 13:25:13 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [LSF/MM] schedule suggestion
Message-ID: <20180419202513.GB14024@bombadil.infradead.org>
References: <20180419015508.GJ27893@dastard>
 <20180419143825.GA3519@redhat.com>
 <20180419144356.GC25406@bombadil.infradead.org>
 <20180419163036.GC3519@redhat.com>
 <1524157119.2943.6.camel@kernel.org>
 <20180419172609.GD3519@redhat.com>
 <1524162667.2943.22.camel@kernel.org>
 <20180419193108.GA4981@redhat.com>
 <20180419195637.GA14024@bombadil.infradead.org>
 <20180419201502.GA11372@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180419201502.GA11372@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jeff Layton <jlayton@kernel.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Thu, Apr 19, 2018 at 04:15:02PM -0400, Jerome Glisse wrote:
> On Thu, Apr 19, 2018 at 12:56:37PM -0700, Matthew Wilcox wrote:
> > > Well scratch that whole idea, i would need to add a new array to task
> > > struct which make it a lot less appealing. Hence a better solution is
> > > to instead have this as part of mm (well indirectly).
> > 
> > It shouldn't be too bad to add a struct radix_tree to the fdtable.
> > 
> > I'm sure we could just not support weird cases like sharing the fdtable
> > without sharing the mm.  Does anyone actually do that?
> 
> Well like you pointed out what i really want is a 1:1 structure linking
> a device struct an a mm_struct. Given that this need to be cleanup when
> mm goes away hence tying this to mmu_notifier sounds like a better idea.
> 
> I am thinking of adding a hashtable to mmu_notifier_mm using file id for
> hash as this should be a good hash value for common cases. I only expect
> few drivers to need that (GPU drivers, RDMA). Today GPU drivers do have
> a hashtable inside their driver and they has on the mm struct pointer,
> i believe hash mmu_notifier_mm using file id will be better.

file descriptors are small positive integers ... ideal for the radix tree.
If you need to find your data based on the struct file address, then by
all means a hashtable is the better data structure.
