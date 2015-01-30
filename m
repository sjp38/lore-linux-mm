Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 563A26B0032
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 11:07:26 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id q108so38752039qgd.0
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 08:07:26 -0800 (PST)
Received: from mail-qc0-x22b.google.com (mail-qc0-x22b.google.com. [2607:f8b0:400d:c01::22b])
        by mx.google.com with ESMTPS id d35si14645638qgf.4.2015.01.30.08.07.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 08:07:25 -0800 (PST)
Received: by mail-qc0-f171.google.com with SMTP id s11so21172952qcv.2
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 08:07:25 -0800 (PST)
Date: Fri, 30 Jan 2015 11:07:22 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] Making memcg track ownership per address_space or anon_vma
Message-ID: <20150130160722.GA26111@htj.dyndns.org>
References: <20150130044324.GA25699@htj.dyndns.org>
 <xr93h9v8yfrv.fsf@gthelen.mtv.corp.google.com>
 <20150130062737.GB25699@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150130062737.GB25699@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, Li Zefan <lizefan@huawei.com>, hughd@google.com, Konstantin Khebnikov <khlebnikov@yandex-team.ru>

Hey, again.

On Fri, Jan 30, 2015 at 01:27:37AM -0500, Tejun Heo wrote:
> The previous behavior was pretty unpredictable in terms of shared file
> ownership too.  I wonder whether the better thing to do here is either
> charging cases like this to the common ancestor or splitting the
> charge equally among the accessors, which might be doable for ro
> files.

I've been thinking more about this.  It's true that doing per-page
association allows for avoiding confronting the worst side effects of
inode sharing head-on, but it is a tradeoff with fairly weak
justfications.  The only thing we're gaining is side-stepping the
blunt of the problem in an awkward manner and the loss of clarity in
taking this compromised position has nasty ramifications when we try
to connect it with the rest of the world.

I could be missing something major but the more I think about it, it
looks to me that the right thing to do here is accounting per-inode
and charging shared inodes to the nearest common ancestor.  The
resulting behavior would be way more logical and predicatable than the
current one, which would make it straight forward to integrate memcg
with blkcg and writeback.

One of the problems that I can think of off the top of my head is that
it'd involve more regular use of charge moving; however, this is an
operation which is per-inode rather than per-page and still gonna be
fairly infrequent.  Another one is that if we move memcg over to this
behavior, it's likely to affect the behavior on the traditional
hierarchies too as we sure as hell don't want to switch between the
two major behaviors dynamically but given that behaviors on inode
sharing aren't very well supported yet, this can be an acceptable
change.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
