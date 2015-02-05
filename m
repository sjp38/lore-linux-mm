Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 46CD8828FD
	for <linux-mm@kvack.org>; Thu,  5 Feb 2015 17:25:27 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id w8so8103353qac.13
        for <linux-mm@kvack.org>; Thu, 05 Feb 2015 14:25:27 -0800 (PST)
Received: from mail-qc0-x230.google.com (mail-qc0-x230.google.com. [2607:f8b0:400d:c01::230])
        by mx.google.com with ESMTPS id h39si531960qgd.108.2015.02.05.14.25.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Feb 2015 14:25:26 -0800 (PST)
Received: by mail-qc0-f176.google.com with SMTP id c9so8943049qcz.7
        for <linux-mm@kvack.org>; Thu, 05 Feb 2015 14:25:25 -0800 (PST)
Date: Thu, 5 Feb 2015 17:25:22 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] Making memcg track ownership per address_space or anon_vma
Message-ID: <20150205222522.GA10580@htj.dyndns.org>
References: <xr93h9v8yfrv.fsf@gthelen.mtv.corp.google.com>
 <20150130062737.GB25699@htj.dyndns.org>
 <20150130160722.GA26111@htj.dyndns.org>
 <54CFCF74.6090400@yandex-team.ru>
 <20150202194608.GA8169@htj.dyndns.org>
 <CAHH2K0aSPjNgt30uJQa_6r=AXZso3SitjWOm96dtJF32CumZjQ@mail.gmail.com>
 <20150204170656.GA18858@htj.dyndns.org>
 <xr93zj8ti6ca.fsf@gthelen.mtv.corp.google.com>
 <20150205131514.GD25736@htj.dyndns.org>
 <xr93siekt3p3.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr93siekt3p3.fsf@gthelen.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, Li Zefan <lizefan@huawei.com>, Hugh Dickins <hughd@google.com>

Hey,

On Thu, Feb 05, 2015 at 02:05:19PM -0800, Greg Thelen wrote:
> >  	A
> >  	+-B    (usage=2M lim=3M min=2M hosted_usage=2M)
> >  	  +-C  (usage=0  lim=2M min=1M shared_usage=2M)
> >  	  +-D  (usage=0  lim=2M min=1M shared_usage=2M)
> >  	  \-E  (usage=0  lim=2M min=0)
...
> Maybe, but I want to understand more about how pressure works in the
> child.  As C (or D) allocates non shared memory does it perform reclaim
> to ensure that its (C.usage + C.shared_usage < C.lim).  Given C's

Yes.

> shared_usage is linked into B.LRU it wouldn't be naturally reclaimable
> by C.  Are you thinking that charge failures on cgroups with non zero
> shared_usage would, as needed, induce reclaim of parent's hosted_usage?

Hmmm.... I'm not really sure but why not?  If we properly account for
the low protection when pushing inodes to the parent, I don't think
it'd break anything.  IOW, allow the amount beyond the sum of low
limits to be reclaimed when one of the sharers is under pressure.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
