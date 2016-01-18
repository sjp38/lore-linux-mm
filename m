Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id D73DB6B0005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 03:14:28 -0500 (EST)
Received: by mail-oi0-f48.google.com with SMTP id k206so171481978oia.1
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 00:14:28 -0800 (PST)
Received: from mail-ob0-x22c.google.com (mail-ob0-x22c.google.com. [2607:f8b0:4003:c01::22c])
        by mx.google.com with ESMTPS id rs7si25833647obc.23.2016.01.18.00.14.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 00:14:28 -0800 (PST)
Received: by mail-ob0-x22c.google.com with SMTP id ba1so567498859obb.3
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 00:14:27 -0800 (PST)
Date: Mon, 18 Jan 2016 00:14:24 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/1] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
In-Reply-To: <569A852B.6050209@linux.intel.com>
Message-ID: <alpine.LSU.2.11.1601172345340.1538@eggly.anvils>
References: <1447181081-30056-1-git-send-email-aarcange@redhat.com> <1447181081-30056-2-git-send-email-aarcange@redhat.com> <alpine.LSU.2.11.1601141356080.13199@eggly.anvils> <20160116174953.GU31137@redhat.com> <569A852B.6050209@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arjan van de Ven <arjan@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>

On Sat, 16 Jan 2016, Arjan van de Ven wrote:
> On 1/16/2016 9:49 AM, Andrea Arcangeli wrote:
> > In short I don't see the KSM sharing limit ever going to be obsolete
> > unless the whole pagetable format changes and we don't deal with
> > pagetables anymore.
> 
> just to put some weight behind Andrea's arguments: this is not theoretical.
> We're running 3500 - 7000 virtual machines on a single server quite easily
> nowadays
> and there's quite a bit of memory that KSM will share between them (often
> even multiple times)..  so your N in O(N) is 7000 to many multiples there of
> in real environments.

Thanks for filling in more of the picture, Arjan, that helps.

> 
> And the long hang do happen... once you start getting a bit of memory
> pressure
> (say you go from 7000 to 7200 VMs and you only have memory for 7150) then you
> are hitting the long delays *for every page* the VM inspects, and it will

I don't understand "*for every page*": why for *every* page?
I won't dispute "for many pages, many more than is bearable".

> inspect
> many... since initially they all (all 200Gb of them) are active. My machine
> was
> just completely "out" in this for 24 hours before I decided to just reboot it
> instead.
> 
> Now, you can make it 2x faster (reboot in 12 hours? ;-) ) but there's really
> a much
> higher order reduction of the "long chain" problem needed...
> I'm with Andrea that prevention of super long chains is the way to go, we can
> argue about 250
> or 500 or 1000. Numbers will speak there... but from a KSM user perspective,
> at some point
> you reduced the cost of a page by 250x or 500x or 1000x... it's hitting
> diminishing returns.

I'm not for a moment denying that there's a problem to be solved,
just questioning what's the right solution.

The reclaim case you illustrate does not persuade me, I already suggested
an easier way to handle that (don't waste time on pages of high mapcount).

Or are you saying that in your usage, the majority of pages start out with
high mapcount?  That would defeat my suggestion, I think,  But it's the
compaction case I want to think more about, that may persuade me also.

And of course you're right about diminishing returns from trying to
minimize the number of dups: that wasn't my concern, merely that
managing several is more complex than managing one.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
