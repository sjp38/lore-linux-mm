Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 743A76B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 02:32:35 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id k11so1557533wes.11
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 23:32:34 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t4si30789495wiw.0.2015.02.10.23.32.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Feb 2015 23:32:33 -0800 (PST)
Date: Wed, 11 Feb 2015 08:32:27 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC] Making memcg track ownership per address_space or anon_vma
Message-ID: <20150211073227.GB30939@quack.suse.cz>
References: <20150204170656.GA18858@htj.dyndns.org>
 <xr93zj8ti6ca.fsf@gthelen.mtv.corp.google.com>
 <20150205131514.GD25736@htj.dyndns.org>
 <xr93siekt3p3.fsf@gthelen.mtv.corp.google.com>
 <20150205222522.GA10580@htj.dyndns.org>
 <xr93pp9nucrt.fsf@gthelen.mtv.corp.google.com>
 <20150206141746.GB10580@htj.dyndns.org>
 <CAHH2K0bxvc34u1PugVQsSfxXhmN8qU6KRpiCWwOVBa6BPqMDOg@mail.gmail.com>
 <20150207143839.GA9926@htj.dyndns.org>
 <20150211021906.GA21356@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150211021906.GA21356@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Greg Thelen <gthelen@google.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, Li Zefan <lizefan@huawei.com>, Hugh Dickins <hughd@google.com>

  Hello Tejun,

On Tue 10-02-15 21:19:06, Tejun Heo wrote:
> On Sat, Feb 07, 2015 at 09:38:39AM -0500, Tejun Heo wrote:
> > If we can argue that memcg and blkcg having different views is
> > meaningful and characterize and justify the behaviors stemming from
> > the deviation, sure, that'd be fine, but I don't think we have that as
> > of now.
...
> So, based on the assumption that write sharings are mostly incidental
> and temporary (ie. we're basically declaring that we don't support
> persistent write sharing), how about something like the following?
> 
> 1. memcg contiues per-page tracking.
> 
> 2. Each inode is associated with a single blkcg at a given time and
>    written out by that blkcg.
> 
> 3. While writing back, if the number of pages from foreign memcg's is
>    higher than certain ratio of total written pages, the inode is
>    marked as disowned and the writeback instance is optionally
>    terminated early.  e.g. if the ratio of foreign pages is over 50%
>    after writing out the number of pages matching 5s worth of write
>    bandwidth for the bdi, mark the inode as disowned.
> 
> 4. On the following dirtying of the inode, the inode is associated
>    with the matching blkcg of the dirtied page.  Note that this could
>    be the next cycle as the inode could already have been marked dirty
>    by the time the above condition triggered.  In that case, the
>    following writeback would be terminated early too.
> 
> This should provide sufficient corrective pressure so that incidental
> and temporary sharing of an inode doesn't become a persistent issue
> while keeping the complexity necessary for implementing such pressure
> fairly minimal and self-contained.  Also, the changes necessary for
> individual filesystems would be minimal.
  I like this proposal. It looks simple enough and when inodes aren't
pernamently write-shared it converges to the blkcg that is currently
writing to the inode. So ack from me.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
