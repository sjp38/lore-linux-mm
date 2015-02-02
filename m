Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id E80BE6B0032
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 14:26:51 -0500 (EST)
Received: by mail-la0-f43.google.com with SMTP id q1so44409694lam.2
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 11:26:51 -0800 (PST)
Received: from forward-corp1m.cmail.yandex.net (forward-corp1m.cmail.yandex.net. [2a02:6b8:b030::69])
        by mx.google.com with ESMTPS id qj10si585634lbb.130.2015.02.02.11.26.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Feb 2015 11:26:50 -0800 (PST)
Message-ID: <54CFCF74.6090400@yandex-team.ru>
Date: Mon, 02 Feb 2015 22:26:44 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [RFC] Making memcg track ownership per address_space or anon_vma
References: <20150130044324.GA25699@htj.dyndns.org> <xr93h9v8yfrv.fsf@gthelen.mtv.corp.google.com> <20150130062737.GB25699@htj.dyndns.org> <20150130160722.GA26111@htj.dyndns.org>
In-Reply-To: <20150130160722.GA26111@htj.dyndns.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, Li Zefan <lizefan@huawei.com>, hughd@google.com

On 30.01.2015 19:07, Tejun Heo wrote:
> Hey, again.
>
> On Fri, Jan 30, 2015 at 01:27:37AM -0500, Tejun Heo wrote:
>> The previous behavior was pretty unpredictable in terms of shared file
>> ownership too.  I wonder whether the better thing to do here is either
>> charging cases like this to the common ancestor or splitting the
>> charge equally among the accessors, which might be doable for ro
>> files.
>
> I've been thinking more about this.  It's true that doing per-page
> association allows for avoiding confronting the worst side effects of
> inode sharing head-on, but it is a tradeoff with fairly weak
> justfications.  The only thing we're gaining is side-stepping the
> blunt of the problem in an awkward manner and the loss of clarity in
> taking this compromised position has nasty ramifications when we try
> to connect it with the rest of the world.
>
> I could be missing something major but the more I think about it, it
> looks to me that the right thing to do here is accounting per-inode
> and charging shared inodes to the nearest common ancestor.  The
> resulting behavior would be way more logical and predicatable than the
> current one, which would make it straight forward to integrate memcg
> with blkcg and writeback.
>
> One of the problems that I can think of off the top of my head is that
> it'd involve more regular use of charge moving; however, this is an
> operation which is per-inode rather than per-page and still gonna be
> fairly infrequent.  Another one is that if we move memcg over to this
> behavior, it's likely to affect the behavior on the traditional
> hierarchies too as we sure as hell don't want to switch between the
> two major behaviors dynamically but given that behaviors on inode
> sharing aren't very well supported yet, this can be an acceptable
> change.
>
> Thanks.
>

Well... that might work.

Per-inode/anonvma memcg will be much more predictable for sure.

In some cases memory cgroup for inode might be assigned statically.
For example database files migth be pinned to special cgroup and
protected with low limit (soft guarantee or whatever it's called
nowadays).

For overlay-fs-like containers might be reasonable to keep shared
template area in separate memory cgroup. (keep cgroup mark at bind-mount 
vfsmount?).

Removing memcg pointer from struct page might be tricky.
It's not clear what to do with truncated pages: either link them
with lru differently or remove from lru right at truncate.
Swap cache pages have the same problem.

Process of moving inodes from memcg to memcg is more or less doable.
Possible solution: keep at inode two pointers to memcg "old" and "new".
Each page will be accounted (and linked into corresponding lru) to one
of them. Separation to "old" and "new" pages could be done by flag on
struct page or by bordering page index stored in inode: pages where
index < border are accounted to the new memcg, the rest to the old.


Keeping shared inodes in common ancestor is reasonable.
We could schedule asynchronous moving when somebody opens or mmaps
inode from outside of its current cgroup. But it's not clear when
inode should be moved into opposite direction: when inode should
become private and how detect if it's no longer shared.

For example each inode could keep yet another pointer to memcg where
it will track subtree of cgroups where it was accessed in past 5
minutes or so. And sometimes that informations goes into moving thread.

Actually I don't see other options except that time-based estimation:
tracking all cgroups for each inode is too expensive, moving pages
from one lru to another is expensive too. So, moving inodes back and
forth at each access from the outside world is not an option.
That should be rare operation which runs in background or in reclaimer.

-- 
Konstantin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
