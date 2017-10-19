Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4A9B86B0038
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 15:35:45 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g10so3367375wrg.6
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 12:35:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w63si1614949wmb.195.2017.10.19.12.35.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 12:35:44 -0700 (PDT)
Date: Thu, 19 Oct 2017 21:35:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: mlock: remove lru_add_drain_all()
Message-ID: <20171019193542.l5baqknxnfhljjkr@dhcp22.suse.cz>
References: <20171018231730.42754-1-shakeelb@google.com>
 <20171019123206.3etacullgnarbnad@dhcp22.suse.cz>
 <CALvZod40MmJ6F9ecKHsCkxyxnf_QR4pNqh55GENqqKKYpendMw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod40MmJ6F9ecKHsCkxyxnf_QR4pNqh55GENqqKKYpendMw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>, Ingo Molnar <mingo@kernel.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 19-10-17 12:19:26, Shakeel Butt wrote:
> On Thu, Oct 19, 2017 at 5:32 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Wed 18-10-17 16:17:30, Shakeel Butt wrote:
> >> Recently we have observed high latency in mlock() in our generic
> >> library and noticed that users have started using tmpfs files even
> >> without swap and the latency was due to expensive remote LRU cache
> >> draining.
> >
> > some numbers would be really nice
> >
> 
> On a production workload, customers complained that single mlock()
> call took around 10 seconds on mapped tmpfs files and the perf profile
> showed lru_add_drain_all as culprit.

draining can take some time. I wouldn't expect orders of seconds so perf
data would be definitely helpful in the changelog.

[...]
> > Is this really true? lru_add_drain_all will flush the previously cached
> > LRU pages. We are not flushing after the pages have been faulted in so
> > this might not do anything wrt. mlocked pages, right?
> >
> 
> Sorry for the confusion. I wanted to say that if the pages which are
> being mlocked are on caches of remote cpus then lru_add_drain_all will
> move them to their corresponding LRUs and then remaining functionality
> of mlock will move them again from their evictable LRUs to unevictable
> LRU.

yes, but the point is that we are draining pages which might be not
directly related to pages which _will_ be mlocked by the syscall. In
fact those will stay on the cache. This is the primary reason why this
draining doesn't make much sense.
 
Or am I still misunderstanding what you are saying here?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
