Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id AA9926B0037
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 15:58:33 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id y10so3646502wgg.30
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 12:58:33 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id qt9si12275088wjc.93.2014.09.22.12.58.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 12:58:32 -0700 (PDT)
Date: Mon, 22 Sep 2014 15:58:29 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: memcontrol: lockless page counters
Message-ID: <20140922195829.GA5197@cmpxchg.org>
References: <1411132928-16143-1-git-send-email-hannes@cmpxchg.org>
 <20140922144436.GG336@dhcp22.suse.cz>
 <20140922155049.GA6630@cmpxchg.org>
 <20140922172800.GA4343@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140922172800.GA4343@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Sep 22, 2014 at 07:28:00PM +0200, Michal Hocko wrote:
> On Mon 22-09-14 11:50:49, Johannes Weiner wrote:
> > On Mon, Sep 22, 2014 at 04:44:36PM +0200, Michal Hocko wrote:
> > > On Fri 19-09-14 09:22:08, Johannes Weiner wrote:
> [...]
> > > Nevertheless I think that the counter should live outside of memcg (it
> > > is ugly and bad in general to make HUGETLB controller depend on MEMCG
> > > just to have a counter). If you made kernel/page_counter.c and led both
> > > containers select CONFIG_PAGE_COUNTER then you do not need a dependency
> > > on MEMCG and I would find it cleaner in general.
> > 
> > The reason I did it this way is because the hugetlb controller simply
> > accounts and limits a certain type of memory and in the future I would
> > like to make it a memcg extension, just like kmem and swap.
> 
> I am not sure this is the right way to go. Hugetlb has always been
> "special" and I do not see any advantage to pull its specialness into
> memcg proper.
>
> It would just make the code more complicated. I can also imagine
> users who simply do not want to pay memcg overhead and use only
> hugetlb controller.

We already group user memory, kernel memory, and swap space together,
what makes hugetlb-backed memory special?

It's much easier to organize the code if all those closely related
things are grouped together.  It's also better for the user interface
to have a single memory controller.

We're also close to the point where we don't differentiate between the
root group and dedicated groups in terms of performance, Dave's tests
fell apart at fairly high concurrency, and I'm already getting rid of
the lock he saw contended.

The downsides of fragmenting our configuration- and testspace, our
user interface, and our code base by far outweigh the benefits of
offering a dedicated hugetlb controller.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
