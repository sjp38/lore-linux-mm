Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8CE336B0038
	for <linux-mm@kvack.org>; Fri,  6 Feb 2015 09:17:51 -0500 (EST)
Received: by mail-qa0-f52.google.com with SMTP id x12so10909481qac.11
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 06:17:51 -0800 (PST)
Received: from mail-qa0-x232.google.com (mail-qa0-x232.google.com. [2607:f8b0:400d:c00::232])
        by mx.google.com with ESMTPS id g34si2976781qgg.111.2015.02.06.06.17.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Feb 2015 06:17:50 -0800 (PST)
Received: by mail-qa0-f50.google.com with SMTP id k15so10940908qaq.9
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 06:17:50 -0800 (PST)
Date: Fri, 6 Feb 2015 09:17:46 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] Making memcg track ownership per address_space or anon_vma
Message-ID: <20150206141746.GB10580@htj.dyndns.org>
References: <20150130160722.GA26111@htj.dyndns.org>
 <54CFCF74.6090400@yandex-team.ru>
 <20150202194608.GA8169@htj.dyndns.org>
 <CAHH2K0aSPjNgt30uJQa_6r=AXZso3SitjWOm96dtJF32CumZjQ@mail.gmail.com>
 <20150204170656.GA18858@htj.dyndns.org>
 <xr93zj8ti6ca.fsf@gthelen.mtv.corp.google.com>
 <20150205131514.GD25736@htj.dyndns.org>
 <xr93siekt3p3.fsf@gthelen.mtv.corp.google.com>
 <20150205222522.GA10580@htj.dyndns.org>
 <xr93pp9nucrt.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr93pp9nucrt.fsf@gthelen.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, Li Zefan <lizefan@huawei.com>, Hugh Dickins <hughd@google.com>

Hello, Greg.

On Thu, Feb 05, 2015 at 04:03:34PM -0800, Greg Thelen wrote:
> So  this is  a system  which charges  all cgroups  using a  shared inode
> (recharge on read) for all resident pages of that shared inode.  There's
> only one copy of the page in memory on just one LRU, but the page may be
> charged to multiple container's (shared_)usage.

Yeap.

> Perhaps I missed it, but what happens when a child's limit is
> insufficient to accept all pages shared by its siblings?  Example
> starting with 2M cached of a shared file:
> 
> 	A
> 	+-B    (usage=2M lim=3M hosted_usage=2M)
> 	  +-C  (usage=0  lim=2M shared_usage=2M)
> 	  +-D  (usage=0  lim=2M shared_usage=2M)
> 	  \-E  (usage=0  lim=1M shared_usage=0)
> 
> If E faults in a new 4K page within the shared file, then E is a sharing
> participant so it'd be charged the 2M+4K, which pushes E over it's
> limit.

OOM?  It shouldn't be participating in sharing of an inode if it can't
match others' protection on the inode, I think.  What we're doing now
w/ page based charging is kinda unfair because in the situations like
above the one under pressure can end up siphoning off of the larger
cgroups' protection if they actually use overlapping areas; however,
for disjoint areas, per-page charging would behave correctly.

So, this part comes down to the same question - whether multiple
cgroups accessing disjoint areas of a single inode is an important
enough use case.  If we say yes to that, we better make writeback
support that too.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
