Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 788F06B0285
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 11:07:25 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 204so244419377pfx.1
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 08:07:25 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id p8si19659991pgf.304.2017.01.24.08.07.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 08:07:24 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id f144so12413576pfa.2
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 08:07:24 -0800 (PST)
Date: Tue, 24 Jan 2017 11:07:22 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/4] mm, page_alloc: Drain per-cpu pages from workqueue
 context
Message-ID: <20170124160722.GC12281@htj.duckdns.org>
References: <20170117092954.15413-1-mgorman@techsingularity.net>
 <20170117092954.15413-4-mgorman@techsingularity.net>
 <06c39883-eff5-1412-a148-b063aa7bcc5f@suse.cz>
 <20170120152606.w3hb53m2w6thzsqq@techsingularity.net>
 <20170123170329.GA7820@htj.duckdns.org>
 <20170123200412.mkesardc4mckk6df@techsingularity.net>
 <20170123205501.GA25944@htj.duckdns.org>
 <20170123230429.os7ssxab4mazrkrb@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170123230429.os7ssxab4mazrkrb@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Petr Mladek <pmladek@suse.cz>

Hello, Mel.

On Mon, Jan 23, 2017 at 11:04:29PM +0000, Mel Gorman wrote:
> On Mon, Jan 23, 2017 at 03:55:01PM -0500, Tejun Heo wrote:
> > Hello, Mel.
> > 
> > On Mon, Jan 23, 2017 at 08:04:12PM +0000, Mel Gorman wrote:
> > > What is the actual mechanism that does that? It's not something that
> > > schedule_on_each_cpu does and one would expect that the core workqueue
> > > implementation would get this sort of detail correct. Or is this a proposal
> > > on how it should be done?
> > 
> > If you use schedule_on_each_cpu(), it's all fine as the thing pins
> > cpus and waits for all the work items synchronously.  If you wanna do
> > it asynchronously, right now, you'll have to manually synchronize work
> > items against the offline callback manually.
> > 
> 
> Is the current implementation and what it does wrong in some way? I ask
> because synchronising against the offline callback sounds like it would
> be a bit of a maintenance mess for relatively little gain.

As long as you wrap them with get/put_online_cpus(), the current
implementation should be fine.  If it were up to me, I'd rather use
static percpu work_structs and synchronize with a mutex tho.  The cost
of synchronizing via mutex isn't high here compared to the overall
operation, the whole thing is synchronous anyway and you won't have to
worry about falling back.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
