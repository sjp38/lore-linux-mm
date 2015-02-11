Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 749BD6B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 17:30:35 -0500 (EST)
Received: by mail-qa0-f47.google.com with SMTP id v10so5052688qac.6
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 14:30:35 -0800 (PST)
Received: from mail-qa0-x233.google.com (mail-qa0-x233.google.com. [2607:f8b0:400d:c00::233])
        by mx.google.com with ESMTPS id b9si2645465qce.45.2015.02.11.14.30.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 14:30:34 -0800 (PST)
Received: by mail-qa0-f51.google.com with SMTP id i13so5006396qae.10
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 14:30:34 -0800 (PST)
Date: Wed, 11 Feb 2015 17:30:30 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] Making memcg track ownership per address_space or anon_vma
Message-ID: <20150211223030.GB12728@htj.duckdns.org>
References: <CAHH2K0bxvc34u1PugVQsSfxXhmN8qU6KRpiCWwOVBa6BPqMDOg@mail.gmail.com>
 <20150207143839.GA9926@htj.dyndns.org>
 <20150211021906.GA21356@htj.duckdns.org>
 <CAHH2K0aHM=jmzbgkSCdFX0NxWbHBcVXqi3EAr0MS-gE3Txk93w@mail.gmail.com>
 <20150211203359.GF21356@htj.duckdns.org>
 <CALYGNiMm2VajBx0Y+XtLJ8860JS-GHfuSXQrBt32Wt0K7QpH0A@mail.gmail.com>
 <20150211214650.GA11920@htj.duckdns.org>
 <CALYGNiPX89HsgUS8BrJvL_jW-EU95xezc7uPf=0Pm72qiUwp7A@mail.gmail.com>
 <20150211220530.GA12728@htj.duckdns.org>
 <CALYGNiMgpU51vNr186x6h-uh_9NqaTqZ_a2L60XG0STozy=30g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiMgpU51vNr186x6h-uh_9NqaTqZ_a2L60XG0STozy=30g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Greg Thelen <gthelen@google.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, Li Zefan <lizefan@huawei.com>, Hugh Dickins <hughd@google.com>

Hello,

On Thu, Feb 12, 2015 at 02:15:29AM +0400, Konstantin Khlebnikov wrote:
> Well, ok. Even if shared writes are rare whey should be handled somehow
> without relying on kupdate-like writeback. If memcg has a lot of dirty pages

This only works iff we consider those cases to be marginal enough to
be handle them in a pretty ghetto way.

> but their inodes are accidentially belong to wrong wb queues when tasks in
> that memcg shouldn't stuck in balance-dirty-pages until somebody outside
> acidentially writes this data. That's all what I wanted to say.

But, right, yeah, corner cases around this could be nasty if writeout
interval is set really high.  I don't think it matters for the default
5s interval at all.  Maybe what we need is queueing a delayed per-wb
work w/ the default writeout interval when dirtying a foreign inode.
I'll think more about it.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
