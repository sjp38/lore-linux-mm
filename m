Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 34B64828FD
	for <linux-mm@kvack.org>; Thu,  5 Feb 2015 19:03:38 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id l13so9174709iga.1
        for <linux-mm@kvack.org>; Thu, 05 Feb 2015 16:03:38 -0800 (PST)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com. [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id hv9si543197igb.0.2015.02.05.16.03.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Feb 2015 16:03:37 -0800 (PST)
Received: by mail-ig0-f181.google.com with SMTP id hn18so3203496igb.2
        for <linux-mm@kvack.org>; Thu, 05 Feb 2015 16:03:37 -0800 (PST)
References: <xr93h9v8yfrv.fsf@gthelen.mtv.corp.google.com> <20150130062737.GB25699@htj.dyndns.org> <20150130160722.GA26111@htj.dyndns.org> <54CFCF74.6090400@yandex-team.ru> <20150202194608.GA8169@htj.dyndns.org> <CAHH2K0aSPjNgt30uJQa_6r=AXZso3SitjWOm96dtJF32CumZjQ@mail.gmail.com> <20150204170656.GA18858@htj.dyndns.org> <xr93zj8ti6ca.fsf@gthelen.mtv.corp.google.com> <20150205131514.GD25736@htj.dyndns.org> <xr93siekt3p3.fsf@gthelen.mtv.corp.google.com> <20150205222522.GA10580@htj.dyndns.org>
From: Greg Thelen <gthelen@google.com>
Subject: Re: [RFC] Making memcg track ownership per address_space or anon_vma
In-reply-to: <20150205222522.GA10580@htj.dyndns.org>
Date: Thu, 05 Feb 2015 16:03:34 -0800
Message-ID: <xr93pp9nucrt.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, Li Zefan <lizefan@huawei.com>, Hugh Dickins <hughd@google.com>


On Thu, Feb 05 2015, Tejun Heo wrote:

> Hey,
>
> On Thu, Feb 05, 2015 at 02:05:19PM -0800, Greg Thelen wrote:
>> >  	A
>> >  	+-B    (usage=2M lim=3M min=2M hosted_usage=2M)
>> >  	  +-C  (usage=0  lim=2M min=1M shared_usage=2M)
>> >  	  +-D  (usage=0  lim=2M min=1M shared_usage=2M)
>> >  	  \-E  (usage=0  lim=2M min=0)
> ...
>> Maybe, but I want to understand more about how pressure works in the
>> child.  As C (or D) allocates non shared memory does it perform reclaim
>> to ensure that its (C.usage + C.shared_usage < C.lim).  Given C's
>
> Yes.
>
>> shared_usage is linked into B.LRU it wouldn't be naturally reclaimable
>> by C.  Are you thinking that charge failures on cgroups with non zero
>> shared_usage would, as needed, induce reclaim of parent's hosted_usage?
>
> Hmmm.... I'm not really sure but why not?  If we properly account for
> the low protection when pushing inodes to the parent, I don't think
> it'd break anything.  IOW, allow the amount beyond the sum of low
> limits to be reclaimed when one of the sharers is under pressure.
>
> Thanks.

I'm not saying that it'd break anything.  I think it's required that
children perform reclaim on shared data hosted in the parent.  The child
is limited by shared_usage, so it needs ability to reclaim it.  So I
think we're in agreement.  Child will reclaim parent's hosted_usage when
the child is charged for shared_usage.  Ideally the only parental memory
reclaimed in this situation would be shared.  But I think (though I
can't claim to have followed the new memcg philosophy discussions) that
internal nodes in the cgroup tree (i.e. parents) do not have any
resources charged directly to them.  All resources are charged to leaf
cgroups which linger until resources are uncharged.  Thus the LRUs of
parent will only contain hosted (shared) memory.  This thankfully focus
parental reclaim easy on shared pages.  Child pressure will,
unfortunately, reclaim shared pages used by any container.  But if
shared pages were charged all sharing containers, then it will help
relieve pressure in the caller.

So  this is  a system  which charges  all cgroups  using a  shared inode
(recharge on read) for all resident pages of that shared inode.  There's
only one copy of the page in memory on just one LRU, but the page may be
charged to multiple container's (shared_)usage.

Perhaps I missed it, but what happens when a child's limit is
insufficient to accept all pages shared by its siblings?  Example
starting with 2M cached of a shared file:

	A
	+-B    (usage=2M lim=3M hosted_usage=2M)
	  +-C  (usage=0  lim=2M shared_usage=2M)
	  +-D  (usage=0  lim=2M shared_usage=2M)
	  \-E  (usage=0  lim=1M shared_usage=0)

If E faults in a new 4K page within the shared file, then E is a sharing
participant so it'd be charged the 2M+4K, which pushes E over it's
limit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
