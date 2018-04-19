Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9F36B0005
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 17:08:26 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id i21-v6so4387414qtp.10
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 14:08:26 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s44-v6si4306633qte.283.2018.04.19.14.08.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 14:08:25 -0700 (PDT)
Date: Thu, 19 Apr 2018 17:08:23 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [LSF/MM] schedule suggestion
Message-ID: <20180419210822.GC4981@redhat.com>
References: <20180419144356.GC25406@bombadil.infradead.org>
 <20180419163036.GC3519@redhat.com>
 <1524157119.2943.6.camel@kernel.org>
 <20180419172609.GD3519@redhat.com>
 <1524162667.2943.22.camel@kernel.org>
 <20180419193108.GA4981@redhat.com>
 <20180419195637.GA14024@bombadil.infradead.org>
 <20180419201502.GA11372@redhat.com>
 <20180419202513.GB14024@bombadil.infradead.org>
 <20180419203953.GK30522@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180419203953.GK30522@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Matthew Wilcox <willy@infradead.org>, Jeff Layton <jlayton@kernel.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Thu, Apr 19, 2018 at 09:39:53PM +0100, Al Viro wrote:
> On Thu, Apr 19, 2018 at 01:25:13PM -0700, Matthew Wilcox wrote:
> > On Thu, Apr 19, 2018 at 04:15:02PM -0400, Jerome Glisse wrote:
> > > On Thu, Apr 19, 2018 at 12:56:37PM -0700, Matthew Wilcox wrote:
> > > > > Well scratch that whole idea, i would need to add a new array to task
> > > > > struct which make it a lot less appealing. Hence a better solution is
> > > > > to instead have this as part of mm (well indirectly).
> > > > 
> > > > It shouldn't be too bad to add a struct radix_tree to the fdtable.
> > > > 
> > > > I'm sure we could just not support weird cases like sharing the fdtable
> > > > without sharing the mm.  Does anyone actually do that?
> > > 
> > > Well like you pointed out what i really want is a 1:1 structure linking
> > > a device struct an a mm_struct. Given that this need to be cleanup when
> > > mm goes away hence tying this to mmu_notifier sounds like a better idea.
> > > 
> > > I am thinking of adding a hashtable to mmu_notifier_mm using file id for
> > > hash as this should be a good hash value for common cases. I only expect
> > > few drivers to need that (GPU drivers, RDMA). Today GPU drivers do have
> > > a hashtable inside their driver and they has on the mm struct pointer,
> > > i believe hash mmu_notifier_mm using file id will be better.
> > 
> > file descriptors are small positive integers ...
> 
> ... except when there's a lot of them.  Or when something uses dup2() in
> interesting ways, but hey - we could "just not support" that, right?
> 
> > ideal for the radix tree.
> > If you need to find your data based on the struct file address, then by
> > all means a hashtable is the better data structure.
> 
> Perhaps it would be a good idea to describe whatever is being attempted?
> 
> FWIW, passing around descriptors is almost always a bloody bad idea.  There
> are very few things really associated with those and just about every time
> I'd seen internal APIs that work in terms of those "small positive numbers"
> they had been badly racy and required massive redesign to get something even
> remotely sane.

Ok i will use struct device pointer as index, or something else (i
would like to use PCI domain:bus:slot but i don't want this to be
PCIE only), maybe dev_t ...

Cheers,
Jerome
