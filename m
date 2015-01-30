Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2923E6B0038
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 01:27:42 -0500 (EST)
Received: by mail-qc0-f176.google.com with SMTP id c9so19214457qcz.7
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 22:27:41 -0800 (PST)
Received: from mail-qc0-x22d.google.com (mail-qc0-x22d.google.com. [2607:f8b0:400d:c01::22d])
        by mx.google.com with ESMTPS id b13si13212229qaw.32.2015.01.29.22.27.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 22:27:41 -0800 (PST)
Received: by mail-qc0-f173.google.com with SMTP id m20so19042145qcx.4
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 22:27:40 -0800 (PST)
Date: Fri, 30 Jan 2015 01:27:37 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] Making memcg track ownership per address_space or anon_vma
Message-ID: <20150130062737.GB25699@htj.dyndns.org>
References: <20150130044324.GA25699@htj.dyndns.org>
 <xr93h9v8yfrv.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr93h9v8yfrv.fsf@gthelen.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, Li Zefan <lizefan@huawei.com>, hughd@google.com, Konstantin Khebnikov <khlebnikov@yandex-team.ru>

Hello, Greg.

On Thu, Jan 29, 2015 at 09:55:53PM -0800, Greg Thelen wrote:
> I find simplification appealing.  But I not sure it will fly, if for no
> other reason than the shared accountings.  I'm ignoring intentional
> sharing, used by carefully crafted apps, and just thinking about
> incidental sharing (e.g. libc).
> 
> Example:
> 
> $ mkdir small
> $ echo 1M > small/memory.limit_in_bytes
> $ (echo $BASHPID > small/cgroup.procs && exec sleep 1h) &
> 
> $ mkdir big
> $ echo 10G > big/memory.limit_in_bytes
> $ (echo $BASHPID > big/cgroup.procs && exec mlockall_database 1h) &
> 
> Assuming big/mlockall_database mlocks all of libc, then it will oom kill
> the small memcg because libc is owned by small due it having touched it
> first.  It'd be hard to figure out what small did wrong to deserve the
> oom kill.

The previous behavior was pretty unpredictable in terms of shared file
ownership too.  I wonder whether the better thing to do here is either
charging cases like this to the common ancestor or splitting the
charge equally among the accessors, which might be doable for ro
files.

> FWIW we've been using memcg writeback where inodes have a memcg
> writeback owner.  Once multiple memcg write to an inode then the inode
> becomes writeback shared which makes it more likely to be written.  Once
> cleaned the inode is then again able to be privately owned:
> https://lkml.org/lkml/2011/8/17/200

The problem is that it introduces deviations between memcg and
writeback / blkcg which will mess up pressure propagation.  Writeback
pressure can't be determined without its associated memcg and neither
can dirty balancing.  We sure can simplify things by trading off
accuracies at places but let's please try to do that throughout the
stack, not in the midpoint, so that we can say "if you do this, it'll
behave this way and you can see it showing up there".  The thing is if
we leave it half-way, in time, some will try to actively exploit
memcg's page granularity and we'll have to deal with writeback
behavior which is difficult to even characterize.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
